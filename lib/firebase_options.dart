// Automatically generated Firebase options file (minimal).
// This file was created to allow initializing Firebase on Android emulator.
// For full, cross-platform configuration, generate with the FlutterFire CLI
// and do not commit secrets to a public repo.

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
        // macOS can typically reuse iOS options for Firebase initialization.
        return ios;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for this platform.\n'
            'To generate this file, run: flutterfire configure');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsm0X7rsX8Ly8DlFAYvOMVGp_FY_-6f1k',
    appId: '1:767478164407:android:7b052e5ef5f28bc7c81632',
    messagingSenderId: '767478164407',
    projectId: 'moodapp-e5799',
    storageBucket: 'moodapp-e5799.firebasestorage.app',
  );

  // iOS options: appId here is a placeholder. For fully correct iOS setup,
  // generate `firebase_options.dart` via FlutterFire CLI on a Mac or provide
  // the real `GoogleService-Info.plist` (preferred).
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsm0X7rsX8Ly8DlFAYvOMVGp_FY_-6f1k',
    appId: '1:767478164407:ios:0000000000000000000000',
    messagingSenderId: '767478164407',
    projectId: 'moodapp-e5799',
    storageBucket: 'moodapp-e5799.firebasestorage.app',
  );

  // Minimal web config stub. Fill or generate via FlutterFire CLI if using web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAsm0X7rsX8Ly8DlFAYvOMVGp_FY_-6f1k',
    appId: '1:767478164407:web:0000000000000000000000',
    messagingSenderId: '767478164407',
    projectId: 'moodapp-e5799',
    storageBucket: 'moodapp-e5799.firebasestorage.app',
  );
}
