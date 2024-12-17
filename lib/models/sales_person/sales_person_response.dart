import 'dart:convert';

SalesPersonResponse salesPersonResponseFromJson(String str) => SalesPersonResponse.fromJson(json.decode(str));

String salesPersonResponseToJson(SalesPersonResponse data) => json.encode(data.toJson());

class SalesPersonResponse {
  bool success;
  String message;
  List<SalesPersonData> data;

  SalesPersonResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SalesPersonResponse.fromJson(Map<String, dynamic> json) => SalesPersonResponse(
    success: json["success"],
    message: json["message"],
    data: List<SalesPersonData>.from(json["data"].map((x) => SalesPersonData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class SalesPersonData {
  int? id;
  int? areaId;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? phoneNo;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  String? dutyHours;

  SalesPersonData({
    this.id,
    this.areaId,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phoneNo,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
  });

  factory SalesPersonData.fromJson(Map<String, dynamic> json) => SalesPersonData(
    id: json["id"],
    areaId: json["area_id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    phoneNo: json["phone_no"],
    isActive: json["is_active"],
    dutyStart: json["duty_start"] ?? "",
    dutyEnd: json["duty_end"] ?? "",
    dutyHours: json["duty_hours"] ?? "",
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
  };
}
