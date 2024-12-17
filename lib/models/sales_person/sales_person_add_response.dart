import 'dart:convert';

SalesPersonAddResponse salesPersonAddResponseFromJson(String str) => SalesPersonAddResponse.fromJson(json.decode(str));

String salesPersonAddResponseToJson(SalesPersonAddResponse data) => json.encode(data.toJson());

class SalesPersonAddResponse {
  bool success;
  String message;
  SalesPersonAddData data;

  SalesPersonAddResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SalesPersonAddResponse.fromJson(Map<String, dynamic> json) => SalesPersonAddResponse(
    success: json["success"],
    message: json["message"],
    data: SalesPersonAddData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class SalesPersonAddData {
  dynamic tag;
  dynamic firmId;
  dynamic yearId;
  dynamic areaId;
  dynamic productId;
  dynamic leadStageId;
  dynamic saleUserId;
  dynamic saleAssignUserId;
  String? date;
  String? time;
  String? mobileNo;
  String? partyname;
  String? address;
  String? locationAddress;
  String? remarks;
  String? nextReminderDate;
  String? nextReminderTime;
  int? id;

  SalesPersonAddData({
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
    this.remarks,
    this.nextReminderDate,
    this.nextReminderTime,
    this.id,
  });

  factory SalesPersonAddData.fromJson(Map<String, dynamic> json) => SalesPersonAddData(
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
    remarks: json["remarks"],
    nextReminderDate: json["next_reminder_date"],
    nextReminderTime: json["next_reminder_time"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
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
    "remarks": remarks,
    "next_reminder_date": nextReminderDate,
    "next_reminder_time": nextReminderTime,
    "id": id,
  };
}
