import 'package:Lextorah/utils/screen_helper.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  final Widget child;
  final Widget chatbot;

  const AdminHome({super.key, required this.child, required this.chatbot});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  bool _isModalOpen = false; // Track modal open state

  // Open chatbot modal for mobile and tablet
  void _openChatBot(BuildContext context) {
    if (ScreenHelper.isMobile(context) || ScreenHelper.isTablet(context)) {
      showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            height: MediaQuery.of(context).size.height * 0.7,
            child: widget.chatbot,
          );
        },
      ).whenComplete(() {
        setState(() {
          _isModalOpen = false;
        });
      });

      setState(() {
        _isModalOpen = true;
      });
    }
  }

  // Close the modal when the screen is resized to desktop
  void _checkAndCloseModal(BuildContext context) {
    // Check if the modal is open and if the screen is resized to tablet or desktop
    if ((_isModalOpen) &&
        (ScreenHelper.isTablet(context) || ScreenHelper.isDesktop(context))) {
      Navigator.of(context).pop(); // Close the modal
      setState(() {
        _isModalOpen = false; // Reset modal state
      });
    }
  }

  bool _isDrawerOpen = false; // Track drawer state

  void _toggleChatBot(BuildContext context) {
    _isDrawerOpen = !_isDrawerOpen;
    (context as Element).markNeedsBuild(); // Force a rebuild to show changes
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to close the modal when screen size changes
    _checkAndCloseModal(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 100),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ScreenHelper(
          mobile: _mobileLayout(context),
          tablet: _tabletLayout(context),
          desktop: _desktopLayout(context),
        ),
      ),
    );
  }

  // Mobile Layout: Chatbot as a FAB (Floating Action Button)
  Widget _mobileLayout(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: 10,
          right: 10,
          child: FloatingActionButton(
            focusElevation: 10,
            elevation: 2,
            mini: true,
            tooltip: 'Your AI Tutor',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () {
              _openChatBot(context);
            },
            backgroundColor: Colors.green,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.chat, color: Colors.white, size: 25),
            ),
          ),
        ),
      ],
    );
  }

  // Tablet Layout: Chatbot at the bottom as a sticky footer
  Widget _tabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: widget.child), // Main content
        GestureDetector(
          onTap: () {
            _toggleChatBot(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 250 : 40, // Narrow when closed
            padding: EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child:
                _isDrawerOpen
                    ? widget.chatbot
                    : Center(
                      child: Icon(
                        Icons.chat,
                        color: Colors.green[700],
                        size: 30,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 15, child: widget.child),
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              color: Colors.grey[400],
            ),
            child: widget.chatbot,
          ),
        ),
      ],
    );
  }
}
