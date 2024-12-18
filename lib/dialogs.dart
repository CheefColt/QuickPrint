// lib/dialogs.dart
import 'package:flutter/material.dart';

void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Custom Dialog', style: Theme.of(context).textTheme.bodyLarge),
        content: Text('This is a custom dialog.', style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      );
    },
  );
}