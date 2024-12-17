import 'dart:convert';

TodoFavouriteResponse todoFavouriteResponseFromJson(String str) => TodoFavouriteResponse.fromJson(json.decode(str));

String todoFavouriteResponseToJson(TodoFavouriteResponse data) => json.encode(data.toJson());

class TodoFavouriteResponse {
  bool? status;
  String? message;
  TodoFavouriteData? data;

  TodoFavouriteResponse({
    this.status,
    this.message,
    this.data,
  });

  factory TodoFavouriteResponse.fromJson(Map<String, dynamic> json) => TodoFavouriteResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : TodoFavouriteData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class TodoFavouriteData {
  int? id;
  String? title;
  String? description;
  int? userId;
  DateTime? assignDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? status;
  int? favorite;

  TodoFavouriteData({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.favorite,
  });

  factory TodoFavouriteData.fromJson(Map<String, dynamic> json) => TodoFavouriteData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    userId: json["user_id"],
    assignDateTime: json["assign_date_time"] == null ? null : DateTime.parse(json["assign_date_time"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    status: json["status"],
    favorite: json["favorite"],
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
    "favorite": favorite,
  };
}
