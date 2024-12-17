import 'dart:convert';

import 'package:omsatya/models/user_response.dart';

LoginResponse loginResponseFromJson(String str) => LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  bool? success;
  String? message;
  String? accessToken;
  String? tokenType;
  UserResponse? user;

  LoginResponse({
    this.success,
    this.message,
    this.accessToken,
    this.tokenType,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json["success"] ?? false,
    message: json["message"],
    accessToken: json["access_token"],
    tokenType: json["token_type"],
    user: json["user"] == null ? null : UserResponse.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "access_token": accessToken,
    "token_type": tokenType,
    "engineer": user!.toJson(),
  };
}

