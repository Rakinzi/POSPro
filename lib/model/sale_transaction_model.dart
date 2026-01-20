class SalesTransactionModel {
  SalesTransactionModel({
    this.id,
    this.businessId,
    this.partyId,
    this.userId,
    this.discountAmount,
    this.discountPercent,
    this.shippingCharge,
    this.dueAmount,
    this.isPaid,
    this.vatAmount,
    this.vatPercent,
    this.paidAmount,
    this.changeAmount,
    this.totalAmount,
    this.paymentTypeId,
    this.paymentType,
    this.discountType,
    this.invoiceNumber,
    this.saleDate,
    this.createdAt,
    this.updatedAt,
    this.detailsSumLossProfit,
    this.user,
    this.party,
    this.salesDetails,
    this.salesReturns,
    this.meta,
    this.vatId,
    this.vat,
    this.image,
    this.roundingAmount,
    this.actualTotalAmount,
    this.roundingOption,
  });

  SalesTransactionModel.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    partyId = num.tryParse(json['party_id'].toString()) ?? 0;
    userId = json['user_id'];
    discountAmount = json['discountAmount'];
    discountPercent = num.tryParse(json['discount_percent'].toString()) ?? 0;
    shippingCharge = num.tryParse(json['shipping_charge'].toString()) ?? 0;
    dueAmount = json['dueAmount'];
    isPaid = json['isPaid'];
    vatAmount = json['vat_amount'];
    vatPercent = json['vat_percent'];
    vatId = json['vat_id'];
    paidAmount = json['paidAmount'];
    changeAmount = json['change_amount'];
    totalAmount = json['totalAmount'];
    paymentTypeId = int.tryParse(json['payment_type_id'].toString()) ?? 0;
    discountType = json['discount_type'];
    invoiceNumber = json['invoiceNumber'];
    saleDate = json['saleDate'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    roundingOption = json['rounding_option'].toString();
    roundingAmount = num.tryParse(json['rounding_amount'].toString()) ?? 0;
    actualTotalAmount = num.tryParse(json['actual_total_amount'].toString()) ?? 0;
    detailsSumLossProfit = json['lossProfit'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    vat = json['vat'] != null ? SalesVat.fromJson(json['vat']) : null;
    paymentType = json['payment_type'] != null ? PaymentType.fromJson(json['payment_type']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    party = json['party'] != null ? SalesParty.fromJson(json['party']) : SalesParty(name: 'Guest', type: 'Guest');
    if (json['details'] != null) {
      salesDetails = [];
      json['details'].forEach((v) {
        salesDetails?.add(SalesDetails.fromJson(v));
      });
    }
    if (json['sale_returns'] != null) {
      salesReturns = [];
      json['sale_returns'].forEach((v) {
        salesReturns?.add(SalesReturn.fromJson(v));
      });
    }
    image = json['image'];
  }

  num? id;
  num? businessId;
  num? partyId;
  num? userId;
  num? discountAmount;
  num? discountPercent;
  num? shippingCharge;
  num? dueAmount;
  bool? isPaid;
  num? vatAmount;
  num? vatPercent;
  num? vatId;
  num? paidAmount;
  num? changeAmount;
  num? totalAmount;
  num? roundingAmount;
  num? actualTotalAmount;
  String? roundingOption;
  PaymentType? paymentType;
  int? paymentTypeId;
  String? discountType;
  String? invoiceNumber;
  String? saleDate;
  String? createdAt;
  String? updatedAt;
  num? detailsSumLossProfit;
  User? user;
  SalesParty? party;
  Meta? meta;
  SalesVat? vat;
  List<SalesDetails>? salesDetails;
  List<SalesReturn>? salesReturns;
  String? image;
}

class SalesDetails {
  SalesDetails({
    this.id,
    this.saleId,
    this.productId,
    this.price,
    this.lossProfit,
    this.quantities,
    this.productPurchasePrice,
    this.mfgDate,
    this.expireDate,
    this.stockId,
    this.stock,
    this.createdAt,
    this.updatedAt,
    this.product,
  });

  SalesDetails.fromJson(dynamic json) {
    id = json['id'];
    saleId = json['sale_id'];
    productId = json['product_id'];
    price = json['price'];
    lossProfit = json['lossProfit'];
    quantities = json['quantities'];
    productPurchasePrice = json['productPurchasePrice'];
    mfgDate = json['mfg_date'];
    expireDate = json['expire_date'];
    stockId = json['stock_id'];

    stock = json['stock'] != null ? SalesStock.fromJson(json['stock']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['product'] != null ? SalesProduct.fromJson(json['product']) : null;
  }

  num? id;
  num? saleId;
  num? productId;
  num? price;
  num? lossProfit;
  num? quantities;
  num? productPurchasePrice;
  String? mfgDate;
  String? expireDate;
  num? stockId;
  SalesStock? stock;
  String? createdAt;

  String? updatedAt;
  SalesProduct? product;
}

class SalesProduct {
  SalesProduct({
    this.id,
    this.productName,
    this.categoryId,
    this.category,
    this.productPurchasePrice,
    this.productStock,
    this.productCode,
    this.productType,
  });

  SalesProduct.fromJson(dynamic json) {
    id = json['id'];
    productName = json['productName'];
    productCode = json['productCode'];
    categoryId = json['category_id'];
    productType = json['product_type'];
    productPurchasePrice = json['productPurchasePrice'];
    productStock = json['productStock'];
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  num? id;
  String? productName;
  String? productCode;
  num? categoryId;
  num? productPurchasePrice;
  num? productStock;
  String? productType;
  Category? category;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['productName'] = productName;
    map['category_id'] = categoryId;
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

class SalesParty {
  SalesParty({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.type,
  });

  SalesParty.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    type = json['type'];
  }

  num? id;
  String? name;
  dynamic email;
  String? phone;
  String? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['type'] = type;
    return map;
  }
}

class User {
  User({
    this.id,
    this.name,
    this.role,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    role = json['role'];
  }

  num? id;
  String? name;
  String? role;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['role'] = role;
    return map;
  }
}

class Meta {
  Meta({
    this.customerPhone,
    this.note,
  });

  Meta.fromJson(dynamic json) {
    customerPhone = json['customer_phone'];
    note = json['note'];
  }

  String? customerPhone;
  String? note;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['customer_phone'] = customerPhone;
    map['note'] = note;
    return map;
  }
}

class SalesReturn {
  SalesReturn({
    this.id,
    this.businessId,
    this.saleId,
    this.invoiceNo,
    this.returnDate,
    this.createdAt,
    this.updatedAt,
    this.salesReturnDetails,
  });

  SalesReturn.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    saleId = json['sale_id'];
    invoiceNo = json['invoice_no'];
    returnDate = json['return_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['details'] != null) {
      salesReturnDetails = [];
      json['details'].forEach((v) {
        salesReturnDetails?.add(SalesReturnDetails.fromJson(v));
      });
    }
  }

  num? id;
  num? businessId;
  num? saleId;
  String? invoiceNo;
  String? returnDate;
  String? createdAt;
  String? updatedAt;
  List<SalesReturnDetails>? salesReturnDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['sale_id'] = saleId;
    map['invoice_no'] = invoiceNo;
    map['return_date'] = returnDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (salesReturnDetails != null) {
      map['details'] = salesReturnDetails?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SalesReturnDetails {
  SalesReturnDetails({
    this.id,
    this.businessId,
    this.saleReturnId,
    this.saleDetailId,
    this.returnAmount,
    this.returnQty,
  });

  SalesReturnDetails.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    saleReturnId = json['sale_return_id'];
    saleDetailId = json['sale_detail_id'];
    returnAmount = json['return_amount'];
    returnQty = json['return_qty'];
  }

  num? id;
  num? businessId;
  num? saleReturnId;
  num? saleDetailId;
  num? returnAmount;
  num? returnQty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['sale_return_id'] = saleReturnId;
    map['sale_detail_id'] = saleDetailId;
    map['return_amount'] = returnAmount;
    map['return_qty'] = returnQty;
    return map;
  }
}

class SalesVat {
  SalesVat({
    this.id,
    this.name,
    this.rate,
  });

  SalesVat.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    rate = json['rate'];
  }

  num? id;
  String? name;
  num? rate;
}

class PaymentType {
  PaymentType({
    this.id,
    this.name,
  });

  PaymentType.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
  }

  num? id;
  String? name;
}

class SalesStock {
  SalesStock({
    this.id,
    this.batchNo,
  });

  SalesStock.fromJson(dynamic json) {
    id = json['id'];
    batchNo = json['batch_no'];
  }

  num? id;
  String? batchNo;
}
