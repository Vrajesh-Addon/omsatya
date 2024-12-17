import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

PartyDetailsByCodeResponse partyDetailsByCodeResponseFromJson(String str) => PartyDetailsByCodeResponse.fromJson(json.decode(str));

String partyDetailsByCodeResponseToJson(PartyDetailsByCodeResponse data) => json.encode(data.toJson());

class PartyDetailsByCodeResponse {
  bool? success;
  String? message;
  Party? data;

  PartyDetailsByCodeResponse({
    this.success,
    this.message,
    this.data,
  });

  factory PartyDetailsByCodeResponse.fromJson(Map<String, dynamic> json) => PartyDetailsByCodeResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : Party.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data!.toJson(),
  };
}

class PartyDetailsByCode {
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

  PartyDetailsByCode({
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
  });

  factory PartyDetailsByCode.fromJson(Map<String, dynamic> json) => PartyDetailsByCode(
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
    password: json["password"] ?? "",
    otherPhoneNo: json["other_phone_no"] ?? "",
    gstNo: json["gst_no"] ?? "",
    contactPersonId: json["contact_person_id"],
    ownerId: json["owner_id"],
    areaId: json["area_id"],
    firmId: json["firm_id"],
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
  };
}
