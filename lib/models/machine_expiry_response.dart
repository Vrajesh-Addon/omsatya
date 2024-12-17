import 'dart:convert';

import 'package:omsatya/models/customer_machine_response.dart';

MachineExpiryResponse machineExpiryResponseFromJson(String str) => MachineExpiryResponse.fromJson(json.decode(str));

String machineExpiryResponseToJson(MachineExpiryResponse data) => json.encode(data.toJson());

class MachineExpiryResponse {
  bool? success;
  String? message;
  List<MachineData>? data;

  MachineExpiryResponse({
    this.success,
    this.message,
    this.data,
  });

  factory MachineExpiryResponse.fromJson(Map<String, dynamic> json) => MachineExpiryResponse(
    success: json["success"],
    message: json["message"],
    data: List<MachineData>.from(json["data"].map((x) => MachineData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}


