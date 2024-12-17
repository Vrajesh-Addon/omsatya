import 'package:flutter/material.dart';

// #region Constants
class AppStrings {
  // General Messages
  static const noInternet = "Please check your network connection";
  static const errorMessage = "Something went wrong. Try again later.";
  static const permissionDenied = "You don't have permission, Access denied.";
  static const notFound = "Record(s) not found.";
  static const selectRecord = "Select atleast one record.";
  static const deleteRecord = "Delete selected record?";
  static const exitApp = "Press again to exit.";
  static const cartDeleteMessage = "Confirm removal of this product from your cart?";
}

class AppDimen {
  static const double smallDeviceWidth = 600;
  static const double mediumDeviceWidth = 900;
  static const double largeDeviceWidth = 1200;

  static const double screenContentMaxWidth = 500;
  static const double screenPadding = 16;

  static const Offset shadowOffset = Offset(0, 0);
  static const double shadowBlurRadius = 8.0;

  static double roundedBorderRadius = 8.0;
  static const BorderRadius customBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(40.0), bottomRight: Radius.circular(40.0));

  static const double iconRadius = 60.0;
  static const double logoIconSize = 185.0;
  static const double iconSize = 48.0;

  static const EdgeInsets buttonPadding = EdgeInsets.all(16.0);
  static const BorderRadius buttonRadius =
      BorderRadius.all(Radius.circular(8.0));

  static const double textLeftRightPadding = 20.0;
  static const double textTopBottomPadding = 16.0;
  static const double textRadius = 8.0;

  static const EdgeInsets dropdownPadding =
      EdgeInsets.only(left: 12.0, top: 4.0, right: 12.0, bottom: 4.0);

  static const EdgeInsets listItemPadding =
      EdgeInsets.only(left: 16.0, top: 8.0, right: 4.0, bottom: 8.0);

  static const double paddingExtraSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double padding = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double marginExtraSmall = 4.0;
  static const double marginSmall = 8.0;
  static const double margin = 16.0;
  static const double marginLarge = 24.0;
  static const double marginExtraLarge = 32.0;
}
// #endregion

// #region Enums
enum ScreenOrientation {
  portrait,
  landscape,
  both,
}

enum SpaceType {
  extraSmall,
  small,
  medium,
  large,
  extraLarge,
}

enum LoadingType {
  circular,
  screen,
  image,
}

enum MessageType {
  none,
  success,
  error,
  warning,
  info,
}

enum DialogResult {
  none,
  ok,
  cancel,
  abort,
  retry,
  ignore,
  yes,
  no,
}
// #endregion

class UserRole {
  static const int customer = 4;
  static const int driver = 5;
}

class CategoryType {
  static const int learning = 1;
  static const int working = 2;
}
