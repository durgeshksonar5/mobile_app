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

    Color statusColor;
    if (info.statusType == 'closed') {
      statusColor = AppColors.statusRed;
    } else if (info.statusType == 'running_close') {
      statusColor = AppColors.statusAmber;
    } else {
      statusColor = AppColors.statusGreen;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Market Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  market.marketName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.resultValue,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Open :',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          market.openTime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                        height: 24, width: 1, color: AppColors.borderLight),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Close :',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                        Text(
                          market.closeTime,
                          style: const TextStyle(
                            fontSize: 12,
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

          // Right Play Actions
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month,
                    color: AppColors.primaryGold, size: 22),
                onPressed: onChartTap,
                tooltip: 'Chart Record',
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: info.canPlay ? onPlayTap : null,
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: info.canPlay
                            ? AppColors.textDark
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        boxShadow: info.canPlay
                            ? const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 20,
                        color: info.canPlay
                            ? AppColors.textWhite
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.canPlay ? 'PLAY NOW' : 'CLOSED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: info.canPlay
                            ? AppColors.textDark
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
