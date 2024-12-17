import 'dart:convert';

SalesFavouriteResponse salesFavouriteResponseFromJson(String str) => SalesFavouriteResponse.fromJson(json.decode(str));

String salesFavouriteResponseToJson(SalesFavouriteResponse data) => json.encode(data.toJson());

class SalesFavouriteResponse {
  bool? status;
  String? message;
  Data? data;

  SalesFavouriteResponse({
    this.status,
    this.message,
    this.data,
  });

  factory SalesFavouriteResponse.fromJson(Map<String, dynamic> json) => SalesFavouriteResponse(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? id;
  String? tag;
  int? firmId;
  int? yearId;
  int? areaId;
  int? productId;
  int? leadStageId;
  int? saleUserId;
  int? saleAssignUserId;
  DateTime? date;
  String? time;
  String? mobileNo;
  String? partyname;
  String? address;
  dynamic locationAddress;
  String? latitude;
  String? logitude;
  dynamic remarks;
  DateTime? nextReminderDate;
  String? nextReminderTime;
  int? favorite;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
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
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    tag: json["tag"],
    firmId: json["firm_id"],
    yearId: json["year_id"],
    areaId: json["area_id"],
    productId: json["product_id"],
    leadStageId: json["lead_stage_id"],
    saleUserId: json["sale_user_id"],
    saleAssignUserId: json["sale_assign_user_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    time: json["time"],
    mobileNo: json["mobile_no"],
    partyname: json["partyname"],
    address: json["address"],
    locationAddress: json["location_Address"],
    latitude: json["latitude"],
    logitude: json["logitude"],
    remarks: json["remarks"],
    nextReminderDate: json["next_reminder_date"] == null ? null : DateTime.parse(json["next_reminder_date"]),
    nextReminderTime: json["next_reminder_time"],
    favorite: json["favorite"],
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
    "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "time": time,
    "mobile_no": mobileNo,
    "partyname": partyname,
    "address": address,
    "location_Address": locationAddress,
    "latitude": latitude,
    "logitude": logitude,
    "remarks": remarks,
    "next_reminder_date": "${nextReminderDate!.year.toString().padLeft(4, '0')}-${nextReminderDate!.month.toString().padLeft(2, '0')}-${nextReminderDate!.day.toString().padLeft(2, '0')}",
    "next_reminder_time": nextReminderTime,
    "favorite": favorite,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
