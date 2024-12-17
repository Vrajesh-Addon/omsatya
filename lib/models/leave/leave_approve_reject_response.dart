import 'dart:convert';

import 'package:omsatya/models/leave/apply_leave_data.dart';

LeaveApprovedRejectResponse leaveApprovedRejectResponseFromJson(String str) => LeaveApprovedRejectResponse.fromJson(json.decode(str));

String leaveApprovedRejectResponseToJson(LeaveApprovedRejectResponse data) => json.encode(data.toJson());

class LeaveApprovedRejectResponse {
  bool status;
  String message;
  ApplyLeaveData data;

  LeaveApprovedRejectResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LeaveApprovedRejectResponse.fromJson(Map<String, dynamic> json) => LeaveApprovedRejectResponse(
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