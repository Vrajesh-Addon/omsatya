import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:omsatya/models/complain_status_response.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/screen/admin/dashboard.dart';
import 'package:omsatya/screen/customer/customer_dashboard.dart';
import 'package:omsatya/screen/engineer/engineer_dashboard.dart';
import 'package:omsatya/screen/sales_person/sales_dashboard.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'animations.dart';

class AppGlobals {
  static String displayDateFormat = "dd/MM/yyyy";
  static String displayTimeFormat = "hh:mm a";
  static String displayDateTimeFormat = "dd/MM/yyyy HH:mm:ss";

  static String androidApiKey = "AIzaSyDc9gp-kJHxqPn0Fkf0TY3JfhH9dZvKpaw";
  static String iosApiKey = "";

  static String token = "";

  static UserResponse? user;

  // static User? user;

  static void navigate(
      BuildContext context, Widget screen, bool isReplace) async {
    if (isReplace) {
      Navigator.of(context).pushReplacement(
        Animations.pageRoute(screen),
      );
    } else {
      Navigator.of(context).push(
        Animations.pageRoute(screen),
      );
    }
  }

  static void navigateAndRemove(
    BuildContext context,
    Widget screen,
    RoleType type,
    bool isReplace,
  ) async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => type == RoleType.customer
                ? const CustomerDashboard()
                : type == RoleType.engineer
                    ? const EngineerDashboard()
                    : type == RoleType.sales
                        ? const SalesDashboard()
                        : const Dashboard()),
        (Route route) => false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  static dynamic navigateAndReturn(
      BuildContext context, Widget screen, bool isDialog) async {
    if (isDialog) {
      return await Navigator.of(context).push(
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) {
            return screen;
          },
          fullscreenDialog: true,
        ),
      );
    } else {
      return await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => screen,
        ),
      );
    }
  }

  static Color hex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String capitalize(String text) {
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  static bool isCouponValid(String expiryDate) {
    DateTime currentDate = DateTime.now();
    DateTime expiryDateTime = DateTime.parse(expiryDate);

    // Check if the current date is before or equal to the expiry date
    return currentDate.isBefore(expiryDateTime) ||
        currentDate.isAtSameMomentAs(expiryDateTime);
  }

  static Future<bool> isInternetAvailable() async {
    try {
      if (kDebugMode) {
        return true;
      }

      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<void> reportError(dynamic error, dynamic stackTrace) async {
    if (kDebugMode) {
      print('Error DateTime   : ${DateTime.now().toString()}');
      print('Error Message    : $error');
      print('Error StackTrace : $stackTrace');
      print(''.padLeft(100, '-'));
      return;
    } else {
      // _sentry.captureException(
      //   exception: error,
      //   stackTrace: stackTrace,
      // );

      // if (response.isSuccessful) {
      //   print('Success! Event ID: ${response.eventId}');
      // } else {
      //   print('Failed to report to Sentry.io: ${response.error}');
      // }
    }
  }

  static void showMessage(String message, MessageType messageType) {
    Widget? icon;
    Color bgColor = Colors.black54;
    Color textColor = Colors.white;
    if (messageType == MessageType.success) {
      bgColor = AppColors.success;
      icon = Icon(Icons.check_circle, color: textColor);
    } else if (messageType == MessageType.error) {
      bgColor = ThemeData.light().colorScheme.error;
      icon = Icon(Icons.error, color: textColor);
    } else if (messageType == MessageType.info) {
      bgColor = AppColors.info;
      icon = Icon(Icons.info, color: textColor);
    } else if (messageType == MessageType.warning) {
      bgColor = AppColors.warning;
      icon = Icon(Icons.warning, color: textColor);
    }

    Widget msg = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimen.padding),
      child: Card(
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.all(AppDimen.padding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon == null
                  ? const SizedBox()
                  : Container(
                      padding: const EdgeInsets.only(right: AppDimen.padding),
                      child: icon,
                    ),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(color: textColor),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  softWrap: true,
                ),
              )
            ],
          ),
        ),
      ),
    );

    BotToast.showCustomText(
      duration: const Duration(seconds: 3),
      onlyOne: true,
      toastBuilder: (_) => msg,
    );
  }

  static Future<DialogResult> showAlertDialog(
      BuildContext context, Widget content,
      {Icon? icon}) async {
    Completer<DialogResult> completer = Completer<DialogResult>();
    AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimen.roundedBorderRadius),
      ),
      actionsAlignment: MainAxisAlignment.center,
      icon: icon == null
          ? null
          : CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Center(
                child: icon,
              ),
            ),
      content: content,
      actions: <Widget>[
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            completer.complete(DialogResult.ok);
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);

    return completer.future;
  }

  static Future<DialogResult> showConfirmDialog(
      BuildContext context, Widget content,
      {Icon? icon,
      Widget okButtonText = const Text("OK"),
      Widget cancelButtonText = const Text("CANCEL")}) async {
    Completer<DialogResult> completer = Completer<DialogResult>();
    AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimen.roundedBorderRadius),
      ),
      actionsAlignment: MainAxisAlignment.center,
      icon: icon == null
          ? null
          : CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Center(
                child: icon,
              ),
            ),
      content: content,
      actions: <Widget>[
        TextButton(
          child: const Text(
            "CANCEL",
            style: TextStyle(color: Colors.grey),
          ),
          onPressed: () {
            completer.complete(DialogResult.cancel);
            Navigator.of(context).pop();
          },
        ),
        const FieldSpace(),
        TextButton(
          child: okButtonText,
          onPressed: () {
            completer.complete(DialogResult.ok);
            Navigator.of(context).pop();
          },
        )
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);

    return completer.future;
  }

  static showConfirmContentDialog(
    BuildContext context,
    Widget content, {
    Icon? icon,
    Widget okButtonText = const Text("OK"),
    Widget cancelButtonText = const Text("CANCEL"),
    VoidCallback? onOkPressed,
    VoidCallback? onCancelPress,
  }) async {
    AlertDialog dialog = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimen.roundedBorderRadius),
      ),
      actionsAlignment: MainAxisAlignment.center,
      icon: icon == null
          ? null
          : CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Center(
                child: icon,
              ),
            ),
      content: content,
      actions: <Widget>[
        TextButton(
          onPressed: onCancelPress,
          child: const Text(
            "CANCEL",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const FieldSpace(),
        TextButton(
          onPressed: onOkPressed,
          child: okButtonText,
        )
      ],
    );
    showDialog(context: context, builder: (BuildContext context) => dialog);
  }

  static Future<DialogResult> showConfirmDeleteDialog(
      BuildContext context, String? message) async {
    return showConfirmDialog(
      context,
      Text(
        message ?? "",
        textAlign: TextAlign.center,
      ),
      icon: const Icon(Icons.delete_outline),
      okButtonText:
          const Text("DELETE", style: TextStyle(color: AppColors.danger)),
    );
  }

  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const List<int> daysInMonth = <int>[
      31,
      -1,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31
    ];
    return daysInMonth[month - 1];
  }

  static Color hexToColor(String colorCode) {
    return Color(
        int.parse(colorCode.replaceAll("#", ""), radix: 16) + 0xFF000000);
  }

  static String fileToBase64Encode(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    return base64Encode(imageBytes);
  }

  static void setOrientation(ScreenOrientation screenOrientation) {
    if (screenOrientation == ScreenOrientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (screenOrientation == ScreenOrientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  static calculateDaysBetweenTwoDates({String? firstDate, String? endDate}) {
    DateTime fromDate = DateFormat('yyyy-MM-dd').parse(firstDate!);
    DateTime toDate = DateFormat('yyyy-MM-dd').parse(endDate!);

    // Calculate the difference in days
    int daysBetween = toDate.difference(fromDate).inDays + 1;
    log("datsBetween ==> $daysBetween");
    return daysBetween;
  }

  String getStatus(int? statusId) {
    switch (statusId) {
      case 1:
        return "Pending";
      case 2:
        return "In Progress";
      case 3:
        return "Closed";
      default:
        return "Pending";
    }
  }

  String getAdminStatus(int? isAssign) {
    switch (isAssign) {
      case 0:
        return "Not Assign";
      case 1:
        return "Assign";
      default:
        return "Not Assign";
    }
  }

  String getLeaveStatus(int? statusId) {
    switch (statusId) {
      case 0:
        return "Pending";
      case 1:
        return "Approved";
      default:
        return "Pending";
    }
  }

  List<DropdownMenuItem<ComplainStatusData>> buildDropdownComplainStatusItems(
      List<ComplainStatusData> complainStatusList) {
    List<DropdownMenuItem<ComplainStatusData>> items = [];
    for (ComplainStatusData item
        in complainStatusList as Iterable<ComplainStatusData>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(
            item.name!.toCapitalize(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }
    return items;
  }

  String getCurrentDate() {
    DateTime dateTime = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String getCurrentTime() {
    DateTime dateTime = DateTime.now();
    return DateFormat('HH:mm:ss').format(dateTime);
    // return DateFormat('HH:mm').format(dateTime);
  }

  int getCurrentMonth() {
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    return currentMonth;
  }

  Color getAPColor(String? ap) {
    switch (ap) {
      case "P":
        return AppColors.success;
      case "A":
        return AppColors.error;
      case "L":
        return AppColors.error;
      case "H":
        return Colors.deepPurpleAccent;
      default:
        return AppColors.success;
    }
  }

  static Future<bool> requestPermission(BuildContext context,
      Permission permission, String permissionName) async {
    // Request microphone permission
    var status = await permission.request();
    log("Status new ==> $status");

    if (status == PermissionStatus.granted) {
      return true;
    } else if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      final res = (await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
              'This permission is needed for $permissionName. You can grant permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                bool result = await openAppSettings();
                if (result) {
                  var ps = await Permission.location.status;
                  Navigator.of(context).pop(ps == PermissionStatus.granted);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ));

      return res;
    } else {
      return false;
    }
  }

  static Future<String?> getVideoThumbnail(File? videoFile) async {
    if (videoFile == null) return null;
    final thumbnail = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 128,
      quality: 100,
    );
    return thumbnail;
  }

  static Future<File?> generateThumbnail(String url) async {
    final String videoUrl = url; // Replace with your video URL

    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128, // specify the width of the thumbnail
      quality: 75,
    );

    if (uint8list != null) {
      final directory = await Directory.systemTemp.createTemp();
      final file = File('${directory.path}/thumbnail.jpg');
      await file.writeAsBytes(uint8list);
      return file;
    }
    return null;
  }

  static double calculateLateHrs({String? dutyHours}) {
    DateTime entryTime = DateFormat('HH:mm:ss').parse(dutyHours!);
    DateTime actualTime =
        DateFormat('HH:mm:ss').parse(AppGlobals().getCurrentTime());

    Duration difference = actualTime.difference(entryTime);

    int diffInHours =
        difference.inMinutes ~/ 60; // Integer division to get hours
    int remainingMinutes = difference.inMinutes % 60;

    log("diffInHours ==> $diffInHours");
    log("remaining Minutes ==> $remainingMinutes");

    String timeGapMessage;

    if (actualTime.isAfter(entryTime)) {
      // If actual time is after the supposed time, it's late
      if (diffInHours > 0) {
        if (remainingMinutes >= 0 && remainingMinutes <= 9) {
          timeGapMessage = "$diffInHours.${remainingMinutes.toString().padLeft(2, '0')}";
        } else {
          timeGapMessage = "$diffInHours.$remainingMinutes";
        }
      } else {
        timeGapMessage = '0.${remainingMinutes.toString().padLeft(2, '0')}';
      }
    } else {
      // If actual time is on or before start time
      timeGapMessage = '0.0';
    }

    // log("calculateLateHrs ==> ${double.parse(timeGapMessage)}");

    return double.parse(timeGapMessage);
  }

  static double calculateEarlyGoingHrs({String? dutyEndHours}) {
    DateTime actualTime =
        DateFormat('HH:mm:ss').parse(AppGlobals().getCurrentTime());
    DateTime exitTime = DateFormat('HH:mm:ss').parse(dutyEndHours!);

    Duration difference = exitTime.difference(actualTime);

    int diffInHours =
        difference.inMinutes ~/ 60; // Integer division to get hours
    int remainingMinutes = difference.inMinutes % 60;

    String timeGapMessage;

    if (exitTime.isAfter(actualTime)) {
      // If actual time is after the supposed time, it's late
      if (diffInHours > 0) {
        if (remainingMinutes >= 0 && remainingMinutes <= 9) {
          timeGapMessage = "$diffInHours.${remainingMinutes.toString().padLeft(2, '0')}";
        } else {
          timeGapMessage = "$diffInHours.$remainingMinutes";
        }
      } else {
        timeGapMessage = '0.${remainingMinutes.toString().padLeft(2, '0')}';
      }
    } else {
      // If actual time is on or before start time
      timeGapMessage = '0.0';
    }

    // log("calculateEarlyGoingHrs ==> ${double.parse(timeGapMessage)}");

    return double.parse(timeGapMessage);
  }

  static double calculateTotalWorkingHrs({String? inTime}) {
    DateTime _inTime = DateFormat('HH:mm:ss').parse(inTime!);
    DateTime _outTime =
        DateFormat('HH:mm:ss').parse(AppGlobals().getCurrentTime());

    Duration difference = _outTime.difference(_inTime);

    int diffInHours =
        difference.inMinutes ~/ 60; // Integer division to get hours
    int remainingMinutes = difference.inMinutes % 60;

    String timeGapMessage;

    if (_outTime.isAfter(_inTime)) {
      // If actual time is after the supposed time, it's late
      if (diffInHours > 0) {
        if (remainingMinutes >= 0 && remainingMinutes <= 9) {
          timeGapMessage = "$diffInHours.${remainingMinutes.toString().padLeft(2, '0')}";
        } else {
          timeGapMessage = "$diffInHours.$remainingMinutes";
        }
      } else {
        timeGapMessage = '0.${remainingMinutes.toString().padLeft(2, '0')}';
      }
    } else {
      timeGapMessage = '0.0';
    }

    // log("calculateTotalWorkingHrs ==> ${double.parse(timeGapMessage)}");

    return double.parse(timeGapMessage);
  }

  static String removeCountryCode(String phoneNumber) {
    if (phoneNumber.startsWith('+91')) {
      return phoneNumber.replaceFirst('+91', '');
    }
    return phoneNumber;
  }

  Widget getCopyRightText() {
    return RichText(
      text: TextSpan(
          text: "Copyright © 2024 ",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          children: <TextSpan>[
            TextSpan(
              text: "Omsatya",
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (await canLaunch(AppConfig.omSatyaUrl)) {
                    await launch(
                      AppConfig.omSatyaUrl,
                    );
                  } else {
                    throw 'Could not launch ${AppConfig.omSatyaUrl}';
                  }
                },
              style: const TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
            const TextSpan(
              text: ". Designed by ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: "AddonWebTech",
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  if (await canLaunch(AppConfig.addonUrl)) {
                    await launch(
                      AppConfig.addonUrl,
                    );
                  } else {
                    throw 'Could not launch ${AppConfig.addonUrl}';
                  }
                },
              style: const TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                fontSize: 12,
              ),
            ),
            const TextSpan(
              text: ". All rights reserved.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ]),
      textAlign: TextAlign.center,
    );
  }

  launchPrivacyUrl() async {
    if (await canLaunch(AppConfig.privacyUrl!)) {
      await launch(AppConfig.privacyUrl!);
    } else {
      throw 'Could not launch ${AppConfig.privacyUrl!}';
    }
  }

  Future<bool> requestCameraAndGalleryPermission() async {
    // Check and request camera permission
    PermissionStatus cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        // Open app settings if camera permission is permanently denied
        bool result = await openAppSettings();
        if (result) {
          var ps = await Permission.camera.status;
          return ps == PermissionStatus.granted;
        } else {
          return false;
        }
      }
    }

    // Check and request gallery permission
    PermissionStatus galleryStatus = await Permission.photos.status;
    if (!galleryStatus.isGranted) {
      galleryStatus = await Permission.photos.request();
      if (galleryStatus.isPermanentlyDenied) {
        // Open app settings if gallery permission is permanently denied
        bool result = await openAppSettings();
        if (result) {
          var ps = await Permission.photos.status;
          return ps == PermissionStatus.granted;
        } else {
          return false;
        }
      }
    }

    if (cameraStatus.isGranted && galleryStatus.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  static bool isToday(String todayDate) {
    DateTime date = DateFormat('yyyy-MM-dd').parse(todayDate);
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static String convertTo24HourFormat(String time12Hour) {
    // Parse the time string into a DateTime object
    DateTime dateTime = DateFormat("h:mm a").parse(time12Hour);
    // Format the DateTime object in 24-hour format
    String formattedTime = DateFormat("HH:mm").format(dateTime);
    return formattedTime; // Format to 24-hour format
  }

  static String convertTo12HourFormat(String time24Hour) {
    // Parse the time string into a DateTime object
    DateTime dateTime = DateFormat("HH:mm").parse(time24Hour);
    // Format the DateTime object in 12-hour format with AM/PM
    String formattedTime = DateFormat("h:mm a").format(dateTime);
    return formattedTime;
  }

  static String convertTo12HourDateTimeFormat(String time24Hour) {
    // Parse the time string into a DateTime object
    DateTime dateTime = DateTime.parse(time24Hour);
    // Format the DateTime object to 12-hour format with AM/PM
    DateFormat formatter = DateFormat('yyyy-MM-dd h:mm:ss a');
    String formattedDateTime = formatter.format(dateTime);
    return formattedDateTime;
  }

  static String changeDateFormat(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    var outputFormat = DateFormat('dd-MM-yyyy');
    return outputFormat.format(parsedDate);
  }

  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.request();

    // Request permission if not granted
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    // Check the permission result
    if (status.isGranted) {
      return true;
    } else {
      final res = (await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'This permission is needed for camera. You can grant permission in the app settings.'),
          actions: [
            TextButton(
              onPressed: () async {
                bool result = await openAppSettings();
                if (result) {
                  var ps = await Permission.camera.status;
                  Navigator.of(context).pop(ps == PermissionStatus.granted);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ));

      return res;
    }
  }

  static String getFileExtension(String filePath) {
    int dotIndex = filePath.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < filePath.length - 1) {
      return filePath.substring(dotIndex + 1).toLowerCase();  // Returns the extension without the dot
    }
    return '';  // Return empty if no extension found
  }

  static ExtensionType getExtensionTypes(String extension) {
    switch (extension) {
      case 'jpg':
        return ExtensionType.jpg;
      case 'jpeg':
        return ExtensionType.jpeg;
      case 'png':
        return ExtensionType.png;
      case 'mp4':
        return ExtensionType.mp4;
      case 'mov':
        return ExtensionType.mov;
      case 'mkv':
        return ExtensionType.mkv;
      case 'pdf':
        return ExtensionType.pdf;
      default:
        throw ArgumentError('Unknown file extension: $extension');
    }
  }
}
