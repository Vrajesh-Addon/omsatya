
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omsatya/helpers/auth_helper.dart';
import 'package:omsatya/helpers/shared_value_helper.dart';
import 'package:omsatya/repository/auth_repository.dart';
import 'package:omsatya/screen/customer/customer_dashboard.dart';
import 'package:omsatya/screen/admin/dashboard.dart';
import 'package:omsatya/screen/engineer/engineer_dashboard.dart';
import 'package:omsatya/screen/sales_person/sales_dashboard.dart';
import 'package:omsatya/screen/splash.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isLoading = false;
  bool? _isInternet;
  String loginBy = "email";
  bool _isAutoLogin = false;

  bool _isRemember = false;

  final GlobalKey<FormState> _formKeySignIn = GlobalKey<FormState>();
  FocusNode? _focusNode;

  final TextEditingController _txtUsernameController = TextEditingController();
  final TextEditingController _txtPasswordController = TextEditingController();

  final FocusNode _txtUsernameFocusNode = FocusNode();
  final FocusNode _txtPasswordFocusNode = FocusNode();

  bool passwordVisible = false;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _signInScreenLoad();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _txtUsernameController.dispose();
    _txtPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        String token = accessToken.$ ?? "";
        if(token.isEmpty) {
          return;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: _isAutoLogin ? const Splash() : _signIn(),
          ),
        ),
      ),
    );
  }

  // #region Design
  Widget _signIn() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.screenPadding),
      child: Column(
        children: [
          const Logo(),
          const FieldSpace(SpaceType.extraLarge),
          Text(
            AppString.signIn,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            AppString.enterCredentialSignIn,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const FieldSpace(SpaceType.extraLarge),
          _signInForm(),
          /*const FieldSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have account?"),
              TextButton(
                onPressed: () {
                  // AppGlobals.navigate(
                  //   context,
                  //   SignupScreen(widget._roleId),
                  //   true,
                  // );
                },
                child: const Text(
                  "Signup",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),*/
        ],
      ),
    );
  }

  Widget _signInForm() {
    return Form(
      key: _formKeySignIn,
      child: Column(
        children: [
          TextFormField(
            controller: _txtUsernameController,
            focusNode: _txtUsernameFocusNode,
            decoration: const InputDecoration(
              labelText: AppString.phone,
              prefixIcon: Icon(
                Icons.call_rounded,
                color: AppColors.primary,
              ),
            ),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              PhoneInputFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (value) {
              bool isValid = Validations.validateInput(value, true, ValidationType.phone);
              if (!isValid) {
                // if (_focusNode == null) {
                //   _focusNode = _txtUsernameFocusNode;
                //   FocusScope.of(context).requestFocus(_focusNode);
                // }
                return AppString.enterValidPhoneNo;
              }
              return null;
            },
          ),
          const FieldSpace(),
          TextFormField(
            controller: _txtPasswordController,
            focusNode: _txtPasswordFocusNode,
            decoration: InputDecoration(
              labelText: AppString.password,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  passwordVisible = !passwordVisible;
                  setState(() {});
                },
              ),
            ),
            inputFormatters: [PasswordInputFormatter()],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            obscureText: !passwordVisible,
            validator: (value) {
              bool isValid = Validations.validateInput(value, true);
              if (isValid == false) {
                // if (_focusNode == null) {
                //   _focusNode = _txtPasswordFocusNode;
                //   FocusScope.of(context).requestFocus(_focusNode);
                // }
                return AppString.enterPassword;
              }
              return null;
            },
          ),
          const FieldSpace(),
         /* Row(
            children: [
              InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    value: _isRemember,
                    onChanged: (value) {
                      _isRemember = value!;
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: AppDimen.paddingExtraSmall),
                  Text(
                    AppString.rememberMe,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const FieldSpace(SpaceType.small),
                ]),
                onTap: () {
                  _isRemember = !_isRemember;
                  setState(() {});
                },
              ),
              // const Spacer(),
              // TextButton(
              //   onPressed: () {
              //     // AppGlobals.navigate(
              //     //   context,
              //     //   const ForgotPasswordScreen(),
              //     //   false,
              //     // );
              //   },
              //   child: Text(
              //     AppString.forgotPassword,
              //     style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.primary),
              //   ),
              // ),
            ],
          ),*/
          const FieldSpace(),
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              dismissKeyboard(context);
                              _handleSignIn();
                            },
                      text: AppString.submit,
                    ),
                  ),
                ],
              ),
              if (isLoading) const ButtonLoader(),
            ],
          ),
        ],
      ),
    );
  }

  // #endregion

  // #region Code
  void _signInScreenLoad() async {
    try {
      _isInternet = await AppGlobals.isInternetAvailable();
      if (_isInternet == false) {
        setState(() {});
        return;
      }
    } catch (error, stackTrace) {
      setState(() {});
      AppGlobals.reportError(error, stackTrace);
    }
  }

  Future<void> _handleSignIn() async {
    try {
      String phone = "";
      String pass = "";

      _focusNode = null;
      if (!_formKeySignIn.currentState!.validate()) {
        if (_isAutoLogin) {
          user.$ = "";
          user.save();
          password.$ = "";
          password.save();

          _isAutoLogin = false;
          isLoading = false;
          setState(() {});
        }
        return;
      }

      phone = _txtUsernameController.text.trim();
      pass = _txtPasswordController.text.trim();

      if (!_isAutoLogin) {
        setState(() {
          isLoading = true;
        });
      }

      var response = await AuthRepository().getLoginResponse(phone, pass);

      if (response.success!) {
        String? firebaseToken = await FirebaseMessaging.instance.getToken();

        var body = {
          "id": response.user!.id.toString(),
          "role": response.user!.roles!.first.name,
          "device_token": firebaseToken,
        };

        await AuthRepository().storeDeviceToken(body: body, token: response.accessToken);

        AppGlobals.showMessage(response.message!, MessageType.success);
        isLoading = false;

        await AuthHelper().setUserData(
          response,
          _txtUsernameController.text.trim(),
          _txtPasswordController.text.trim(),
          _isRemember,
        );

        setState(() {});

        if (mounted) {
            Future.delayed(Duration.zero, () {
              if(response.user!.roles!.first.id == 5){
                AppGlobals.navigate(
                  context,
                  const SalesDashboard(),
                  true,
                );
              } else if(response.user!.roles!.first.id == 3) {
                AppGlobals.navigate(
                  context,
                  const CustomerDashboard(),
                  true,
                );
              } else if(response.user!.roles!.first.id == 4) {
                AppGlobals.navigate(
                  context,
                  const EngineerDashboard(),
                  true,
                );
              } else {
                AppGlobals.navigate(
                  context,
                  const Dashboard(),
                  true,
                );
              }
            });
        }
      } else {
        AppGlobals.showMessage(response.message!, MessageType.error);
        _isAutoLogin = false;
        setState(() {
          isLoading = false;
        });
        return;
      }
    } catch (error, stackTrace) {
      AppGlobals.reportError(error, stackTrace);
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
// #endregion
}
