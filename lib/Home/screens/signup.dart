import 'package:Lextorah/Home/components/customButton.dart';
import 'package:Lextorah/Home/components/customTextField.dart';

import 'package:Lextorah/controllers/register_controller.dart';
import 'package:Lextorah/providers/register_provider.dart';
import 'package:Lextorah/utils/fadeanimation.dart';

import 'package:Lextorah/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with AutomaticKeepAliveClientMixin<SignupScreen> {
  RegisterController controller = RegisterController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true; // This is necessary to keep the state alive.

  @override
  Widget build(BuildContext context) {
    final regProvider = Provider.of<RegistrationProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 10,
                color: Colors.white,
                child: Container(
                  width: 400,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Form(
                    key: controller.formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          child: Text(
                            "Create your account",
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        CustomTextField(
                          focusNode: controller.nameFocusNode,
                          errorText: null,
                          label: 'Full Name',
                          icon: Icons.title,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          controller: controller.nameController,
                          onSubmitted: (_) {
                            // Move to next field when "Enter" is pressed
                            FocusScope.of(
                              context,
                            ).requestFocus(controller.phoneFocusNode);
                          },
                        ),

                        SizedBox(height: 15),
                        CustomTextField(
                          focusNode: controller.phoneFocusNode,
                          errorText: null,
                          label: 'Phone Number',
                          icon: Icons.phone_android_rounded,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please enter your phone number";
                            }

                            // Nigerian phone number regex
                            final RegExp phoneRegExp = RegExp(
                              r'^(?:\+234|0)[789][01]\d{8}$',
                            );

                            if (!phoneRegExp.hasMatch(val)) {
                              return "Please enter a valid Nigerian phone number";
                            }

                            return null;
                          },
                          controller: controller.phoneController,
                          onSubmitted: (_) {
                            // Move to next field when "Enter" is pressed
                            FocusScope.of(
                              context,
                            ).requestFocus(controller.emailFocusNode);
                          },
                        ),

                        SizedBox(height: 15),
                        CustomTextField(
                          focusNode: controller.emailFocusNode,
                          errorText: null,
                          label: 'Email',
                          icon: Icons.email_outlined,

                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Email is Required"; // Ensures field is not empty
                            }

                            // Standard email regex validation
                            final RegExp emailRegExp = RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            );

                            if (!emailRegExp.hasMatch(val)) {
                              return "Please enter a valid email address"; // Ensures valid email format
                            }

                            return null;
                          },

                          controller: controller.emailController,
                          onSubmitted: (_) {
                            // Move to next field when "Enter" is pressed
                            FocusScope.of(
                              context,
                            ).requestFocus(controller.passwordFocusNode);
                          },
                        ),

                        SizedBox(height: 15),

                        CustomTextField(
                          focusNode: controller.passwordFocusNode,

                          errorText: null,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          showSuffixIcon: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Password is Required"; // Ensures field is not empty
                            }
                            if (val.length < 6) {
                              return "Password must be up to 6 characters"; // "Password must be more than six characters"
                            }
                            return null;
                          },
                          controller: controller.passwordController,
                          onSubmitted: (_) {
                            FocusScope.of(
                              context,
                            ).requestFocus(controller.confirmPasswordFocusNode);
                          },
                        ),

                        SizedBox(height: 15),

                        CustomTextField(
                          focusNode: controller.confirmPasswordFocusNode,

                          errorText: null,
                          label: 'Confirm Password',
                          icon: Icons.lock_open_outlined,
                          obscureText: true,
                          showSuffixIcon: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Confirm Password is Required"; // Ensures field is not empty
                            }
                            if (val != controller.passwordController.text) {
                              return "Passwords do not match"; // Ensures passwords match
                            }
                            return null;
                          },
                          controller: controller.confirmPasswordController,
                          onSubmitted: (_) {
                            controller.register(context, regProvider);
                          },
                        ),
                        SizedBox(height: 5),
                        regProvider.errorMessage != null
                            ? Text(
                              regProvider.errorMessage!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                letterSpacing: 0.5,
                              ),
                            )
                            : SizedBox(),
                        SizedBox(height: 25),
                        CustomButton(
                          buttonText: "Create Account",
                          onPressed: () {
                            controller.register(context, regProvider);
                          },
                          isLoading: regProvider.isLoading,
                          backgroundColor: Colors.green,
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),

              //End of Center Card
              //Start of outer card
              SizedBox(height: 5),

              FadeAnimation(
                delay: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "If you have an account ",
                      style: TextStyle(color: Colors.grey, letterSpacing: 0.5),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRouteName.home);
                        // GoRouter.of(context).pop();
                      },
                      child: Text(
                        "Sign in",
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
    );
  }
}
