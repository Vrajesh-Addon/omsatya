import 'dart:convert';

RolesResponse rolesResponseFromJson(String str) => RolesResponse.fromJson(json.decode(str));

String rolesResponseToJson(RolesResponse data) => json.encode(data.toJson());

class RolesResponse {
  bool? success;
  String? message;
  List<RolesData>? data;

  RolesResponse({
    this.success,
    this.message,
    this.data,
  });

  factory RolesResponse.fromJson(Map<String, dynamic> json) => RolesResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<RolesData>.from(json["data"]!.map((x) => RolesData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class RolesData {
  int? id;
  String? name;
  String? guardName;
  DateTime? createdAt;
  DateTime? updatedAt;

  RolesData({
    this.id,
    this.name,
    this.guardName,
    this.createdAt,
    this.updatedAt,
  });

  factory RolesData.fromJson(Map<String, dynamic> json) => RolesData(
    id: json["id"],
    name: json["name"],
    guardName: json["guard_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "guard_name": guardName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
