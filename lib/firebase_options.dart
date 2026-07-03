import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration for project-atlas (project-atlas-529bf).
/// Web-only for now — Chrome is the dev target. Android/iOS options get
/// added when mobile builds begin (flutterfire configure at that point).
/// These values are public identifiers by design; access control lives in
/// Firestore security rules (ATLAS-004), not here.
class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmNupO5mwh5tyTkObxJNAm02AI7mj-bp0',
    authDomain: 'project-atlas-529bf.firebaseapp.com',
    projectId: 'project-atlas-529bf',
    storageBucket: 'project-atlas-529bf.firebasestorage.app',
    messagingSenderId: '23461148383',
    appId: '1:23461148383:web:bdf67e15a62f0e06b21b6a',
    measurementId: 'G-8XWP9C4CW2',
  );
}
