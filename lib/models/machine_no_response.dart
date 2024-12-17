import 'dart:convert';

MachineNoResponse machineNoFromJson(String str) => MachineNoResponse.fromJson(json.decode(str));

String machineNoToJson(MachineNoResponse data) => json.encode(data.toJson());

class MachineNoResponse {
  bool success;
  String message;
  List<MachineNoData> data;

  MachineNoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MachineNoResponse.fromJson(Map<String, dynamic> json) => MachineNoResponse(
    success: json["success"],
    message: json["message"],
    data: List<MachineNoData>.from(json["data"].map((x) => MachineNoData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MachineNoData {
  String mcNo;

  MachineNoData({
    required this.mcNo,
  });

  factory MachineNoData.fromJson(Map<String, dynamic> json) => MachineNoData(
    mcNo: json["mc_no"],
  );

  Map<String, dynamic> toJson() => {
    "mc_no": mcNo,
  };
}
