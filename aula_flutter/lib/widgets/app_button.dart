import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: icon != null
          ? ElevatedButton.icon(
              icon: Icon(icon, size: 20),
              label: Text(text),
              onPressed: onPressed,
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(text),
            ),
    );
  }
}