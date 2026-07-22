import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_sms_provided_placeholder_web_key',
    appId: '1:100000000000:web:sms_provided_app_id',
    messagingSenderId: '100000000000',
    projectId: 'sms-provided',
    authDomain: 'sms-provided.firebaseapp.com',
    storageBucket: 'sms-provided.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_sms_provided_placeholder_android_key',
    appId: '1:100000000000:android:sms_provided_android_app_id',
    messagingSenderId: '100000000000',
    projectId: 'sms-provided',
    storageBucket: 'sms-provided.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_sms_provided_placeholder_ios_key',
    appId: '1:100000000000:ios:sms_provided_ios_app_id',
    messagingSenderId: '100000000000',
    projectId: 'sms-provided',
    storageBucket: 'sms-provided.appspot.com',
    iosBundleId: 'com.kingwin.app.kingWinsMobileApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_sms_provided_placeholder_ios_key',
    appId: '1:100000000000:ios:sms_provided_ios_app_id',
    messagingSenderId: '100000000000',
    projectId: 'sms-provided',
    storageBucket: 'sms-provided.appspot.com',
    iosBundleId: 'com.kingwin.app.kingWinsMobileApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA_sms_provided_placeholder_web_key',
    appId: '1:100000000000:web:sms_provided_app_id',
    messagingSenderId: '100000000000',
    projectId: 'sms-provided',
    authDomain: 'sms-provided.firebaseapp.com',
    storageBucket: 'sms-provided.appspot.com',
  );
}
