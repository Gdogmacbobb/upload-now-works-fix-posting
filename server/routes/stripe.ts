import express, { Request, Response } from 'express';
import Stripe from 'stripe';
import { db } from '../db';
import { donations, notifications, userProfiles } from '../shared/schema';
import { eq } from 'drizzle-orm';

const router = express.Router();

// Initialize Stripe
const getStripe = () => {
  const stripeKey = process.env.STRIPE_SECRET_KEY;
  if (!stripeKey) {
    throw new Error('STRIPE_SECRET_KEY environment variable is not set');
  }
  return new Stripe(stripeKey, { apiVersion: '2025-08-27.basil' });
};

// Create Payment Intent
router.post('/create-payment-intent', async (req: Request, res: Response) => {
  try {
    const stripe = getStripe();
    const { amount, currency, donation_id, use_checkout, success_url, cancel_url } = req.body;

    // Validate input
    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Invalid amount' });
    }

    if (!donation_id) {
      return res.status(400).json({ error: 'Donation ID required' });
    }

    // If checkout session is requested (PCI-DSS compliant approach)
    if (use_checkout) {
      if (!success_url || !cancel_url) {
        return res.status(400).json({ error: 'Success and cancel URLs required for checkout session' });
      }

      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: currency || 'usd',
            product_data: {
              name: 'YNFNY Performer Support',
              description: 'Support a street performer in New York',
            },
            unit_amount: Math.round(amount * 100), // Convert dollars to cents
          },
          quantity: 1,
        }],
        mode: 'payment',
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: {
          donation_id: donation_id,
          platform: 'YNFNY'
        },
      });

      return res.json({
        checkout_url: session.url,
        session_id: session.id,
        amount: Math.round(amount * 100),
        currency: currency || 'usd',
      });
    } else {
      // Create a Stripe payment intent (for direct integration)
      const paymentIntent = await stripe.paymentIntents.create({
        amount: Math.round(amount * 100), // Convert dollars to cents
        currency: currency || 'usd',
        automatic_payment_methods: {
          enabled: true,
        },
        metadata: {
          donation_id: donation_id,
          platform: 'YNFNY'
        },
      });

      return res.json({
        payment_intent_id: paymentIntent.id,
        client_secret: paymentIntent.client_secret,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
      });
    }
  } catch (error: any) {
    console.error('Create payment intent error:', error);
    return res.status(400).json({ error: error.message });
  }
});

// Stripe Webhook Handler
router.post('/webhook', async (req: Request, res: Response) => {
  try {
    const stripe = getStripe();
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    
    if (!webhookSecret) {
      console.error('STRIPE_WEBHOOK_SECRET not configured');
      return res.status(500).json({ error: 'Webhook secret not configured' });
    }

    const signature = req.headers['stripe-signature'];
    if (!signature) {
      console.error('No Stripe signature found');
      return res.status(400).json({ error: 'No signature' });
    }

    let event: Stripe.Event;
    
    try {
      // Verify webhook signature
      event = stripe.webhooks.constructEvent(req.body, signature, webhookSecret);
      console.log(`✅ WEBHOOK: Verified event type: ${event.type}`);
    } catch (err: any) {
      console.error(`❌ WEBHOOK: Signature verification failed: ${err}`);
      return res.status(400).json({ error: 'Invalid signature' });
    }

    // Handle the event
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;
      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object as Stripe.PaymentIntent);
        break;
      default:
        console.log(`🔄 WEBHOOK: Unhandled event type: ${event.type}`);
    }

    return res.json({ received: true });
  } catch (error: any) {
    console.error(`❌ WEBHOOK: Error processing webhook: ${error}`);
    return res.status(500).json({ error: 'Webhook processing failed' });
  }
});

// Helper function to handle successful payment
async function handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  try {
    console.log(`💰 WEBHOOK: Payment succeeded: ${paymentIntent.id}`);
    
    const donationId = paymentIntent.metadata.donation_id;
    if (!donationId) {
      console.error('No donation_id in payment intent metadata');
      return;
    }

    console.log(`🔄 WEBHOOK: Processing donation completion: ${donationId}`);

    // Get donation with idempotency check
    const [donation] = await db
      .select()
      .from(donations)
      .where(eq(donations.id, donationId))
      .limit(1);

    if (!donation) {
      console.error(`❌ WEBHOOK: Donation not found: ${donationId}`);
      return;
    }

    if (donation.transactionStatus === 'completed') {
      console.log(`✅ WEBHOOK: Donation ${donationId} already completed - idempotent`);
      return;
    }

    // Validate payment amount matches donation amount
    const expectedAmountCents = Math.round(parseFloat(donation.amount) * 100);
    if (paymentIntent.amount !== expectedAmountCents) {
      console.error(`❌ WEBHOOK: SECURITY VIOLATION - Payment amount mismatch!`);
      
      await db
        .update(donations)
        .set({
          transactionStatus: 'failed',
        })
        .where(eq(donations.id, donationId));
      
      return;
    }
    
    console.log(`✅ WEBHOOK: Amount validation passed`);

    // Update donation status to completed
    await db
      .update(donations)
      .set({
        transactionStatus: 'completed',
        completedAt: new Date(),
      })
      .where(eq(donations.id, donationId));

    // Update performer's total donations - simplified approach
    const amount = parseFloat(donation.amount);
    const netAmount = parseFloat(donation.performerAmount);

    // Get current total donations
    const [performer] = await db
      .select()
      .from(userProfiles)
      .where(eq(userProfiles.id, donation.performerId))
      .limit(1);

    if (performer) {
      const currentTotal = parseFloat(performer.totalDonationsReceived || '0');
      const newTotal = (currentTotal + netAmount).toFixed(2);

      await db
        .update(userProfiles)
        .set({
          totalDonationsReceived: newTotal,
        })
        .where(eq(userProfiles.id, donation.performerId));
    }

    // Create notification for performer
    await db.insert(notifications).values({
      userId: donation.performerId,
      type: 'donation',
      title: 'Donation Received!',
      message: `You received a $${amount.toFixed(2)} donation!`,
      data: {
        donation_id: donationId,
        amount: amount,
        net_amount: netAmount,
      },
    });

    console.log(`🎉 WEBHOOK: Successfully processed donation ${donationId}`);
  } catch (error) {
    console.error(`❌ WEBHOOK: Error in handlePaymentIntentSucceeded:`, error);
  }
}

