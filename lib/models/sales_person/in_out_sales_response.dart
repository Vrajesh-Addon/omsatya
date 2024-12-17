import 'dart:convert';

InOutSalesResponse inOutSalesResponseFromJson(String str) => InOutSalesResponse.fromJson(json.decode(str));

String inOutSalesResponseToJson(InOutSalesResponse data) => json.encode(data.toJson());

class InOutSalesResponse {
  bool? status;
  String? message;
  InOutSalesData? data;

  InOutSalesResponse({
    this.status,
    this.message,
    this.data,
  });

  factory InOutSalesResponse.fromJson(Map<String, dynamic> json) => InOutSalesResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : InOutSalesData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class InOutSalesData {
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
  String? outAddress;
  String? inAddress;
  String? outDateTime;
  String? inDateTime;
  String? timeDuration;
  String? latitude;
  String? logitude;
  dynamic remarks;
  DateTime? nextReminderDate;
  String? nextReminderTime;
  int? favorite;
  dynamic statusId;
  dynamic closedBy;
  dynamic closedDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  InOutSalesData({
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
    this.outAddress,
    this.inAddress,
    this.outDateTime,
    this.inDateTime,
    this.timeDuration,
    this.latitude,
    this.logitude,
    this.remarks,
    this.nextReminderDate,
    this.nextReminderTime,
    this.favorite,
    this.statusId,
    this.closedBy,
    this.closedDate,
    this.createdAt,
    this.updatedAt,
  });

  factory InOutSalesData.fromJson(Map<String, dynamic> json) => InOutSalesData(
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
    outAddress: json["out_address"],
    inAddress: json["in_address"],
    outDateTime: json["out_date_time"],
    inDateTime: json["in_date_time"],
    timeDuration: json["time_duration"],
    latitude: json["latitude"],
    logitude: json["logitude"],
    remarks: json["remarks"],
    nextReminderDate: json["next_reminder_date"] == null ? null : DateTime.parse(json["next_reminder_date"]),
    nextReminderTime: json["next_reminder_time"],
    favorite: json["favorite"],
    statusId: json["status_id"],
    closedBy: json["closed_by"],
    closedDate: json["closed_date"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
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
    "out_address": outAddress,
    "in_address": inAddress,
    "out_date_time": outDateTime,
    "in_date_time": inDateTime,
    "time_duration": timeDuration,
    "latitude": latitude,
    "logitude": logitude,
    "remarks": remarks,
    "next_reminder_date": nextReminderDate,
    "next_reminder_time": nextReminderTime,
    "favorite": favorite,
    "status_id": statusId,
    "closed_by": closedBy,
    "closed_date": closedDate,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
