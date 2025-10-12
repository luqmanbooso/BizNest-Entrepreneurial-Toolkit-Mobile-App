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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDDsxKyZQzQnzj-jTFIzEtiIomLNzAMlGo',
    appId: '1:632141432993:web:your_web_app_id_here',
    messagingSenderId: '632141432993',
    projectId: 'biznest-1a094',
    authDomain: 'biznest-1a094.firebaseapp.com',
    storageBucket: 'biznest-1a094.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDsxKyZQzQnzj-jTFIzEtiIomLNzAMlGo',
    appId: '1:632141432993:android:202c4c4d27140dc72588e0',
    messagingSenderId: '632141432993',
    projectId: 'biznest-1a094',
    storageBucket: 'biznest-1a094.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDsxKyZQzQnzj-jTFIzEtiIomLNzAMlGo',
    appId: '1:632141432993:ios:your_ios_app_id_here',
    messagingSenderId: '632141432993',
    projectId: 'biznest-1a094',
    storageBucket: 'biznest-1a094.firebasestorage.app',
  );
}