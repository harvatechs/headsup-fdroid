import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGA08fFX_N6HA2bIVs0RkabH2-f5_Nklk',
    appId: '1:1057841670500:android:15c316bb5c60cf904e3271',
    messagingSenderId: '1057841670500',
    projectId: 'heads-up-43f7c',
    storageBucket: 'heads-up-43f7c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGA08fFX_N6HA2bIVs0RkabH2-f5_Nklk',
    appId: '1:1057841670500:ios:15c316bb5c60cf904e3271',
    messagingSenderId: '1057841670500',
    projectId: 'heads-up-43f7c',
    storageBucket: 'heads-up-43f7c.firebasestorage.app',
    iosBundleId: 'com.kora.headsup',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAGA08fFX_N6HA2bIVs0RkabH2-f5_Nklk',
    appId: '1:1057841670500:web:15c316bb5c60cf904e3271',
    messagingSenderId: '1057841670500',
    projectId: 'heads-up-43f7c',
    authDomain: 'heads-up-43f7c.firebaseapp.com',
    storageBucket: 'heads-up-43f7c.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAGA08fFX_N6HA2bIVs0RkabH2-f5_Nklk',
    appId: '1:1057841670500:ios:15c316bb5c60cf904e3271',
    messagingSenderId: '1057841670500',
    projectId: 'heads-up-43f7c',
    storageBucket: 'heads-up-43f7c.firebasestorage.app',
    iosBundleId: 'com.kora.headsup',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAGA08fFX_N6HA2bIVs0RkabH2-f5_Nklk',
    appId: '1:1057841670500:web:15c316bb5c60cf904e3271',
    messagingSenderId: '1057841670500',
    projectId: 'heads-up-43f7c',
    authDomain: 'heads-up-43f7c.firebaseapp.com',
    storageBucket: 'heads-up-43f7c.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyAGA08fFX_N6HA2bIVs0RkabH2-f5_Nklk',
    appId: '1:1057841670500:web:15c316bb5c60cf904e3271',
    messagingSenderId: '1057841670500',
    projectId: 'heads-up-43f7c',
    authDomain: 'heads-up-43f7c.firebaseapp.com',
    storageBucket: 'heads-up-43f7c.firebasestorage.app',
  );
}
