import 'dart:convert';

CustomerMachineResponse customerMachineResponseFromJson(String str) => CustomerMachineResponse.fromJson(json.decode(str));

String customerMachineResponseToJson(CustomerMachineResponse data) => json.encode(data.toJson());

class CustomerMachineResponse {
  bool? success;
  String? message;
  MData? data;

  CustomerMachineResponse({
    this.success,
    this.message,
    this.data,
  });

  factory CustomerMachineResponse.fromJson(Map<String, dynamic> json) => CustomerMachineResponse(
    success: json["success"],
    message: json["message"],
    data: MData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data!.toJson(),
  };
}

class MData {
  int? total;
  int? perPage;
  int? currentPage;
  int? lastPage;
  int? from;
  int? to;
  List<MachineData>? data;

  MData({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
    required this.data,
  });

  factory MData.fromJson(Map<String, dynamic> json) => MData(
    total: json["total"],
    perPage: json["per_page"],
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    from: json["from"],
    to: json["to"],
    data: List<MachineData>.from(json["data"].map((x) => MachineData.fromJson(x))),
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

class MachineData {
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
  String? remarks;
  int? serviceTypeId;
  String? contenorNo;
  String? image;
  String? image1;
  String? image2;
  String? image3;
  String? lat;
  String? long;
  String? mapUrl;
  int? tag;
  int? isActive;
  int? micFittingEngineerId;
  int? deliveryEngineerId;
  String? cMessage;
  Partys? party;
  Product? product;
  ServiceType? serviceType;
  String? isExpired;

  MachineData({
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
   this.cMessage,
   this.party,
   this.product,
   this.serviceType,
    this.isExpired,
  });

  factory MachineData.fromJson(Map<String, dynamic> json) => MachineData(
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
    remarks: json["remarks"] ?? "",
    serviceTypeId: json["service_type_id"],
    contenorNo: json["contenor_no"] ?? "",
    image: json["image"] ?? "",
    image1: json["image1"] ?? "",
    image2: json["image2"] ?? "",
    image3: json["image3"] ?? "",
    lat: json["lat"] ?? "",
    long: json["long"] ?? "",
    mapUrl: json["map_url"] ?? "",
    tag: json["tag"],
    isActive: json["is_active"],
    micFittingEngineerId: json["mic_fitting_engineer_id"],
    deliveryEngineerId: json["delivery_engineer_id"],
    cMessage: json["c_message"],
    party: json["party"] == null ? null : Partys.fromJson(json["party"]),
    product: Product.fromJson(json["product"]),
    serviceType: json["service_type"] == null ? null : ServiceType.fromJson(json["service_type"]),
    isExpired: json["is_expired"] ?? "",
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
    "c_message": cMessage,
    "party": party!.toJson(),
    "product": product!.toJson(),
    "service_type": serviceType!.toJson(),
    "is_expired": isExpired,
  };
}

class Partys {
  int? id;
  String? code;
  String? name;
  String? email;
  String? panNo;
  String? address;
  int? cityId;
  int? stateId;
  String? pincode;
  String? phoneNo;
  String? password;
  String? otherPhoneNo;
  String? gstNo;
  int? contactPersonId;
  int? ownerId;
  int? areaId;
  int? firmId;
  ServiceType? contactPerson;
  ServiceType? owner;
  ServiceType? area;

  Partys({
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
    this.contactPerson,
    this.owner,
    this.area,
  });

  factory Partys.fromJson(Map<String, dynamic> json) => Partys(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    email: json["email"] ?? "",
    panNo: json["pan_no"] ?? "",
    address: json["address"],
    cityId: json["city_id"],
    stateId: json["state_id"],
    pincode: json["pincode"] ?? "",
    phoneNo: json["phone_no"],
    password: json["password"],
    otherPhoneNo: json["other_phone_no"],
    gstNo: json["gst_no"] ?? "",
    contactPersonId: json["contact_person_id"],
    ownerId: json["owner_id"],
    areaId: json["area_id"],
    firmId: json["firm_id"],
    contactPerson: ServiceType.fromJson(json["contact_person"]),
    owner: ServiceType.fromJson(json["owner"]),
    area: ServiceType.fromJson(json["area"]),
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
    "contact_person": contactPerson!.toJson(),
    "owner": owner!.toJson(),
    "area": area!.toJson(),
  };
}

class ServiceType {
  int? id;
  String? name;
  String? phoneNo;

  ServiceType({
    this.id,
    this.name,
    this.phoneNo,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json) => ServiceType(
    id: json["id"],
    name: json["name"],
    phoneNo: json["phone_no"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "phone_no": phoneNo,
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

