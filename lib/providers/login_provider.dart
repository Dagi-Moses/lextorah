import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? _loginErrorMsg;
  String? get loginErrorMsg => _loginErrorMsg;

  set loginErrorMsg(String? value) {
    _loginErrorMsg = value;
    notifyListeners();
  }

  String? _registerErrorMsg;
  String? get registerErrorMsg => _registerErrorMsg;

  set registerErrorMsg(String? value) {
    _registerErrorMsg = value;
    notifyListeners();
  }

  Future<void> storeAuthToken(String authToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('auth_token', authToken);
  }

  Future<void> signInUser({
    required String studentId,
    required String password,
    required BuildContext context,
  }) async {
    try {
      loginErrorMsg = null;
      isLoading = true;
      // Look up the email associated with the student ID
      final studentSnapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .where('studentId', isEqualTo: studentId.trim())
              .limit(1)
              .get();

      if (studentSnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'student-not-found',
          message: 'No account found for this student ID.',
        );
      }

      final email = studentSnapshot.docs.first['email'] as String;

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(Duration(seconds: 90));

      openLink("https://lextorah-elearning.com/");
      storeAuthToken(userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Invalid Email";
          break;

        case 'wrong-password':
          errorMessage = "Incorrect PassWord";
          break;
        case 'user-not-found':
          errorMessage = "User not found";
          break;
        case 'network-request-failed':
          errorMessage =
              "Network request failed, check ur internet and try again";
          break;
        default:
          errorMessage = "An unexpected error occured, please try again";
      }
      loginErrorMsg = errorMessage;
    } on TimeoutException {
      Fluttertoast.showToast(
        toastLength: Toast.LENGTH_LONG,
        msg: "Please check ur internet connection and try again",
      );
      loginErrorMsg = "Network request failed, check ur internet and try again";
    } catch (e) {
      print("login error: ${e.toString()}");
      Fluttertoast.showToast(toastLength: Toast.LENGTH_LONG, msg: e.toString());
    } finally {
      isLoading = false;
    }
  }

  Future<String> getUserImage() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot snap =
        await _firestore.collection('students').doc(uid).get();
    String image = (snap.data()! as dynamic)['profileImage'];
    return image;
  }

  Future<void> openLink(url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), webOnlyWindowName: '_self');
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print("Error launching URL: $e");
    }
  }
}
