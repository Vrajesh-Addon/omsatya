import 'package:omsatya/models/user_response.dart';

class ApplyLeaveData {
  int? id;
  dynamic firmId;
  dynamic yearId;
  dynamic userId;
  String? dateTime;
  String? leaveFrom;
  String? leaveTill;
  dynamic totalLeave;
  String? reason;
  dynamic isApproved;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserResponse? userResponse;

  ApplyLeaveData({
    this.id,
    this.firmId,
    this.yearId,
    this.userId,
    this.dateTime,
    this.leaveFrom,
    this.leaveTill,
    this.totalLeave,
    this.reason,
    this.isApproved,
    this.createdAt,
    this.updatedAt,
    this.userResponse,
  });

  factory ApplyLeaveData.fromJson(Map<String, dynamic> json) => ApplyLeaveData(
    id: json["id"],
    firmId: json["firm_id"],
    yearId: json["year_id"],
    userId: json["user_id"],
    dateTime: json["date_time"],
    leaveFrom: json["leave_from"],
    leaveTill: json["leave_till"],
    totalLeave: json["total_leave"],
    reason: json["reason"],
    isApproved: json["is_approved"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    userResponse: json["user"] == null ? null : UserResponse.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firm_id": firmId,
    "year_id": yearId,
    "user_id": userId,
    "date_time": dateTime,
    "leave_from": leaveFrom,
    "leave_till": leaveTill,
    "total_leave": totalLeave,
    "reason": reason,
    "is_approved": isApproved,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "user": userResponse!.toJson(),
  };
}