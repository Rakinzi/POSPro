import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/income_modle.dart';
import '../Repo/income_repo.dart';

IncomeRepo incomeRepo = IncomeRepo();
final incomeProvider = FutureProvider<List<Income>>((ref) => incomeRepo.fetchIncome());
