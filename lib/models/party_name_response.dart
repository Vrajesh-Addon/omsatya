import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

PartyNameResponse partyNameResponseFromJson(String str) => PartyNameResponse.fromJson(json.decode(str));

String partyNameResponseToJson(PartyNameResponse data) => json.encode(data.toJson());

class PartyNameResponse {
  bool success;
  String message;
  List<Party> data;

  PartyNameResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PartyNameResponse.fromJson(Map<String, dynamic> json) => PartyNameResponse(
    success: json["success"],
    message: json["message"],
    data: List<Party>.from(json["data"].map((x) => Party.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}
