
import 'dart:convert';

import 'package:omsatya/models/todo/get_todo_all_data.dart';

GetTodoFilterResponse getTodoFilterResponseFromJson(String str) => GetTodoFilterResponse.fromJson(json.decode(str));

String getTodoFilterResponseToJson(GetTodoFilterResponse data) => json.encode(data.toJson());

class GetTodoFilterResponse {
  bool? success;
  String? message;
  GetAllTodoData? data;

  GetTodoFilterResponse({
    this.success,
    this.message,
    this.data,
  });

  factory GetTodoFilterResponse.fromJson(Map<String, dynamic> json) => GetTodoFilterResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] is List && json["data"].isEmpty ? null : GetAllTodoData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}