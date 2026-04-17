import 'package:flutter/material.dart';

class ToastHelper {
  static void show(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}