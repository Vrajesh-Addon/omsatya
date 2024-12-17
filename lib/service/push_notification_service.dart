// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:omsatya/widgets/general_widgets.dart';
//
// class PushNotificationService{
//   PushNotificationService._privateConstructor();
//   static final PushNotificationService instance = PushNotificationService._privateConstructor();
//
//   String get fcmToken => _fcmToken;
//
//   String _fcmToken = "";
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   static const channelId = 'OM_SATYA_ID';
//   static const channelName = 'OM SATYA';
//   static const channelDescription = 'Notification';
//
//   static Future<String> getServerKey() async {
//     final serviceAccountJson = {
//       "type": "service_account",
//       "project_id": "om-satya-aac05",
//       "private_key_id": "eba2608fc8df9eef022dd51e2fcfa16afa7e5199",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChDn7G9DARx8ed\ne8u1tVQAV2QhEuDKxlo63dkXepL3N6BM3DIzrRe5QvGm6Tx6T0FL58IQaWj2fn2k\n8YbtMMPHFINCAI6+xCayVrs2LPutHfVvYys3gmwVr8LdNJmSFQTlcRwRyrZ7k7BJ\nudFv3ERi9V7HrmzR/eTvxwXQjdlCFr8sIx0Bk4rjfcoaufaLN5p/gLZGveDW2XA1\neYuU9OSDsUtRjZmcJokxlM41VT/fZR1ESbkVpX7RHv3n579yd8COVEG3NRhNL/wV\nabHw9bGZR+ArNtahnQtwGRKh3XOZHitOjQQ4Mkkuly0u7py0KJQ9s04jf9PsolGw\nNxTVT9KjAgMBAAECggEAAZaignTQyo0+gGTC0BJ4ZNVTPkUem7qByuFDrX+sevYh\nafU3bdILbH8dvXF33igWF4/pzWxZSnNZ6uEuFCE3Wak46neoOeS2Wv192VRK9bgP\na/q9wyjjxwGMjBfREexn3FBMe8lLh5YNhGbp+M7QZrUqqxDHivk4/uAd1n4579Bp\nK6MjzGNN0QTtSv89q0b2Cegr+Do3PMVa0TQD4vle7jSLm3sz3638U1HUMKQRj2+U\nZE1gBEYa5yTZIyclZ0CbM1QloLjFbNZcg8Q4xmK6f+6MwvPEG+GZAqdmR+8Lk+5q\nNhPOXJwRbvIdmxOV3t/CEjGL8qwCx/rXc5SV4gfQKQKBgQDcVp90+SUf3GWYEYBQ\nCWXk85r8gjsfacevIvvjz91RNuuSaSom6DhhElqmqus42aTtLqeRV4RpRucgqUFZ\nkf3wASRuKaKYL3r8HmI/ipPMZwd8G7gS8oN1EvszygfepzoKfKQyJpm8tx+FqVXM\nz9Ap9dJkc1EGTZfy8PX1DOTKuQKBgQC7H6AdHbGG4QELHDkTTg2Azw9yQtbDhlpQ\nADJeBWEOG1SMyt84MDWPShUlkoQWjVkNebt9hE/c8gBNuhw7yuossN1nww2IrGAS\n9Cm37GvJJ0/RQr8Z05j+Zq+tQmqjsYiGIYpFEwnHOGq7yVyTDioKZTnGCmOVWvQT\nf0Zt0YjqOwKBgCQT/vodTYnhAbWbsAHq+Ac8KDWOcXXcUTkJJmuP/rIspvgLRj6m\nqYyjf7popClj4dCAYim3RdQjKvc7H5s1/3mMBlYPdTMsGxwrMXUsELVYbW5R75sS\noJnL6Nv7CbzYbvWGoTAhB+1RotS0/HqT0Ib+XFvcUfkRPX8nG27rlI7pAoGAR0OJ\nF+2aEZMZcaDC/94m+FpjOJHJ9tbxCCy7AeGsj9HKxn/wuRZrH3IIUbHWCjy0oJQu\n2mOMgsnLYc6yN/dUbcbB22WGfvme8Tj5tmkct5P4KurvmqdiSejTmPmFYWgYZXTa\nkunoPG35ACF01zB6xFC+yvRj7pqf/9jl+qblLMcCgYEAsQc9OMmFx0VIfNsAB3k5\neImqn9MBXgVEOAONzjJLP4ltA+9/449a86ElF8WREgivyVwj8M0vnQ+MSkvwci4g\nOYNWEDJWtoYSzT29WUnBmViY6KQKVXBW5DbF3bdFvw1R/gyIKgw9U4jymhtWbz2w\n+L14A9/5qvKdHoK8JPfkyAA=\n-----END PRIVATE KEY-----\n",
//       "client_email": "firebase-adminsdk-8kt8d@om-satya-aac05.iam.gserviceaccount.com",
//       "client_id": "116990289782245515918",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-8kt8d%40om-satya-aac05.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com"
//     };
//
//     List<String> scopes = [
//       "https://www.googleapis.com/auth/userinfo.email",
//       "https://www.googleapis.com/auth/firebase.database",
//       "https://www.googleapis.com/auth/firebase.messaging",
//     ];
//
//
//     http.Client client = await auth.clientViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//         scopes
//     );
//
//     auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
//         auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//         scopes,
//         client
//     );
//
//     client.close();
//
//     showMessage("credentials.access token.data ==> ${credentials.accessToken.data}");
//
//     return credentials.accessToken.data;
//   }
//
//   Future<void> initialize() async {
//     await Firebase.initializeApp();
//     await initializeLocalNotification();
//     // firebaseMessaging.subscribeToTopic('omsatya_app');
//
//     await firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     firebaseMessaging.getToken().then((token) {
//       _fcmToken = token!;
//       showMessage("Firebase Cloud Messaging Token ==> $token");
//     });
//
//     firebaseMessaging.getInitialMessage().then((message) {
//       if (message != null) {
//         // Handle initial message (e.g., open app from notification)
//         showMessage('Initial Message ==> ${message.data}');
//       }
//     });
//
//     NotificationSettings notificationSettings = await firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//         // Handle incoming notifications while app is in the foreground
//         // showMessage('Foreground Message ==> ${message.data}');
//         // showMessage('Message title: ${message.notification?.title}, body: ${message.notification?.body}');
//
//         AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
//           channelId,
//           channelName,
//           channelDescription: channelDescription,
//           // sound: RawResourceAndroidNotificationSound('sms'),
//           playSound: true,
//           enableVibration: true,
//           importance: Importance.max,
//           priority: Priority.high,
//         );
//
//         DarwinNotificationDetails iosNotificationDetails = const DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//           // sound: 'security_alert.caf',
//         );
//
//         NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
//
//         await flutterLocalNotificationsPlugin.show(
//           0,
//           message.notification!.title!,
//           message.notification!.body!,
//           notificationDetails,
//         );
//         // Show notification in the app (optional)
//
//         FlutterRingtonePlayer().play(
//           android: AndroidSounds.notification,
//           ios: const IosSound(1023),
//           looping: false,
//           volume: 1,
//         );
//       });
//
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         // Handle notifications tapped while app is in the background
//         // showMessage('Opened App from Notification ==> ${message.data}');
//         // Navigate to the relevant screen within the app
//       });
//     }
//   }
//
//   initializeLocalNotification() {
//     AndroidInitializationSettings android = const AndroidInitializationSettings('@mipmap/ic_launcher');
//     DarwinInitializationSettings ios = const DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );
//     InitializationSettings platform = InitializationSettings(android: android, iOS: ios);
//     flutterLocalNotificationsPlugin.initialize(platform);
//   }
//
// }