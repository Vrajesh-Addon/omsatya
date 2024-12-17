import 'dart:convert';

import 'package:omsatya/models/todo/todo_data.dart';

TodoResponse todoResponseFromJson(String str) => TodoResponse.fromJson(json.decode(str));

String todoResponseToJson(TodoResponse data) => json.encode(data.toJson());

class TodoResponse {
  bool? status;
  String? message;
  TodoData? data;

  TodoResponse({
    this.status,
    this.message,
    this.data,
  });

  factory TodoResponse.fromJson(Map<String, dynamic> json) => TodoResponse(
    status: json["status"],
    message: json["message"],
    data: TodoData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data!.toJson(),
  };
}


