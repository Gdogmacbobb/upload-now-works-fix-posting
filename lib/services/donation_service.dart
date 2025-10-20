import 'package:flutter/foundation.dart';
import './api_service.dart';

class DonationService {
  final ApiService _apiService = ApiService();

  // Create donation record and initiate Stripe payment
  Future<Map<String, dynamic>?> createDonation({
    required String performerId,
    required double amount,
    String? videoId,
    String? message,
  }) async {
    try {
      final currentUser = _apiService.currentUser;
      final userId = currentUser?['id'];
      
      if (userId == null) throw Exception('User not authenticated');
      if (amount <= 0) throw Exception('Donation amount must be greater than 0');

      // Create donation record
      final donationResponse = await _apiService.post('/stripe/create-donation', {
        'donor_id': userId,
        'performer_id': performerId,
        if (videoId != null) 'video_id': videoId,
        'amount': amount,
        'message': message,
      });

      if (donationResponse == null || donationResponse['donation'] == null) {
        throw Exception('Failed to create donation');
      }

      final donation = donationResponse['donation'] as Map<String, dynamic>;

      // Create Stripe payment intent
      final paymentResponse = await _apiService.post('/stripe/create-payment-intent', {
        'amount': amount,
        'currency': 'usd',
        'donation_id': donation['id'],
      });

      if (paymentResponse == null) {
        throw Exception('Failed to create payment intent');
      }

      return {
        ...donation,
        'client_secret': paymentResponse['client_secret'],
        'payment_intent_id': paymentResponse['payment_intent_id'],
      };
    } catch (error) {
      debugPrint('Create donation error: $error');
      rethrow;
    }
  }

  // Confirm donation payment
  Future<void> confirmDonationPayment(String donationId) async {
    try {
      // Payment confirmation is handled by Stripe webhook
      // This method is here for compatibility but actual confirmation
      // happens automatically via webhook
      debugPrint('Donation payment confirmation initiated for: $donationId');
    } catch (error) {
      debugPrint('Confirm donation payment error: $error');
      rethrow;
    }
  }

  // Get performer's donations
  Future<List<Map<String, dynamic>>> getPerformerDonations(
    String performerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/stripe/donations/performer/$performerId?limit=$limit&offset=$offset',
      );

      if (response == null || response['donations'] == null) {
        return [];
      }

      final donations = response['donations'] as List;
      return List<Map<String, dynamic>>.from(donations.map((d) => {
        ...d,
        'donor': {
          'username': d['donorUsername'],
          'full_name': d['donorFullName'],
          'profile_image_url': d['donorAvatar'],
        },
      }));
    } catch (error) {
      debugPrint('Get performer donations error: $error');
      return [];
    }
  }

  // Get user's donation history
  Future<List<Map<String, dynamic>>> getUserDonations(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/stripe/donations/user/$userId?limit=$limit&offset=$offset',
      );

      if (response == null || response['donations'] == null) {
        return [];
      }

      final donations = response['donations'] as List;
      return List<Map<String, dynamic>>.from(donations.map((d) => {
        ...d,
        'performer': {
          'username': d['performerUsername'],
          'full_name': d['performerFullName'],
          'profile_image_url': d['performerAvatar'],
        },
      }));
    } catch (error) {
      debugPrint('Get user donations error: $error');
      return [];
    }
  }

  // Get donation statistics for performer
  Future<Map<String, dynamic>> getPerformerDonationStats(String performerId) async {
    try {
      final donations = await getPerformerDonations(performerId, limit: 1000);
      
      double totalReceived = 0;
      double totalEarned = 0;
      int donationCount = 0;
      final uniqueDonors = <String>{};

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      for (final donation in donations) {
        if (donation['transactionStatus'] == 'completed') {
          final amount = double.tryParse(donation['amount'].toString()) ?? 0;
          final performerAmount = amount * 0.95; // 5% platform fee
          
          totalReceived += amount;
          totalEarned += performerAmount;
          donationCount++;

          // Count recent unique donors
          final completedAt = DateTime.tryParse(donation['completedAt'] ?? '');
          if (completedAt != null && completedAt.isAfter(thirtyDaysAgo)) {
            uniqueDonors.add(donation['donorId'] as String);
          }
        }
      }

      return {
        'total_received': totalReceived,
        'total_earned': totalEarned,
        'total_donations': donationCount,
        'recent_donors_count': uniqueDonors.length,
        'platform_fee_rate': 0.05,
      };
    } catch (error) {
      debugPrint('Get performer donation stats error: $error');
      return {
        'total_received': 0.0,
        'total_earned': 0.0,
        'total_donations': 0,
        'recent_donors_count': 0,
        'platform_fee_rate': 0.05,
      };
    }
  }
}
