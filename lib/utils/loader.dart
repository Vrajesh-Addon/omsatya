import 'package:flutter/material.dart';

class Loader {
  static BuildContext? _context;

  static show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        Loader._context = context;
        return const AlertDialog(
            content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(
              width: 10,
            ),
            Text("Please wait..."),
          ],
        ));
      },
    );
  }

  static close() {
    if (Loader._context != null) {
      Navigator.of(Loader._context!).pop();
    }
  }

  static Widget bottomLoading(bool value) {
    return value
        ? Container(
            alignment: Alignment.center,
            child: const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
          )
        : const SizedBox(
            height: 5,
            width: 5,
          );
  }
}
