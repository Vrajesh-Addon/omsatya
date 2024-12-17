import 'dart:convert';

import 'package:omsatya/models/todo/get_todo_all_data.dart';
import 'package:omsatya/models/todo/priority_response.dart';

TodoTask todoTaskFromJson(String str) => TodoTask.fromJson(json.decode(str));

String todoTaskToJson(TodoTask data) => json.encode(data.toJson());

class TodoTask {
  int? id;
  int? todoId;
  String? date;
  String?time;
  String?commentFirst;
  String?commentSecond;
  int? priorityId;
  PriorityResponse? priorityResponse;
  int? userId;
  AssignUserDetail? todoTaskUser;

  TodoTask({
    this.id,
    this.todoId,
    this.date,
    this.time,
    this.commentFirst,
    this.commentSecond,
    this.priorityId,
    this.priorityResponse,
    this.userId,
    this.todoTaskUser,
  });

  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
    id: json["id"],
    todoId: json["todo_id"],
    date: json["date"],
    time: json["time"],
    commentFirst: json["comment_first"],
    commentSecond: json["comment_second"],
    priorityId: json["priority_id"],
    priorityResponse: json["prioritys"] == null ? null : PriorityResponse.fromJson(json["prioritys"]),
    userId: json["user_id"] ?? 0,
    todoTaskUser: json["todo_task_user"] == null ? null : AssignUserDetail.fromJson(json["todo_task_user"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "todo_id": todoId,
    "date": date,
    "time": time,
    "comment_first": commentFirst,
    "comment_second": commentSecond,
    "priority_id": priorityId,
    "prioritys": priorityResponse!.toJson(),
    "user_id": userId,
    "todo_task_user": todoTaskUser!.toJson(),
  };
}