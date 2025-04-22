import 'dart:async';
import 'package:Lextorah/apis/api_service.dart';
import 'package:Lextorah/constants/constants.dart';
import 'package:Lextorah/utils/routes.dart';
import 'package:Lextorah/widgets/snackBar.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';

class EmailProvider with ChangeNotifier {
  //FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _hasError = false;
  bool get hasError => _hasError;
  set hasError(bool value) {
    _hasError = value;
    notifyListeners();
  }

  String _currentText = "";
  String get currentText => _currentText;
  set currentText(String value) {
    _currentText = value;
    notifyListeners();
  }

  bool _isLinkSent = false;

  bool get isLinkSent => _isLinkSent;

  set isLinkSent(bool value) {
    _isLinkSent = value;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    isLoading = true;

    try {
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        isLinkSent = true;
      } else {
        errorMessage = "No account found with this email.";
      }
    } catch (e) {
      errorMessage = "An error occurred while sending the reset email.";
      print("Error: $e");
    } finally {
      isLoading = false;
    }
  }

  Future<void> verifyOtp(
    String email,
    BuildContext context,
    StreamController<ErrorAnimationType>? errorController,
  ) async {
    isLoading = true;

    try {
      final response = await http.post(
        Uri.parse('${ApiService.serverUrl}/verify-otp'), // Backend API endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': _currentText}),
      );
      print("response: ${response.body.toString()}");
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final customToken =
            responseBody['customToken']
                as String?; // The custom token sent from the server
        if (customToken != null) {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCustomToken(customToken);
          Navigator.of(context).pushNamed(AppRouteName.home);
          //  firebaseFunctions.storeAuthToken(userCredential.user!.uid);
          errorMessage = null;
        } else {
          errorMessage = "Failed to sign in with custom token.";
          errorController!.add(
            ErrorAnimationType.shake,
          ); // Trigger shake animation
        }
      } else {
        errorMessage = "Invalid OTP or OTP expired.";
        errorController!.add(
          ErrorAnimationType.shake,
        ); // Trigger shake animation
      }
    } catch (error) {
      errorMessage = "An error occurred. Please try again.";
      errorController!.add(ErrorAnimationType.shake); // Trigger shake animation
      print("Error: ${error}");
    } finally {
      isLoading = false;
    }
  }
}
