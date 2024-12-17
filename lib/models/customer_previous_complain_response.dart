import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

CustomerPreviousComplainResponse customerPreviousComplainResponseFromJson(String str) => CustomerPreviousComplainResponse.fromJson(json.decode(str));

String customerPreviousComplainResponseToJson(CustomerPreviousComplainResponse data) => json.encode(data.toJson());

class CustomerPreviousComplainResponse {
  bool success;
  String message;
  List<ComplainData> data;

  CustomerPreviousComplainResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CustomerPreviousComplainResponse.fromJson(Map<String, dynamic> json) => CustomerPreviousComplainResponse(
    success: json["success"],
    message: json["message"],
    data: List<ComplainData>.from(json["data"].map((x) => ComplainData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}