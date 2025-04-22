import 'dart:developer';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Lextorah/hive/boxes.dart';
import 'package:Lextorah/hive/settings.dart';
import 'package:Lextorah/providers/settings_provider.dart';
import 'package:Lextorah/widgets/build_display_image.dart';
import 'package:Lextorah/widgets/settings_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // File? file;
  String userImage = '';
  String userName = 'user';
  // final ImagePicker _picker = ImagePicker();

  // pick an image

  Uint8List? fileBytes; // For web

  void pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // important for web!
      );

      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.first;

        setState(() {
          fileBytes = picked.bytes; // For web preview via Image.memory
        });
      }
    } catch (e) {
      log('error: $e');
    }
  }

  // get user data
  void getUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // get user data fro box
      final userBox = Boxes.getUser();

      // check is user data is not empty
      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        setState(() {
          userImage = user!.name;
          userName = user.image;
        });
      }
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

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
              Center(
                child: BuildDisplayImage(
                  fileBytes: fileBytes,
                  userImage: userImage,
                  onPressed: () {
                    // open camera or gallery
                    pickImage();
                  },
                ),
              ),

              const SizedBox(height: 20.0),

              // user name
              Text(userName, style: Theme.of(context).textTheme.titleSmall),

              const SizedBox(height: 40.0),

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
