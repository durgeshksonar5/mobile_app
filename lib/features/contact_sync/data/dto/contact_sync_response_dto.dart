class ContactSyncResponseDto {
  final bool success;
  final int syncedCount;
  final int rejectedCount;
  final String? batchId;

  const ContactSyncResponseDto({
    required this.success,
    required this.syncedCount,
    this.rejectedCount = 0,
    this.batchId,
  });

  factory ContactSyncResponseDto.fromJson(Map<String, dynamic> json) {
    return ContactSyncResponseDto(
      success: json['success'] as bool? ?? true,
      syncedCount: (json['synced_count'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          0,
      rejectedCount: (json['rejected_count'] as num?)?.toInt() ?? 0,
      batchId: json['batch_id'] as String?,
    );
  }
}
