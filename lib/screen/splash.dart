import 'dart:convert';

import 'package:flutter/material.dart';


import 'package:omsatya/helpers/shared_value_helper.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/screen/customer/customer_dashboard.dart';
import 'package:omsatya/screen/admin/dashboard.dart';
import 'package:omsatya/screen/engineer/engineer_dashboard.dart';
import 'package:omsatya/screen/sales_person/sales_dashboard.dart';
import 'package:omsatya/screen/signin.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? _isInternet;

  @override
  void initState() {
    super.initState();

    _splashScreenLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppGlobals.setOrientation(ScreenOrientation.portrait);

    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Splash(),
        ),
      ),
    );
  }

  // #region Code
  void _splashScreenLoad() async {
    try {

      _isInternet = await AppGlobals.isInternetAvailable();
      if (_isInternet == false) {
        setState(() {});
        return;
      }

      getSharedValueHelperData().then((onValue) async {
        if ((phoneNo.$ == null || phoneNo.$!.isEmpty) && (password.$ == null || password.$!.isEmpty)) {
          if (mounted) {
            AppGlobals.navigate(
              context,
              const SignInScreen(),
              true,
            );
          }
          return;
        }

        int? roleId;
        if(user.$ != null) {
          Map<String, dynamic> userMap = await jsonDecode(user.$!);
          AppGlobals.user = UserResponse.fromJson(userMap);
          showMessage("AppGlobals.user ==> ${AppGlobals.user!.toJson()}");
          roleId = AppGlobals.user!.roles!.first.id!;
        }

        if (mounted) {
          if(roleId != null && roleId == 5){
            updateBadgeCounter();
            AppGlobals.navigate(
              context,
              const SalesDashboard(),
              true,
            );
          } else if(roleId != null && roleId == 3) {
            updateBadgeCounter();
            AppGlobals.navigate(
              context,
              const CustomerDashboard(),
              true,
            );
          } else if(roleId != null && roleId == 4) {
            updateBadgeCounter();
            AppGlobals.navigate(
              context,
              const EngineerDashboard(),
              true,
            );
          } else{
            updateBadgeCounter();
            AppGlobals.navigate(
              context,
              const Dashboard(),
              // const SalesPerson(),
              true,
            );
          }
        }
      });

    } catch (error, stackTrace) {
      setState(() {});
      AppGlobals.reportError(error, stackTrace);
    }
  }

  updateBadgeCounter(){
    appBadgeCount.$ = 0;
    appBadgeCount.save();

    // FlutterAppIconBadge.updateBadge(appBadgeCount.$ ?? 0);
  }
// #endregion
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Logo(),
          const FieldSpace(SpaceType.extraLarge),
          SizedBox(
            height: 300,
            child: Image.asset(AppImages.appLogoSingle),
          )
        ],
      ),
    );
  }
}
