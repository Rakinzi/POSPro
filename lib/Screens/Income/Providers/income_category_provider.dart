import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/income_category.dart';
import '../Repo/income_category_repo.dart';

IncomeCategoryRepo incomeCategoryRepo = IncomeCategoryRepo();
final incomeCategoryProvider = FutureProvider.autoDispose<List<IncomeCategory>>((ref) => incomeCategoryRepo.fetchAllIncomeCategory());
