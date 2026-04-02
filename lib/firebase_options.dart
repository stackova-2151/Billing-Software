import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCB6BKtx7XrUam37z_bCkR9zhVCLaKh_g0',
    appId: '1:845084546928:web:1222f166e5ec6652f621b5',
    messagingSenderId: '845084546928',
    projectId: 'billingapp-94811',
    authDomain: 'billingapp-94811.firebaseapp.com',
    storageBucket: 'billingapp-94811.firebasestorage.app',
    measurementId: 'G-4VNHYC8KDM',
  );
}