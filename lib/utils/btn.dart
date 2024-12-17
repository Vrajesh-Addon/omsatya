import "package:flutter/material.dart";
import 'package:omsatya/utils/app_colors.dart';

class Btn {
  static Widget basic(
      {color = const Color.fromARGB(0, 0, 0, 0),
        shape = const RoundedRectangleBorder(),
        child = const SizedBox(),
        EdgeInsets padding = EdgeInsets.zero,
        dynamic minWidth,
        dynamic minHeight = 10,
        dynamic onPressed}) {
    //if (width != null && height != null)
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: Colors.transparent,
          padding: padding,
          backgroundColor: color,
          minimumSize: minWidth == null ? null : Size(minWidth.toDouble(), minHeight.toDouble()),

          shape: shape),
      child: child,
      onPressed: onPressed ?? () {},
    );
  }

  static Widget minWidthFixHeight(
      {required minWidth,
        required double height,
        color,
        shape,
        required child,
        dynamic onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(

          foregroundColor: Colors.transparent,
          minimumSize: Size(minWidth.toDouble(), height.toDouble()),
          backgroundColor: onPressed != null ? color : AppColors.grey153,
          shape: shape,
          disabledForegroundColor: Colors.blue),
      child: child,
      onPressed: onPressed,
    );
  }

  static Widget maxWidthFixHeight(
      {required maxWidth, required height, color, shape, required child, dynamic onPressed}) {
    return TextButton(
      style: TextButton.styleFrom(
          foregroundColor: Colors.transparent, maximumSize: Size(maxWidth, height),
          backgroundColor: color,
          shape: shape),
      child: child,
      onPressed: onPressed,
    );
  }
}
