import 'dart:convert';

import 'package:omsatya/models/user_response.dart';

RolesUserResponse rolesUserResponseFromJson(String str) => RolesUserResponse.fromJson(json.decode(str));

String rolesUserResponseToJson(RolesUserResponse data) => json.encode(data.toJson());

class RolesUserResponse {
  bool? success;
  String? message;
  List<UserResponse>? data;

  RolesUserResponse({
    this.success,
    this.message,
    this.data,
  });

  factory RolesUserResponse.fromJson(Map<String, dynamic> json) => RolesUserResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<UserResponse>.from(json["data"]!.map((x) => UserResponse.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}
