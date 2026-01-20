class VatModel {
  VatModel({
    this.id,
    this.name,
    this.businessId,
    this.rate,
    this.subTax,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  VatModel.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    businessId = json['business_id'];
    rate = json['rate'];
    if (json['sub_vat'] != null) {
      subTax = [];
      json['sub_vat'].forEach((v) {
        subTax?.add(SubVat.fromJson(v));
      });
    }
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  num? businessId;
  num? rate;
  List<SubVat>? subTax;
  bool? status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['business_id'] = businessId;
    map['rate'] = rate;
    if (subTax != null) {
      map['sub_vat'] = subTax?.map((v) => v.toJson()).toList();
    }
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class SubVat {
  SubVat({
    this.id,
    this.name,
    this.rate,
  });

  SubVat.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  num? id;
  String? name;
  num? rate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['rate'] = rate;
    return map;
  }
}
