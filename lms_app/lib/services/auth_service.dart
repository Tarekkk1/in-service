import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms_app/services/device_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lms_app/utils/snackbars.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<User?> userSteam = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> loginWithEmailPassword(BuildContext context, String email, String password) async {
    try {
      // Get current device ID
      final currentDeviceId = await DeviceService.getDeviceId();
      
      // Get user document from Firestore first to check device ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userData = userDoc.docs.first.data();
        final storedDeviceId = userData['device_id'];

        // If device ID exists and doesn't match
        if (userData['email'] != 'tarekzeyad31@yahoo.com' && storedDeviceId != null && storedDeviceId != currentDeviceId) {
          if (!context.mounted) return null;
          openSnackbarFailure(context, 'This account can only be accessed from the original device');
          return null;
        }
      }

      // Proceed with login
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      // If this is first login (no device ID stored), save the current device ID
      if (userDoc.docs.isEmpty || userDoc.docs.first.data()['device_id'] == null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'device_id': currentDeviceId});
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('error: $e');
      if (!context.mounted) return null;
      openSnackbarFailure(context, e.message);
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    // Check device ID
    final currentDeviceId = await DeviceService.getDeviceId();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: googleUser.email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final userData = userDoc.docs.first.data();
      final storedDeviceId = userData['device_id'];
      
      if (userData['email'] != 'tarekzeyad31@yahoo.com' && storedDeviceId != null && storedDeviceId != currentDeviceId) {
        throw FirebaseAuthException(
          code: 'wrong-device',
          message: 'This account can only be accessed from the original device'
        );
      }
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    
    // If first login, save device ID
    if (userDoc.docs.isEmpty || userDoc.docs.first.data()['device_id'] == null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'device_id': currentDeviceId});
    }
    
    return userCredential;
  }

  Future<UserCredential?> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status != LoginStatus.success) return null;

    // Get Facebook user data to check email
    final userData = await FacebookAuth.instance.getUserData();
    final email = userData['email'];

    // Check device ID
    final currentDeviceId = await DeviceService.getDeviceId();
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (userDoc.docs.isNotEmpty) {
      final userData = userDoc.docs.first.data();
      final storedDeviceId = userData['device_id'];
      
      if (userData['email'] != 'tarekzeyad31@yahoo.com' && storedDeviceId != null && storedDeviceId != currentDeviceId) {
        throw FirebaseAuthException(
          code: 'wrong-device',
          message: 'This account can only be accessed from the original device'
        );
      }
    }

    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
    final userCredential = await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    
    // If first login, save device ID
    if (userDoc.docs.isEmpty || userDoc.docs.first.data()['device_id'] == null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({'device_id': currentDeviceId});
    }
    
    return userCredential;
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  Future userLogOut() async {
    if (user != null) {
      await _firebaseAuth.signOut();
    } else {
      debugPrint('Not signed in');
    }
  }

  Future googleLogout() async {
    final bool isSignedIn = await googleSignIn.isSignedIn();
    if (isSignedIn) {
      await googleSignIn.signOut();
    }
  }

  Future<UserCredential?> signUpWithEmailPassword(BuildContext context, String email, String password) async {
    UserCredential? user;
    try {
      user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint('error: e');
      if (!context.mounted) return null;
      openSnackbarFailure(context, e.message);
    }
    return user;
  }

  Future deleteUserAuth() async {
    await user?.delete().catchError((e) {
      debugPrint('error on deleting account');
      Fluttertoast.showToast(msg: e);
    });
  }

  Future sendEmailVerification() async {
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.sendEmailVerification().catchError((e) => debugPrint('Email sending failed'));
    }
  }

  Future sendPasswordRestEmail(BuildContext context, String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      openSnackbar(context, 'An email has been sent to $email. Go to that link & reset your password.');
    } on FirebaseAuthException catch (error) {
      if (!context.mounted) return;
      openSnackbarFailure(context, error.message);
    }
  }
}
