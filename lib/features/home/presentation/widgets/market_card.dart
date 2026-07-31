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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: statusColor, width: 2),
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      );
    } else {
      playButton = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400, width: 2),
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: info.canPlay
              ? const Color(0xFFE7D5A2).withOpacity(0.8)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: info.canPlay
                ? const Color(0xFFE4AA25).withOpacity(0.06)
                : Colors.black.withOpacity(0.03),
            blurRadius: 9,
            offset: const Offset(0, 3.5),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3.5),

                // Result Value (Bold Gold)
                Text(
                  info.resultValue,
                  style: const TextStyle(
                    fontSize: 22.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGold, // Theme gold: Color(0xFFE4AA25)
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 3.5),

                // Status text (Betting is Running / Closed)
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 9),

                // Timings Row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Open :',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          market.openTime.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 13),
                    const Text(
                      '|',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Close :',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          market.closeTime.toLowerCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
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
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              // Play/Locked Action
              playButton,
            ],
          ),
        ],
      ),
    );
  }
}
