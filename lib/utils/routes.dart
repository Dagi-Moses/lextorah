import 'package:Lextorah/Home/screens/forgot_password.dart';
import 'package:Lextorah/Home/screens/login.dart';
import 'package:Lextorah/Home/screens/pin_code.dart';
import 'package:Lextorah/Home/screens/signup.dart';
import 'package:Lextorah/screens/chat_home_screen.dart';
import 'package:Lextorah/screens/errorScreen.dart';
import 'package:Lextorah/screens/mainView.dart';
import 'package:Lextorah/screens/splashScreen.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouteName {
  static const home = 'home';
  static const forgotPassword = 'forgotPassword';
  static const otpVerification = 'verify-otp';
  static const signup = 'signup';

  static const splash = 'splash';
  static const errorScreen = 'error';
}

abstract class AppRoutePath {
  static const home = '/home';
  static const forgotPassword = '$home/forgotPassword';
  static const otpVerification = '$home/verify-otp/:email';
  static const signup = '/signup';

  static const splash = '/splash';
  static const errorScreen = '/error/:message';
}

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutePath.home,
      errorBuilder:
          (context, state) => const ErrorScreen(message: "Page not found"),
      redirect: (context, state) {
        final isAuthenticated =
            true; // Replace with actual authentication check

        if (isAuthenticated && state.matchedLocation == AppRoutePath.home) {
          return state.uri.toString() == AppRoutePath.home
              ? AppRoutePath.home
              : state.uri.toString();
        }
        return null;
      },
      routes: [
        // Shell Route for Persistent Admin Home
        ShellRoute(
          builder:
              (context, state, child) => AdminHome(
                child: child,
                chatbot: ChatHomeScreen(),
              ), // Pass child to AdminHome
          routes: [
            GoRoute(
              path: AppRoutePath.home,
              name: AppRouteName.home,
              builder: (context, state) => LoginScreen(),
              routes: [
                GoRoute(
                  path: AppRouteName.forgotPassword,
                  name: AppRouteName.forgotPassword,
                  builder: (context, state) => ForgotPasswordScreen(),
                  routes: [],
                ),
                GoRoute(
                  path: 'verify-otp/:email',
                  name: AppRouteName.otpVerification,
                  builder: (context, state) {
                    final email = state.pathParameters['email'];
                    return PinCodeVerificationScreen(email: email);
                  },
                  routes: [],
                ),
              ],
            ),

            GoRoute(
              path: AppRoutePath.signup,
              name: AppRouteName.signup,
              builder: (context, state) => SignupScreen(),
            ),
          ],
        ),

        GoRoute(
          path: AppRoutePath.splash,
          name: AppRouteName.splash,
          builder: (context, state) => SplashScreen(),
        ),

        GoRoute(
          path: AppRoutePath.errorScreen,
          name: AppRouteName.errorScreen,
          builder: (context, state) {
            final message = state.pathParameters["message"]!;
            return ErrorScreen(message: message);
          },
        ),
      ],
    );
  }
}
