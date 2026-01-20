import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/payment_type/provider/payment_type_provider.dart';

import '../../generated/l10n.dart' as lang;

class PaymentTypeSelectorDropdown extends ConsumerWidget {
  const PaymentTypeSelectorDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.isFormField = false,
  });

  final int? value;
  final ValueChanged<int?>? onChanged;
  final bool isFormField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentTypes = ref.watch(paymentTypeProvider);

    return paymentTypes.when(
      data: (data) {
        final _data = [...data.where((element) => element.status == 1)];
        if (value == null && _data.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (value == null && _data.isNotEmpty) {
              onChanged?.call(_data.first.id);
            }
          });
        }

        if (isFormField) {
          return DropdownButtonFormField<int>(
            hint: const Text('Select a payment type'),
            decoration: InputDecoration(
              labelText: lang.S.of(context).paymentTypes,
            ),
            initialValue: value,
            items: _data.map((item) {
              return DropdownMenuItem(
                value: item.id,
                child: Text(item.name ?? 'N/A'),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null || value < 0) {
                return 'Please select a payment type';
              }
              return null;
            },
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  lang.S.of(context).paymentTypes,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.wallet,
                  color: Colors.green,
                )
              ],
            ),
            SizedBox(
              width: 110,
              child: DropdownButton<int?>(
                hint: const Text('Select type'),
                value: value,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                underline: SizedBox.shrink(),
                items: _data.map((item) {
                  return DropdownMenuItem(
                    value: item.id,
                    child: Text(
                      item.name ?? 'N/A',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) {
        return Center(child: Text(error.toString()));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
