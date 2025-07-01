import 'package:flutter/material.dart';

Future<dynamic> customPopUp(BuildContext context,String title, String description, TextButton button) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          button
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      );
    },
  );
}
