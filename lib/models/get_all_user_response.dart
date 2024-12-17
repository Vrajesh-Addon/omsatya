import 'dart:convert';

import 'package:omsatya/models/user_response.dart';

GetAllUserResponse getAllUserResponseFromJson(String str) => GetAllUserResponse.fromJson(json.decode(str));

String getAllUserResponseToJson(GetAllUserResponse data) => json.encode(data.toJson());

class GetAllUserResponse {
  bool success;
  String message;
  List<UserResponse> data;

  GetAllUserResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetAllUserResponse.fromJson(Map<String, dynamic> json) => GetAllUserResponse(
    success: json["success"],
    message: json["message"],
    data: List<UserResponse>.from(json["data"].map((x) => UserResponse.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}