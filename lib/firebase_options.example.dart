import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:1234567890:android:0123456789abcdef',
    messagingSenderId: '1234567890',
    projectId: 'demo-apk-auth',
    authDomain: 'demo-apk-auth.firebaseapp.com',
  );
}
