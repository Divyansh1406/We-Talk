// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBEEuiqY6JWn5qS2ps2IUCiDhP9NIDeJJY',
    appId: '1:195593901209:web:8df3c2f1a61f25174b5408',
    messagingSenderId: '195593901209',
    projectId: 'wetalk-8b392',
    authDomain: 'wetalk-8b392.firebaseapp.com',
    storageBucket: 'wetalk-8b392.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVLu67yhKwTVbnU6AHVdaKw_9RzWKnKU8',
    appId: '1:195593901209:android:87879e75fe3b9a604b5408',
    messagingSenderId: '195593901209',
    projectId: 'wetalk-8b392',
    storageBucket: 'wetalk-8b392.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSVMeDwZaRj14mcQlrzkuvoxtfY8EJod4',
    appId: '1:195593901209:ios:09cff6ddb85287af4b5408',
    messagingSenderId: '195593901209',
    projectId: 'wetalk-8b392',
    storageBucket: 'wetalk-8b392.appspot.com',
    androidClientId: '195593901209-4ccd2la07sn65cr5dfj5rv8fqd5ghrlb.apps.googleusercontent.com',
    iosClientId: '195593901209-sm8euqile5ipd6h3n9b42q99h29d3a0r.apps.googleusercontent.com',
    iosBundleId: 'com.example.weTalk',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSVMeDwZaRj14mcQlrzkuvoxtfY8EJod4',
    appId: '1:195593901209:ios:22f117abb376dc7a4b5408',
    messagingSenderId: '195593901209',
    projectId: 'wetalk-8b392',
    storageBucket: 'wetalk-8b392.appspot.com',
    androidClientId: '195593901209-4ccd2la07sn65cr5dfj5rv8fqd5ghrlb.apps.googleusercontent.com',
    iosClientId: '195593901209-ck92ru7lje3rid2pj9bhqimom5mg1u5e.apps.googleusercontent.com',
    iosBundleId: 'com.example.weTalk.RunnerTests',
  );
}
