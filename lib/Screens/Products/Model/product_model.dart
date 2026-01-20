class ProductModel {
  ProductModel({
    this.id,
    this.productName,
    this.businessId,
    this.unitId,
    this.brandId,
    this.categoryId,
    this.warehouseId,
    this.modelId,
    this.productCode,
    this.productPicture,
    this.productType,
    this.productDealerPrice,
    this.productPurchasePrice,
    this.productSalePrice,
    this.productWholeSalePrice,
    this.productStockSum,
    this.expireDate,
    this.alertQty,
    this.profitPercent,
    this.vatAmount,
    this.totalStockValue,
    this.vatType,
    this.size,
    this.type,
    this.color,
    this.weight,
    this.capacity,
    this.productManufacturer,
    this.meta,
    this.createdAt,
    this.updatedAt,
    this.vatId,
    this.unit,
    this.brand,
    this.category,
    this.productModel,
    this.stocks,
    this.vat,
  });

  ProductModel.fromJson(dynamic json) {
    id = json['id'];
    productName = json['productName'];
    businessId = json['business_id'];
    unitId = json['unit_id'];
    brandId = json['brand_id'];
    categoryId = json['category_id'];
    warehouseId = json['warehouse_id'];
    modelId = json['model_id'];
    productCode = json['productCode'];
    productPicture = json['productPicture'];
    productType = json['product_type'];
    productDealerPrice = json['productDealerPrice'];
    totalStockValue = json['total_stock_value'];
    productPurchasePrice = json['productPurchasePrice'];
    productSalePrice = json['productSalePrice'];
    productWholeSalePrice = json['productWholeSalePrice'];
    productStockSum = json['stocks_sum_product_stock'];
    expireDate = json['expire_date'];
    alertQty = json['alert_qty'];
    profitPercent = json['profit_percent'];
    vatAmount = json['vat_amount'];
    vatType = json['vat_type'];
    vat = json['vat_rate'];
    size = json['size'];
    type = json['type'];
    color = json['color'];
    weight = json['weight'];
    capacity = json['capacity'];
    productManufacturer = json['productManufacturer'];
    meta = json['meta'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vatId = json['vat_id'];
    vat = json['vat'] != null ? Vat.fromJson(json['vat']) : null;
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null ? Category.fromJson(json['category']) : null;
    productModel = json['product_model'] != null ? Model.fromJson(json['product_model']) : null;
    if (json['stocks'] != null) {
      stocks = [];
      json['stocks'].forEach((v) {
        stocks?.add(Stocks.fromJson(v));
      });
    }
  }
  num? id;
  String? productName;
  num? businessId;
  num? unitId;
  num? brandId;
  num? categoryId;
  dynamic warehouseId;
  num? modelId;
  String? productCode;
  dynamic productPicture;
  String? productType;
  num? productDealerPrice;
  num? productPurchasePrice;
  num? productSalePrice;
  num? productWholeSalePrice;
  num? productStockSum;
  dynamic expireDate;
  num? alertQty;
  num? profitPercent;
  Vat? vat;
  num? vatAmount;
  String? vatType;
  String? size;
  String? type;
  String? color;
  String? weight;
  String? capacity;
  String? productManufacturer;
  dynamic meta;
  String? createdAt;
  num? totalStockValue;
  String? updatedAt;
  num? vatId;
  Unit? unit;
  Brand? brand;
  Category? category;
  Model? productModel;
  List<Stocks>? stocks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['productName'] = productName;
    map['business_id'] = businessId;
    map['unit_id'] = unitId;
    map['brand_id'] = brandId;
    map['category_id'] = categoryId;
    map['warehouse_id'] = warehouseId;
    map['model_id'] = modelId;
    map['productCode'] = productCode;
    map['productPicture'] = productPicture;
    map['product_type'] = productType;
    map['productDealerPrice'] = productDealerPrice;
    map['productPurchasePrice'] = productPurchasePrice;
    map['productSalePrice'] = productSalePrice;
    map['productWholeSalePrice'] = productWholeSalePrice;
    map['productStock'] = productStockSum;
    map['expire_date'] = expireDate;
    map['total_stock_value'] = totalStockValue;
    map['alert_qty'] = alertQty;
    map['profit_percent'] = profitPercent;
    map['vat_amount'] = vatAmount;
    map['vat_type'] = vatType;
    map['size'] = size;
    map['type'] = type;
    map['color'] = color;
    map['weight'] = weight;
    map['capacity'] = capacity;
    map['productManufacturer'] = productManufacturer;
    map['meta'] = meta;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['vat_id'] = vatId;
    if (unit != null) {
      map['unit'] = unit?.toJson();
    }
    if (brand != null) {
      map['brand'] = brand?.toJson();
    }
    if (category != null) {
      map['category'] = category?.toJson();
    }
    map['product_model'] = productModel;
    if (stocks != null) {
      map['stocks'] = stocks?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Stocks {
  Stocks({
    this.id,
    this.businessId,
    this.productId,
    this.batchNo,
    this.productStock,
    this.productPurchasePrice,
    this.profitPercent,
    this.productSalePrice,
    this.productWholeSalePrice,
    this.productDealerPrice,
    this.mfgDate,
    this.expireDate,
    this.createdAt,
    this.updatedAt,
  });

  Stocks.fromJson(dynamic json) {
    id = json['id'];
    businessId = json['business_id'];
    productId = json['product_id'];
    batchNo = json['batch_no'];
    productStock = json['productStock'];
    productPurchasePrice = json['productPurchasePrice'];
    profitPercent = json['profit_percent'];
    productSalePrice = json['productSalePrice'];
    productWholeSalePrice = json['productWholeSalePrice'];
    productDealerPrice = json['productDealerPrice'];
    mfgDate = json['mfg_date'];
    expireDate = json['expire_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? businessId;
  num? productId;
  String? batchNo;
  num? productStock;
  num? productPurchasePrice;
  num? profitPercent;
  num? productSalePrice;
  num? productWholeSalePrice;
  num? productDealerPrice;
  String? mfgDate;
  String? expireDate;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['business_id'] = businessId;
    map['product_id'] = productId;
    map['batch_no'] = batchNo;
    map['productStock'] = productStock;
    map['productPurchasePrice'] = productPurchasePrice;
    map['profit_percent'] = profitPercent;
    map['productSalePrice'] = productSalePrice;
    map['productWholeSalePrice'] = productWholeSalePrice;
    map['productDealerPrice'] = productDealerPrice;
    map['mfg_date'] = mfgDate;
    map['expire_date'] = expireDate;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
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

class Brand {
  Brand({
    this.id,
    this.brandName,
  });

  Brand.fromJson(dynamic json) {
    id = json['id'];
    brandName = json['brandName'];
  }
  num? id;
  String? brandName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['brandName'] = brandName;
    return map;
  }
}

class Vat {
  Vat({
    this.id,
    this.rate,
  });

  Vat.fromJson(dynamic json) {
    id = json['id'];
    rate = json['rate'];
  }
  num? id;
  num? rate;
}

class Unit {
  Unit({
    this.id,
    this.unitName,
  });

  Unit.fromJson(dynamic json) {
    id = json['id'];
    unitName = json['unitName'];
  }
  num? id;
  String? unitName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['unitName'] = unitName;
    return map;
  }
}

class Model {
  Model({
    this.id,
    this.modelName,
  });

  Model.fromJson(dynamic json) {
    id = json['id'];
    modelName = json['modelName'];
  }
  num? id;
  String? modelName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['modelName'] = modelName;
    return map;
  }
}
