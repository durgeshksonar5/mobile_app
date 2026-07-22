import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// App notification model for in-app alert panel.
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category; // 'all', 'result', 'transaction', 'system'
  final bool isRead;
  final IconData icon;
  final Color accentColor;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
    required this.icon,
    required this.accentColor,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    String? category,
    bool? isRead,
    IconData? icon,
    Color? accentColor,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  static List<AppNotification> getInitialSampleNotifications() {
    return const [
      AppNotification(
        id: '1',
        title: 'Welcome to King Win App! 👑',
        message:
            'Experience fast Satta Matka results and 24/7 instant withdrawals. Enjoy your games!',
        timeAgo: 'Just now',
        category: 'system',
        isRead: false,
        icon: Icons.star_rounded,
        accentColor: AppColors.primaryGold,
      ),
      AppNotification(
        id: '2',
        title: 'KALYAN BAZAR Result Declared 🎯',
        message:
            'Winning Jodi result for Kalyan Bazar is 480-27-123. Check your bid history for payouts.',
        timeAgo: '15 mins ago',
        category: 'result',
        isRead: false,
        icon: Icons.emoji_events_rounded,
        accentColor: Color(0xFF16A34A),
      ),
      AppNotification(
        id: '3',
        title: 'Instant Deposit Approved 💳',
        message:
            'Your recent deposit request of ₹1,000 has been verified and added to your wallet balance.',
        timeAgo: '1 hour ago',
        category: 'transaction',
        isRead: false,
        icon: Icons.account_balance_wallet_rounded,
        accentColor: Color(0xFF2563EB),
      ),
      AppNotification(
        id: '4',
        title: '24/7 WhatsApp Support Available 💬',
        message:
            'Have questions or need quick balance additions? Tap support to chat with our admin directly.',
        timeAgo: '3 hours ago',
        category: 'system',
        isRead: true,
        icon: Icons.support_agent_rounded,
        accentColor: Color(0xFF9333EA),
      ),
      AppNotification(
        id: '5',
        title: 'MILAN NIGHT Market Closing Soon ⏰',
        message:
            'Bidding closes in 20 minutes for Milan Night open session. Place your bets now!',
        timeAgo: '5 hours ago',
        category: 'result',
        isRead: true,
        icon: Icons.access_time_filled_rounded,
        accentColor: Color(0xFFDC2626),
      ),
    ];
  }
}
