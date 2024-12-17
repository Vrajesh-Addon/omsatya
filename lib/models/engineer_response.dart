import 'dart:convert';

EngineerResponse engineerResponseFromJson(String str) => EngineerResponse.fromJson(json.decode(str));

String engineerResponseToJson(EngineerResponse data) => json.encode(data.toJson());

class EngineerResponse {
  bool success;
  String message;
  List<EngineerDataResponse> data;

  EngineerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EngineerResponse.fromJson(Map<String, dynamic> json) => EngineerResponse(
    success: json["success"],
    message: json["message"],
    data: List<EngineerDataResponse>.from(json["data"].map((x) => EngineerDataResponse.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class EngineerDataResponse {
  int id;
  String name;
  bool isSelected;
  int pendingComplaints;
  String phoneNo;
  int areaId;

  EngineerDataResponse({
    required this.id,
    required this.name,
    this.isSelected = false,
    required this.pendingComplaints,
    required this.phoneNo,
    required this.areaId,
  });

  factory EngineerDataResponse.fromJson(Map<String, dynamic> json) => EngineerDataResponse(
    id: json["id"],
    name: json["name"],
    pendingComplaints: json["pending_complaints"] ?? 0,
    phoneNo: json["phone_no"] ?? "",
    areaId: json["area_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "pending_complaints": pendingComplaints,
    "phone_no": phoneNo,
    "area_id": areaId,
  };
}
