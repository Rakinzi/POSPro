import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/category_model.dart';
import '../../repo/category_repo.dart';

CategoryRepo categoryRepo = CategoryRepo();
final categoryProvider = FutureProvider<List<CategoryModel>>((ref) => categoryRepo.fetchAllCategory());
