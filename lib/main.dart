import 'package:Lextorah/providers/chat_provider.dart';
import 'package:Lextorah/providers/email_provider.dart';
import 'package:Lextorah/providers/login_provider.dart';
import 'package:Lextorah/providers/register_provider.dart';
import 'package:Lextorah/providers/settings_provider.dart';
import 'package:Lextorah/themes/my_theme.dart';
import 'package:Lextorah/utils/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ChatProvider.initHive();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => RegistrationProvider()),
        ChangeNotifierProvider(create: (context) => EmailProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => LoginProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    setTheme();
    super.initState();
  }

  void setTheme() {
    final settingsProvider = context.read<SettingsProvider>();
    settingsProvider.getSavedSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lextorah',
      debugShowCheckedModeBanner: false,
      theme:
          context.watch<SettingsProvider>().isDarkMode ? darkTheme : lightTheme,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
