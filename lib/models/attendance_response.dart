import 'dart:convert';

AttendanceResponse attendanceResponseFromJson(String str) => AttendanceResponse.fromJson(json.decode(str));

String attendanceResponseToJson(AttendanceResponse data) => json.encode(data.toJson());

class AttendanceResponse {
  bool success;
  String message;
  AttendanceData data;

  AttendanceResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) => AttendanceResponse(
    success: json["success"],
    message: json["message"],
    data: AttendanceData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class AttendanceData {
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
  String? earligoingHrs;
  String? workingHrs;
  double? pdays;
  double? inLate;
  double? inLong;
  String? inAddress;
  double? outLate;
  double? outLong;
  String? outAddress;

  AttendanceData({
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
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
    id: json["id"],
    firmId: json["firm_id"],
    engineerId: json["engineer_id"],
    yearId: json["year_id"],
    inDate: json["in_date"] ?? "",
    inTime: json["in_time"] ?? "",
    outDate: json["out_date"] ?? "",
    outTime: json["out_time"] ?? "",
    ap: json["ap"],
    lateHrs: json["late_hrs"] != null ? double.parse(json["late_hrs"].toString()) : 0.0,
    earligoingHrs: json["earligoing_hrs"].toString(),
    workingHrs: json["working_hrs"].toString(),
    pdays: json["pdays"] != null ? double.parse(json["pdays"].toString()) : 0.0,
    inLate: json["in_late"] != null ? double.parse(json["in_late"].toString()) : 0.0,
    inLong: json["in_long"] != null ? double.parse(json["in_long"].toString()) : 0.0,
    inAddress: json["in_address"] ?? "",
    outLate: json["out_late"] != null ? double.parse(json["out_late"].toString()) : 0.0,
    outLong: json["out_long"] != null ? double.parse(json["out_long"].toString()) : 0.0,
    outAddress: json["out_address"] ?? "",
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
  };
}
