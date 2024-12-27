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

  apiKey:
  authDomain: 
  projectId: 
  storageBucket: 
  messagingSenderId:
  appId:
  );

  static const FirebaseOptions android = FirebaseOptions(
    // Android configuration
    apiKey:  // Replace 'YOUR_API_KEY' with the actual API key from the JSON
      appId: // Replace with your mobilesdk_app_id
      messagingSenderId:  // Replace 'YOUR_SENDER_ID' with your messaging sender ID
      projectId:  // Replace with your project ID
      storageBucket:  // Replace with your storage bucket
      
  );

  



 
}
