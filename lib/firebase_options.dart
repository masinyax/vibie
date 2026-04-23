// Automatically generated Firebase options file.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAUoljpuowDFiHo_MvAwnot-_kMwt9mnSo',
    appId: '1:767478164407:ios:9a3e0e3412b48a7bc81632',
    messagingSenderId: '767478164407',
    projectId: 'moodapp-e5799',
    storageBucket: 'moodapp-e5799.firebasestorage.app',
  );

  // ✨ แก้ไขค่า iOS ให้ตรงกับไฟล์ GoogleService-Info.plist ของ Masinya แล้วครับ
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAUoljpuowDFiHo_MvAwnot-_kMwt9mnSo',
    appId: '1:767478164407:ios:9a3e0e3412b48a7bc81632',
    messagingSenderId: '767478164407',
    projectId: 'moodapp-e5799',
    storageBucket: 'moodapp-e5799.firebasestorage.app',
    iosBundleId: 'com.earth.vibie',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAUoljpuowDFiHo_MvAwnot-_kMwt9mnSo',
    appId: '1:767478164407:ios:9a3e0e3412b48a7bc81632',
    messagingSenderId: '767478164407',
    projectId: 'moodapp-e5799',
    storageBucket: 'moodapp-e5799.firebasestorage.app',
  );
}