import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Purchase/Model/purchase_transaction_model.dart';
import 'package:mobile_pos/Screens/Purchase/Repo/purchase_repo.dart';
import 'package:mobile_pos/Screens/Sales/Repo/sales_repo.dart';
import 'package:mobile_pos/model/sale_transaction_model.dart';

SaleRepo saleRepo = SaleRepo();
final salesTransactionProvider = FutureProvider<List<SalesTransactionModel>>((ref) => saleRepo.fetchSalesList());
final salesReturnTransactionProvider = FutureProvider<List<SalesTransactionModel>>((ref) => saleRepo.fetchSalesList(salesReturn: true));

// PurchaseTransitionRepo purchaseTransitionRepo = PurchaseTransitionRepo();
PurchaseRepo repo = PurchaseRepo();
final purchaseTransactionProvider = FutureProvider<List<PurchaseTransaction>>((ref) => repo.fetchPurchaseList());
final purchaseReturnTransactionProvider = FutureProvider<List<PurchaseTransaction>>((ref) => repo.fetchPurchaseList(purchaseReturn: true));
