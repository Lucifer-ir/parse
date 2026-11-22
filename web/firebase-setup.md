# Firebase Web / Flutter setup

1. Create Firebase project and register Android and Web apps.
2. Run FlutterFire CLI locally: flutterfire configure; commit/secure config according to Firebase client-config conventions.
3. Add firebase_core and firebase_messaging, initialize Firebase and request notification permission.
4. Register FCM tokens through an authenticated backend endpoint; handle refresh and logout.
5. Firebase Admin credentials must remain server-side.
6. Web push requires HTTPS and a messaging service worker.

This commit adds documentation only; delivery is not active without project credentials.
