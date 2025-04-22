import 'dart:async';

import 'package:Lextorah/Home/components/otpCard.dart';

import 'package:Lextorah/providers/register_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PinCodeVerificationScreen extends StatefulWidget {
  final String? email;

  const PinCodeVerificationScreen({Key? key, this.email}) : super(key: key);
  @override
  State<PinCodeVerificationScreen> createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regProvider = Provider.of<RegistrationProvider>(context);
    return OtpCard(
      errorMessage: regProvider.errorMessage,
      onChanged: (value) {
        regProvider.currentText = value;
      },
      email: widget.email,
      formKey: formKey,
      errorController: errorController,
      textEditingController: textEditingController,
      onCompleted: (v) {
        regProvider.verifyOtp(
          context: context,
          errorController: errorController,
        );
      },
      isRegLinkSent: regProvider.isRegLinkSent,
      isRegister: true,
      onRegLinkSent: regProvider.onRegLinkSent,
      isRegLinkLoading: regProvider.isLinkLoading,

      onRegTap: () {
        regProvider.isRegLinkSent = false; // Reset the flag
      },
      hasError: regProvider.hasError,
      isLoading: regProvider.isLoading,
      onResend: () async {
        await regProvider.sendOtp(
          email: widget.email ?? "",
          resendController: textEditingController,
          isResend: true,

          context: context,
        );
      },
      currentText: regProvider.currentText,
    );
  }
}
