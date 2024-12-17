import 'dart:convert';

ComplainAddResponse complainAddResponseFromJson(String str) => ComplainAddResponse.fromJson(json.decode(str));

String complainAddResponseToJson(ComplainAddResponse data) => json.encode(data.toJson());

class ComplainAddResponse {
  bool success;
  String message;
  ComplainAddData data;

  ComplainAddResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ComplainAddResponse.fromJson(Map<String, dynamic> json) => ComplainAddResponse(
    success: json["success"],
    message: json["message"],
    data: ComplainAddData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}

class ComplainAddData {
  int? partyId;
  String? date;
  String? time;
  int? complaintTypeId;
  int? salesEntryId;
  int? serviceTypeId;
  int? statusId;
  int? productId;
  int? firmId;
  int? yearId;
  int? id;
  int? engineerId;
  int? isAssigned;
  String? image;
  String? video;
  String? audio;

  ComplainAddData({
    this.partyId,
    this.date,
    this.time,
    this.complaintTypeId,
    this.salesEntryId,
    this.serviceTypeId,
    this.statusId,
    this.productId,
    this.firmId,
    this.yearId,
    this.id,
    this.engineerId,
    this.isAssigned,
    this.audio,
    this.video,
    this.image,
  });

  factory ComplainAddData.fromJson(Map<String, dynamic> json) => ComplainAddData(
    partyId: json["party_id"],
    date: json["date"],
    time: json["time"],
    complaintTypeId: json["complaint_type_id"],
    salesEntryId: json["sales_entry_id"],
    serviceTypeId: json["service_type_id"],
    statusId: json["status_id"],
    productId: json["product_id"],
    firmId: json["firm_id"],
    yearId: json["year_id"],
    id: json["id"],
    engineerId: json["engineer_id"] ?? 0,
    isAssigned: json["is_assigned"],
    image: json["image"] ?? "",
    video: json["video"] ?? "",
    audio: json["audio"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "party_id": partyId,
    "date": date,
    "time": time,
    "complaint_type_id": complaintTypeId,
    "sales_entry_id": salesEntryId,
    "service_type_id": serviceTypeId,
    "status_id": statusId,
    "product_id": productId,
    "firm_id": firmId,
    "year_id": yearId,
    "id": id,
    "engineer_id": engineerId,
    "is_assigned": isAssigned,
    "image": image,
    "video": video,
    "audio": audio,
  };
}
