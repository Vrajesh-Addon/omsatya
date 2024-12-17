import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/helpers/auth_helper.dart';
import 'package:omsatya/helpers/shared_value_helper.dart';
import 'package:omsatya/models/global_models.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/screen/change_password.dart';
import 'package:omsatya/screen/customer/customer_complain.dart';
import 'package:omsatya/screen/customer/customer_expiry.dart';
import 'package:omsatya/screen/customer/customer_home.dart';
import 'package:omsatya/screen/customer/customer_machine.dart';
import 'package:omsatya/screen/signin.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_images.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedDrawerIndex = 1;
  int _complainStatus = 1;
  int roleId = 0;

  final drawerItems = [
    DrawerItem(AppString.dashboard, Icons.computer),
    DrawerItem(AppString.machineComplain, Icons.warning_amber_rounded),
    DrawerItem(AppString.complainReport, Icons.list_alt_rounded),
    DrawerItem(AppString.expiryReport, Icons.list_alt_rounded),
    DrawerItem(AppString.changePassword, Icons.lock_outline_rounded),
    DrawerItem(AppString.privacyPolicy, Icons.privacy_tip_rounded),
    DrawerItem(AppString.logout, Icons.logout_rounded),
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    Map<String, dynamic> userMap = await jsonDecode(user.$!);
    AppGlobals.user = UserResponse.fromJson(userMap);
    showMessage("AppGlobals.user ==> ${AppGlobals.user!.toJson()}");
    roleId = AppGlobals.user!.roles!.first.id!;

    //Comment
    // drawerItems.removeWhere((item) => item.title == AppString.expiryReport);
    // setState(() {});
  }

  _getDrawerItemWidget(BuildContext context, int pos) {
    switch (pos) {
      case 0:
        if(_scaffoldKey.currentState!.isDrawerOpen) {
          Navigator.of(context).pop(); // close the drawer
        }
        return;
      case 1:
        return AppGlobals.navigate(context, const CustomerMachine(), false);
      case 2:
        return AppGlobals.navigate(context, CustomerComplain(complainStatusKey: _complainStatus), false);
      case 3:
        return AppGlobals.navigate(context, const CustomerExpiry(), false);
      case 4:
        return AppGlobals.navigate(context, const ChangePasswordScreen(), false);
      default:
        return const Text("Error");
    }
  }

  _logout(BuildContext context) {
    AppGlobals.showMessage("Logout successfully.", MessageType.success);
    AuthHelper().clearUserData();
    // Future.delayed(Duration.zero, () {
    //   AppGlobals.navigate(context, const SignInScreen(), true);
    // });
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ));
    });
  }

  _onChangeIndex(int index, {int complainStatus = 1}) {
    setState(() {
      // _selectedDrawerIndex = index;
      _complainStatus = complainStatus;
    });
    AppGlobals.navigate(context, CustomerComplain(complainStatusKey: _complainStatus), false);
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop(); // close the drawer
    }
  }

  _onSelectItem(int index, {int complainStatus = 1}) {
    setState(() {
      _selectedDrawerIndex = index;
      _complainStatus = complainStatus;
    });
    if(_scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop(); // close the drawer
    }
  }

  Future<bool?> _showBackDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
          const Text("Do you want close the app?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  // Reset flag after dialog is closed
                });
              },
              child: const Text(AppString.no),
            ),
            TextButton(
              onPressed: () {
                Platform.isAndroid ? SystemNavigator.pop() : exit(0);
              },
              child: const Text(AppString.yes),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (var i = 0; i < drawerItems.length; i++) {
      var d = drawerItems[i];
      drawerOptions.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimen.paddingSmall),
          child: ListTile(
            leading: Icon(
              d.icon,
              color: AppColors.primary,
            ),
            title: Text(
              d.title,
              style: const TextStyle(
                color: AppColors.primary,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimen.textRadius),
            ),
            // selectedTileColor: AppColors.primary.withOpacity(0.2),
            // selected: i == _selectedDrawerIndex,
            onTap: () {
              if (i == 5) {
                AppGlobals().launchPrivacyUrl();
              } else if (i == 6) {
                _scaffoldKey.currentState?.closeDrawer();
                showLogoutDialog();
              } else {
                _getDrawerItemWidget(context, i);
                // _onSelectItem(i);
              }
            },
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final NavigatorState navigator = Navigator.of(context);
        final bool? shouldPop = await _showBackDialog();
        if (shouldPop ?? false) {
          navigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        drawer: SafeArea(
          child: Drawer(
            child: Stack(
              children: <Widget>[
                Column(
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                      ),
                      currentAccountPicture: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          color: Colors.white,
                          child: Image.asset(
                            AppImages.appLogo,
                          ),
                        ),
                      ),
                      accountName: Text(
                        AppGlobals.user == null ? "" : AppGlobals.user!.name!,
                        style: const TextStyle(
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      accountEmail: Text(
                        AppGlobals.user == null ? "" : AppGlobals.user!.phoneNo!,
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Column(children: drawerOptions),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: AppGlobals().getCopyRightText(),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: CustomerHome(
          changeIndex: (index, status) {
            _onChangeIndex(index, complainStatus: status);
          },
        ),
        // body: _getDrawerItemWidget(context, _selectedDrawerIndex),
      ),
    );
  }

  showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          title: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.13,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const FieldSpace(SpaceType.medium),
              const Text(
                AppString.logOutHeading,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppString.logOutSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              const FieldSpace(SpaceType.large),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FieldSpace(SpaceType.medium),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ButtonStyle(
                        // backgroundColor: const WidgetStatePropertyAll(AppColors.error),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            ),
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: AppDimen.paddingLarge,
                              vertical: AppDimen.paddingSmall,
                            ),
                          )),
                      child: const Text(
                        AppString.no,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const FieldSpace(SpaceType.medium),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        _logout(context);
                      },
                      style: ButtonStyle(
                        // backgroundColor: const WidgetStatePropertyAll(AppColors.success),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimen.textRadius),
                            ),
                          ),
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: AppDimen.paddingLarge,
                              vertical: AppDimen.paddingSmall,
                            ),
                          )),
                      child: const Text(
                        AppString.yes,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const FieldSpace(SpaceType.medium),
                ],
              ),
              const FieldSpace(SpaceType.large),
            ],
          ),
        );
      },
    );
  }
}
