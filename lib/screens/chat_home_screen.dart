import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Lextorah/providers/chat_provider.dart';
import 'package:Lextorah/screens/chat_history_screen.dart';
import 'package:Lextorah/screens/chat_screen.dart';
import 'package:Lextorah/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  // list of screens
  final List<Widget> _screens = [
    const ChatHistoryScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[400],
          body: PageView(
            controller: chatProvider.pageController,
            children: _screens,
            onPageChanged: (index) {
              chatProvider.setCurrentIndex(newIndex: index);
            },
          ),
          bottomNavigationBar: customBottomNav(context, chatProvider),
        );
      },
    );
  }
}

Widget customBottomNav(BuildContext context, ChatProvider provider) {
  final icons = [
    Icons.history,
    CupertinoIcons.chat_bubble,
    CupertinoIcons.settings,
  ];

  return Container(
    decoration: BoxDecoration(
      color: Colors.grey[400],
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(icons.length, (index) {
        final isActive = provider.currentIndex == index;
        return IconButton(
          icon: Icon(
            icons[index],
            color: isActive ? Colors.green : Colors.black45,
            size: 25,
          ),
          onPressed: () {
            provider.setCurrentIndex(newIndex: index);
            provider.pageController.jumpToPage(index);
          },
          tooltip: "", // avoid showing label on hover
        );
      }),
    ),
  );
}
