import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

EngineerInOutResponse engineerInOutResponseFromJson(String str) => EngineerInOutResponse.fromJson(json.decode(str));

String engineerInOutResponseToJson(EngineerInOutResponse data) => json.encode(data.toJson());

class EngineerInOutResponse {
  bool success;
  String message;
  ComplainData data;

  EngineerInOutResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EngineerInOutResponse.fromJson(Map<String, dynamic> json) => EngineerInOutResponse(
    success: json["success"],
    message: json["message"],
    data: ComplainData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}