import '../../../model/sale_transaction_model.dart';
import '../../Customers/Model/parties_model.dart';

class DueCollection {
  DueCollection({
    this.id,
    this.businessId,
    this.partyId,
    this.userId,
    this.saleId,
    this.purchaseId,
    this.totalDue,
    this.dueAmountAfterPay,
    this.payDueAmount,
    this.paymentTypeId,
    this.paymentType,
    this.paymentDate,
    this.invoiceNumber,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.party,
  });

  DueCollection.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    partyId = json['party_id'];
    userId = json['user_id'];
    saleId = json['sale_id'];
    purchaseId = json['purchase_id'];
    totalDue = json['totalDue'];
    dueAmountAfterPay = json['dueAmountAfterPay'];
    payDueAmount = json['payDueAmount'];
    paymentTypeId = int.tryParse(json["payment_type_id"].toString());
    // paymentType = json['paymentType'];
    paymentDate = json['paymentDate'];
    invoiceNumber = json['invoiceNumber'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    party = json['party'] != null ? Party.fromJson(json['party']) : null;
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
  }

  num? id;
  num? businessId;
  num? partyId;
  num? userId;
  num? saleId;
  num? purchaseId;
  num? totalDue;
  num? dueAmountAfterPay;
  num? payDueAmount;
  int? paymentTypeId;
  PaymentType? paymentType;
  String? invoiceNumber;
  String? paymentDate;
  String? createdAt;
  String? updatedAt;
  User? user;
  Party? party;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['party_id'] = partyId;
    map['user_id'] = userId;
    map['sale_id'] = saleId;
    map['purchase_id'] = purchaseId;
    map['totalDue'] = totalDue;
    map['dueAmountAfterPay'] = dueAmountAfterPay;
    map['payDueAmount'] = payDueAmount;
    map['paymentType'] = paymentType;
    map['paymentDate'] = paymentDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (party != null) {
      map['party'] = party?.toJson();
    }
    return map;
  }
}

class PaymentType {
  int? id;
  String? name;

  PaymentType({required this.id, required this.name});

  // Factory constructor to create an instance from a Map
  factory PaymentType.fromJson(Map<String, dynamic> json) {
    return PaymentType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  // Method to convert an instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
