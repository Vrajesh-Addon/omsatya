import 'dart:convert';

import 'package:omsatya/models/sales_person/lead_sales_person_response.dart';

GetSalesPersonByIdResponse getSalesPersonByIdResponseFromJson(String str) => GetSalesPersonByIdResponse.fromJson(json.decode(str));

String getSalesPersonByIdResponseToJson(GetSalesPersonByIdResponse data) => json.encode(data.toJson());

class GetSalesPersonByIdResponse {
  bool? success;
  String? message;
  LeadSalesPersonData? data;

  GetSalesPersonByIdResponse({
    this.success,
    this.message,
    this.data,
  });

  factory GetSalesPersonByIdResponse.fromJson(Map<String, dynamic> json) => GetSalesPersonByIdResponse(
    success: json["success"],
    message: json["message"],
    data: LeadSalesPersonData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data!.toJson(),
  };
}