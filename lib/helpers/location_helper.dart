import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:omsatya/widgets/general_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class LocationHelper {

  static Future<bool> handleLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      final result = (await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
              'This permission is needed for Location. You can grant permission in the app settings.'),
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

      return result;

      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition();
    return true;
  }

  static Future<Position?> getCurrentPosition(BuildContext context) async {
    try {
      // final hasPermission = await handleLocationPermission(context);
      // showMessage("Permission Denied 3 ==> $hasPermission");
      // if (!hasPermission) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placeMarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placeMarks[0];
      return "${place.street}, ${place.subLocality},${place.subAdministrativeArea} ${place.postalCode}";
    } catch (e) {
      return null;
    }
  }
}