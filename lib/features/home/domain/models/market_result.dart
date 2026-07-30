/// Live Satta Market entity reproducing the web result formatting & open/close window calculations.
class MarketResult {
  final int id;
  final String marketName;
  final String resultValue;
  final String resultDate;
  final String openTime;
  final String closeTime;
  final bool isActive;
  final String openDays;

  const MarketResult({
    required this.id,
    required this.marketName,
    required this.resultValue,
    required this.resultDate,
    required this.openTime,
    required this.closeTime,
    this.isActive = true,
    this.openDays = '',
  });

  factory MarketResult.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      if (val is num) return val != 0;
      return true;
    }

    return MarketResult(
      id: parseId(json['id']),
      marketName: (json['market_name'] ?? '').toString(),
      resultValue: (json['result_value'] ?? '***-**-***').toString(),
      resultDate: (json['result_date'] ?? '').toString(),
      openTime: (json['open_time'] ?? '').toString(),
      closeTime: (json['close_time'] ?? '').toString(),
      isActive: parseBool(json['is_active']),
      openDays: (json['open_days'] ?? json['open_day'] ?? '').toString(),
    );
  }

  static bool isValueDeclared(String val) {
    if (val.isEmpty) return false;
    final clean = val.toUpperCase().trim();
    if (clean == 'COMING OPEN' ||
        clean == 'COMING' ||
        clean.contains('COMING OPEN') ||
        clean == '***-**-***') {
      return false;
    }
    return true;
  }

  static String formatResultDisplay(String val) {
    if (val.isEmpty) return '***-**-***';
    String clean = val.toUpperCase().trim();
    if (clean.contains('COMING OPEN') || clean == 'COMING') {
      return '***-**-***';
    }
    clean = clean.replaceAll('COMING CLOSE', '***');
    clean = clean.replaceAll('_', '-');

    final parts = clean.split('-');
    if (parts.length == 3) {
      return '${parts[0]}-${parts[1]}-${parts[2]}';
    } else if (parts.length == 2) {
      String jodi = parts[1];
      if (jodi.length == 1) jodi = '$jodi*';
      return '${parts[0]}-$jodi-***';
    } else if (parts.length == 1) {
      if (clean == '***') return '***-**-***';
      return clean;
    }
    return clean;
  }

  /// Calculates display info (result text, status text, color, play availability)
  MarketDisplayInfo getDisplayInfo(String todayStr, DateTime referenceDate) {
    int timeToMinutes(String timeStr) {
      if (timeStr.isEmpty) return 0;
      final clean = timeStr.trim().toUpperCase();
      final match = RegExp(r'^(\d+):(\d+)\s*(AM|PM)$').firstMatch(clean);
      if (match == null) return 0;
      int hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final modifier = match.group(3)!;
      if (modifier == 'PM' && hours < 12) hours += 12;
      if (modifier == 'AM' && hours == 12) hours = 0;
      return hours * 60 + minutes;
    }

    final openMin = timeToMinutes(openTime);
    final closeMin = timeToMinutes(closeTime);
    final currentMin = referenceDate.hour * 60 + referenceDate.minute;

    DateTime effectiveDate = referenceDate;
    if (closeMin < openMin && currentMin < openMin) {
      effectiveDate = referenceDate.subtract(const Duration(days: 1));
    }

    final effectiveTodayStr =
        "${effectiveDate.year}-${effectiveDate.month.toString().padLeft(2, '0')}-${effectiveDate.day.toString().padLeft(2, '0')}";

    final weekdaysMap = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    final currentDayAbbr = weekdaysMap[effectiveDate.weekday] ?? '';
    final isOpenToday = openDays.trim().isEmpty ||
        openDays
            .toLowerCase()
            .split(',')
            .map((e) => e.trim().toLowerCase())
            .contains(currentDayAbbr.toLowerCase());

    final isToday = resultDate == effectiveTodayStr;
    final isDeclared = isToday && isValueDeclared(resultValue);

    final openParsed = _parseTimeStr(openTime, effectiveDate);
    final openTimeArrived =
        openParsed != null && referenceDate.isAfter(openParsed);

    var closeParsed = _parseTimeStr(closeTime, effectiveDate);
    if (closeMin < openMin && closeParsed != null) {
      closeParsed = closeParsed.add(const Duration(days: 1));
    }
    bool closeTimeArrived =
        closeParsed != null && referenceDate.isAfter(closeParsed);

    // 11:59 PM lockout window check (11:59 PM to 12:30 AM)
    if (closeTime.trim().toUpperCase() == '11:59 PM') {
      final hours = referenceDate.hour;
      final minutes = referenceDate.minute;
      if ((hours == 23 && minutes >= 59) || (hours == 0 && minutes < 30)) {
        closeTimeArrived = true;
      }
    }

    String statusText;
    String statusType;
    bool canPlay;

    if (!isOpenToday) {
      statusText = 'Market is closed for today';
      statusType = 'closed';
      canPlay = false;
    } else if (closeTimeArrived) {
      statusText = 'Market Closed';
      statusType = 'closed';
      canPlay = false;
    } else if (openTimeArrived) {
      statusText = 'Running Close';
      statusType = 'running_close';
      canPlay = true;
    } else {
      statusText = 'Market Running';
      statusType = 'running';
      canPlay = true;
    }

    final formattedValue =
        isDeclared ? formatResultDisplay(resultValue) : '***-**-***';

    return MarketDisplayInfo(
      resultValue: formattedValue,
      statusText: statusText,
      statusType: statusType,
      canPlay: canPlay,
    );
  }

  static DateTime? _parseTimeStr(String timeStr, DateTime refDate) {
    if (timeStr.isEmpty) return null;
    try {
      final clean = timeStr.trim().toUpperCase();
      final match = RegExp(r'^(\d+):(\d+)\s*(AM|PM)$').firstMatch(clean);
      if (match == null) return null;

      int hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final modifier = match.group(3)!;

      if (modifier == 'PM' && hours < 12) hours += 12;
      if (modifier == 'AM' && hours == 12) hours = 0;

      return DateTime(refDate.year, refDate.month, refDate.day, hours, minutes);
    } catch (_) {
      return null;
    }
  }

  int getOpenTimeMinutes() {
    if (openTime.isEmpty) return 0;
    try {
      final clean = openTime.trim().toUpperCase();
      final match = RegExp(r'^(\d+):(\d+)\s*(AM|PM)$').firstMatch(clean);
      if (match == null) return 0;

      int hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final modifier = match.group(3)!;

      if (modifier == 'PM' && hours < 12) hours += 12;
      if (modifier == 'AM' && hours == 12) hours = 0;

      return hours * 60 + minutes;
    } catch (_) {
      return 0;
    }
  }
}

class MarketDisplayInfo {
  final String resultValue;
  final String statusText;
  final String statusType; // 'closed', 'running_close', 'running'
  final bool canPlay;

  const MarketDisplayInfo({
    required this.resultValue,
    required this.statusText,
    required this.statusType,
    required this.canPlay,
  });
}
