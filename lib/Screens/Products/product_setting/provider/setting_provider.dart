import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/get_product_setting_model.dart';
import '../repo/product_setting_repo.dart';

ProductSettingRepo repo = ProductSettingRepo();

final fetchSettingProvider = FutureProvider<GetProductSettingModel>((ref) {
  return repo.fetchProductSetting();
});
