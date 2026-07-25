import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/dependency_injection/providers.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../domain/models/market_result.dart';

class WeekRow {
  final DateTime monday;
  final DateTime sunday;
  final Map<int, MarketResult> days; // 1 = Mon ... 7 = Sun

  WeekRow({
    required this.monday,
    required this.sunday,
    required this.days,
  });

  String get weekRangeLabel {
    final monStr =
        '${monday.day.toString().padLeft(2, '0')}/${monday.month.toString().padLeft(2, '0')}';
    final sunStr =
        '${sunday.day.toString().padLeft(2, '0')}/${sunday.month.toString().padLeft(2, '0')}';
    return '$monStr - $sunStr';
  }
}

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

  static bool isRedJodi(String jodi) {
    final clean = jodi.trim();
    if (clean.length != 2) return false;
    final d1 = int.tryParse(clean[0]);
    final d2 = int.tryParse(clean[1]);
    if (d1 == null || d2 == null) return false;
    if (d1 == d2) return true;
    if ((d1 - d2).abs() == 5) return true;
    return false;
  }

  List<WeekRow> _buildWeekRows(List<MarketResult> history) {
    final Map<DateTime, Map<int, MarketResult>> weekMap = {};

    for (final item in history) {
      if (item.resultDate.isEmpty) continue;
      try {
        final date = DateTime.parse(item.resultDate);
        final monday = DateTime(date.year, date.month, date.day)
            .subtract(Duration(days: date.weekday - 1));
        final dayOfWeek = date.weekday;

        weekMap.putIfAbsent(monday, () => {});
        weekMap[monday]![dayOfWeek] = item;
      } catch (_) {}
    }

    final sortedMondays = weekMap.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return sortedMondays.map((monday) {
      final sunday = monday.add(const Duration(days: 6));
      return WeekRow(
        monday: monday,
        sunday: sunday,
        days: weekMap[monday]!,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final weekRows = _buildWeekRows(_history);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
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

              // Red Jodi Legend / Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: AppColors.surfaceGold,
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, size: 14, color: AppColors.statusRed),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Red Jodis (Doublets & Cut Pairs) highlighted in red.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGold))
                    : weekRows.isEmpty
                        ? const Center(
                            child: Text(
                              'No history records found for this market.',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 13),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _buildTable(weekRows),
                            ),
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

  Widget _buildTable(List<WeekRow> weekRows) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Table(
      border: TableBorder.all(
        color: AppColors.border,
        width: 1,
      ),
      columnWidths: const {
        0: FixedColumnWidth(96), // Week Range
        1: FixedColumnWidth(48), // Mon
        2: FixedColumnWidth(48), // Tue
        3: FixedColumnWidth(48), // Wed
        4: FixedColumnWidth(48), // Thu
        5: FixedColumnWidth(48), // Fri
        6: FixedColumnWidth(48), // Sat
        7: FixedColumnWidth(48), // Sun
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        // Header Row
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.surfaceGold,
          ),
          children: [
            _buildHeaderCell('Week Range'),
            ...dayLabels.map((d) => _buildHeaderCell(d)),
          ],
        ),
        // Data Rows
        for (final row in weekRows)
          TableRow(
            children: [
              // Week Range cell
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                alignment: Alignment.center,
                child: Text(
                  row.weekRangeLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Day cells 1..7 (Mon..Sun)
              for (int day = 1; day <= 7; day++)
                _buildDayCell(row.days[day]),
            ],
          ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDayCell(MarketResult? result) {
    String openPanna = '***';
    String jodi = '**';
    String closePanna = '***';

    if (result != null) {
      final displayVal = MarketResult.formatResultDisplay(result.resultValue);
      final parts = displayVal.split('-');
      if (parts.isNotEmpty && parts[0].isNotEmpty) openPanna = parts[0];
      if (parts.length > 1 && parts[1].isNotEmpty) jodi = parts[1];
      if (parts.length > 2 && parts[2].isNotEmpty) closePanna = parts[2];
    }

    final redJodi = isRedJodi(jodi);

    if (_chartType == 'jodi') {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        alignment: Alignment.center,
        child: Text(
          jodi,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: jodi == '**'
                ? AppColors.textMuted
                : (redJodi ? AppColors.statusRed : AppColors.textPrimary),
          ),
        ),
      );
    } else {
      // Panel Chart: Stacked 3 lines
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              openPanna,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: openPanna == '***'
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              jodi,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: jodi == '**'
                    ? AppColors.textMuted
                    : (redJodi ? AppColors.statusRed : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              closePanna,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: closePanna == '***'
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }
  }
}

