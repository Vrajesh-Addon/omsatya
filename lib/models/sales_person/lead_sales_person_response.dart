import 'dart:convert';

import 'package:omsatya/models/sales_person/sales_person_task.dart';
import 'package:omsatya/models/todo/priority_response.dart';

LeadSalesPersonResponse leadSalesPersonResponseFromJson(String str) => LeadSalesPersonResponse.fromJson(json.decode(str));

String leadSalesPersonResponseToJson(LeadSalesPersonResponse data) => json.encode(data.toJson());

class LeadSalesPersonResponse {
  bool success;
  String message;
  List<LeadSalesPersonData> data;

  LeadSalesPersonResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LeadSalesPersonResponse.fromJson(Map<String, dynamic> json) => LeadSalesPersonResponse(
    success: json["success"],
    message: json["message"],
    data: List<LeadSalesPersonData>.from(json["data"].map((x) => LeadSalesPersonData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LeadSalesPersonData {
  int? id;
  String? tag;
  int? firmId;
  int? yearId;
  int? areaId;
  int? productId;
  int? leadStageId;
  int? saleUserId;
  int? saleAssignUserId;
  int? favourite;
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
  int? statusId;
  int? closedBy;
  String? closedDate;
  String? inAddress;
  String? outAddress;
  String? inDateTime;
  String? outDateTime;
  String? timeDuration;
  LeadArea? area;
  LeadProduct? product;
  PriorityResponse? priority;
  SaleAssignUser? saleUserDetail;
  SaleAssignUser? saleAssignUser;
  List<SalesPersonTask>? salesPersonTask;

  LeadSalesPersonData({
    this.id,
    this.tag,
    this.firmId,
    this.yearId,
    this.areaId,
    this.productId,
    this.leadStageId,
    this.saleUserId,
    this.favourite,
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
    this.statusId,
    this.closedBy,
    this.closedDate,
    this.inAddress,
    this.outAddress,
    this.inDateTime,
    this.outDateTime,
    this.timeDuration,
    this.area,
    this.product,
    this.priority,
    this.saleUserDetail,
    this.saleAssignUser,
    this.salesPersonTask,
  });

  factory LeadSalesPersonData.fromJson(Map<String, dynamic> json) => LeadSalesPersonData(
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
    favourite: json["favorite"],
    nextReminderDate: json["next_reminder_date"],
    nextReminderTime: json["next_reminder_time"],
    statusId: json["status_id"],
    closedBy: json["closed_by"],
    closedDate: json["closed_date"],
    inAddress: json["in_address"],
    outAddress: json["out_address"],
    inDateTime: json["in_date_time"],
    outDateTime: json["out_date_time"],
    timeDuration: json["time_duration"],
    area: LeadArea.fromJson(json["area"]),
    product: json["product"] == null ? null : LeadProduct.fromJson(json["product"]),
    priority: json["status_detail"] == null ? null : PriorityResponse.fromJson(json["status_detail"]),
    saleUserDetail: json["salse_user_detail"] == null ? null : SaleAssignUser.fromJson(json["salse_user_detail"]),
    saleAssignUser: json["sale_assign_user"] == null ? null : SaleAssignUser.fromJson(json["sale_assign_user"]),
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
    "favorite": favourite,
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
    "status_id": statusId,
    "closed_by": closedBy,
    "closed_date": closedDate,
    "in_address": inAddress,
    "out_address": outAddress,
    "in_date_time": inDateTime,
    "out_date_time": outDateTime,
    "time_duration": timeDuration,
    "area": area!.toJson(),
    "product": product!.toJson(),
    "status_detail": priority!.toJson(),
    "salse_user_detail": saleAssignUser!.toJson(),
    "sale_assign_user": saleAssignUser!.toJson(),
    "sales_person_task": List<dynamic>.from(salesPersonTask!.map((x) => x.toJson())),
  };
}

class LeadArea {
  int? id;
  String? name;

  LeadArea({
    this.id,
    this.name,
  });

  factory LeadArea.fromJson(Map<String, dynamic> json) => LeadArea(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class LeadProduct {
  int? id;
  String? name;
  int? productGroupId;
  int? tag;

  LeadProduct({
    this.id,
    this.name,
    this.productGroupId,
    this.tag,
  });

  factory LeadProduct.fromJson(Map<String, dynamic> json) => LeadProduct(
    id: json["id"],
    name: json["name"],
    productGroupId: json["product_group_id"],
    tag: json["tag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "product_group_id": productGroupId,
    "tag": tag,
  };
}

class SaleAssignUser {
  int? id;
  int? areaId;
  String? name;
  String? email;
  String? phoneNo;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  String? dutyHours;

  SaleAssignUser({
    this.id,
    this.areaId,
    this.name,
    this.email,
    this.phoneNo,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
  });

  factory SaleAssignUser.fromJson(Map<String, dynamic> json) => SaleAssignUser(
    id: json["id"],
    areaId: json["area_id"],
    name: json["name"],
    email: json["email"] ?? "",
    phoneNo: json["phone_no"] ?? "",
    isActive: json["is_active"],
    dutyStart: json["duty_start"] ?? "",
    dutyEnd: json["duty_end"] ?? "",
    dutyHours: json["duty_hours"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "area_id": areaId,
    "name": name,
    "email": email,
    "phone_no": phoneNo,
    "is_active": isActive,
    "duty_start": dutyStart,
    "duty_end": dutyEnd,
    "duty_hours": dutyHours,
  };
}
