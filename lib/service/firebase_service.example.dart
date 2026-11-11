import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

const useFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: true,
);

Future<void> initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (useFirebaseEmulators) {
    const override = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
    final host = override.isNotEmpty
        ? override
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? '10.0.2.2'
              : '127.0.0.1');
    await FirebaseAuth.instance.useAuthEmulator(
      host,
      9099,
      automaticHostMapping: false,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      8085,
      automaticHostMapping: false,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
  }
  await FirebaseAuth.instance.setLanguageCode('pt-BR');
}
