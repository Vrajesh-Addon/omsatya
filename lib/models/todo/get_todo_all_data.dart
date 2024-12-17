import 'dart:convert';

import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/models/todo/todo_task.dart';

GetAllTodoResponse getAllTodoResponseFromJson(String str) => GetAllTodoResponse.fromJson(json.decode(str));

String getAllTodoResponseToJson(GetAllTodoResponse data) => json.encode(data.toJson());

class GetAllTodoResponse {
  bool? success;
  String? message;
  GetAllTodoData? data;

  GetAllTodoResponse({
    this.success,
    this.message,
    this.data,
  });

  factory GetAllTodoResponse.fromJson(Map<String, dynamic> json) => GetAllTodoResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : GetAllTodoData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class GetAllTodoData {
  List<GetTodoData>? todo;
  List<TodoAssignUserElement>? todoAssignUser;

  GetAllTodoData({
    this.todo,
    this.todoAssignUser,
  });

  factory GetAllTodoData.fromJson(Map<String, dynamic> json) => GetAllTodoData(
    todo: json["todo"] == null ? [] : List<GetTodoData>.from(json["todo"]!.map((x) => GetTodoData.fromJson(x))),
    todoAssignUser: json["todoAssignUser"] == null ? [] : List<TodoAssignUserElement>.from(json["todoAssignUser"]!.map((x) => TodoAssignUserElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "todo": todo == null ? [] : List<dynamic>.from(todo!.map((x) => x.toJson())),
    "todoAssignUser": todoAssignUser == null ? [] : List<dynamic>.from(todoAssignUser!.map((x) => x.toJson())),
  };
}

class TodoAssignUserElement {
  GetTodoData? todoDetail;

  TodoAssignUserElement({
    this.todoDetail,
  });

  factory TodoAssignUserElement.fromJson(Map<String, dynamic> json) => TodoAssignUserElement(
    todoDetail: json["todo_detail"] == null ? null : GetTodoData.fromJson(json["todo_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "todo_detail": todoDetail?.toJson(),
  };
}

class GetTodoData {
  int? id;
  String? title;
  String? description;
  int? userId;
  String? assignDateTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? priorityId;
  int? status;
  int? favorite;
  List<TodoTask>? todoTasks;
  List<TodoAssignUser>? todoAssignUsers;
  bool isExpanded;
  AssignUserDetail? todoUser;
  PriorityResponse? priority;

  GetTodoData({
    this.id,
    this.title,
    this.description,
    this.userId,
    this.assignDateTime,
    this.createdAt,
    this.updatedAt,
    this.priorityId,
    this.status,
    this.favorite,
    this.todoTasks,
    this.todoAssignUsers,
    this.isExpanded = false,
    this.todoUser,
    this.priority,
  });

  factory GetTodoData.fromJson(Map<String, dynamic> json) => GetTodoData(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    userId: json["user_id"],
    assignDateTime: json["assign_date_time"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    priorityId: json["priority_id"],
    status: json["status"],
    favorite: json["favorite"],
    todoTasks: json["todo_tasks"] == null ? [] : List<TodoTask>.from(json["todo_tasks"]!.map((x) => TodoTask.fromJson(x))),
    todoAssignUsers: json["todo_assign_users"] == null ? [] : List<TodoAssignUser>.from(json["todo_assign_users"]!.map((x) => TodoAssignUser.fromJson(x))),
    todoUser: json["todo_user"] == null ? null : AssignUserDetail.fromJson(json["todo_user"]),
    priority: json["priority"] == null ? null : PriorityResponse.fromJson(json["priority"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "user_id": userId,
    "assign_date_time": assignDateTime,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "priority_id": priorityId,
    "status": status,
    "favorite": favorite,
    "todo_tasks": todoTasks == null ? [] : List<dynamic>.from(todoTasks!.map((x) => x.toJson())),
    "todo_assign_users": todoAssignUsers == null ? [] : List<dynamic>.from(todoAssignUsers!.map((x) => x.toJson())),
    "todo_user": todoUser?.toJson(),
    "priority": priority?.toJson(),
  };
}

class AssignUserDetail {
  int? id;
  int? areaId;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? phoneNo;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  dynamic dutyHours;
  String? deviceToken;

  AssignUserDetail({
    this.id,
    this.areaId,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.phoneNo,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
    this.deviceToken,
  });

  factory AssignUserDetail.fromJson(Map<String, dynamic> json) => AssignUserDetail(
    id: json["id"],
    areaId: json["area_id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    phoneNo: json["phone_no"],
    isActive: json["is_active"],
    dutyStart: json["duty_start"],
    dutyEnd: json["duty_end"],
    dutyHours: json["duty_hours"],
    deviceToken: json["device_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "area_id": areaId,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "phone_no": phoneNo,
    "is_active": isActive,
    "duty_start": dutyStart,
    "duty_end": dutyEnd,
    "duty_hours": dutyHours,
    "device_token": deviceToken,
  };
}

class TodoAssignUser {
  int? id;
  int? todoId;
  int? assignUserId;
  AssignUserDetail? assignUserDetail;

  TodoAssignUser({
    this.id,
    this.todoId,
    this.assignUserId,
    this.assignUserDetail,
  });

  factory TodoAssignUser.fromJson(Map<String, dynamic> json) => TodoAssignUser(
    id: json["id"],
    todoId: json["todo_id"],
    assignUserId: json["assign_user_id"],
    assignUserDetail: json["assign_user_detail"] == null ? null : AssignUserDetail.fromJson(json["assign_user_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "todo_id": todoId,
    "assign_user_id": assignUserId,
    "assign_user_detail": assignUserDetail?.toJson(),
  };
}

