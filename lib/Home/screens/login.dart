import 'package:Lextorah/Home/components/customButton.dart';
import 'package:Lextorah/Home/components/customTextField.dart';
import 'package:Lextorah/providers/login_provider.dart';

import 'package:Lextorah/utils/fadeanimation.dart';

import 'package:Lextorah/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Create FocusNodes for both text fields
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  final _formkey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void _submitForm(LoginProvider loginProvider) {
    if (_formkey.currentState!.validate()) {
      loginProvider.signInUser(
        studentId: emailController.text.trim(),
        password: passwordController.text.trim(),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to lextorah - school of languages",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center, // Ensure the text is centered
                ),
                const SizedBox(height: 5),
                const Text(
                  "Get answers to your academic questions instantly",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center, // Ensure the text is centered
                ),
                const SizedBox(height: 5),
                Card(
                  elevation: 10,
                  color: Colors.white,
                  child: Container(
                    width: 400,
                    padding: EdgeInsets.only(
                      left: 40,
                      right: 40,
                      top: 40,
                      bottom: 30,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeAnimation(
                          delay: 0.8,
                          child: Image.network(
                            "https://cdni.iconscout.com/illustration/premium/thumb/job-starting-date-2537382-2146478.png",
                            width: 100,
                            height: 100,
                          ),
                        ),
                        SizedBox(height: 10),
                        FadeAnimation(
                          delay: 1,
                          child: const Text(
                            "Please sign in to continue",
                            style: TextStyle(
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          focusNode: _emailFocusNode,
                          errorText: null,
                          label: 'Student ID',
                          icon: Icons.email_outlined,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Student ID';
                            }
                            return null;
                          },
                          onSubmitted: (_) {
                            // Move to next field when "Enter" is pressed
                            FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocusNode);
                          },
                          controller: emailController,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          focusNode: _passwordFocusNode,
                          errorText: null,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          showSuffixIcon: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          onSubmitted: (_) {
                            _submitForm(loginProvider);
                          },
                        ),
                        SizedBox(height: 5),
                        loginProvider.loginErrorMsg != null
                            ? Text(
                              loginProvider.loginErrorMsg!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                letterSpacing: 0.5,
                              ),
                            )
                            : SizedBox(),
                        const SizedBox(height: 20),
                        CustomButton(
                          buttonText: "Login",
                          onPressed: () {
                            _submitForm(loginProvider);
                          },
                          isLoading: loginProvider.isLoading,
                          backgroundColor: Colors.green,
                        ),
                        Flexible(child: SizedBox(height: 10)),
                        FadeAnimation(
                          delay: 1,
                          child: GestureDetector(
                            onTap: (() {
                              context.go(AppRoutePath.forgotPassword);
                            }),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.blue.withOpacity(0.9),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //End of Center Card
                //Start of outer card
                SizedBox(height: 10),
                FadeAnimation(
                  delay: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go(AppRoutePath.signup);
                        },
                        child: Text(
                          "Sign up",

                          style: TextStyle(
                            color: Colors.blue.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
