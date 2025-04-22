import 'dart:developer';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Lextorah/hive/boxes.dart';
import 'package:Lextorah/hive/settings.dart';
import 'package:Lextorah/providers/settings_provider.dart';

import 'package:Lextorah/widgets/settings_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(
        backgroundColor: Colors.grey[400],
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,

        // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ValueListenableBuilder<Box<Settings>>(
                valueListenable: Boxes.getSettings().listenable(),
                builder: (context, box, child) {
                  if (box.isEmpty) {
                    return Column(
                      children: [
                        // ai voice
                        SettingsTile(
                          // icon: Icons.mic,
                          icon: CupertinoIcons.mic,
                          title: 'Enable AI voice',
                          value: false,
                          onChanged: (value) {
                            final settingProvider =
                                context.read<SettingsProvider>();
                            settingProvider.toggleSpeak(value: value);
                          },
                        ),

                        const SizedBox(height: 10.0),

                        // Theme
                        SettingsTile(
                          // icon: Icons.light_mode,
                          icon: CupertinoIcons.sun_max,
                          title: 'Theme',
                          value: false,
                          onChanged: (value) {
                            final settingProvider =
                                context.read<SettingsProvider>();
                            settingProvider.toggleDarkMode(value: value);
                          },
                        ),
                      ],
                    );
                  } else {
                    final settings = box.getAt(0);
                    return Column(
                      children: [
                        // ai voice
                        SettingsTile(
                          icon: CupertinoIcons.mic,
                          title: 'Enable AI voice',
                          value: settings!.shouldSpeak,
                          onChanged: (value) {
                            final settingProvider =
                                context.read<SettingsProvider>();
                            settingProvider.toggleSpeak(value: value);
                          },
                        ),

                        const SizedBox(height: 10.0),

                        // theme
                        SettingsTile(
                          icon:
                              settings.isDarkTheme
                                  ? CupertinoIcons.moon_fill
                                  : CupertinoIcons.sun_max_fill,
                          title: 'Theme',
                          value: settings.isDarkTheme,
                          onChanged: (value) {
                            final settingProvider =
                                context.read<SettingsProvider>();
                            settingProvider.toggleDarkMode(value: value);
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
