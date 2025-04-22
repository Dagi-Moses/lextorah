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

class _ChatHomeScreenState extends State<ChatHomeScreen>
    with AutomaticKeepAliveClientMixin<ChatHomeScreen> {
  @override
  bool get wantKeepAlive => true; // Ensures the screen is kept alive when switching between tabs.

  // list of screens
  final List<Widget> _screens = [
    const ChatHistoryScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[400],
          body: PageView(
            controller: chatProvider.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
            // onPageChanged: (index) {
            //   chatProvider.navigate(index);
            // },
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
            provider.navigate(index);
          },
          tooltip: "", // avoid showing label on hover
        );
      }),
    ),
  );
}
