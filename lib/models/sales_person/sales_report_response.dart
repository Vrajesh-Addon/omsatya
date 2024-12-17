import 'dart:convert';

import 'package:omsatya/models/user_response.dart';

SalesReportResponse salesReportResponseFromJson(String str) => SalesReportResponse.fromJson(json.decode(str));

String salesReportResponseToJson(SalesReportResponse data) => json.encode(data.toJson());

class SalesReportResponse {
  bool? status;
  List<SalesReportData>? data;
  int? totalRecords;

  SalesReportResponse({
    this.status,
    this.data,
    this.totalRecords,
  });

  factory SalesReportResponse.fromJson(Map<String, dynamic> json) => SalesReportResponse(
    status: json["status"],
    data: json["data"] == null ? [] : List<SalesReportData>.from(json["data"]!.map((x) => SalesReportData.fromJson(x))),
    totalRecords: json["total_records"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "total_records": totalRecords,
  };
}

class SalesReportData {
  int? saleUserId;
  int? totalSales;
  UserResponse? salseUserDetail;

  SalesReportData({
    this.saleUserId,
    this.totalSales,
    this.salseUserDetail,
  });

  factory SalesReportData.fromJson(Map<String, dynamic> json) => SalesReportData(
    saleUserId: json["sale_user_id"],
    totalSales: json["total_sales"],
    salseUserDetail: json["salse_user_detail"] == null ? null : UserResponse.fromJson(json["salse_user_detail"]),
  );

  Map<String, dynamic> toJson() => {
    "sale_user_id": saleUserId,
    "total_sales": totalSales,
    "salse_user_detail": salseUserDetail?.toJson(),
  };
}

