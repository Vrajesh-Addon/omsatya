import 'dart:convert';

import 'package:omsatya/models/leave/apply_leave_data.dart';

AddLeaveResponse addLeaveResponseFromJson(String str) => AddLeaveResponse.fromJson(json.decode(str));

String addLeaveResponseToJson(AddLeaveResponse data) => json.encode(data.toJson());

class AddLeaveResponse {
  bool status;
  String message;
  ApplyLeaveData data;

  AddLeaveResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory AddLeaveResponse.fromJson(Map<String, dynamic> json) => AddLeaveResponse(
    status: json["status"],
    message: json["message"],
    data: ApplyLeaveData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}