import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

AssignEngineerResponse assignEngineerResponseFromJson(String str) => AssignEngineerResponse.fromJson(json.decode(str));

String assignEngineerResponseToJson(AssignEngineerResponse data) => json.encode(data.toJson());

class AssignEngineerResponse {
  bool success;
  String message;
  ComplainData data;

  AssignEngineerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AssignEngineerResponse.fromJson(Map<String, dynamic> json) => AssignEngineerResponse(
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

