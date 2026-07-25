import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';

/// Service to handle Firebase Cloud Messaging (FCM) configurations, permissions,
/// foreground/background message listeners, and device token syncing with Django.
class NotificationService {
  final ApiClient _apiClient;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _isRegistering = false;

  NotificationService(this._apiClient) {
    _initializeListeners();
  }

  void _initializeListeners() {
    // 1. Listen for foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          'Received foreground notification: ${message.notification?.title}');
      if (message.notification != null) {
        // Log notification details. Future enhancement can trigger toast/banner UI here.
        debugPrint(
            'Foreground Notification Body: ${message.notification?.body}');
      }
    });

    // 2. Listen for app open events from notification background tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened via notification: ${message.notification?.title}');
    });

    // 3. Listen for token refreshes and sync with backend dynamically
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint("FCM token refreshed: $newToken");
      _syncTokenWithBackend(newToken);
    });
  }

  /// Request iOS and Android 13+ push notification permissions
  Future<void> requestPermissions() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint(
          'User push notifications permission authorizationStatus: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  /// Retrieve the current FCM token and register it with the Django backend
  Future<void> requestPermissionsAndRegister() async {
    if (_isRegistering) return;
    _isRegistering = true;

    try {
      // Step 1: Ensure permission is requested
      await requestPermissions();

      // Step 2: Retrieve FCM token
      String? token = await _fcm.getToken();
      if (token == null) {
        debugPrint("FCM Token is null, cannot sync with backend.");
        _isRegistering = false;
        return;
      }
      debugPrint("FCM Registration Token retrieved: $token");

      // Step 3: Send token to backend
      await _syncTokenWithBackend(token);
    } catch (e) {
      debugPrint("Error during FCM registration: $e");
    } finally {
      _isRegistering = false;
    }
  }

  /// Syncs the FCM token to the Django backend
  Future<void> _syncTokenWithBackend(String token) async {
    try {
      String platform = Platform.isAndroid ? "android" : "ios";

      final response = await _apiClient.dio.post(
        '/notifications/device-tokens/',
        data: {
          "token": token,
          "platform": platform,
          "device_name": Platform.localHostname,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("Device token successfully synced with Django backend.");
      } else {
        debugPrint(
            "Failed to sync device token. Status Code: ${response.statusCode}, Body: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error syncing FCM token with Django backend: $e");
    }
  }
}
