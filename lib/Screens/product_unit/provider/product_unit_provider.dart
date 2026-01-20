import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Products/Repo/unit_repo.dart';
import '../../product_unit/model/unit_model.dart';

final unitsProvider = FutureProvider<List<Unit>>((ref) => UnitsRepo().fetchAllUnits());
