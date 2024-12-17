import 'dart:convert';

TodoStatusResponse todoStatusResponseFromJson(String str) => TodoStatusResponse.fromJson(json.decode(str));

String todoStatusResponseToJson(TodoStatusResponse data) => json.encode(data.toJson());

class TodoStatusResponse {
  bool? status;
  String? message;
  TodoStatusData? data;

  TodoStatusResponse({
    this.status,
    this.message,
    this.data,
  });

  factory TodoStatusResponse.fromJson(Map<String, dynamic> json) => TodoStatusResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : TodoStatusData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class TodoStatusData {
  int? id;
  String? title;
  String? description;
  int? userId;
  DateTime? assignDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic status;

  TodoStatusData({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory TodoStatusData.fromJson(Map<String, dynamic> json) => TodoStatusData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    userId: json["user_id"],
    assignDateTime: json["assign_date_time"] == null ? null : DateTime.parse(json["assign_date_time"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "user_id": userId,
    "assign_date_time": assignDateTime?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "status": status,
  };
}
