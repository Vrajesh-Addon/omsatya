import 'dart:convert';

GetAllAttendanceDataResponse getAllAttendanceDataResponseFromJson(String str) => GetAllAttendanceDataResponse.fromJson(json.decode(str));

String getAllAttendanceDataResponseToJson(GetAllAttendanceDataResponse data) => json.encode(data.toJson());

class GetAllAttendanceDataResponse {
  bool? success;
  String? message;
  List<GetAllAttendanceData>? data;

  GetAllAttendanceDataResponse({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllAttendanceDataResponse.fromJson(Map<String, dynamic> json) => GetAllAttendanceDataResponse(
    success: json["success"],
    message: json["message"],
    data: List<GetAllAttendanceData>.from(json["data"].map((x) => GetAllAttendanceData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class GetAllAttendanceData {
  int? id;
  int? engineerId;
  int? areaId;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? phoneNo;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  dynamic dutyHours;
  String? deviceToken;
  String? inTime;
  String? outTime;
  String? inDate;
  String? outDate;
  String? ap;
  dynamic lateHrs;
  dynamic earligoingHrs;
  dynamic workingHrs;
  dynamic pdays;
  String? inAddress;
  String? outAddress;
  String? attendanceStatus;
  int? pendingComplaintsCount;
  int? inProgressComplaintsCount;
  int? closedComplaintsCount;
  List<Role>? roles;

  GetAllAttendanceData({
    this.id,
    this.engineerId,
    this.areaId,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phoneNo,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
    this.deviceToken,
    this.inTime,
    this.outTime,
    this.inDate,
    this.outDate,
    this.ap,
    this.lateHrs,
    this.earligoingHrs,
    this.workingHrs,
    this.pdays,
    this.inAddress,
    this.outAddress,
    this.attendanceStatus,
    this.pendingComplaintsCount,
    this.inProgressComplaintsCount,
    this.closedComplaintsCount,
    this.roles,
  });

  factory GetAllAttendanceData.fromJson(Map<String, dynamic> json) => GetAllAttendanceData(
    id: json["id"],
    engineerId: json["engineer_id"] ?? 0,
    areaId: json["area_id"],
    name: json["name"],
    email: json["email"] ?? "",
    emailVerifiedAt: json["email_verified_at"] ,
    phoneNo: json["phone_no"],
    isActive: json["is_active"],
    dutyStart: json["duty_start"] ?? "",
    dutyEnd: json["duty_end"] ?? "",
    dutyHours: json["duty_hours"] ?? "",
    deviceToken: json["device_token"] ?? "",
    inTime: json["in_time"] ?? "",
    outTime: json["out_time"] ?? "",
    inDate: json["in_date"] ?? "",
    outDate: json["out_date"] ?? "",
    ap: json["ap"] ?? "",
    lateHrs: json["late_hrs"] ?? 0,
    earligoingHrs: json["earligoing_hrs"] ?? 0,
    workingHrs: json["working_hrs"] ?? 0,
    pdays: json["pdays"] ?? 0,
    inAddress: json["in_address"] ?? "",
    outAddress: json["out_address"] ?? "",
    attendanceStatus: json["attendance_status"],
    pendingComplaintsCount: json["pending_complaints_count"] ?? 0,
    inProgressComplaintsCount: json["in_progress_complaints_count"] ?? 0,
    closedComplaintsCount: json["closed_complaints_count"] ?? 0,
    roles: json["roles"] == null ? [] : List<Role>.from(json["roles"]!.map((x) => Role.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "area_id": areaId,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "phone_no": phoneNo,
    "is_active": isActive,
    "duty_start": dutyStart,
    "duty_end": dutyEnd,
    "duty_hours": dutyHours,
    "device_token": deviceToken,
    "in_time": inTime,
    "out_time": outTime,
    "in_date": inDate,
    "out_date": outDate,
    "ap": ap,
    "late_hrs": lateHrs,
    "earligoing_hrs": earligoingHrs,
    "working_hrs": workingHrs,
    "pdays": pdays,
    "in_address": inAddress,
    "out_address": outAddress,
    "attendance_status": attendanceStatus,
    "pending_complaints_count": pendingComplaintsCount,
    "in_progress_complaints_count": inProgressComplaintsCount,
    "closed_complaints_count": closedComplaintsCount,
    "roles": roles == null ? [] : List<dynamic>.from(roles!.map((x) => x.toJson())),
  };
}

class Role {
  int? id;
  String? name;
  String? guardName;

  Role({
    this.id,
    this.name,
    this.guardName,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"],
    name: json["name"],
    guardName: json["guard_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "guard_name": guardName,
  };
}