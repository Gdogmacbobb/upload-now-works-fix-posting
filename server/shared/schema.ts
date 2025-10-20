import { pgTable, uuid, text, timestamp, boolean, decimal, integer, jsonb, pgEnum, index, uniqueIndex, check } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// Enums
export const userRoleEnum = pgEnum('user_role', ['street_performer', 'new_yorker', 'admin']);
export const performanceTypeEnum = pgEnum('performance_type', ['singer', 'dancer', 'magician', 'musician', 'artist', 'other']);
export const verificationStatusEnum = pgEnum('verification_status', ['pending', 'approved', 'rejected', 'under_review']);
export const transactionStatusEnum = pgEnum('transaction_status', ['pending', 'completed', 'failed', 'refunded']);
export const reportTypeEnum = pgEnum('report_type', ['spam', 'harassment', 'inappropriate_content', 'copyright', 'fake_account', 'violence', 'hate_speech', 'nudity', 'other']);
export const moderationActionTypeEnum = pgEnum('moderation_action_type', ['warning', 'content_removal', 'account_suspension', 'account_ban', 'content_approval', 'report_dismissed', 'content_demonetization']);
export const reportStatusEnum = pgEnum('report_status', ['pending', 'under_review', 'resolved', 'dismissed']);

// User Profiles Table
export const userProfiles = pgTable('user_profiles', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  username: text('username').notNull().unique(),
  fullName: text('full_name').notNull(),
  role: userRoleEnum('role').default('new_yorker'),
  profileImageUrl: text('profile_image_url'),
  bio: text('bio'),
  
  // Street Performer specific fields
  performanceType: performanceTypeEnum('performance_type'),
  performanceTypes: jsonb('performance_types').default('[]'),
  frequentPerformanceSpots: text('frequent_performance_spots'),
  socialMediaLinks: jsonb('social_media_links').default('{}'),
  verificationStatus: verificationStatusEnum('verification_status').default('pending'),
  verificationPhotoUrl: text('verification_photo_url'),
  totalDonationsReceived: decimal('total_donations_received', { precision: 10, scale: 2 }).default('0.00'),
  totalDonationsGiven: decimal('total_donations_given', { precision: 10, scale: 2 }).default('0.00'),
  
  // Social metrics
  followerCount: integer('follower_count').default(0),
  followingCount: integer('following_count').default(0),
  videoCount: integer('video_count').default(0),
  
  // Account status
  isActive: boolean('is_active').default(true),
  isVerified: boolean('is_verified').default(false),
  isSuspended: boolean('is_suspended').default(false),
  suspensionReason: text('suspension_reason'),
  suspendedUntil: timestamp('suspended_until', { withTimezone: true }),
  
  // Timestamps
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  usernameIdx: index('idx_user_profiles_username').on(table.username),
  roleIdx: index('idx_user_profiles_role').on(table.role),
  verificationStatusIdx: index('idx_user_profiles_verification_status').on(table.verificationStatus),
  suspendedIdx: index('idx_user_profiles_suspended').on(table.isSuspended, table.suspendedUntil),
  authRoleIdx: index('idx_user_profiles_auth_role').on(table.id, table.role),
  performanceTypesIdx: index('idx_user_profiles_performance_types').on(table.performanceTypes),
}));

// Videos Table
export const videos = pgTable('videos', {
  id: uuid('id').primaryKey().defaultRandom(),
  performerId: uuid('performer_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  description: text('description'),
  videoUrl: text('video_url').notNull(),
  thumbnailUrl: text('thumbnail_url'),
  thumbnailFrameTime: integer('thumbnail_frame_time').default(0),
  duration: integer('duration').notNull(),
  
  // Location data
  locationLatitude: decimal('location_latitude', { precision: 10, scale: 7 }).notNull(),
  locationLongitude: decimal('location_longitude', { precision: 10, scale: 7 }).notNull(),
  locationName: text('location_name'),
  borough: text('borough').notNull(),
  
  // Engagement metrics
  viewCount: integer('view_count').default(0),
  likeCount: integer('like_count').default(0),
  commentCount: integer('comment_count').default(0),
  shareCount: integer('share_count').default(0),
  repostCount: integer('repost_count').default(0),
  
  // Content moderation
  isApproved: boolean('is_approved').default(false),
  isFlagged: boolean('is_flagged').default(false),
  moderationNotes: text('moderation_notes'),
  
  // Hashtags
  hashtags: text('hashtags').array().default([]),
  
  // Timestamps
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  performerIdx: index('idx_videos_performer_id').on(table.performerId),
  createdIdx: index('idx_videos_created_at').on(table.createdAt),
  boroughIdx: index('idx_videos_borough').on(table.borough),
  approvedIdx: index('idx_videos_approved').on(table.isApproved),
  createdApprovedIdx: index('idx_videos_created_approved').on(table.createdAt),
  performerApprovedIdx: index('idx_videos_performer_approved').on(table.performerId, table.createdAt),
  boroughApprovedIdx: index('idx_videos_borough_approved').on(table.borough, table.createdAt),
  hashtagsIdx: index('idx_videos_hashtags_gin').on(table.hashtags),
  thumbnailFrameTimeIdx: index('idx_videos_thumbnail_frame_time').on(table.thumbnailFrameTime),
  repostCountIdx: index('idx_videos_repost_count').on(table.repostCount),
}));

