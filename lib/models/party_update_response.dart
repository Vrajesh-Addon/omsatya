import 'dart:convert';

import 'package:omsatya/models/complain_response.dart';

PartyUpdateResponse partyUpdateResponseFromJson(String str) => PartyUpdateResponse.fromJson(json.decode(str));

String partyUpdateResponseToJson(PartyUpdateResponse data) => json.encode(data.toJson());

class PartyUpdateResponse {
  bool success;
  String message;
  Party data;

  PartyUpdateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PartyUpdateResponse.fromJson(Map<String, dynamic> json) => PartyUpdateResponse(
    success: json["success"],
    message: json["message"],
    data: Party.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data.toJson(),
  };
}