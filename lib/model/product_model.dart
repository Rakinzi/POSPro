// class TestProductModel {
//   TestProductModel({
//     String? message,
//     num? totalStockValue,
//     List<Data>? data,
//   }) {
//     _message = message;
//     _totalStockValue = totalStockValue;
//     _data = data;
//   }
//
//   TestProductModel.fromJson(dynamic json) {
//     _message = json['message'];
//     _totalStockValue = json['total_stock_value'];
//     if (json['data'] != null) {
//       _data = [];
//       json['data'].forEach((v) {
//         _data?.add(Data.fromJson(v));
//       });
//     }
//   }
//   String? _message;
//   num? _totalStockValue;
//   List<Data>? _data;
//   TestProductModel copyWith({
//     String? message,
//     num? totalStockValue,
//     List<Data>? data,
//   }) =>
//       TestProductModel(
//         message: message ?? _message,
//         totalStockValue: totalStockValue ?? _totalStockValue,
//         data: data ?? _data,
//       );
//   String? get message => _message;
//   num? get totalStockValue => _totalStockValue;
//   List<Data>? get data => _data;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['message'] = _message;
//     map['total_stock_value'] = _totalStockValue;
//     if (_data != null) {
//       map['data'] = _data?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }
//
// class Data {
//   Data({
//     num? id,
//     String? productName,
//     num? businessId,
//     num? unitId,
//     num? brandId,
//     num? categoryId,
//     String? productCode,
//     dynamic productPicture,
//     String? productType,
//     num? productDealerPrice,
//     num? productPurchasePrice,
//     num? productSalePrice,
//     num? productWholeSalePrice,
//     num? productStock,
//     dynamic expireDate,
//     num? alertQty,
//     num? profitPercent,
//     num? vatAmount,
//     String? vatType,
//     String? size,
//     String? type,
//     String? color,
//     String? weight,
//     dynamic capacity,
//     String? productManufacturer,
//     dynamic meta,
//     String? createdAt,
//     String? updatedAt,
//     dynamic vatId,
//     num? modelId,
//     dynamic warehouseId,
//     num? stocksSumProductStock,
//     Unit? unit,
//     dynamic vat,
//     Brand? brand,
//     Category? category,
//     ProductModel? productModel,
//     List<Stocks>? stocks,
//   }) {
//     _id = id;
//     _productName = productName;
//     _businessId = businessId;
//     _unitId = unitId;
//     _brandId = brandId;
//     _categoryId = categoryId;
//     _productCode = productCode;
//     _productPicture = productPicture;
//     _productType = productType;
//     _productDealerPrice = productDealerPrice;
//     _productPurchasePrice = productPurchasePrice;
//     _productSalePrice = productSalePrice;
//     _productWholeSalePrice = productWholeSalePrice;
//     _productStock = productStock;
//     _expireDate = expireDate;
//     _alertQty = alertQty;
//     _profitPercent = profitPercent;
//     _vatAmount = vatAmount;
//     _vatType = vatType;
//     _size = size;
//     _type = type;
//     _color = color;
//     _weight = weight;
//     _capacity = capacity;
//     _productManufacturer = productManufacturer;
//     _meta = meta;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//     _vatId = vatId;
//     _modelId = modelId;
//     _warehouseId = warehouseId;
//     _stocksSumProductStock = stocksSumProductStock;
//     _unit = unit;
//     _vat = vat;
//     _brand = brand;
//     _category = category;
//     _productModel = productModel;
//     _stocks = stocks;
//   }
//
//   Data.fromJson(dynamic json) {
//     _id = json['id'];
//     _productName = json['productName'];
//     _businessId = json['business_id'];
//     _unitId = json['unit_id'];
//     _brandId = json['brand_id'];
//     _categoryId = json['category_id'];
//     _productCode = json['productCode'];
//     _productPicture = json['productPicture'];
//     _productType = json['product_type'];
//     _productDealerPrice = json['productDealerPrice'];
//     _productPurchasePrice = json['productPurchasePrice'];
//     _productSalePrice = json['productSalePrice'];
//     _productWholeSalePrice = json['productWholeSalePrice'];
//     _productStock = json['productStock'];
//     _expireDate = json['expire_date'];
//     _alertQty = json['alert_qty'];
//     _profitPercent = json['profit_percent'];
//     _vatAmount = json['vat_amount'];
//     _vatType = json['vat_type'];
//     _size = json['size'];
//     _type = json['type'];
//     _color = json['color'];
//     _weight = json['weight'];
//     _capacity = json['capacity'];
//     _productManufacturer = json['productManufacturer'];
//     _meta = json['meta'];
//     _createdAt = json['created_at'];
//     _updatedAt = json['updated_at'];
//     _vatId = json['vat_id'];
//     _modelId = json['model_id'];
//     _warehouseId = json['warehouse_id'];
//     _stocksSumProductStock = json['stocks_sum_product_stock'];
//     _unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
//     _vat = json['vat'];
//     _brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
//     _category = json['category'] != null ? Category.fromJson(json['category']) : null;
//     _productModel = json['product_model'] != null ? ProductModel.fromJson(json['product_model']) : null;
//     if (json['stocks'] != null) {
//       _stocks = [];
//       json['stocks'].forEach((v) {
//         _stocks?.add(Stocks.fromJson(v));
//       });
//     }
//   }
//   num? _id;
//   String? _productName;
//   num? _businessId;
//   num? _unitId;
//   num? _brandId;
//   num? _categoryId;
//   String? _productCode;
//   dynamic _productPicture;
//   String? _productType;
//   num? _productDealerPrice;
//   num? _productPurchasePrice;
//   num? _productSalePrice;
//   num? _productWholeSalePrice;
//   num? _productStock;
//   dynamic _expireDate;
//   num? _alertQty;
//   num? _profitPercent;
//   num? _vatAmount;
//   String? _vatType;
//   String? _size;
//   String? _type;
//   String? _color;
//   String? _weight;
//   dynamic _capacity;
//   String? _productManufacturer;
//   dynamic _meta;
//   String? _createdAt;
//   String? _updatedAt;
//   dynamic _vatId;
//   num? _modelId;
//   dynamic _warehouseId;
//   num? _stocksSumProductStock;
//   Unit? _unit;
//   dynamic _vat;
//   Brand? _brand;
//   Category? _category;
//   ProductModel? _productModel;
//   List<Stocks>? _stocks;
//   Data copyWith({
//     num? id,
//     String? productName,
//     num? businessId,
//     num? unitId,
//     num? brandId,
//     num? categoryId,
//     String? productCode,
//     dynamic productPicture,
//     String? productType,
//     num? productDealerPrice,
//     num? productPurchasePrice,
//     num? productSalePrice,
//     num? productWholeSalePrice,
//     num? productStock,
//     dynamic expireDate,
//     num? alertQty,
//     num? profitPercent,
//     num? vatAmount,
//     String? vatType,
//     String? size,
//     String? type,
//     String? color,
//     String? weight,
//     dynamic capacity,
//     String? productManufacturer,
//     dynamic meta,
//     String? createdAt,
//     String? updatedAt,
//     dynamic vatId,
//     num? modelId,
//     dynamic warehouseId,
//     num? stocksSumProductStock,
//     Unit? unit,
//     dynamic vat,
//     Brand? brand,
//     Category? category,
//     ProductModel? productModel,
//     List<Stocks>? stocks,
//   }) =>
//       Data(
//         id: id ?? _id,
//         productName: productName ?? _productName,
//         businessId: businessId ?? _businessId,
//         unitId: unitId ?? _unitId,
//         brandId: brandId ?? _brandId,
//         categoryId: categoryId ?? _categoryId,
//         productCode: productCode ?? _productCode,
//         productPicture: productPicture ?? _productPicture,
//         productType: productType ?? _productType,
//         productDealerPrice: productDealerPrice ?? _productDealerPrice,
//         productPurchasePrice: productPurchasePrice ?? _productPurchasePrice,
//         productSalePrice: productSalePrice ?? _productSalePrice,
//         productWholeSalePrice: productWholeSalePrice ?? _productWholeSalePrice,
//         productStock: productStock ?? _productStock,
//         expireDate: expireDate ?? _expireDate,
//         alertQty: alertQty ?? _alertQty,
//         profitPercent: profitPercent ?? _profitPercent,
//         vatAmount: vatAmount ?? _vatAmount,
//         vatType: vatType ?? _vatType,
//         size: size ?? _size,
//         type: type ?? _type,
//         color: color ?? _color,
//         weight: weight ?? _weight,
//         capacity: capacity ?? _capacity,
//         productManufacturer: productManufacturer ?? _productManufacturer,
//         meta: meta ?? _meta,
//         createdAt: createdAt ?? _createdAt,
//         updatedAt: updatedAt ?? _updatedAt,
//         vatId: vatId ?? _vatId,
//         modelId: modelId ?? _modelId,
//         warehouseId: warehouseId ?? _warehouseId,
//         stocksSumProductStock: stocksSumProductStock ?? _stocksSumProductStock,
//         unit: unit ?? _unit,
//         vat: vat ?? _vat,
//         brand: brand ?? _brand,
//         category: category ?? _category,
//         productModel: productModel ?? _productModel,
//         stocks: stocks ?? _stocks,
//       );
//   num? get id => _id;
//   String? get productName => _productName;
//   num? get businessId => _businessId;
//   num? get unitId => _unitId;
//   num? get brandId => _brandId;
//   num? get categoryId => _categoryId;
//   String? get productCode => _productCode;
//   dynamic get productPicture => _productPicture;
//   String? get productType => _productType;
//   num? get productDealerPrice => _productDealerPrice;
//   num? get productPurchasePrice => _productPurchasePrice;
//   num? get productSalePrice => _productSalePrice;
//   num? get productWholeSalePrice => _productWholeSalePrice;
//   num? get productStock => _productStock;
//   dynamic get expireDate => _expireDate;
//   num? get alertQty => _alertQty;
//   num? get profitPercent => _profitPercent;
//   num? get vatAmount => _vatAmount;
//   String? get vatType => _vatType;
//   String? get size => _size;
//   String? get type => _type;
//   String? get color => _color;
//   String? get weight => _weight;
//   dynamic get capacity => _capacity;
//   String? get productManufacturer => _productManufacturer;
//   dynamic get meta => _meta;
//   String? get createdAt => _createdAt;
//   String? get updatedAt => _updatedAt;
//   dynamic get vatId => _vatId;
//   num? get modelId => _modelId;
//   dynamic get warehouseId => _warehouseId;
//   num? get stocksSumProductStock => _stocksSumProductStock;
//   Unit? get unit => _unit;
//   dynamic get vat => _vat;
//   Brand? get brand => _brand;
//   Category? get category => _category;
//   ProductModel? get productModel => _productModel;
//   List<Stocks>? get stocks => _stocks;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['productName'] = _productName;
//     map['business_id'] = _businessId;
//     map['unit_id'] = _unitId;
//     map['brand_id'] = _brandId;
//     map['category_id'] = _categoryId;
//     map['productCode'] = _productCode;
//     map['productPicture'] = _productPicture;
//     map['product_type'] = _productType;
//     map['productDealerPrice'] = _productDealerPrice;
//     map['productPurchasePrice'] = _productPurchasePrice;
//     map['productSalePrice'] = _productSalePrice;
//     map['productWholeSalePrice'] = _productWholeSalePrice;
//     map['productStock'] = _productStock;
//     map['expire_date'] = _expireDate;
//     map['alert_qty'] = _alertQty;
//     map['profit_percent'] = _profitPercent;
//     map['vat_amount'] = _vatAmount;
//     map['vat_type'] = _vatType;
//     map['size'] = _size;
//     map['type'] = _type;
//     map['color'] = _color;
//     map['weight'] = _weight;
//     map['capacity'] = _capacity;
//     map['productManufacturer'] = _productManufacturer;
//     map['meta'] = _meta;
//     map['created_at'] = _createdAt;
//     map['updated_at'] = _updatedAt;
//     map['vat_id'] = _vatId;
//     map['model_id'] = _modelId;
//     map['warehouse_id'] = _warehouseId;
//     map['stocks_sum_product_stock'] = _stocksSumProductStock;
//     if (_unit != null) {
//       map['unit'] = _unit?.toJson();
//     }
//     map['vat'] = _vat;
//     if (_brand != null) {
//       map['brand'] = _brand?.toJson();
//     }
//     if (_category != null) {
//       map['category'] = _category?.toJson();
//     }
//     if (_productModel != null) {
//       map['product_model'] = _productModel?.toJson();
//     }
//     if (_stocks != null) {
//       map['stocks'] = _stocks?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }
//
// class Stocks {
//   Stocks({
//     num? id,
//     num? businessId,
//     num? productId,
//     dynamic batchNo,
//     num? productStock,
//     num? productPurchasePrice,
//     num? profitPercent,
//     num? productSalePrice,
//     num? productWholeSalePrice,
//     num? productDealerPrice,
//     String? mfgDate,
//     String? expireDate,
//     String? createdAt,
//     String? updatedAt,
//   }) {
//     _id = id;
//     _businessId = businessId;
//     _productId = productId;
//     _batchNo = batchNo;
//     _productStock = productStock;
//     _productPurchasePrice = productPurchasePrice;
//     _profitPercent = profitPercent;
//     _productSalePrice = productSalePrice;
//     _productWholeSalePrice = productWholeSalePrice;
//     _productDealerPrice = productDealerPrice;
//     _mfgDate = mfgDate;
//     _expireDate = expireDate;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//   }
//
//   Stocks.fromJson(dynamic json) {
//     _id = json['id'];
//     _businessId = json['business_id'];
//     _productId = json['product_id'];
//     _batchNo = json['batch_no'];
//     _productStock = json['productStock'];
//     _productPurchasePrice = json['productPurchasePrice'];
//     _profitPercent = json['profit_percent'];
//     _productSalePrice = json['productSalePrice'];
//     _productWholeSalePrice = json['productWholeSalePrice'];
//     _productDealerPrice = json['productDealerPrice'];
//     _mfgDate = json['mfg_date'];
//     _expireDate = json['expire_date'];
//     _createdAt = json['created_at'];
//     _updatedAt = json['updated_at'];
//   }
//   num? _id;
//   num? _businessId;
//   num? _productId;
//   dynamic _batchNo;
//   num? _productStock;
//   num? _productPurchasePrice;
//   num? _profitPercent;
//   num? _productSalePrice;
//   num? _productWholeSalePrice;
//   num? _productDealerPrice;
//   String? _mfgDate;
//   String? _expireDate;
//   String? _createdAt;
//   String? _updatedAt;
//   Stocks copyWith({
//     num? id,
//     num? businessId,
//     num? productId,
//     dynamic batchNo,
//     num? productStock,
//     num? productPurchasePrice,
//     num? profitPercent,
//     num? productSalePrice,
//     num? productWholeSalePrice,
//     num? productDealerPrice,
//     String? mfgDate,
//     String? expireDate,
//     String? createdAt,
//     String? updatedAt,
//   }) =>
//       Stocks(
//         id: id ?? _id,
//         businessId: businessId ?? _businessId,
//         productId: productId ?? _productId,
//         batchNo: batchNo ?? _batchNo,
//         productStock: productStock ?? _productStock,
//         productPurchasePrice: productPurchasePrice ?? _productPurchasePrice,
//         profitPercent: profitPercent ?? _profitPercent,
//         productSalePrice: productSalePrice ?? _productSalePrice,
//         productWholeSalePrice: productWholeSalePrice ?? _productWholeSalePrice,
//         productDealerPrice: productDealerPrice ?? _productDealerPrice,
//         mfgDate: mfgDate ?? _mfgDate,
//         expireDate: expireDate ?? _expireDate,
//         createdAt: createdAt ?? _createdAt,
//         updatedAt: updatedAt ?? _updatedAt,
//       );
//   num? get id => _id;
//   num? get businessId => _businessId;
//   num? get productId => _productId;
//   dynamic get batchNo => _batchNo;
//   num? get productStock => _productStock;
//   num? get productPurchasePrice => _productPurchasePrice;
//   num? get profitPercent => _profitPercent;
//   num? get productSalePrice => _productSalePrice;
//   num? get productWholeSalePrice => _productWholeSalePrice;
//   num? get productDealerPrice => _productDealerPrice;
//   String? get mfgDate => _mfgDate;
//   String? get expireDate => _expireDate;
//   String? get createdAt => _createdAt;
//   String? get updatedAt => _updatedAt;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['business_id'] = _businessId;
//     map['product_id'] = _productId;
//     map['batch_no'] = _batchNo;
//     map['productStock'] = _productStock;
//     map['productPurchasePrice'] = _productPurchasePrice;
//     map['profit_percent'] = _profitPercent;
//     map['productSalePrice'] = _productSalePrice;
//     map['productWholeSalePrice'] = _productWholeSalePrice;
//     map['productDealerPrice'] = _productDealerPrice;
//     map['mfg_date'] = _mfgDate;
//     map['expire_date'] = _expireDate;
//     map['created_at'] = _createdAt;
//     map['updated_at'] = _updatedAt;
//     return map;
//   }
// }
//
// class ProductModel {
//   ProductModel({
//     num? id,
//     String? name,
//   }) {
//     _id = id;
//     _name = name;
//   }
//
//   ProductModel.fromJson(dynamic json) {
//     _id = json['id'];
//     _name = json['name'];
//   }
//   num? _id;
//   String? _name;
//   ProductModel copyWith({
//     num? id,
//     String? name,
//   }) =>
//       ProductModel(
//         id: id ?? _id,
//         name: name ?? _name,
//       );
//   num? get id => _id;
//   String? get name => _name;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['name'] = _name;
//     return map;
//   }
// }
//
// class Category {
//   Category({
//     num? id,
//     String? categoryName,
//   }) {
//     _id = id;
//     _categoryName = categoryName;
//   }
//
//   Category.fromJson(dynamic json) {
//     _id = json['id'];
//     _categoryName = json['categoryName'];
//   }
//   num? _id;
//   String? _categoryName;
//   Category copyWith({
//     num? id,
//     String? categoryName,
//   }) =>
//       Category(
//         id: id ?? _id,
//         categoryName: categoryName ?? _categoryName,
//       );
//   num? get id => _id;
//   String? get categoryName => _categoryName;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['categoryName'] = _categoryName;
//     return map;
//   }
// }
//
// class Brand {
//   Brand({
//     num? id,
//     String? brandName,
//   }) {
//     _id = id;
//     _brandName = brandName;
//   }
//
//   Brand.fromJson(dynamic json) {
//     _id = json['id'];
//     _brandName = json['brandName'];
//   }
//   num? _id;
//   String? _brandName;
//   Brand copyWith({
//     num? id,
//     String? brandName,
//   }) =>
//       Brand(
//         id: id ?? _id,
//         brandName: brandName ?? _brandName,
//       );
//   num? get id => _id;
//   String? get brandName => _brandName;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['brandName'] = _brandName;
//     return map;
//   }
// }
//
// class Unit {
//   Unit({
//     num? id,
//     String? unitName,
//   }) {
//     _id = id;
//     _unitName = unitName;
//   }
//
//   Unit.fromJson(dynamic json) {
//     _id = json['id'];
//     _unitName = json['unitName'];
//   }
//   num? _id;
//   String? _unitName;
//   Unit copyWith({
//     num? id,
//     String? unitName,
//   }) =>
//       Unit(
//         id: id ?? _id,
//         unitName: unitName ?? _unitName,
//       );
//   num? get id => _id;
//   String? get unitName => _unitName;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['unitName'] = _unitName;
//     return map;
//   }
// }