// Video Interactions Table
export const videoInteractions = pgTable('video_interactions', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  videoId: uuid('video_id').notNull().references(() => videos.id, { onDelete: 'cascade' }),
  interactionType: text('interaction_type').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  userVideoIdx: index('idx_video_interactions_user_video').on(table.userId, table.videoId),
  videoTypeIdx: index('idx_video_interactions_video_type').on(table.videoId, table.interactionType),
  userTypeVideoIdx: index('idx_video_interactions_user_type_video').on(table.userId, table.interactionType, table.videoId),
  uniqueInteraction: uniqueIndex('video_interactions_user_video_type_unique').on(table.userId, table.videoId, table.interactionType),
}));

// Comments Table - declared first without parent reference
export const comments: any = pgTable('comments', {
  id: uuid('id').primaryKey().defaultRandom(),
  videoId: uuid('video_id').notNull().references(() => videos.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  parentCommentId: uuid('parent_comment_id'),
  content: text('content').notNull(),
  isFlagged: boolean('is_flagged').default(false),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  videoIdx: index('idx_comments_video_id').on(table.videoId),
  userIdx: index('idx_comments_user_id').on(table.userId),
  parentIdx: index('idx_comments_parent_id').on(table.parentCommentId),
  videoParentIdx: index('idx_comments_video_parent').on(table.videoId, table.parentCommentId),
}));

// Follows Table
export const follows = pgTable('follows', {
  id: uuid('id').primaryKey().defaultRandom(),
  followerId: uuid('follower_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  followingId: uuid('following_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  followerIdx: index('idx_follows_follower_id').on(table.followerId),
  followingIdx: index('idx_follows_following_id').on(table.followingId),
  followingCreatedIdx: index('idx_follows_following_created').on(table.followingId, table.createdAt),
  uniqueFollow: uniqueIndex('follows_follower_following_unique').on(table.followerId, table.followingId),
}));

