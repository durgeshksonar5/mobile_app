/// Live Satta Market entity reproducing the web result formatting & open/close window calculations.
class MarketResult {
  final int id;
  final String marketName;
  final String resultValue;
  final String resultDate;
  final String openTime;
  final String closeTime;
  final bool isActive;

  const MarketResult({
    required this.id,
    required this.marketName,
    required this.resultValue,
    required this.resultDate,
    required this.openTime,
    required this.closeTime,
    this.isActive = true,
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
    final isToday = resultDate == todayStr;
    final isDeclared = isToday && isValueDeclared(resultValue);

    final openParsed = _parseTimeStr(openTime, referenceDate);
    final openTimeArrived =
        openParsed != null && referenceDate.isAfter(openParsed);

    final closeParsed = _parseTimeStr(closeTime, referenceDate);
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

    if (closeTimeArrived) {
      statusText = 'Market Closed';
      statusType = 'closed';
    } else if (openTimeArrived) {
      statusText = 'Running Close';
      statusType = 'running_close';
    } else {
      statusText = 'Market Running';
      statusType = 'running';
    }

    final formattedValue =
        isDeclared ? formatResultDisplay(resultValue) : '***-**-***';

    return MarketDisplayInfo(
      resultValue: formattedValue,
      statusText: statusText,
      statusType: statusType,
      canPlay: !closeTimeArrived,
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
