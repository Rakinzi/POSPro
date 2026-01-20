import 'package:mobile_pos/Screens/Products/Model/product_model.dart';

class ProductListResponse {
  final double totalStockValue;
  final List<ProductModel> products;

  ProductListResponse({
    required this.totalStockValue,
    required this.products,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      totalStockValue: (json['total_stock_value'] as num).toDouble(),
      products: (json['data'] as List).map((item) => ProductModel.fromJson(item)).toList(),
    );
  }
}
