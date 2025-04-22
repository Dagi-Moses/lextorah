import 'package:Lextorah/models/student.dart';
import 'package:Lextorah/providers/register_provider.dart';

import 'package:flutter/material.dart';

class RegisterController {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void register(BuildContext context, RegistrationProvider regProvider) {
    if (regProvider.isLoading) return;
    final user = Student(
      email: emailController.text,
      fullName: nameController.text,
      phoneNumber: phoneController.text,
      id: "",
    );
    if (formKey.currentState!.validate()) {
      regProvider.sendOtp(
        email: emailController.text,
        user: user,
        password: passwordController.text,
        isResend: false,
        context: context,
      );
    }
  }

  void dispose() {
    emailFocusNode.dispose();
    phoneFocusNode.dispose();

    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();

    emailController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    passwordController.dispose();
  }
}
