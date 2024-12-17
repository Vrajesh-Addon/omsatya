class UserResponse {
  int? id;
  String? name;
  String? email;
  String? phoneNo;
  int? areaId;
  int? isActive;
  String? dutyStart;
  String? dutyEnd;
  String? dutyHours;
  List<Role>? roles;
  dynamic isSalseEmb;
  dynamic isSalseCir;
  String? profile;

  UserResponse({
    this.id,
    this.name,
    this.email,
    this.phoneNo,
    this.areaId,
    this.isActive,
    this.dutyStart,
    this.dutyEnd,
    this.dutyHours,
    this.roles,
    this.isSalseEmb,
    this.isSalseCir,
    this.profile,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json["id"],
    name: json["name"],
    email: json["email"] ?? "",
    phoneNo: json["phone_no"],
    areaId: json["area_id"],
    isActive: json["is_active"],
    dutyStart: json["duty_start"] ?? "",
    dutyEnd: json["duty_end"] ?? "",
    dutyHours: json["duty_hours"] ?? "",
    roles: json["roles"] == null ? [] : List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
    isSalseEmb: json["is_salse_emb"],
    isSalseCir: json["is_salse_cir"],
    profile: json["profile"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone_no": phoneNo,
    "area_id": areaId,
    "is_active": isActive,
    "duty_start": dutyStart,
    "duty_end": dutyEnd,
    "duty_hours": dutyHours,
    "roles": List<dynamic>.from(roles!.map((x) => x.toJson())),
    "is_salse_emb": isSalseEmb,
    "is_salse_cir": isSalseCir,
    "profile": profile,
  };
}

class Role {
  int? id;
  String? name;
  String? guardName;
  Pivot? pivot;

  Role({
   this.id,
   this.name,
   this.guardName,
   this.pivot,
  });

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json["id"],
    name: json["name"],
    guardName: json["guard_name"],
    pivot: json["pivot"] == null ? Pivot.fromJson({}) : Pivot.fromJson(json["pivot"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "guard_name": guardName,
    "pivot": pivot!.toJson(),
  };
}

class Pivot {
  String? modelType;
  int? modelId;
  int? roleId;

  Pivot({
    this.modelType,
    this.modelId,
    this.roleId,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
    modelType: json["model_type"],
    modelId: json["model_id"],
    roleId: json["role_id"],
  );

  Map<String, dynamic> toJson() => {
    "model_type": modelType,
    "model_id": modelId,
    "role_id": roleId,
  };
}