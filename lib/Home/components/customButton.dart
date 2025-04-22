import 'package:Lextorah/utils/fadeanimation.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText; // Button text
  final VoidCallback? onPressed; // Action when pressed
  final bool isLoading; // Show loading spinner or not
  final Color backgroundColor; // Background color of button
  final EdgeInsetsGeometry padding; // Button padding
  final double borderRadius; // Button border radius

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isLoading = false, // Default to false (not loading)
    this.backgroundColor = Colors.green, // Default color
    this.padding = const EdgeInsets.symmetric(
      vertical: 14.0,
      horizontal: 80,
    ), // Default padding
    this.borderRadius = 12.0, // Default border radius
  });

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: 1,
      child: TextButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.5,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
