class PaymentTypeModel {
  int? id;
  int? businessId;
  String? name;
  int? status;

  PaymentTypeModel({
    this.id,
    this.businessId,
    this.name,
    this.status,
  });

  PaymentTypeModel copyWith({
    int? id,
    int? businessId,
    String? name,
    int? status,
  }) =>
      PaymentTypeModel(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        name: name ?? this.name,
        status: status ?? this.status,
      );

  factory PaymentTypeModel.fromJson(Map<String, dynamic> json) => PaymentTypeModel(
        id: json["id"],
        businessId: json["business_id"],
        name: json["name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "status": status.toString(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentTypeModel && other.id == id && other.businessId == businessId;
  }

  @override
  int get hashCode => Object.hash(id, businessId);
}
