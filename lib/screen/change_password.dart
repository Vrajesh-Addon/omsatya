import 'package:flutter/material.dart';
import 'package:omsatya/helpers/shared_value_helper.dart';
import 'package:omsatya/repository/auth_repository.dart';
import 'package:omsatya/utils/app_colors.dart';
import 'package:omsatya/utils/app_const.dart';
import 'package:omsatya/utils/app_globals.dart';
import 'package:omsatya/utils/app_string.dart';
import 'package:omsatya/utils/validations.dart';
import 'package:omsatya/widgets/components.dart';
import 'package:omsatya/widgets/general_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isLoading = false;
  final GlobalKey<FormState> _formKeyChangePassword = GlobalKey<FormState>();
  FocusNode? _focusNode;

  final TextEditingController _txtOldPasswordController = TextEditingController();
  final TextEditingController _txtPasswordController = TextEditingController();
  final TextEditingController _txtConfirmPasswordController = TextEditingController();

  final FocusNode _txtOldPasswordFocusNode = FocusNode();
  final FocusNode _txtPasswordFocusNode = FocusNode();
  final FocusNode _txtConfirmPasswordFocusNode = FocusNode();

  bool oldPasswordVisible = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _txtOldPasswordController.dispose();
    _txtPasswordController.dispose();
    _txtConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isShowBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Center(child: _buildChangePassword()),
      ),
    );
  }

  // #region Design
  Widget _buildChangePassword() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimen.screenPadding),
      child: Column(
        children: [
          Text(
            AppString.changePassword,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const FieldSpace(SpaceType.extraLarge),
          _changePasswordForm(),
        ],
      ),
    );
  }

  Widget _changePasswordForm() {
    return Form(
      key: _formKeyChangePassword,
      child: Column(
        children: [
          TextFormField(
            controller: _txtOldPasswordController,
            focusNode: _txtOldPasswordFocusNode,
            decoration: InputDecoration(
              labelText: AppString.oldPassword,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(oldPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  oldPasswordVisible = !oldPasswordVisible;
                  setState(() {});
                },
              ),
            ),
            inputFormatters: [PasswordInputFormatter()],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            obscureText: !oldPasswordVisible,
            validator: (value) {
              bool isValid = Validations.validateInput(value, true);
              if (isValid == false) {
                // if (_focusNode == null) {
                //   _focusNode = _txtOldPasswordFocusNode;
                //   FocusScope.of(context).requestFocus(_focusNode);
                // }
                return AppString.enterCurrentPassword;
              }
              return null;
            },
          ),
          const FieldSpace(),
          TextFormField(
            controller: _txtPasswordController,
            focusNode: _txtPasswordFocusNode,
            decoration: InputDecoration(
              labelText: AppString.newPassword,
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
              errorMaxLines: 2,
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
                return AppString.enterNewPassword;
              }
              return null;
            },
          ),
          const FieldSpace(),
          TextFormField(
            controller: _txtConfirmPasswordController,
            focusNode: _txtConfirmPasswordFocusNode,
            decoration: InputDecoration(
              labelText: AppString.confirmPassword,
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  confirmPasswordVisible = !confirmPasswordVisible;
                  setState(() {});
                },
              ),
            ),
            inputFormatters: [PasswordInputFormatter()],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            obscureText: !confirmPasswordVisible,
            onChanged: (value) {},
            validator: (value) {
              bool isValid = Validations.validateInput(value, true);
              if (!isValid) {
                // if (_focusNode == null) {
                //   _focusNode = _txtConfirmPasswordFocusNode;
                //   FocusScope.of(context).requestFocus(_focusNode);
                // }
                return AppString.enterConfirmPassword;
              }
              if (isValid && _txtPasswordController.text.trim() != value) {
                // if (_focusNode == null) {
                //   _focusNode = _txtConfirmPasswordFocusNode;
                //   FocusScope.of(context).requestFocus(_focusNode);
                // }
                return AppString.passwordNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(
            height: 50,
          ),
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
                              _handleChangePassword();
                            },
                      text: AppString.submit,
                    ),
                  ),
                ],
              ),
              if (isLoading)
                const ButtonLoader(),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    try {
      _focusNode = null;
      if (_formKeyChangePassword.currentState!.validate() == false) {
        return;
      }

      setState(() {
        isLoading = true;
      });

      var response = await AuthRepository().getPasswordResponse(
        _txtOldPasswordController.text.trim(),
        _txtPasswordController.text.trim(),
        _txtConfirmPasswordController.text.trim(),
      );

      if (response.success!) {
        AppGlobals.showMessage(response.message!, MessageType.success);

        accessToken.$ = response.accessToken;
        accessToken.save();

        setState(() {
          isLoading = false;
          _txtOldPasswordController.clear();
          _txtPasswordController.clear();
          _txtConfirmPasswordController.clear();
        });
      } else {
        AppGlobals.showMessage(response.message!, MessageType.error);
        setState(() {
          isLoading = false;
        });
        return;
      }
    } catch (error, stackTrace) {
      setState(() {
        isLoading = false;
      });
      AppGlobals.reportError(error, stackTrace);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
// #endregion
}
