import 'dart:convert';

import 'package:omsatya/models/user_response.dart';

ApDetailsResponse apDetailsResponseFromJson(String str) => ApDetailsResponse.fromJson(json.decode(str));

String apDetailsResponseToJson(ApDetailsResponse data) => json.encode(data.toJson());

class ApDetailsResponse {
  bool? success;
  String? message;
  ApPageData? data;

  ApDetailsResponse({
    this.success,
    this.message,
    this.data,
  });

  factory ApDetailsResponse.fromJson(Map<String, dynamic> json) => ApDetailsResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] is List && json["data"].isEmpty ? null : ApPageData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class ApPageData {
  int? from;
  int? to;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  List<ApDetailsData>? data;

  ApPageData({
    this.from,
    this.to,
    this.total,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.data,
  });

  factory ApPageData.fromJson(Map<String, dynamic> json) => ApPageData(
    from: json["from"],
    to: json["to"],
    total: json["total"],
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    data: json["data"] == null ? [] : List<ApDetailsData>.from(json["data"]!.map((x) => ApDetailsData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "from": from,
    "to": to,
    "total": total,
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ApDetailsData {
  int? id;
  int? firmId;
  int? engineerId;
  int? yearId;
  String? inDate;
  String? inTime;
  String? outDate;
  String? outTime;
  String? ap;
  dynamic lateHrs;
  dynamic earligoingHrs;
  dynamic workingHrs;
  int? pdays;
  String? inLate;
  String? inLong;
  String? inAddress;
  String? outLate;
  String? outLong;
  String? outAddress;
  UserResponse? users;

  ApDetailsData({
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

  factory ApDetailsData.fromJson(Map<String, dynamic> json) => ApDetailsData(
    id: json["id"],
    firmId: json["firm_id"],
    engineerId: json["engineer_id"],
    yearId: json["year_id"],
    inDate: json["in_date"] ?? "",
    inTime: json["in_time"] ?? "",
    outDate: json["out_date"] ?? "",
    outTime: json["out_time"] ?? "",
    ap: json["ap"],
    lateHrs: json["late_hrs"],
    earligoingHrs: json["earligoing_hrs"],
    workingHrs: json["working_hrs"],
    pdays: json["pdays"],
    inLate: json["in_late"],
    inLong: json["in_long"],
    inAddress: json["in_address"],
    outLate: json["out_late"],
    outLong: json["out_long"],
    outAddress: json["out_address"],
    users: json["users"] == null ? null : UserResponse.fromJson(json["users"]),
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
