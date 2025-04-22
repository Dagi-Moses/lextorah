import 'dart:async';
import 'dart:convert';
import 'package:Lextorah/apis/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Lextorah/models/student.dart';

import 'package:Lextorah/widgets/snackBar.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class RegistrationProvider with ChangeNotifier {
  //FirebaseFunctions firebaseFunctions = FirebaseFunctions();

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  String? _onRegLinkSent;
  String? get onRegLinkSent => _onRegLinkSent;
  set onRegLinkSent(String? value) {
    _onRegLinkSent = value;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isRegLinkSent = false;
  bool get isRegLinkSent => _isRegLinkSent;

  set isRegLinkSent(bool value) {
    _isRegLinkSent = value;
    notifyListeners();
  }

  bool _isLinkLoading = false;
  bool get isLinkLoading => _isLinkLoading;

  set isLinkLoading(bool value) {
    _isLinkLoading = value;
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

  // Future<void> storeAuthToken(String authToken) async {
  //   prefs.setString('auth_token', authToken);
  // }

  // Future<void> sendOtp({
  //   required Student user,
  //   required String password,
  //   TextEditingController? resendController, // Optional parameter
  //   required bool isResend,
  //   required BuildContext context,
  // }) async {
  //   isLoading = true;
  //   errorMessage = null;

  //   try {
  //     if (isResend) {
  //       resendController!.clear();
  //     }
  //     List<String> signInMethods = await FirebaseAuth.instance
  //         .fetchSignInMethodsForEmail(user.email!);
  //     if (signInMethods.isEmpty) {
  //       final response = await http
  //           .post(
  //             Uri.parse('${Constants.serverUrl}/send-otp'),
  //             headers: {'Content-Type': 'application/json'},
  //             body: jsonEncode({'email': user.email?.trim()}),
  //           )
  //           .timeout(
  //             Duration(seconds: 16), // Timeout duration
  //             onTimeout: () {
  //               throw TimeoutException("OTP request timed out");
  //             },
  //           );
  //       print("message + ${response.body}");
  //       if (response.statusCode == 200) {
  //         errorMessage = null;
  //         if (isResend) {
  //           snackBar("OTP Resent", context);
  //         } else {
  //          // context.go(AppRoutePath.otpVerification);

  //           Navigator.pushNamed(
  //             context,
  //             Routes.regCodeVerification,
  //             arguments: RegistrationCodeVerificationArgs(
  //               user: user,
  //               password: password,
  //             ),
  //           );
  //         }
  //       } else {
  //         errorMessage = app.failedToSendOtp;
  //       }
  //     } else {
  //       errorMessage = app.emailAlreadyInUse;
  //     }
  //   } catch (error) {
  //     errorMessage = app.anError;
  //     print(error);
  //   } finally {
  //     isLoading = false;
  //   }
  // }

  Future<void> sendOtp({
    Student? user,
    String? password,
    required String email,
    TextEditingController? resendController,
    required bool isResend,
    required BuildContext context,
  }) async {
    print("Started sending OTP");
    print("User: ${user?.email}");
    isLoading = true;
    errorMessage = null;

    try {
      if (isResend) {
        resendController?.clear();
      }

      // Persist user data
      if (!isResend) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('reg_email', user?.email ?? email.trim());
        await prefs.setString('reg_fullName', user?.fullName ?? "");
        await prefs.setString('reg_phone', user?.phoneNumber ?? "");
        await prefs.setString('reg_password', password!);
      }

      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(user?.email.trim() ?? email.trim());

      if (signInMethods.isEmpty) {
        final response = await http
            .post(
              Uri.parse('${ApiService.serverUrl}/send-otp'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': user?.email.trim() ?? email.trim()}),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw TimeoutException("OTP request timed out"),
            );

        if (response.statusCode == 200) {
          errorMessage = null;
          if (isResend) {
            snackBar("OTP Resent", context);
          } else {
            try {
              Fluttertoast.showToast(msg: "navigating to otp screen");
              final encodedEmail = Uri.encodeComponent(
                user?.email.trim() ?? email.trim(),
              );
              print("Encoded: $encodedEmail");
              context.go('/home/verify-otp/$encodedEmail');
            } catch (e) {
              print("Error: $e");
              Fluttertoast.showToast(msg: e.toString());
            }
          }
        } else {
          errorMessage = "Failed to send OTP. Please try again.";
        }
      } else {
        errorMessage = "email already in use";
      }
    } catch (error) {
      errorMessage = "An error occurred, Please try again";
      if (error is FirebaseException) {
        debugPrint('FirebaseException: ${error.message}');
      } else {
        debugPrint('OTP Error: $error');
      }
    } finally {
      isLoading = false;
      // Optionally update your UI here
    }
  }

  Future<void> verifyOtp({
    required BuildContext context,
    StreamController<ErrorAnimationType>? errorController,
  }) async {
    isLoading = true;
    errorMessage = null;
    isLinkLoading = true;
    onRegLinkSent = "";

    try {
      // Retrieve data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('reg_email') ?? '';
      final fullName = prefs.getString('reg_fullName') ?? '';
      final phone = prefs.getString('reg_phone') ?? '';
      final password = prefs.getString('reg_password') ?? '';

      if (email.isEmpty ||
          fullName.isEmpty ||
          phone.isEmpty ||
          password.isEmpty) {
        errorMessage = "User data is missing. Please restart registration.";
        errorController?.add(ErrorAnimationType.shake);
        isLoading = false;
        return;
      }

      final payload = {
        'email': email.trim(),
        'otp': _currentText.trim(),
        'type': 'register',
        'fullName': fullName.trim(),
        'phoneNumber': phone.trim(),
        'password': password.trim(),
      };

      final response = await http
          .post(
            Uri.parse('${ApiService.serverUrl}/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(
            Duration(seconds: 40), // Timeout duration
            onTimeout: () {
              throw TimeoutException("OTP request timed out");
            },
          );
      print("response: ${response.body.toString()}");
      if (response.statusCode == 200) {
        currentText = '';
        isRegLinkSent = true;
        onRegLinkSent =
            "Account created successfully! \n Your Student ID has been sent to your email.";

        final responseData = jsonDecode(response.body);
        final studentId = responseData['studentId'];

        // Clean up prefs after successful registration
        await prefs.remove('reg_email');
        await prefs.remove('reg_fullName');
        await prefs.remove('reg_phone');
        await prefs.remove('reg_password');

        snackBar(
          "Account created successfully! Student ID sent to your email.",
          context,
        );
        //   context.go(AppRoutePath.home);
      } else {
        errorMessage = "Invalid OTP";
        errorController?.add(
          ErrorAnimationType.shake,
        ); // Trigger shake animation
      }
    } catch (error) {
      errorMessage = "An unexpected error occurred. Please try again.";
      errorController?.add(ErrorAnimationType.shake); // Trigger shake animation
      print("Error: ${error}");
    } finally {
      isLoading = false;
      isLinkLoading = false;
    }
  }
}
