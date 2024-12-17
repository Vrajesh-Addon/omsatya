import 'dart:convert';

import 'package:omsatya/models/customer_machine_response.dart';

ComplainMachineResponse complainMachineResponseFromJson(String str) => ComplainMachineResponse.fromJson(json.decode(str));

String complainMachineResponseToJson(ComplainMachineResponse data) => json.encode(data.toJson());

class ComplainMachineResponse {
  bool success;
  String message;
  List<ComplainMachineData> data;

  ComplainMachineResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ComplainMachineResponse.fromJson(Map<String, dynamic> json) => ComplainMachineResponse(
    success: json["success"],
    message: json["message"],
    data: List<ComplainMachineData>.from(json["data"].map((x) => ComplainMachineData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ComplainMachineData {
  int? id;
  String? code;
  String? name;
  String? email;
  String? panNo;
  String? address;
  String? pincode;
  String? phoneNo;
  String? otherPhoneNo;
  String? gstNo;
  List<MachineData>? machineData;

  ComplainMachineData({
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
    this.machineData,
  });

  factory ComplainMachineData.fromJson(Map<String, dynamic> json) => ComplainMachineData(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    email: json["email"] ?? "",
    panNo: json["pan_no"] ?? "",
    address: json["address"],
    pincode: json["pincode"] ?? "",
    phoneNo: json["phone_no"] ?? "",
    otherPhoneNo: json["other_phone_no"] ?? "",
    gstNo: json["gst_no"] ?? "",
    machineData: List<MachineData>.from(json["machine_sales"].map((x) => MachineData.fromJson(x))),
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
    "machine_sales": List<dynamic>.from(machineData!.map((x) => x.toJson())),
  };
}

class MachineSale {
  int id;
  int firmId;
  int yearId;
  DateTime date;
  int partyId;
  int productId;
  String serialNo;
  String mcNo;
  DateTime installDate;
  DateTime serviceExpiryDate;
  int freeService;
  String orderNo;
  dynamic remarks;
  int serviceTypeId;
  dynamic contenorNo;
  dynamic image;
  dynamic image1;
  dynamic image2;
  dynamic image3;
  dynamic lat;
  dynamic long;
  dynamic mapUrl;
  int tag;
  int isActive;
  int micFittingEngineerId;
  int deliveryEngineerId;
  Product product;

  MachineSale({
    required this.id,
    required this.firmId,
    required this.yearId,
    required this.date,
    required this.partyId,
    required this.productId,
    required this.serialNo,
    required this.mcNo,
    required this.installDate,
    required this.serviceExpiryDate,
    required this.freeService,
    required this.orderNo,
    required this.remarks,
    required this.serviceTypeId,
    required this.contenorNo,
    required this.image,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.lat,
    required this.long,
    required this.mapUrl,
    required this.tag,
    required this.isActive,
    required this.micFittingEngineerId,
    required this.deliveryEngineerId,
    required this.product,
  });

  factory MachineSale.fromJson(Map<String, dynamic> json) => MachineSale(
    id: json["id"],
    firmId: json["firm_id"],
    yearId: json["year_id"],
    date: DateTime.parse(json["date"]),
    partyId: json["party_id"],
    productId: json["product_id"],
    serialNo: json["serial_no"],
    mcNo: json["mc_no"],
    installDate: DateTime.parse(json["install_date"]),
    serviceExpiryDate: DateTime.parse(json["service_expiry_date"]),
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
    product: Product.fromJson(json["product"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firm_id": firmId,
    "year_id": yearId,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "party_id": partyId,
    "product_id": productId,
    "serial_no": serialNo,
    "mc_no": mcNo,
    "install_date": "${installDate.year.toString().padLeft(4, '0')}-${installDate.month.toString().padLeft(2, '0')}-${installDate.day.toString().padLeft(2, '0')}",
    "service_expiry_date": "${serviceExpiryDate.year.toString().padLeft(4, '0')}-${serviceExpiryDate.month.toString().padLeft(2, '0')}-${serviceExpiryDate.day.toString().padLeft(2, '0')}",
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
    "product": product.toJson(),
  };
}

class Product {
  int id;
  String name;
  int productGroupId;
  int tag;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.productGroupId,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["id"],
    name: json["name"],
    productGroupId: json["product_group_id"],
    tag: json["tag"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "product_group_id": productGroupId,
    "tag": tag,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
