import 'dart:convert';

import 'package:omsatya/models/todo/todo_task.dart';
import 'package:omsatya/models/user_response.dart';

TodoData todoDataFromJson(String str) => TodoData.fromJson(json.decode(str));

String todoDataToJson(TodoData data) => json.encode(data.toJson());

class TodoData {
  int? id;
  String? title;
  String? description;
  dynamic userId;
  dynamic assignUserId;
  String? assignDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<TodoTask>? todoTasks;
  UserResponse? userResponse;

  TodoData({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.assignUserId,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
    this.todoTasks,
    this.userResponse,
  });

  factory TodoData.fromJson(Map<String, dynamic> json) => TodoData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    userId: json["user_id"],
    assignUserId: json["assign_user_id"],
    assignDateTime: json["assign_date_time"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    todoTasks: json["todo_tasks"] == null ? null : List<TodoTask>.from(json["todo_tasks"].map((x) => TodoTask.fromJson(x))),
    userResponse: json["assigned_user"] == null ? null : UserResponse.fromJson(json["assigned_user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "user_id": userId,
    "assign_user_id": assignUserId,
    "assign_date_time": assignDateTime,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "todo_tasks": List<dynamic>.from(todoTasks!.map((x) => x.toJson())),
    "assigned_user": userResponse!.toJson(),
  };
}