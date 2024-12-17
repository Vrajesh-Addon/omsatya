import 'dart:convert';

GetComplainNoResponse getComplainNoResponseFromJson(String str) => GetComplainNoResponse.fromJson(json.decode(str));

String getComplainNoResponseToJson(GetComplainNoResponse data) => json.encode(data.toJson());

class GetComplainNoResponse {
  bool success;
  String message;
  int data;

  GetComplainNoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetComplainNoResponse.fromJson(Map<String, dynamic> json) => GetComplainNoResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data,
  };
}
