import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/screen/splash.dart';
import 'package:omsatya/service/push_notification_service.dart';
import 'package:omsatya/utils/app_config.dart';
import 'package:omsatya/utils/app_themes.dart';
import 'package:omsatya/utils/one_context.dart';
import 'package:omsatya/utils/shared_value/shared_value.dart';
import 'package:omsatya/widgets/general_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: Platform.isAndroid ? "AIzaSyDz1sjgaGFk6Dw8ETyrHrM1y1N6T1JAo-0" : "AIzaSyBRtL_bHePsfTtFVphxlh_-glcYpPLYqcY", // paste your api key here
      appId: Platform.isAndroid ? "1:328829441572:android:4f4a8d6e2957251b182ab1" : "1:328829441572:ios:6e907553cab61172182ab1", //paste your app id here
      messagingSenderId: "328829441572", //paste your messagingSenderId here
      projectId: "om-satya-exim-pvt-ltd", //paste your project id here
    ),
  );
  await PushNotificationService.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  runApp(
    SharedValue.wrapApp(const MyApp()),
  );
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  showMessage('Background message Id : ${message.messageId}');
  showMessage('Background message Time : ${message.sentTime}');
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    OneContext().context = context;
    return MaterialApp(
      scrollBehavior: AppScrollBehavior(),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppThemes().light,
      // home: DashboardScreen(),
      home: const SplashScreen(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}