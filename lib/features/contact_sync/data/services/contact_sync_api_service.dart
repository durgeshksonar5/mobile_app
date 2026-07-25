import 'package:dio/dio.dart';
import '../dto/contact_sync_request_dto.dart';
import '../dto/contact_sync_response_dto.dart';

class ContactSyncApiService {
  final Dio _dio;

  ContactSyncApiService(this._dio);

  Future<ContactSyncResponseDto> syncContactsBatch(
      ContactSyncRequestDto dto) async {
    try {
      final response =
          await _dio.post('/auth/contacts/sync/', data: dto.toJson());
      return ContactSyncResponseDto.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Return clear response when endpoint is not configured on server
        return ContactSyncResponseDto(
          success: false,
          syncedCount: 0,
          rejectedCount: dto.contacts.length,
        );
      }
      rethrow;
    }
  }

  Future<bool> deleteSyncedContacts() async {
    try {
      final response = await _dio.delete('/contacts/sync/delete/');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }
}
