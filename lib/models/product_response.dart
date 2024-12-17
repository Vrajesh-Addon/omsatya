import 'dart:convert';

ProductResponse productResponseFromJson(String str) => ProductResponse.fromJson(json.decode(str));

String productResponseToJson(ProductResponse data) => json.encode(data.toJson());

class ProductResponse {
  bool success;
  String message;
  List<ProductData> data;

  ProductResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) => ProductResponse(
    success: json["success"],
    message: json["message"],
    data: List<ProductData>.from(json["data"].map((x) => ProductData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ProductData {
  int id;
  String name;
  int productTypeId;
  int productGroupId;
  int tag;

  ProductData({
    required this.id,
    required this.name,
    required this.productTypeId,
    required this.productGroupId,
    required this.tag,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) => ProductData(
    id: json["id"],
    name: json["name"],
    productTypeId: json["product_type_id"],
    productGroupId: json["product_group_id"],
    tag: json["tag"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "product_type_id": productTypeId,
    "product_group_id": productGroupId,
    "tag": tag,
  };
}