// Donations Table
export const donations = pgTable('donations', {
  id: uuid('id').primaryKey().defaultRandom(),
  donorId: uuid('donor_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  performerId: uuid('performer_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  videoId: uuid('video_id').references(() => videos.id, { onDelete: 'set null' }),
  
  // Payment details
  amount: decimal('amount', { precision: 10, scale: 2 }).notNull(),
  currency: text('currency').default('USD'),
  stripePaymentIntentId: text('stripe_payment_intent_id').unique(),
  transactionStatus: transactionStatusEnum('transaction_status').default('pending'),
  
  // Platform fee (5%)
  platformFee: decimal('platform_fee', { precision: 10, scale: 2 }).notNull(),
  performerAmount: decimal('performer_amount', { precision: 10, scale: 2 }).notNull(),
  
  // Optional message from donor
  message: text('message'),
  
  // Timestamps
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  completedAt: timestamp('completed_at', { withTimezone: true }),
}, (table) => ({
  performerIdx: index('idx_donations_performer_id').on(table.performerId),
  donorIdx: index('idx_donations_donor_id').on(table.donorId),
  statusIdx: index('idx_donations_status').on(table.transactionStatus),
}));

// Reposts Table
export const reposts = pgTable('reposts', {
  id: uuid('id').primaryKey().defaultRandom(),
  reposterId: uuid('reposter_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  videoId: uuid('video_id').notNull().references(() => videos.id, { onDelete: 'cascade' }),
  repostText: text('repost_text'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  reposterIdx: index('idx_reposts_reposter_id').on(table.reposterId, table.createdAt),
  videoIdx: index('idx_reposts_video_id').on(table.videoId),
  createdIdx: index('idx_reposts_created_at').on(table.createdAt),
  uniqueRepost: uniqueIndex('reposts_reposter_video_unique').on(table.reposterId, table.videoId),
}));

// Hashtags Table
export const hashtags = pgTable('hashtags', {
  id: uuid('id').primaryKey().defaultRandom(),
  tag: text('tag').notNull().unique(),
  tagNormalized: text('tag_normalized').notNull().unique(),
  videoCount: integer('video_count').default(0),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  tagNormalizedIdx: index('idx_hashtags_tag_normalized').on(table.tagNormalized),
  videoCountIdx: index('idx_hashtags_video_count').on(table.videoCount),
}));

// Video Hashtags Junction Table
export const videoHashtags = pgTable('video_hashtags', {
  videoId: uuid('video_id').notNull().references(() => videos.id, { onDelete: 'cascade' }),
  hashtagId: uuid('hashtag_id').notNull().references(() => hashtags.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  pk: uniqueIndex('video_hashtags_pkey').on(table.videoId, table.hashtagId),
  hashtagIdx: index('idx_video_hashtags_hashtag_id').on(table.hashtagId),
}));

// Notifications Table
export const notifications = pgTable('notifications', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  type: text('type').notNull(),
  title: text('title').notNull(),
  message: text('message').notNull(),
  data: jsonb('data').default('{}'),
  isRead: boolean('is_read').default(false),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  userIdx: index('idx_notifications_user_id').on(table.userId),
  unreadIdx: index('idx_notifications_unread').on(table.userId, table.isRead),
}));

