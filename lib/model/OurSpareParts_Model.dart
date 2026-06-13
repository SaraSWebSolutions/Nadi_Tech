import 'dart:convert';
import 'package:flutter/material.dart';

OurSpareParts ourSparePartsFromJson(String str) =>
    OurSpareParts.fromJson(json.decode(str));

String ourSparePartsToJson(OurSpareParts data) => json.encode(data.toJson());

class OurSpareParts {
  bool success;
  List<Datum> data;

  OurSpareParts({required this.success, required this.data});

  factory OurSpareParts.fromJson(Map<String, dynamic> json) => OurSpareParts(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  String id;
  String technicianId;
  ProductId productId;
  String count;
  DateTime createdAt;
  DateTime updatedAt;

  int v;

  Datum({
    required this.id,
    required this.technicianId,
    required this.productId,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    technicianId: json["technicianId"],
    productId: ProductId.fromJson(json["productId"]),
    count: json["count"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "technicianId": technicianId,
    "productId": productId.toJson(),
    "count": count,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class ProductId {
  String id;
  String productName;
  int quantity;
  bool stock;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  int price;
  String productNameEn;
  String productNameAr;

  ProductId({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.price,
    required this.productNameAr,
    required this.productNameEn,
  });

  factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
    id: json["_id"],
    productName: json["productName"],
    quantity: json["quantity"] is int
        ? json["quantity"]
        : int.parse(json["quantity"].toString()),
    stock: json["stock"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    price: json["price"],
    productNameEn: json["productName_en"] ?? "",
    productNameAr: json["productName_ar"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "productName": productName,
    "quantity": quantity,
    "productName_en": productNameEn,
    "productName_ar": productNameAr,
    "stock": stock,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
    "price": price,
  };
}

extension ProductNameLocalization on ProductId {
  String name(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    if (locale == 'ar') {
      return productNameAr.isNotEmpty ? productNameAr : productNameEn;
    }
    return productNameEn;
  }
}
