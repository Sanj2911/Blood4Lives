import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      
      
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Existing Firebase options for web, Android, and iOS

  static const FirebaseOptions web = FirebaseOptions(

  apiKey: "AIzaSyCi5t5Bxt3wQe3m0v2A6rvljGDOxXaM5hQ",
  authDomain: "save-lives-a7e08.firebaseapp.com",
  projectId: "save-lives-a7e08",
  storageBucket: "save-lives-a7e08.appspot.com",
  messagingSenderId: "809810494177",
  appId: "1:809810494177:web:052e8f84c4d478847aeda0"
  );

  static const FirebaseOptions android = FirebaseOptions(
    // Android configuration
    apiKey: 'AIzaSyCF8rRBJecHou7U4dgC5eN3p-kym_0p7vo', // Replace 'YOUR_API_KEY' with the actual API key from the JSON
      appId: '1:809810494177:android:59f676d15925d9667aeda0', // Replace with your mobilesdk_app_id
      messagingSenderId: '809810494177', // Replace 'YOUR_SENDER_ID' with your messaging sender ID
      projectId: 'save-lives-a7e08', // Replace with your project ID
      storageBucket: 'save-lives-a7e08.appspot.com', // Replace with your storage bucket
      
  );

  



 
}
