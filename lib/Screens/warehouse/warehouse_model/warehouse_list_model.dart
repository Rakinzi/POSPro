class WarehouseListModel {
  WarehouseListModel({
    this.message,
    this.data,
  });

  WarehouseListModel.fromJson(dynamic json) {
    message = json['message'];
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }
  String? message;
  List<Data>? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    this.id,
    this.businessId,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.totalQuantity,
    this.totalValue,
  });

  Data.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    totalQuantity = json['total_quantity'];
    totalValue = json['total_value'];
  }
  num? id;
  num? businessId;
  String? name;
  String? phone;
  String? email;
  String? address;
  num? totalQuantity;
  num? totalValue;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['name'] = name;
    map['phone'] = phone;
    map['email'] = email;
    map['address'] = address;
    map['total_quantity'] = totalQuantity;
    map['total_value'] = totalValue;
    return map;
  }
}
