import 'package:firebase_auth/firebase_auth.dart';
import 'package:time_of_mine/services/firestore_service.dart'; // Cloud Firestore operations
import 'package:time_of_mine/services/local_storage_service.dart'; // Local data storage/cleanup

// Service for authentication and user profile management
class AuthService {
  // Singleton instance of FirebaseAuth
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current signed-in user (nullable)
  static User? get currentUser => _auth.currentUser;

  // Stream to listen to authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Map FirebaseAuthException codes to human-readable messages
  static String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already registered";
      case 'invalid-email':
        return "Invalid email format";
      case 'weak-password':
        return "Password is too weak (min 6 characters)";
      case 'user-not-found':
        return "No user found with this email";
      case 'wrong-password':
        return "Incorrect password";
      default:
        return e.message ?? "Authentication error";
    }
  }

  // Sign up a new user (guest or email/password)
  static Future<String?> signUp({
    required bool isGuest,
    String? email,
    String? password,
    String? name,
  }) async {
    try {
      if (isGuest) {
        // Anonymous login for guest users
        await _auth.signInAnonymously();
      } else {
        if (email == null || password == null) {
          return "Email and password are required";
        }
        // Create a new user account
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Set display name
        await userCredential.user?.updateDisplayName(name);
        await userCredential.user?.reload(); // Refresh user info
      }
      return null; // No error
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e); // Return mapped error message
    } catch (e) {
      return e.toString(); // Generic error
    }
  }

  // Sign in an existing user
  static Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out the user
  static Future<void> signOut() async {
    await LocalStorageService.clearUserData(); // Clear local storage
    await _auth.signOut(); // Firebase sign-out
  }

  // Update user display name
  static Future<String?> updateProfile({required String displayName}) async {
    try {
      final user = currentUser;
      if (user == null) return "User not found";

      await user.updateDisplayName(displayName); // Change display name
      await user.reload(); // Refresh info
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Update user password after reauthentication
  static Future<String?> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) return "User not found";

      // Reauthenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential); // Ensure recent login
      await user.updatePassword(newPassword); // Update password
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e);
    } catch (e) {
      return e.toString();
    }
  }

  // Delete the current user account
  static Future<String?> deleteAccount({String? password}) async {
    try {
      final user = currentUser;
      if (user == null) return "User not found";

      // If user is not anonymous, reauthenticate first
      if (!user.isAnonymous && password != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Clear local data and cloud data
      await LocalStorageService.clearUserData();
      await FirestoreService.deleteAllCloudData();

      // Delete Firebase account
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Firebase requires recent login to delete account
        return "Please reauthenticate before deleting your account.";
      }
      return _mapFirebaseError(e);
    } catch (e) {
      return e.toString();
    }
  }
}
