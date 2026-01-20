import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/currency_model.dart';
import '../Repo/currency_repo.dart';

CurrencyRepo repo = CurrencyRepo();
final currencyProvider = FutureProvider.autoDispose<List<CurrencyModel>>((ref) => repo.fetchAllCurrency());
