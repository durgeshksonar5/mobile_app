import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/market_result.dart';

class ChartModalDialog extends ConsumerStatefulWidget {
  final String marketName;

  const ChartModalDialog({super.key, required this.marketName});

  @override
  ConsumerState<ChartModalDialog> createState() => _ChartModalDialogState();
}

class _ChartModalDialogState extends ConsumerState<ChartModalDialog> {
  String _chartType = 'jodi'; // 'jodi' or 'panel'
  bool _isLoading = true;
  List<MarketResult> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    final repo = ref.read(resultsRepositoryProvider);
    final res = await repo.getSattaHistory(widget.marketName);
    if (mounted) {
      setState(() {
        _history = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Gold Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF8D044),
                      Color(0xFFE4AA25),
                      Color(0xFFC58514),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.marketName.toUpperCase()} CHARTS',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Historical Jodi & Panel Results',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textPrimary, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Tab Selector
              Container(
                color: AppColors.background,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _chartType = 'jodi'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _chartType == 'jodi'
                                ? AppColors.primaryGold
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Text(
                            'Jodi Chart',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _chartType == 'jodi'
                                  ? AppColors.textWhite
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _chartType = 'panel'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _chartType == 'panel'
                                ? AppColors.primaryGold
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Text(
                            'Panel Chart',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _chartType == 'panel'
                                  ? AppColors.textWhite
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Chart Data Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGold))
                    : _history.isEmpty
                        ? const Center(
                            child: Text(
                              'No history records found for this market.',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _history.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              final displayVal =
                                  MarketResult.formatResultDisplay(
                                      item.resultValue);
                              final parts = displayVal.split('-');

                              String openPanna =
                                  parts.isNotEmpty ? parts[0] : '***';
                              String jodi = parts.length > 1 ? parts[1] : '**';
                              String closePanna =
                                  parts.length > 2 ? parts[2] : '***';

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.resultDate,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary),
                                    ),
                                    if (_chartType == 'jodi')
                                      Text(
                                        jodi,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryGold,
                                        ),
                                      )
                                    else
                                      Row(
                                        children: [
                                          Text(openPanna,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          const SizedBox(width: 8),
                                          Text(jodi,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w900,
                                                  color:
                                                      AppColors.primaryGold)),
                                          const SizedBox(width: 8),
                                          Text(closePanna,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.statusRed)),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),

              // Close Footer Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close Charts'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
