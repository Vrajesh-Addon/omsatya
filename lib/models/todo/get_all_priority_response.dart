import 'dart:convert';

import 'package:omsatya/models/todo/priority_response.dart';

GetAllPriorityResponse getAllPriorityResponseFromJson(String str) => GetAllPriorityResponse.fromJson(json.decode(str));

String getAllPriorityResponseToJson(GetAllPriorityResponse data) => json.encode(data.toJson());

class GetAllPriorityResponse {
  bool success;
  String message;
  List<PriorityResponse> data;
  int total;

  GetAllPriorityResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
  });

  factory GetAllPriorityResponse.fromJson(Map<String, dynamic> json) => GetAllPriorityResponse(
    success: json["success"],
    message: json["message"],
    data: List<PriorityResponse>.from(json["data"].map((x) => PriorityResponse.fromJson(x))),
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "total": total,
  };
}