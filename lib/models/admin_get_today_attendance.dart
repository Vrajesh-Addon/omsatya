import 'dart:convert';

AdminGetTodayAttendanceResponse adminGetTodayAttendanceResponseFromJson(String str) =>
    AdminGetTodayAttendanceResponse.fromJson(json.decode(str));

String adminGetTodayAttendanceResponseToJson(AdminGetTodayAttendanceResponse data) => json.encode(data.toJson());

class AdminGetTodayAttendanceResponse {
  bool success;
  String message;
  List<AdminGetTodayAttendanceData> data;

  AdminGetTodayAttendanceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdminGetTodayAttendanceResponse.fromJson(Map<String, dynamic> json) => AdminGetTodayAttendanceResponse(
        success: json["success"],
        message: json["message"],
        data: List<AdminGetTodayAttendanceData>.from(json["data"].map((x) => AdminGetTodayAttendanceData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AdminGetTodayAttendanceData {
  int? id;
  int? firmId;
  int? engineerId;
  int? yearId;
  String? inDate;
  String? inTime;
  String? outDate;
  String? outTime;
  String? ap;
  double? lateHrs;
  double? earligoingHrs;
  double? workingHrs;
  double? pdays;
  String? inLate;
  String? inLong;
  String? inAddress;
  String? outLate;
  String? outLong;
  String? outAddress;
  Users? users;

  AdminGetTodayAttendanceData({
    this.id,
    this.firmId,
    this.engineerId,
    this.yearId,
    this.inDate,
    this.inTime,
    this.outDate,
    this.outTime,
    this.ap,
    this.lateHrs,
    this.earligoingHrs,
    this.workingHrs,
    this.pdays,
    this.inLate,
    this.inLong,
    this.inAddress,
    this.outLate,
    this.outLong,
    this.outAddress,
    this.users,
  });

  factory AdminGetTodayAttendanceData.fromJson(Map<String, dynamic> json) => AdminGetTodayAttendanceData(
        id: json["id"],
        firmId: json["firm_id"],
        engineerId: json["engineer_id"],
        yearId: json["year_id"],
        inDate: json["in_date"],
        inTime: json["in_time"],
        outDate: json["out_date"] ?? "",
        outTime: json["out_time"] ?? "",
        ap: json["ap"],
        lateHrs: json["late_hrs"] == 0
            ? 0.0
            : json["late_hrs"] is int
                ? double.parse(json["late_hrs"].toString())
                : json["late_hrs"] ?? 0.0,
        earligoingHrs: json["earligoing_hrs"] == 0
            ? 0.0
            : json["earligoing_hrs"] is int
                ? double.parse(json["earligoing_hrs"].toString())
                : json["earligoing_hrs"] ?? 0.0,
        workingHrs: json["working_hrs"] == 0
            ? 0.0
            : json["working_hrs"] is int
                ? double.parse(json["working_hrs"].toString())
                : json["working_hrs"] ?? 0.0,
        pdays: json["pdays"] == 0
            ? 0.0
            : json["pdays"] is int
                ? double.parse(json["pdays"].toString())
                : json["pdays"] ?? 0.0,
        inLate: json["in_late"],
        inLong: json["in_long"],
        inAddress: json["in_address"],
        outLate: json["out_late"] ?? "",
        outLong: json["out_long"] ?? "",
        outAddress: json["out_address"] ?? "",
        users: json["users"] == null ? null : Users.fromJson(json["users"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firm_id": firmId,
        "engineer_id": engineerId,
        "year_id": yearId,
        "in_date": inDate,
        "in_time": inTime,
        "out_date": outDate,
        "out_time": outTime,
        "ap": ap,
        "late_hrs": lateHrs,
        "earligoing_hrs": earligoingHrs,
        "working_hrs": workingHrs,
        "pdays": pdays,
        "in_late": inLate,
        "in_long": inLong,
        "in_address": inAddress,
        "out_late": outLate,
        "out_long": outLong,
        "out_address": outAddress,
        "users": users?.toJson(),
      };
}

class Users {
  int id;
  int areaId;
  String name;
  dynamic email;
  dynamic emailVerifiedAt;
  DateTime createdAt;
  DateTime updatedAt;
  String phoneNo;
  int isActive;
  String dutyStart;
  String dutyEnd;
  dynamic dutyHours;

  Users({
    required this.id,
    required this.areaId,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.phoneNo,
    required this.isActive,
    required this.dutyStart,
    required this.dutyEnd,
    required this.dutyHours,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        id: json["id"],
        areaId: json["area_id"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        phoneNo: json["phone_no"],
        isActive: json["is_active"],
        dutyStart: json["duty_start"],
        dutyEnd: json["duty_end"],
        dutyHours: json["duty_hours"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "area_id": areaId,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "phone_no": phoneNo,
        "is_active": isActive,
        "duty_start": dutyStart,
        "duty_end": dutyEnd,
        "duty_hours": dutyHours,
      };
}