// Reports Table
export const reports = pgTable('reports', {
  id: uuid('id').primaryKey().defaultRandom(),
  reporterId: uuid('reporter_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  
  // What is being reported (polymorphic)
  reportedUserId: uuid('reported_user_id').references(() => userProfiles.id, { onDelete: 'cascade' }),
  reportedVideoId: uuid('reported_video_id').references(() => videos.id, { onDelete: 'cascade' }),
  reportedCommentId: uuid('reported_comment_id').references(() => comments.id, { onDelete: 'cascade' }),
  
  // Report details
  reportType: reportTypeEnum('report_type').notNull(),
  description: text('description').notNull(),
  status: reportStatusEnum('status').default('pending'),
  
  // Moderation tracking
  assignedModeratorId: uuid('assigned_moderator_id').references(() => userProfiles.id, { onDelete: 'set null' }),
  moderatorNotes: text('moderator_notes'),
  resolutionReason: text('resolution_reason'),
  
  // Timestamps
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
  resolvedAt: timestamp('resolved_at', { withTimezone: true }),
}, (table) => ({
  reporterIdx: index('idx_reports_reporter_id').on(table.reporterId),
  statusIdx: index('idx_reports_status').on(table.status),
  typeIdx: index('idx_reports_type').on(table.reportType),
  reportedUserIdx: index('idx_reports_reported_user').on(table.reportedUserId),
  reportedVideoIdx: index('idx_reports_reported_video').on(table.reportedVideoId),
  reportedCommentIdx: index('idx_reports_reported_comment').on(table.reportedCommentId),
  moderatorIdx: index('idx_reports_moderator').on(table.assignedModeratorId),
  createdPendingIdx: index('idx_reports_created_pending').on(table.createdAt),
}));

// User Blocks Table
export const userBlocks = pgTable('user_blocks', {
  id: uuid('id').primaryKey().defaultRandom(),
  blockerId: uuid('blocker_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  blockedId: uuid('blocked_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  reason: text('reason'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  blockerIdx: index('idx_user_blocks_blocker').on(table.blockerId),
  blockedIdx: index('idx_user_blocks_blocked').on(table.blockedId),
  relationshipIdx: index('idx_user_blocks_relationship').on(table.blockerId, table.blockedId),
  uniqueBlock: uniqueIndex('user_blocks_blocker_blocked_unique').on(table.blockerId, table.blockedId),
}));

// Moderation Actions Table
export const moderationActions = pgTable('moderation_actions', {
  id: uuid('id').primaryKey().defaultRandom(),
  moderatorId: uuid('moderator_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  
  // What was acted upon (polymorphic)
  targetUserId: uuid('target_user_id').references(() => userProfiles.id, { onDelete: 'cascade' }),
  targetVideoId: uuid('target_video_id').references(() => videos.id, { onDelete: 'cascade' }),
  targetCommentId: uuid('target_comment_id').references(() => comments.id, { onDelete: 'cascade' }),
  relatedReportId: uuid('related_report_id').references(() => reports.id, { onDelete: 'set null' }),
  
  // Action details
  actionType: moderationActionTypeEnum('action_type').notNull(),
  reason: text('reason').notNull(),
  notes: text('notes'),
  durationDays: integer('duration_days'),
  
  // Timestamps
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  expiresAt: timestamp('expires_at', { withTimezone: true }),
}, (table) => ({
  moderatorIdx: index('idx_moderation_actions_moderator').on(table.moderatorId),
  targetUserIdx: index('idx_moderation_actions_target_user').on(table.targetUserId),
  targetVideoIdx: index('idx_moderation_actions_target_video').on(table.targetVideoId),
  createdIdx: index('idx_moderation_actions_created').on(table.createdAt),
  activeIdx: index('idx_moderation_actions_active').on(table.expiresAt),
}));

// Content Warnings Table
export const contentWarnings = pgTable('content_warnings', {
  id: uuid('id').primaryKey().defaultRandom(),
  videoId: uuid('video_id').notNull().references(() => videos.id, { onDelete: 'cascade' }),
  warningType: text('warning_type').notNull(),
  warningMessage: text('warning_message').notNull(),
  createdByModeratorId: uuid('created_by_moderator_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  videoIdx: index('idx_content_warnings_video').on(table.videoId),
  activeIdx: index('idx_content_warnings_active').on(table.isActive),
  uniqueWarning: uniqueIndex('content_warnings_video_type_unique').on(table.videoId, table.warningType),
}));

// User Violations Table
export const userViolations = pgTable('user_violations', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  violationType: reportTypeEnum('violation_type').notNull(),
  severity: integer('severity').notNull().default(1),
  description: text('description').notNull(),
  relatedReportId: uuid('related_report_id').references(() => reports.id, { onDelete: 'set null' }),
  createdByModeratorId: uuid('created_by_moderator_id').notNull().references(() => userProfiles.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
}, (table) => ({
  userIdx: index('idx_user_violations_user').on(table.userId),
  severityIdx: index('idx_user_violations_severity').on(table.severity),
  createdIdx: index('idx_user_violations_created').on(table.createdAt),
}));

// Export all tables
export type UserProfile = typeof userProfiles.$inferSelect;
export type NewUserProfile = typeof userProfiles.$inferInsert;
export type Video = typeof videos.$inferSelect;
export type NewVideo = typeof videos.$inferInsert;
export type VideoInteraction = typeof videoInteractions.$inferSelect;
export type NewVideoInteraction = typeof videoInteractions.$inferInsert;
export type Comment = typeof comments.$inferSelect;
export type NewComment = typeof comments.$inferInsert;
export type Follow = typeof follows.$inferSelect;
export type NewFollow = typeof follows.$inferInsert;
export type Donation = typeof donations.$inferSelect;
export type NewDonation = typeof donations.$inferInsert;
export type Repost = typeof reposts.$inferSelect;
export type NewRepost = typeof reposts.$inferInsert;
export type Hashtag = typeof hashtags.$inferSelect;
export type NewHashtag = typeof hashtags.$inferInsert;
export type Notification = typeof notifications.$inferSelect;
export type NewNotification = typeof notifications.$inferInsert;
export type Report = typeof reports.$inferSelect;
export type NewReport = typeof reports.$inferInsert;
export type UserBlock = typeof userBlocks.$inferSelect;
export type NewUserBlock = typeof userBlocks.$inferInsert;
export type ModerationAction = typeof moderationActions.$inferSelect;
export type NewModerationAction = typeof moderationActions.$inferInsert;
export type ContentWarning = typeof contentWarnings.$inferSelect;
export type NewContentWarning = typeof contentWarnings.$inferInsert;
export type UserViolation = typeof userViolations.$inferSelect;
export type NewUserViolation = typeof userViolations.$inferInsert;
