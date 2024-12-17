import 'dart:convert';

import 'package:omsatya/helpers/shared_value_helper.dart';
import 'package:omsatya/models/login_response.dart';
import 'package:omsatya/models/user_response.dart';
import 'package:omsatya/utils/app_globals.dart';

class AuthHelper {
  setUserData(LoginResponse loginResponse, String phone, String pass, bool isRemember) async {
    AppGlobals.user = loginResponse.user;
    Map<String, dynamic> dataMap = loginResponse.user!.toJson();
    String data = jsonEncode(UserResponse.fromJson(dataMap));
    user.$ = data;
    user.save();
    accessToken.$ = loginResponse.accessToken;
    accessToken.save();
    // if(isRemember) {
      phoneNo.$ = phone;
      phoneNo.save();
      password.$ = pass;
      password.save();
    // }
  }

  clearUserData() {
    AppGlobals.user = null;
    user.$ = "";
    user.save();
    accessToken.$ = "";
    accessToken.save();
    phoneNo.$ = "";
    phoneNo.save();
    password.$ = "";
    password.save();
  }

// fetch_and_set() async {
//   var userByTokenResponse = await AuthRepository().getUserByTokenResponse();
//   if (userByTokenResponse.result == true) {
//     setUserData(userByTokenResponse);
//   } else {
//     clearUserData();
//   }
// }
}
