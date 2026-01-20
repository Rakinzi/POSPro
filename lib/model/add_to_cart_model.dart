class SaleCartModel {
  SaleCartModel({
    required this.productId,
    this.productCode,
    this.productType,
    required this.batchName,
    required this.stockId,
    this.productName,
    this.unitPrice,
    this.quantity = 1,
    this.itemCartIndex = -1,
    this.stock,
    this.productPurchasePrice,
    this.lossProfit,
  });

  num productId;
  num stockId;
  String batchName;
  String? productType;
  String? productCode;
  String? productName;
  num? unitPrice;
  num? productPurchasePrice;
  num quantity = 1;
  int itemCartIndex;
  num? stock;
  num? lossProfit;
}
