// To parse this JSON data, do
//
//     final salesUserReportResponse = salesUserReportResponseFromJson(jsonString);

import 'dart:convert';

import 'package:omsatya/models/sales_person/sales_person_task.dart';
import 'package:omsatya/models/todo/priority_response.dart';
import 'package:omsatya/models/user_response.dart';

SalesUserReportResponse salesUserReportResponseFromJson(String str) => SalesUserReportResponse.fromJson(json.decode(str));

String salesUserReportResponseToJson(SalesUserReportResponse data) => json.encode(data.toJson());

class SalesUserReportResponse {
  bool? status;
  List<SalesUserReportData>? data;

  SalesUserReportResponse({
    this.status,
    this.data,
  });

  factory SalesUserReportResponse.fromJson(Map<String, dynamic> json) => SalesUserReportResponse(
    status: json["status"],
    data: json["data"] == null ? [] : List<SalesUserReportData>.from(json["data"]!.map((x) => SalesUserReportData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class SalesUserReportData {
  int? id;
  String? tag;
  int? firmId;
  int? yearId;
  int? areaId;
  int? productId;
  int? leadStageId;
  int? saleUserId;
  int? saleAssignUserId;
  String? date;
  String? time;
  String? mobileNo;
  String? partyname;
  String? address;
  String? locationAddress;
  String? latitude;
  String? logitude;
  String? remarks;
  String? nextReminderDate;
  String? nextReminderTime;
  int? favorite;
  int? statusId;
  int? closedBy;
  String? closedDate;
  String? inAddress;
  String? outAddress;
  String? inDateTime;
  String? outDateTime;
  String? timeDuration;
  UserResponse? salseUserDetail;
  UserResponse? saleAssignUserDetail;
  Product? product;
  PriorityResponse? statusDetail;
  List<SalesPersonTask>? salesPersonTask;
  bool isExpanded;

  SalesUserReportData({
    this.id,
    this.tag,
    this.firmId,
    this.yearId,
    this.areaId,
    this.productId,
    this.leadStageId,
    this.saleUserId,
    this.saleAssignUserId,
    this.date,
    this.time,
    this.mobileNo,
    this.partyname,
    this.address,
    this.locationAddress,
    this.latitude,
    this.logitude,
    this.remarks,
    this.nextReminderDate,
    this.nextReminderTime,
    this.favorite,
    this.statusId,
    this.closedBy,
    this.closedDate,
    this.inAddress,
    this.outAddress,
    this.inDateTime,
    this.outDateTime,
    this.timeDuration,
    this.salseUserDetail,
    this.saleAssignUserDetail,
    this.product,
    this.statusDetail,
    this.salesPersonTask,
    this.isExpanded = false,
  });

  factory SalesUserReportData.fromJson(Map<String, dynamic> json) => SalesUserReportData(
    id: json["id"],
    tag: json["tag"],
    firmId: json["firm_id"],
    yearId: json["year_id"],
    areaId: json["area_id"],
    productId: json["product_id"],
    leadStageId: json["lead_stage_id"],
    saleUserId: json["sale_user_id"],
    saleAssignUserId: json["sale_assign_user_id"],
    date: json["date"],
    time: json["time"],
    mobileNo: json["mobile_no"],
    partyname: json["partyname"],
    address: json["address"],
    locationAddress: json["location_Address"],
    latitude: json["latitude"],
    logitude: json["logitude"],
    remarks: json["remarks"],
    nextReminderDate: json["next_reminder_date"],
    nextReminderTime: json["next_reminder_time"],
    favorite: json["favorite"],
    statusId: json["status_id"],
    closedBy: json["closed_by"],
    closedDate: json["closed_date"],
    inAddress: json["in_address"],
    outAddress: json["out_address"],
    inDateTime: json["in_date_time"],
    outDateTime: json["out_date_time"],
    timeDuration: json["time_duration"],
    salseUserDetail: json["salse_user_detail"] == null ? null : UserResponse.fromJson(json["salse_user_detail"]),
    saleAssignUserDetail: json["sale_assign_user_detail"] == null ? null : UserResponse.fromJson(json["sale_assign_user_detail"]),
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    statusDetail: json["status_detail"] == null ? null : PriorityResponse.fromJson(json["status_detail"]),
    salesPersonTask: List<SalesPersonTask>.from(json["sales_person_task"].map((x) => SalesPersonTask.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tag": tag,
    "firm_id": firmId,
    "year_id": yearId,
    "area_id": areaId,
    "product_id": productId,
    "lead_stage_id": leadStageId,
    "sale_user_id": saleUserId,
    "sale_assign_user_id": saleAssignUserId,
    "date": date,
    "time": time,
    "mobile_no": mobileNo,
    "partyname": partyname,
    "address": address,
    "location_Address": locationAddress,
    "latitude": latitude,
    "logitude": logitude,
    "remarks": remarks,
    "next_reminder_date": nextReminderDate,
    "next_reminder_time": nextReminderTime,
    "favorite": favorite,
    "status_id": statusId,
    "closed_by": closedBy,
    "closed_date": closedDate,
    "in_address": inAddress,
    "out_address": outAddress,
    "in_date_time": inDateTime,
    "out_date_time": outDateTime,
    "time_duration": timeDuration,
    "salse_user_detail": salseUserDetail?.toJson(),
    "sale_assign_user_detail": saleAssignUserDetail?.toJson(),
    "product": product?.toJson(),
    "status_detail": statusDetail?.toJson(),
    "sales_person_task": List<dynamic>.from(salesPersonTask!.map((x) => x.toJson())),
  };
}

class Product {
  int? id;
  String? name;
  int? productGroupId;
  int? productTypeId;
  int? tag;

  Product({
    this.id,
    this.name,
    this.productGroupId,
    this.productTypeId,
    this.tag,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    productGroupId: json["product_group_id"],
    productTypeId: json["product_type_id"],
    tag: json["tag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "product_group_id": productGroupId,
    "product_type_id": productTypeId,
    "tag": tag,
  };
}
