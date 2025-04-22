import 'package:Lextorah/Home/components/customButton.dart';
import 'package:Lextorah/Home/components/customTextField.dart';
import 'package:Lextorah/providers/email_provider.dart';
import 'package:Lextorah/utils/fadeanimation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formkey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final emailProvider = Provider.of<EmailProvider>(context);

    void Continue() {
      if (_formkey.currentState!.validate()) {
        String email = emailController.text.trim();

        emailProvider.sendPasswordResetEmail(email: email);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child:
                    emailProvider.isLinkSent
                        ? Card(
                          key: ValueKey('sentCard'),
                          elevation: 10,
                          color: Colors.white,
                          child: Container(
                            width: 400,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: () {
                                      emailProvider.isLinkSent =
                                          false; // Reset the flag
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                      color:
                                          Colors
                                              .green, // Adjust color as needed
                                    ),
                                  ),
                                ),
                                // T
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.email,
                                        size: 50.0,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Link sent! If the email is registered with us, you will get a link to reset your password.", // "Link sent, if the email is registered with us you will get a link to reset your password"
                                        style: TextStyle(
                                          color: Colors.black,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : Card(
                          elevation: 10,
                          color: Colors.white,
                          child: Container(
                            width: 400,
                            padding: const EdgeInsets.all(40.0),
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
                                Text(
                                  "Let us help you",
                                  style: TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Form(
                                  key: _formkey,
                                  child: CustomTextField(
                                    errorText: emailProvider.errorMessage,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    onSubmitted: (_) {
                                      Continue();
                                    },
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
                                    controller: emailController,
                                  ),
                                ),
                                const SizedBox(height: 25),

                                CustomButton(
                                  buttonText: "Continue",
                                  onPressed: () {
                                    Continue();
                                  },
                                  isLoading: emailProvider.isLoading,
                                  backgroundColor: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Want to try again? ",
                    style: TextStyle(color: Colors.black, letterSpacing: 0.5),
                  ),
                  GestureDetector(
                    onTap: () {
                      emailProvider.isLinkSent = false;
                      emailProvider.errorMessage = null;
                      emailController.clear();
                      GoRouter.of(context).pop();
                      //  Navigator.pop(context);
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.blue,
                        decorationColor: Colors.blue,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
