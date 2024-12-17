import 'dart:convert';

AddCommentResponse addCommentResponseFromJson(String str) => AddCommentResponse.fromJson(json.decode(str));

String addCommentResponseToJson(AddCommentResponse data) => json.encode(data.toJson());

class AddCommentResponse {
  bool? success;
  String? message;
  AddCommentData? data;

  AddCommentResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AddCommentResponse.fromJson(Map<String, dynamic> json) => AddCommentResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : AddCommentData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class AddCommentData {
  String? todoId;
  String? date;
  String? time;
  String? commentFirst;
  String? commentSecond;
  String? priorityId;
  String? userId;
  int? id;

  AddCommentData({
    this.todoId,
    this.date,
    this.time,
    this.commentFirst,
    this.commentSecond,
    this.priorityId,
    this.userId,
    this.id,
  });

  factory AddCommentData.fromJson(Map<String, dynamic> json) => AddCommentData(
    todoId: json["todo_id"],
    date: json["date"],
    time: json["time"],
    commentFirst: json["comment_first"],
    commentSecond: json["comment_second"],
    priorityId: json["priority_id"],
    userId: json["user_id"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "todo_id": todoId,
    "date": date,
    "time": time,
    "comment_first": commentFirst,
    "comment_second": commentSecond,
    "priority_id": priorityId,
    "user_id": userId,
    "id": id,
  };
}
