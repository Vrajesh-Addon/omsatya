import 'dart:convert';

AdminTodayReportResponse adminTodayReportResponseFromJson(String str) => AdminTodayReportResponse.fromJson(json.decode(str));

String adminTodayReportResponseToJson(AdminTodayReportResponse data) => json.encode(data.toJson());

class AdminTodayReportResponse {
  bool? success;
  String? message;
  AdminTodayReportData? data;

  AdminTodayReportResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AdminTodayReportResponse.fromJson(Map<String, dynamic> json) => AdminTodayReportResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : AdminTodayReportData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class AdminTodayReportData {
  String? title;
  List<TodaysTotalDone>? totalPendingComplaints;
  List<TodaysTotalDone>? totalTodaysComplaints;
  List<TodaysTotalDone>? todaysTotalDones;

  AdminTodayReportData({
    this.title,
    this.totalPendingComplaints,
    this.totalTodaysComplaints,
    this.todaysTotalDones,
  });

  factory AdminTodayReportData.fromJson(Map<String, dynamic> json) => AdminTodayReportData(
    title: json["title"],
    totalPendingComplaints: json["total_pending_complaints"] is List && json["total_pending_complaints"].isEmpty ? [] : List<TodaysTotalDone>.from(json["total_pending_complaints"]!.map((x) => TodaysTotalDone.fromJson(x))),
    totalTodaysComplaints: json["total_todays_complaints"] is List && json["total_todays_complaints"].isEmpty ? [] : List<TodaysTotalDone>.from(json["total_todays_complaints"]!.map((x) => TodaysTotalDone.fromJson(x))),
    todaysTotalDones: json["todays_total_dones"] is List && json["todays_total_dones"].isEmpty ? [] : List<TodaysTotalDone>.from(json["todays_total_dones"]!.map((x) => TodaysTotalDone.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "total_pending_complaints": totalPendingComplaints == null ? [] : List<dynamic>.from(totalPendingComplaints!.map((x) => x.toJson())),
    "total_todays_complaints": totalTodaysComplaints == null ? [] : List<dynamic>.from(totalTodaysComplaints!.map((x) => x.toJson())),
    "todays_total_dones": todaysTotalDones == null ? [] : List<dynamic>.from(todaysTotalDones!.map((x) => x.toJson())),
  };
}

class TodaysTotalDone {
  int? id;
  int? tag;
  int? userId;
  int? firmId;
  int? partyId;
  int? yearId;
  String? date;
  String? time;
  int? complaintTypeId;
  int? salesEntryId;
  int? productId;
  String? remarks;
  dynamic image;
  dynamic video;
  dynamic audio;
  int? engineerId;
  dynamic engineerComplaintId;
  String? engineerAssignDate;
  String? engineerAssignTime;
  dynamic engineerVideo;
  dynamic engineerAudio;
  dynamic engineerImage;
  dynamic jointengg;
  dynamic serviceTypeId;
  dynamic statusId;
  String? complaintNo;
  String? engineerInTime;
  String? engineerOutTime;
  String? engineerInDate;
  String? engineerOutDate;
  String? engineerTimeDuration;
  int? isUrgent;
  int? isAssigned;
  String? engineerInAddress;
  String? engineerOutAddress;
  Party? party;
  Product? product;
  MachineSalesEntry? machineSalesEntry;
  Engineer? engineer;

  TodaysTotalDone({
    this.id,
    this.tag,
    this.userId,
    this.firmId,
    this.partyId,
    this.yearId,
    this.date,
    this.time,
    this.complaintTypeId,
    this.salesEntryId,
    this.productId,
    this.remarks,
    this.image,
    this.video,
    this.audio,
    this.engineerId,
    this.engineerComplaintId,
    this.engineerAssignDate,
    this.engineerAssignTime,
    this.engineerVideo,
    this.engineerAudio,
    this.engineerImage,
    this.jointengg,
    this.serviceTypeId,
    this.statusId,
    this.complaintNo,
    this.engineerInTime,
    this.engineerOutTime,
    this.engineerInDate,
    this.engineerOutDate,
    this.engineerTimeDuration,
    this.isUrgent,
    this.isAssigned,
    this.engineerInAddress,
    this.engineerOutAddress,
    this.party,
    this.product,
    this.machineSalesEntry,
    this.engineer,
  });

  factory TodaysTotalDone.fromJson(Map<String, dynamic> json) => TodaysTotalDone(
    id: json["id"],
    tag: json["tag"],
    userId: json["user_id"],
    firmId: json["firm_id"],
    partyId: json["party_id"],
    yearId: json["year_id"],
    date: json["date"],
    time: json["time"],
    complaintTypeId: json["complaint_type_id"],
    salesEntryId: json["sales_entry_id"],
    productId: json["product_id"],
    remarks: json["remarks"],
    image: json["image"],
    video: json["video"],
    audio: json["audio"],
    engineerId: json["engineer_id"],
    engineerComplaintId: json["engineer_complaint_id"],
    engineerAssignDate: json["engineer_assign_date"],
    engineerAssignTime: json["engineer_assign_time"],
    engineerVideo: json["engineer_video"],
    engineerAudio: json["engineer_audio"],
    engineerImage: json["engineer_image"],
    jointengg: json["jointengg"],
    serviceTypeId: json["service_type_id"],
    statusId: json["status_id"],
    complaintNo: json["complaint_no"],
    engineerInTime: json["engineer_in_time"],
    engineerOutTime: json["engineer_out_time"],
    engineerInDate: json["engineer_in_date"],
    engineerOutDate: json["engineer_out_date"],
    engineerTimeDuration: json["engineer_time_duration"] ?? "",
    isUrgent: json["is_urgent"],
    isAssigned: json["is_assigned"],
    engineerInAddress: json["engineer_in_address"],
    engineerOutAddress: json["engineer_out_address"],
    party: json["party"] == null ? null : Party.fromJson(json["party"]),
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    machineSalesEntry: json["machine_sales_entry"] == null ? null : MachineSalesEntry.fromJson(json["machine_sales_entry"]),
    engineer: json["engineer"] == null ? null : Engineer.fromJson(json["engineer"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tag": tag,
    "user_id": userId,
    "firm_id": firmId,
    "party_id": partyId,
    "year_id": yearId,
    "date": date,
    "time": time,
    "complaint_type_id": complaintTypeId,
    "sales_entry_id": salesEntryId,
    "product_id": productId,
    "remarks": remarks,
    "image": image,
    "video": video,
    "audio": audio,
    "engineer_id": engineerId,
    "engineer_complaint_id": engineerComplaintId,
    "engineer_assign_date": engineerAssignDate,
    "engineer_assign_time": engineerAssignTime,
    "engineer_video": engineerVideo,
    "engineer_audio": engineerAudio,
    "engineer_image": engineerImage,
    "jointengg": jointengg,
    "service_type_id": serviceTypeId,
    "status_id": statusId,
    "complaint_no": complaintNo,
    "engineer_in_time": engineerInTime,
    "engineer_out_time": engineerOutTime,
    "engineer_in_date": engineerInDate,
    "engineer_out_date": engineerOutDate,
    "engineer_time_duration": engineerTimeDuration,
    "is_urgent": isUrgent,
    "is_assigned": isAssigned,
    "engineer_in_address": engineerInAddress,
    "engineer_out_address": engineerOutAddress,
    "party": party?.toJson(),
    "product": product?.toJson(),
    "machine_sales_entry": machineSalesEntry?.toJson(),
    "engineer": engineer?.toJson(),
  };
}

class Engineer {
  int? id;
  int? areaId;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? phoneNo;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  dynamic dutyHours;
  String? deviceToken;

  Engineer({
    this.id,
    this.areaId,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phoneNo,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
    this.deviceToken,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) => Engineer(
    id: json["id"],
    areaId: json["area_id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    phoneNo: json["phone_no"],
    isActive: json["is_active"],
    dutyStart: json["duty_start"],
    dutyEnd: json["duty_end"],
    dutyHours: json["duty_hours"],
    deviceToken: json["device_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "area_id": areaId,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "phone_no": phoneNo,
    "is_active": isActive,
    "duty_start": dutyStart,
    "duty_end": dutyEnd,
    "duty_hours": dutyHours,
    "device_token": deviceToken,
  };
}

class MachineSalesEntry {
  int? id;
  int? firmId;
  int? yearId;
  String? date;
  int? partyId;
  int? productId;
  String? serialNo;
  String? mcNo;
  String? installDate;
  String? serviceExpiryDate;
  int? freeService;
  String? orderNo;
  dynamic remarks;
  int? serviceTypeId;
  dynamic contenorNo;
  dynamic image;
  dynamic image1;
  dynamic image2;
  dynamic image3;
  dynamic lat;
  dynamic long;
  dynamic mapUrl;
  int? tag;
  int? isActive;
  int? micFittingEngineerId;
  int? deliveryEngineerId;

  MachineSalesEntry({
    this.id,
    this.firmId,
    this.yearId,
    this.date,
    this.partyId,
    this.productId,
    this.serialNo,
    this.mcNo,
    this.installDate,
    this.serviceExpiryDate,
    this.freeService,
    this.orderNo,
    this.remarks,
    this.serviceTypeId,
    this.contenorNo,
    this.image,
    this.image1,
    this.image2,
    this.image3,
    this.lat,
    this.long,
    this.mapUrl,
    this.tag,
    this.isActive,
    this.micFittingEngineerId,
    this.deliveryEngineerId,
  });

  factory MachineSalesEntry.fromJson(Map<String, dynamic> json) => MachineSalesEntry(
    id: json["id"],
    firmId: json["firm_id"],
    yearId: json["year_id"],
    date: json["date"],
    partyId: json["party_id"],
    productId: json["product_id"],
    serialNo: json["serial_no"],
    mcNo: json["mc_no"],
    installDate: json["install_date"],
    serviceExpiryDate: json["service_expiry_date"],
    freeService: json["free_service"],
    orderNo: json["order_no"],
    remarks: json["remarks"],
    serviceTypeId: json["service_type_id"],
    contenorNo: json["contenor_no"],
    image: json["image"],
    image1: json["image1"],
    image2: json["image2"],
    image3: json["image3"],
    lat: json["lat"],
    long: json["long"],
    mapUrl: json["map_url"],
    tag: json["tag"],
    isActive: json["is_active"],
    micFittingEngineerId: json["mic_fitting_engineer_id"],
    deliveryEngineerId: json["delivery_engineer_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firm_id": firmId,
    "year_id": yearId,
    "date": date,
    "party_id": partyId,
    "product_id": productId,
    "serial_no": serialNo,
    "mc_no": mcNo,
    "install_date": installDate,
    "service_expiry_date": serviceExpiryDate,
    "free_service": freeService,
    "order_no": orderNo,
    "remarks": remarks,
    "service_type_id": serviceTypeId,
    "contenor_no": contenorNo,
    "image": image,
    "image1": image1,
    "image2": image2,
    "image3": image3,
    "lat": lat,
    "long": long,
    "map_url": mapUrl,
    "tag": tag,
    "is_active": isActive,
    "mic_fitting_engineer_id": micFittingEngineerId,
    "delivery_engineer_id": deliveryEngineerId,
  };
}

class Party {
  int? id;
  String? code;
  String? name;
  dynamic email;
  dynamic panNo;
  String? address;
  int? cityId;
  int? stateId;
  dynamic pincode;
  String? phoneNo;
  String? password;
  String? otherPhoneNo;
  dynamic gstNo;
  int? contactPersonId;
  int? ownerId;
  int? areaId;
  int? firmId;
  int? isActive;
  String? locationAddress;
  String? deviceToken;
  Area? area;

  Party({
    this.id,
    this.code,
    this.name,
    this.email,
    this.panNo,
    this.address,
    this.cityId,
    this.stateId,
    this.pincode,
    this.phoneNo,
    this.password,
    this.otherPhoneNo,
    this.gstNo,
    this.contactPersonId,
    this.ownerId,
    this.areaId,
    this.firmId,
    this.isActive,
    this.locationAddress,
    this.deviceToken,
    this.area,
  });

  factory Party.fromJson(Map<String, dynamic> json) => Party(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    email: json["email"],
    panNo: json["pan_no"],
    address: json["address"],
    cityId: json["city_id"],
    stateId: json["state_id"],
    pincode: json["pincode"],
    phoneNo: json["phone_no"],
    password: json["password"],
    otherPhoneNo: json["other_phone_no"],
    gstNo: json["gst_no"],
    contactPersonId: json["contact_person_id"],
    ownerId: json["owner_id"],
    areaId: json["area_id"],
    firmId: json["firm_id"],
    isActive: json["is_active"],
    locationAddress: json["location_address"],
    deviceToken: json["device_token"],
    area: json["area"] == null ? null : Area.fromJson(json["area"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
    "email": email,
    "pan_no": panNo,
    "address": address,
    "city_id": cityId,
    "state_id": stateId,
    "pincode": pincode,
    "phone_no": phoneNo,
    "password": password,
    "other_phone_no": otherPhoneNo,
    "gst_no": gstNo,
    "contact_person_id": contactPersonId,
    "owner_id": ownerId,
    "area_id": areaId,
    "firm_id": firmId,
    "is_active": isActive,
    "location_address": locationAddress,
    "device_token": deviceToken,
    "area": area?.toJson(),
  };
}

class Area {
  int? id;
  String? name;

  Area({
    this.id,
    this.name,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Product {
  int? id;
  String? name;
  int? productGroupId;
  int? tag;

  Product({
    this.id,
    this.name,
    this.productGroupId,
    this.tag,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
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
