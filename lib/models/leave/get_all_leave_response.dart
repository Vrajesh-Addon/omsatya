import 'dart:convert';

import 'package:omsatya/models/leave/apply_leave_data.dart';

GetAllLeaveResponse getAllLeaveResponseFromJson(String str) => GetAllLeaveResponse.fromJson(json.decode(str));

String getAllLeaveResponseToJson(GetAllLeaveResponse data) => json.encode(data.toJson());

class GetAllLeaveResponse {
  bool status;
  String message;
  List<ApplyLeaveData> data;

  GetAllLeaveResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAllLeaveResponse.fromJson(Map<String, dynamic> json) => GetAllLeaveResponse(
    status: json["status"],
    message: json["message"],
    data: List<ApplyLeaveData>.from(json["data"].map((x) => ApplyLeaveData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}


