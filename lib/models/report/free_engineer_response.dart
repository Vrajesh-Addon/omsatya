
import 'dart:convert';

FreeEngineerResponse freeEngineerResponseFromJson(String str) => FreeEngineerResponse.fromJson(json.decode(str));

String freeEngineerResponseToJson(FreeEngineerResponse data) => json.encode(data.toJson());

class FreeEngineerResponse {
  bool? success;
  String? message;
  List<FreeEngineerData>? data;

  FreeEngineerResponse({
    this.success,
    this.message,
    this.data,
  });

  factory FreeEngineerResponse.fromJson(Map<String, dynamic> json) => FreeEngineerResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<FreeEngineerData>.from(json["data"]!.map((x) => FreeEngineerData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class FreeEngineerData {
  int? id;
  String? name;
  int? pendingComplaints;

  FreeEngineerData({
    this.id,
    this.name,
    this.pendingComplaints,
  });

  factory FreeEngineerData.fromJson(Map<String, dynamic> json) => FreeEngineerData(
    id: json["id"],
    name: json["name"],
    pendingComplaints: json["pending_complaints"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "pending_complaints": pendingComplaints,
  };
}
