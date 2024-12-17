import 'dart:convert';

import 'package:omsatya/helpers/main_helper.dart';
import 'package:omsatya/models/common_response.dart';
import 'package:omsatya/models/device_token_response.dart';
import 'package:omsatya/models/get_all_user_response.dart';
import 'package:omsatya/models/login_response.dart';
import 'package:omsatya/utils/app_config.dart';

import 'api_request.dart';

class AuthRepository {

  Future<LoginResponse> getLoginResponse(String? phone, String password) async {
    String url = "${AppConfig.baseUrl}/login?phone_no=$phone&password=$password";
    final response = await ApiRequest.post(url: url, body: "");
    return loginResponseFromJson(response.body);
  }

  Future<CommonResponse> getLogOutResponse() async {
    String url = "${AppConfig.baseUrl}/logout";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return commonResponseFromJson(response.body);
  }

  Future<LoginResponse> getPasswordResponse(String currentPassword, String password, String confirmPassword) async {
    var body = jsonEncode({
      "current_password": currentPassword,
      "password": password,
      "password_confirmation": confirmPassword,
    });
    String url = "${AppConfig.baseUrl}/change-password";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return loginResponseFromJson(response.body);
  }

  Future<GetAllUserResponse> getAllUserData() async {
    String url = "${AppConfig.baseUrl}/users";
    Map<String, String>? headerMap = commonHeader;
    headerMap.addAll(authHeader);
    final response = await ApiRequest.get(url: url, header: headerMap);
    return getAllUserResponseFromJson(response.body);
  }

  Future<DeviceTokenResponse> storeDeviceToken({dynamic body, String? token}) async {
    String url = "${AppConfig.baseUrl}/device-token";
    Map<String, String>? headerMap = acceptHeader;
    headerMap.addAll({"Authorization": "Bearer $token"});
    final response = await ApiRequest.post(url: url, header: headerMap, body: body);
    return deviceTokenResponseFromJson(response.body);
  }
}
