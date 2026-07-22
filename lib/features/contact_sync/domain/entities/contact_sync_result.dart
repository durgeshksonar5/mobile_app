class ContactSyncResult {
  final bool isSuccess;
  final bool isPartialSuccess;
  final int syncedCount;
  final int rejectedCount;
  final String? errorMessage;
  final DateTime syncTimestamp;

  const ContactSyncResult({
    required this.isSuccess,
    this.isPartialSuccess = false,
    required this.syncedCount,
    this.rejectedCount = 0,
    this.errorMessage,
    required this.syncTimestamp,
  });

  factory ContactSyncResult.success(int count) {
    return ContactSyncResult(
      isSuccess: true,
      syncedCount: count,
      syncTimestamp: DateTime.now(),
    );
  }

  factory ContactSyncResult.failure(String message) {
    return ContactSyncResult(
      isSuccess: false,
      syncedCount: 0,
      errorMessage: message,
      syncTimestamp: DateTime.now(),
    );
  }
}
