class Income {
  Income({
    this.id,
    this.account,
    this.amount,
    this.incomeCategoryId,
    this.userId,
    this.businessId,
    this.incomeFor,
    this.paymentTypeId,
    this.paymentType,
    this.referenceNo,
    this.note,
    this.incomeDate,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  Income.fromJson(dynamic json) {
    id = json['id'];
    account = json['account'];
    amount = json['amount'] as num;
    incomeCategoryId = json['income_category_id'];
    userId = json['user_id'];
    businessId = json['business_id'];
    incomeFor = json['incomeFor'];
    paymentTypeId = json["payment_type_id"];
    paymentType = json['paymentType'];
    referenceNo = json['referenceNo'];
    note = json['note'];
    incomeDate = json['incomeDate'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  num? id;
  num? account;
  num? amount;
  num? incomeCategoryId;
  num? userId;
  num? businessId;
  String? incomeFor;
  int? paymentTypeId;
  String? paymentType;
  String? referenceNo;
  String? note;
  String? incomeDate;
  String? createdAt;
  String? updatedAt;
  Category? category;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['account'] = account;
    map['amount'] = amount;
    map['expense_category_id'] = incomeCategoryId;
    map['user_id'] = userId;
    map['business_id'] = businessId;
    map['expanseFor'] = incomeFor;
    map['paymentType'] = paymentType;
    map['referenceNo'] = referenceNo;
    map['note'] = note;
    map['incomeDate'] = incomeDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (category != null) {
      map['category'] = category?.toJson();
    }
    return map;
  }
}

class Category {
  Category({
    this.id,
    this.categoryName,
  });

  Category.fromJson(dynamic json) {
    id = json['id'];
    categoryName = json['categoryName'];
  }

  num? id;
  String? categoryName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['categoryName'] = categoryName;
    return map;
  }
}
