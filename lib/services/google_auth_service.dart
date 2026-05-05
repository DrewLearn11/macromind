// google_auth_service.dart
// Handles all Google Sign-In logic.

import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // Replace with your Web Client ID
  static const String _webClientId =
      '318143221819-6039pii827lo5m7vrml4jd9hbpbfdp4a.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  // Sign in with Google
  // Returns the user's email if successful, null if failed/cancelled
  static Future<Map<String, String>?> signIn() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) return null; // User cancelled

      return {
        'email': account.email,
        'displayName': account.displayName ?? account.email,
        'photoUrl': account.photoUrl ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  // Sign out from Google
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Check if user is already signed in with Google
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }
}