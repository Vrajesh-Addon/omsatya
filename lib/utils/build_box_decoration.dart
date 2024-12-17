import 'package:flutter/material.dart';

class BoxDecorations {
  static BoxDecoration buildBoxDecoration_1({double radius =6.0}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 20,
          spreadRadius: 0.0,
          offset: const Offset(0.0, 10.0), // shadow direction: bottom right
        )
      ],
    );
  }

  static BoxDecoration buildBoxDecoration_2({double radius =6.0}) {
    return BoxDecoration(
      // borderRadius: BorderRadius.circular(radius),
      color: Colors.white,
      boxShadow: [
        BoxShadow( // Top shadow
          color: Colors.grey.withOpacity(0.2), // Adjust color and opacity
          offset: const Offset(0.0, -5.0), // Move shadow upwards (negative y-offset)
          blurRadius: 0.0, // Adjust blur radius for softness
          spreadRadius: 0.0,
        ),
        BoxShadow( // Bottom shadow
          color: Colors.grey.withOpacity(0.2), // Adjust color and opacity
          offset: const Offset(0.0, 5.0), // Move shadow downwards
          blurRadius: 0.0, // Adjust blur radius for softness
          spreadRadius: 0.0,
        ),
      ],
    );
  }

  static BoxDecoration buildCartCircularButtonDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.0),
      color:  const Color.fromRGBO(229,241,248, 1),

    );
  }

  static BoxDecoration buildCircularButtonDecoration_1() {
    return
      BoxDecoration(
        borderRadius: BorderRadius.circular(36.0),
        color: Colors.white.withOpacity(.80),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            spreadRadius: 0.0,
            offset: const Offset(0.0, 10.0), // shadow direction: bottom right
          )
        ],
      );
  }
}
