import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCjulikgUL1q-v6yjoeS7Rzq198L0WOzzY",
    authDomain: "test-ad968.firebaseapp.com",
    projectId: "test-ad968",
    storageBucket: "test-ad968.firebasestorage.app",
    messagingSenderId: "68519481900",
    appId: "1:68519481900:web:70ff7b281559973232b789",
  );
}
