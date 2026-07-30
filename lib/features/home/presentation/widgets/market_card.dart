import 'package:flutter/material.dart';
import '../../domain/models/market_result.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class MarketCard extends StatelessWidget {
  final MarketResult market;
  final String todayStr;
  final DateTime referenceDate;
  final VoidCallback onChartTap;
  final VoidCallback onPlayTap;

  const MarketCard({
    super.key,
    required this.market,
    required this.todayStr,
    required this.referenceDate,
    required this.onChartTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = market.getDisplayInfo(todayStr, referenceDate);

    // Status mapping exactly matching the visual states
    String statusText;
    Color statusColor;
    if (info.statusType == 'closed') {
      statusText = 'Betting is Closed for today';
      statusColor = const Color(0xFFC62828); // Solid Red
    } else if (info.statusType == 'running_close') {
      statusText = 'Betting is Running for Close';
      statusColor = const Color(0xFFE65100); // Light Orange/Amber
    } else {
      statusText = 'Betting is Running for today';
      statusColor = const Color(0xFF2E7D32); // Solid Green
    }

    // Play action button styling matching the image outer ring + inner solid circle
    Widget playButton;
    if (info.canPlay) {
      playButton = GestureDetector(
        onTap: onPlayTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 2),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      );
    } else {
      playButton = Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: info.canPlay
            ? const LinearGradient(
                colors: [
                  Color(0x26E6B450), // Gold-bronze edge (15% opacity)
                  Color(0xFFFFFFFF), // Pure white center start
                  Color(0xFFFFFFFF), // Pure white center end
                  Color(0x26E6B450), // Gold-bronze edge (15% opacity)
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : LinearGradient(
                colors: [
                  const Color(0x1AA0A0A0), // Muted grey edge (10% opacity)
                  const Color(0xFFFFFFFF),
                  const Color(0xFFFFFFFF),
                  const Color(0x1AA0A0A0),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: info.canPlay
              ? const Color(0xFFE7D5A2).withOpacity(0.8)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: info.canPlay
                ? const Color(0xFFE4AA25).withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Text details stack
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Market Name (Bold Black)
                Text(
                  market.marketName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Result Value (Bold Gold)
                Text(
                  info.resultValue,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGold, // Theme gold: Color(0xFFE4AA25)
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),

                // Status text (Betting is Running / Closed)
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 10),

                // Timings Row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Open :',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          market.openTime.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      '|',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Close :',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          market.closeTime.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right side: Calendar Icon (Top) & Play Action (Bottom)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              // Calendar/Chart Icon
              GestureDetector(
                onTap: onChartTap,
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primaryGold,
                  size: 34,
                ),
              ),
              const SizedBox(height: 24),
              // Play/Locked Action
              playButton,
            ],
          ),
        ],
      ),
    );
  }
}
