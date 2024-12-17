import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

TodayMachineExpiryResponse todayMachineExpiryResponseFromJson(String str) => TodayMachineExpiryResponse.fromJson(json.decode(str));

String todayMachineExpiryResponseToJson(TodayMachineExpiryResponse data) => json.encode(data.toJson());

class TodayMachineExpiryResponse {
  bool? success;
  String? message;
  List<TodayMachineExpiryData>? data;

  TodayMachineExpiryResponse({
    this.success,
    this.message,
    this.data,
  });

  factory TodayMachineExpiryResponse.fromJson(Map<String, dynamic> json) => TodayMachineExpiryResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<TodayMachineExpiryData>.from(json["data"]!.map((x) => TodayMachineExpiryData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TodayMachineExpiryData {
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
  dynamic freeServiceDate;
  String? orderNo;
  dynamic remarks;
  int? serviceTypeId;
  int? tag;
  int? isActive;
  int? micFittingEngineerId;
  int? deliveryEngineerId;
  Party? party;
  Product? product;
  ServiceType? serviceType;

  TodayMachineExpiryData({
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
    this.freeServiceDate,
    this.orderNo,
    this.remarks,
    this.serviceTypeId,
    this.tag,
    this.isActive,
    this.micFittingEngineerId,
    this.deliveryEngineerId,
    this.party,
    this.product,
    this.serviceType,
  });

  factory TodayMachineExpiryData.fromJson(Map<String, dynamic> json) => TodayMachineExpiryData(
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
    freeServiceDate: json["free_service_date"],
    orderNo: json["order_no"],
    remarks: json["remarks"],
    serviceTypeId: json["service_type_id"],
    tag: json["tag"],
    isActive: json["is_active"],
    micFittingEngineerId: json["mic_fitting_engineer_id"],
    deliveryEngineerId: json["delivery_engineer_id"],
    party: json["party"] == null ? null : Party.fromJson(json["party"]),
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    serviceType: json["service_type"] == null ? null : ServiceType.fromJson(json["service_type"]),
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
    "free_service_date": freeServiceDate,
    "order_no": orderNo,
    "remarks": remarks,
    "service_type_id": serviceTypeId,
    "tag": tag,
    "is_active": isActive,
    "mic_fitting_engineer_id": micFittingEngineerId,
    "delivery_engineer_id": deliveryEngineerId,
    "party": party?.toJson(),
    "product": product?.toJson(),
    "service_type": serviceType?.toJson(),
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
    phoneNo: json["phone_no"],
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
