import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/payment_type_model.dart';
import '../repo/payment_type_repo.dart';

PaymentTypeRepo repo = PaymentTypeRepo();
final paymentTypeProvider = FutureProvider.autoDispose<List<PaymentTypeModel>>((ref) => repo.fetchAllPaymentType());
