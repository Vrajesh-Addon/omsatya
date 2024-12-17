import 'dart:convert';

DeleteTodoResponse deleteTodoResponseFromJson(String str) => DeleteTodoResponse.fromJson(json.decode(str));

String deleteTodoResponseToJson(DeleteTodoResponse data) => json.encode(data.toJson());

class DeleteTodoResponse {
  bool status;
  String message;

  DeleteTodoResponse({
    required this.status,
    required this.message,
  });

  factory DeleteTodoResponse.fromJson(Map<String, dynamic> json) => DeleteTodoResponse(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}


DeleteSalesResponse deleteSalesResponseFromJson(String str) => DeleteSalesResponse.fromJson(json.decode(str));

String deleteSalesResponseToJson(DeleteSalesResponse data) => json.encode(data.toJson());

class DeleteSalesResponse {
  bool success;
  String message;

  DeleteSalesResponse({
    required this.success,
    required this.message,
  });

  factory DeleteSalesResponse.fromJson(Map<String, dynamic> json) => DeleteSalesResponse(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}
