import 'dart:convert';

import 'package:omsatya/models/todo/get_todo_all_data.dart';
import 'package:omsatya/models/todo/todo_task.dart';

TodoDataByIdResponse todoDataByIdResponseFromJson(String str) => TodoDataByIdResponse.fromJson(json.decode(str));

String todoDataByIdResponseToJson(TodoDataByIdResponse data) => json.encode(data.toJson());

class TodoDataByIdResponse {
  bool? status;
  String? message;
  TodoDataById? data;

  TodoDataByIdResponse({
    this.status,
    this.message,
    this.data,
  });

  factory TodoDataByIdResponse.fromJson(Map<String, dynamic> json) => TodoDataByIdResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : TodoDataById.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class TodoDataById {
  int? id;
  String? title;
  String? description;
  int? userId;
  DateTime? assignDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? status;
  List<TodoTask>? todoTasks;
  List<TodoAssignUser>? todoAssignUsers;

  TodoDataById({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.todoTasks,
    this.todoAssignUsers,
  });

  factory TodoDataById.fromJson(Map<String, dynamic> json) => TodoDataById(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    userId: json["user_id"],
    assignDateTime: json["assign_date_time"] == null ? null : DateTime.parse(json["assign_date_time"]),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    status: json["status"],
    todoTasks: json["todo_tasks"] == null ? [] : List<TodoTask>.from(json["todo_tasks"]!.map((x) => TodoTask.fromJson(x))),
    todoAssignUsers: json["todo_assign_users"] == null ? [] : List<TodoAssignUser>.from(json["todo_assign_users"]!.map((x) => TodoAssignUser.fromJson(x))),
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
    "todo_tasks": todoTasks == null ? [] : List<dynamic>.from(todoTasks!.map((x) => x.toJson())),
    "todo_assign_users": todoAssignUsers == null ? [] : List<dynamic>.from(todoAssignUsers!.map((x) => x.toJson())),
  };
}