// Helper function to handle failed payment
async function handlePaymentIntentFailed(paymentIntent: Stripe.PaymentIntent) {
  try {
    console.log(`❌ WEBHOOK: Payment failed: ${paymentIntent.id}`);
    
    const donationId = paymentIntent.metadata.donation_id;
    if (!donationId) {
      console.error('No donation_id in payment intent metadata');
      return;
    }

    // Update donation status to failed
    await db
      .update(donations)
      .set({
        transactionStatus: 'failed',
      })
      .where(eq(donations.id, donationId));

    console.log(`🔄 WEBHOOK: Marked donation ${donationId} as failed`);
  } catch (error) {
    console.error(`❌ WEBHOOK: Error in handlePaymentIntentFailed:`, error);
  }
}

// Create Donation
router.post('/create-donation', async (req: Request, res: Response) => {
  try {
    const { performer_id, amount, video_id, message, donor_id } = req.body;

    if (!donor_id || !performer_id || !amount || amount <= 0) {
      return res.status(400).json({ error: 'Invalid donation data' });
    }

    const platformFee = (amount * 0.05).toFixed(2);
    const performerAmount = (amount * 0.95).toFixed(2);

    const [donation] = await db
      .insert(donations)
      .values({
        donorId: donor_id,
        performerId: performer_id,
        videoId: video_id || null,
        amount: amount.toString(),
        currency: 'USD',
        platformFee: platformFee,
        performerAmount: performerAmount,
        message: message || null,
        transactionStatus: 'pending',
      })
      .returning();

    res.json({ donation });
  } catch (error: any) {
    console.error('[DONATION] Error creating donation:', error);
    res.status(500).json({ error: 'Failed to create donation' });
  }
});

// Get performer donations
router.get('/donations/performer/:performerId', async (req: Request, res: Response) => {
  try {
    const { performerId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const performerDonations = await db
      .select({
        id: donations.id,
        amount: donations.amount,
        currency: donations.currency,
        message: donations.message,
        transactionStatus: donations.transactionStatus,
        createdAt: donations.createdAt,
        completedAt: donations.completedAt,
        donorId: donations.donorId,
        performerId: donations.performerId,
        donorUsername: userProfiles.username,
        donorFullName: userProfiles.fullName,
        donorAvatar: userProfiles.profileImageUrl,
      })
      .from(donations)
      .leftJoin(userProfiles, eq(donations.donorId, userProfiles.id))
      .where(eq(donations.performerId, performerId))
      .orderBy(donations.createdAt)
      .limit(limit)
      .offset(offset);

    res.json({ donations: performerDonations });
  } catch (error: any) {
    console.error('[DONATION] Error fetching performer donations:', error);
    res.status(500).json({ error: 'Failed to fetch donations' });
  }
});

// Get user donations
router.get('/donations/user/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit as string) || 20;
    const offset = parseInt(req.query.offset as string) || 0;

    const userDonations = await db
      .select({
        id: donations.id,
        amount: donations.amount,
        currency: donations.currency,
        message: donations.message,
        transactionStatus: donations.transactionStatus,
        createdAt: donations.createdAt,
        completedAt: donations.completedAt,
        donorId: donations.donorId,
        performerId: donations.performerId,
        performerUsername: userProfiles.username,
        performerFullName: userProfiles.fullName,
        performerAvatar: userProfiles.profileImageUrl,
      })
      .from(donations)
      .leftJoin(userProfiles, eq(donations.performerId, userProfiles.id))
      .where(eq(donations.donorId, userId))
      .orderBy(donations.createdAt)
      .limit(limit)
      .offset(offset);

    res.json({ donations: userDonations });
  } catch (error: any) {
    console.error('[DONATION] Error fetching user donations:', error);
    res.status(500).json({ error: 'Failed to fetch donations' });
  }
});

export default router;
