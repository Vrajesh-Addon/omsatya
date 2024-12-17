import 'dart:convert';

import 'package:omsatya/models/todo/get_todo_all_data.dart';
import 'package:omsatya/models/todo/priority_response.dart';

SalesPersonTask salesPersonTaskFromJson(String str) => SalesPersonTask.fromJson(json.decode(str));

String salesPersonTaskToJson(SalesPersonTask data) => json.encode(data.toJson());

class SalesPersonTask {
  int? id;
  int? todoId;
  String? date;
  String?time;
  String?commentFirst;
  String?commentSecond;
  int? priorityId;
  int? assignUserId;
  PriorityResponse? priorityResponse;
  AssignUserDetail?assignUserDetail;

  SalesPersonTask({
    this.id,
    this.todoId,
    this.date,
    this.time,
    this.assignUserId,
    this.commentFirst,
    this.commentSecond,
    this.priorityId,
    this.priorityResponse,
    this.assignUserDetail
  });

  factory SalesPersonTask.fromJson(Map<String, dynamic> json) => SalesPersonTask(
    id: json["id"],
    todoId: json["todo_id"],
    date: json["date"],
    time: json["time"],
    assignUserId: json["assign_user_id"],
    commentFirst: json["comment_first"],
    commentSecond: json["comment_second"],
    priorityId: json["priority_id"],
    priorityResponse: json["prioritys"] == null ? null : PriorityResponse.fromJson(json["prioritys"]),
    assignUserDetail: json["assign_user_detail"] == null ? null : AssignUserDetail.fromJson(json["assign_user_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "todo_id": todoId,
    "date": date,
    "time": time,
    "assign_user_id": assignUserId,
    "comment_first": commentFirst,
    "comment_second": commentSecond,
    "priority_id": priorityId,
    "prioritys": priorityResponse!.toJson(),
    "assign_user_detail": assignUserDetail!.toJson(),
  };
}