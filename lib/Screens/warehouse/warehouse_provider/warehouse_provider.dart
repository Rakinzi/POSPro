import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../warehouse_model/warehouse_list_model.dart';
import '../warehouse_repo/warehouse_repo.dart';

WarehouseRepo repo = WarehouseRepo();

// fetch warehouse list
final fetchWarehouseListProvider = FutureProvider<WarehouseListModel>((ref) {
  return repo.fetchWareHouseList();
});
