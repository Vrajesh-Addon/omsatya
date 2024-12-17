import 'dart:convert';

import 'package:omsatya/models/admin_get_today_attendance.dart';

LeaveApprovedRejectResponse leaveApprovedRejectResponseFromJson(String str) => LeaveApprovedRejectResponse.fromJson(json.decode(str));

String leaveApprovedRejectResponseToJson(LeaveApprovedRejectResponse data) => json.encode(data.toJson());

class LeaveApprovedRejectResponse {
  bool success;
  String message;
  AdminGetTodayAttendanceData data;

  LeaveApprovedRejectResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LeaveApprovedRejectResponse.fromJson(Map<String, dynamic> json) => LeaveApprovedRejectResponse(
    success: json["success"],
    message: json["message"],
    data: AdminGetTodayAttendanceData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}