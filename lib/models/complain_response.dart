import 'dart:convert';

ComplainResponse complainResponseFromJson(String str) => ComplainResponse.fromJson(json.decode(str));

String complainResponseToJson(ComplainResponse data) => json.encode(data.toJson());

class ComplainResponse {
  bool? success;
  String? message;
  Data? data;

  ComplainResponse({
    this.success,
    this.message,
    this.data,
  });

  factory ComplainResponse.fromJson(Map<String, dynamic> json) => ComplainResponse(
        success: json["success"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data!.toJson(),
      };
}

class Data {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;
  List<ComplainData>? data;

  Data({
    this.total,
    this.perPage,
    this.currentPage,
    this.lastPage,
    this.from,
    this.to,
    this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    total: json["total"],
    perPage: json["per_page"],
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    from: json["from"],
    to: json["to"],
    data: List<ComplainData>.from(json["data"].map((x) => ComplainData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "per_page": perPage,
    "current_page": currentPage,
    "last_page": lastPage,
    "from": from,
    "to": to,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class ComplainData {
  int? id;
  String? date;
  String? time;
  String? remarks;
  int? engineerId;
  String? engineerAssignDate;
  String? engineerAssignTime;
  dynamic statusId;
  String? complaintNo;
  String? engineerInTime;
  String? engineerOutTime;
  String? engineerTimeDuration;
  String? engineerInDate;
  String? engineerOutDate;
  int? isUrgent;
  int? isAssign;
  String? engineerInAddress;
  String? engineerOutAddress;
  Party? party;
  ServiceType? serviceType;
  SalesEntry? salesEntry;
  ServiceType? status;
  Product? product;
  ServiceType? complaintType;
  List<ComplainData>? pastComplaints;
  Engineer? engineer;
  String? imageUrl;
  String? videoUrl;
  String? audioUrl;
  String? image;
  String? video;
  String? audio;
  int? isCustomerComplain;
  String? engineerImageUrl;
  String? engineerVideoUrl;
  String? engineerAudioUrl;
  Engineer? engineerDetail;

  ComplainData({
    this.id,
    this.date,
    this.time,
    this.remarks,
    this.engineerId,
    this.engineerAssignDate,
    this.engineerAssignTime,
    this.statusId,
    this.complaintNo,
    this.engineerInTime,
    this.engineerOutTime,
    this.engineerTimeDuration,
    this.engineerInDate,
    this.engineerOutDate,
    this.isUrgent,
    this.isAssign,
    this.engineerInAddress,
    this.engineerOutAddress,
    this.party,
    this.serviceType,
    this.salesEntry,
    this.status,
    this.product,
    this.complaintType,
    this.pastComplaints,
    this.engineer,
    this.imageUrl,
    this.videoUrl,
    this.audioUrl,
    this.image,
    this.video,
    this.audio,
    this.isCustomerComplain,
    this.engineerImageUrl,
    this.engineerVideoUrl,
    this.engineerAudioUrl,
    this.engineerDetail,
  });

  factory ComplainData.fromJson(Map<String, dynamic> json) => ComplainData(
        id: json["id"],
        date: json["date"],
        time: json["time"],
        remarks: json["remarks"],
        engineerId: json["engineer_id"],
        engineerAssignDate: json["engineer_assign_date"] ?? "",
        engineerAssignTime: json["engineer_assign_time"] ?? "",
        statusId: json["status_id"],
        complaintNo: json["complaint_no"] ?? "",
        engineerInTime: json["engineer_in_time"],
        engineerOutTime: json["engineer_out_time"],
        engineerInDate: json["engineer_in_date"],
        engineerOutDate: json["engineer_out_date"],
        engineerTimeDuration: json["engineer_time_duration"],
        isUrgent: json["is_urgent"],
        isAssign: json["is_assigned"],
        engineerInAddress: json["engineer_in_address"],
        engineerOutAddress: json["engineer_out_address"],
        party: json["party"] == null ? null : Party.fromJson(json["party"]),
        serviceType: json["service_type"] == null ? null : ServiceType.fromJson(json["service_type"]),
        salesEntry: json["sales_entry"] == null ? null : SalesEntry.fromJson(json["sales_entry"]),
        status: json["status"] == null ? null : ServiceType.fromJson(json["status"]),
        product: json["product"] == null ? null : Product.fromJson(json["product"]),
        complaintType: json["complaint_type"] == null ? null : ServiceType.fromJson(json["complaint_type"]),
        pastComplaints: json["past_complaints"] == null
            ? []
            : List<ComplainData>.from(json["past_complaints"].map(
                (x) => ComplainData.fromJson(x),
              )),
        engineer: json["engineer"] == null ? null : Engineer.fromJson(json["engineer"]),
        imageUrl: json["image_url"] ?? "",
        videoUrl: json["video_url"] ?? "",
        audioUrl: json["audio_url"] ?? "",
        image: json["image"] ?? "",
        video: json["video"] ?? "",
        audio: json["audio"] ?? "",
        isCustomerComplain: json["is_customer_complaint"],
        engineerImageUrl: json["engineer_image_url"] ?? "",
        engineerVideoUrl: json["engineer_video_url"] ?? "",
        engineerAudioUrl: json["engineer_audio_url"] ?? "",
        engineerDetail: json["engineer_detail"] == null ? null : Engineer.fromJson(json["engineer_detail"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "time": time,
        "remarks": remarks,
        "engineer_id": engineerId,
        "engineer_assign_date": engineerAssignDate,
        "engineer_assign_time": engineerAssignTime,
        "status_id": statusId,
        "complaint_no": complaintNo,
        "engineer_in_time": engineerInTime,
        "engineer_out_time": engineerOutTime,
        "engineer_time_duration": engineerTimeDuration,
        "engineer_in_date": engineerInDate,
        "engineer_out_date": engineerInDate,
        "is_urgent": isUrgent,
        "is_assigned": isAssign,
        "engineer_in_address": engineerInAddress,
        "engineer_out_address": engineerOutAddress,
        "party": party!.toJson(),
        "service_type": serviceType!.toJson(),
        "sales_entry": salesEntry!.toJson(),
        "status": status!.toJson(),
        "product": product!.toJson(),
        "complaint_type": complaintType!.toJson(),
        "past_complaints": List<dynamic>.from(pastComplaints!.map((x) => x.toJson())),
        "engineer": engineer!.toJson(),
        "image_url": imageUrl,
        "video_url": videoUrl,
        "audio_url": audioUrl,
        "image": image,
        "video": video,
        "audio": audio,
        "is_customer_complaint": isCustomerComplain,
        "engineer_image_url": engineerImageUrl,
        "engineer_video_url": engineerVideoUrl,
        "engineer_audio_url": engineerAudioUrl,
      };
}

class Party {
  int? id;
  String? name;
  String? code;
  String? email;
  String? panNo;
  String? address;
  String? pincode;
  String? phoneNo;
  String? otherPhoneNo;
  String? gstNo;
  int? contactPersonId;
  int? ownerId;
  int? areaId;
  int? firmId;
  String? deviceToken;
  String? locationAddress;
  ServiceType? contactPerson;
  ServiceType? owner;
  Area? area;

  Party({
    this.id,
    this.code,
    this.name,
    this.email,
    this.panNo,
    this.address,
    this.pincode,
    this.phoneNo,
    this.otherPhoneNo,
    this.gstNo,
    this.contactPersonId,
    this.ownerId,
    this.areaId,
    this.firmId,
    this.deviceToken,
    this.locationAddress,
    this.contactPerson,
    this.owner,
    this.area,
  });

  factory Party.fromJson(Map<String, dynamic> json) => Party(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        email: json["email"] ?? "",
        panNo: json["pan_no"] ?? "",
        address: json["address"],
        pincode: json["pincode"] ?? "",
        phoneNo: json["phone_no"],
        otherPhoneNo: json["other_phone_no"] ?? "",
        gstNo: json["gst_no"] ?? "",
        contactPersonId: json["contact_person_id"],
        ownerId: json["owner_id"],
        areaId: json["area_id"],
        firmId: json["firm_id"],
        deviceToken: json["device_token"] ?? "",
        locationAddress: json["location_address"] ?? "",
        contactPerson: json["contact_person"] == null ? null : ServiceType.fromJson(json["contact_person"]),
        owner: json["owner"] == null ? null : ServiceType.fromJson(json["owner"]),
        area: json["area"] == null ? null : Area.fromJson(json["area"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "email": email,
        "pan_no": panNo,
        "address": address,
        "pincode": pincode,
        "phone_no": phoneNo,
        "other_phone_no": otherPhoneNo,
        "gst_no": gstNo,
        "contact_person_id": contactPersonId,
        "owner_id": ownerId,
        "area_id": areaId,
        "firm_id": firmId,
        "device_token": deviceToken,
        "location_address": locationAddress,
        "contact_person": contactPerson?.toJson(),
        "owner": owner!.toJson(),
        "area": area!.toJson(),
      };
}

class Area {
  int id;
  String name;
  String? phoneNo;

  Area({
    required this.id,
    required this.name,
    this.phoneNo,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    id: json["id"],
    name: json["name"],
    phoneNo: json["phone_no"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone_no": phoneNo,
  };
}

class ServiceType {
  int id;
  String name;
  String? phoneNo;
  String? description;

  ServiceType({
    required this.id,
    required this.name,
    this.phoneNo,
    this.description,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
        id: json["id"],
        name: json["name"],
        phoneNo: json["phone_no"] ?? "",
        description: json["description"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone_no": phoneNo,
        "description": description,
      };
}

class SalesEntry {
  int? id;
  int? billNo;
  DateTime? date;
  String? serialNo;
  String? mcNo;
  DateTime? installDate;
  DateTime? serviceExpiryDate;
  int? freeService;
  String? orderNo;
  String? remarks;
  int? serviceTypeId;
  String? image;
  String? image1;
  String? image2;
  String? image3;
  String? mapUrl;
  int? tag;
  int? isActive;
  Party? party;

  SalesEntry({
    this.id,
    this.billNo,
    this.date,
    this.serialNo,
    this.mcNo,
    this.installDate,
    this.serviceExpiryDate,
    this.freeService,
    this.orderNo,
    this.remarks,
    this.serviceTypeId,
    this.image,
    this.image1,
    this.image2,
    this.image3,
    this.mapUrl,
    this.tag,
    this.isActive,
    this.party,
  });

  factory SalesEntry.fromJson(Map<String, dynamic> json) => SalesEntry(
        id: json["id"],
        billNo: json["bill_no"],
        date: DateTime.parse(json["date"]),
        serialNo: json["serial_no"],
        mcNo: json["mc_no"],
        installDate: DateTime.parse(json["install_date"]),
        serviceExpiryDate: DateTime.parse(json["service_expiry_date"]),
        freeService: json["free_service"],
        orderNo: json["order_no"],
        remarks: json["remarks"] ?? "",
        serviceTypeId: json["service_type_id"],
        image: json["image"] ?? "",
        image1: json["image1"] ?? "",
        image2: json["image2"] ?? "",
        image3: json["image3"] ?? "",
        mapUrl: json["map_url"] ?? "",
        tag: json["tag"],
        isActive: json["is_active"],
        party: Party.fromJson(json["party"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bill_no": billNo,
        "date": date,
        "serial_no": serialNo,
        "mc_no": mcNo,
        "install_date": installDate,
        "service_expiry_date": serviceExpiryDate,
        "free_service": freeService,
        "order_no": orderNo,
        "remarks": remarks,
        "service_type_id": serviceTypeId,
        "image": image,
        "image1": image1,
        "image2": image2,
        "image3": image3,
        "map_url": mapUrl,
        "tag": tag,
        "is_active": isActive,
        "party": party!.toJson(),
      };
}

class Product {
  int id;
  String name;
  int productGroupId;
  int tag;

  Product({
    required this.id,
    required this.name,
    required this.productGroupId,
    required this.tag,
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

class Engineer {
  int? id;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? phoneNo;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  String? dutyHours;

  Engineer({
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.phoneNo,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) => Engineer(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: json["email_verified_at"],
    phoneNo: json["phone_no"],
    isActive: json["is_active"],
    dutyStart: json["duty_start"],
    dutyEnd: json["duty_end"],
    dutyHours: json["duty_hours"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt,
    "phone_no": phoneNo,
    "is_active": isActive,
    "duty_start": dutyStart,
    "duty_end": dutyEnd,
    "duty_hours": dutyHours,
  };
}
