import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Repository/API/business_info_update_repo.dart';
import '../../../constant.dart';
import 'model/amount_rounding_dropdown_model.dart';

class SalesSettingsScreen extends ConsumerStatefulWidget {
  const SalesSettingsScreen({super.key});

  @override
  ConsumerState<SalesSettingsScreen> createState() => _SalesSettingsScreenState();
}

class _SalesSettingsScreenState extends ConsumerState<SalesSettingsScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(businessInfoProvider).when(
          data: (data) {
            setState(() {
              selectedMethod = roundingMethods.firstWhere(
                (element) => element.value == data.saleRoundingOption,
              );
            });
          },
          error: (error, stackTrace) {},
          loading: () {},
        );
  }

  AmountRoundingDropdownModel? selectedMethod = roundingMethods[0];

  @override
  Widget build(BuildContext context) {
    final _lang = lang.S.of(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            _lang.salesSetting,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            child: Text(lang.S.of(context).save),
            onPressed: () async {
              ref.watch(businessInfoProvider).when(
                    data: (data) async {
                      final businessRepository = BusinessUpdateRepository();
                      final isProfileUpdated = await businessRepository.updateSalesSettings(
                        id: data.id.toString(),
                        ref: ref,
                        context: context,
                        saleRoundingOption: selectedMethod?.value,
                      );

                      if (!context.mounted) return;
                      if (isProfileUpdated) {
                        ref.invalidate(businessInfoProvider);
                        ref.invalidate(businessSettingProvider);
                        Navigator.pop(context);
                      }
                    },
                    error: (error, stackTrace) {},
                    loading: () {},
                  );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15,
            children: [
              Text(
                '${_lang.amountRoundingMethod}:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              DropdownButtonFormField<AmountRoundingDropdownModel>(
                decoration: InputDecoration(
                  labelText: _lang.amountRoundingMethod,
                  border: OutlineInputBorder(),
                ),
                initialValue: selectedMethod,
                items: roundingMethods.map((method) {
                  return DropdownMenuItem<AmountRoundingDropdownModel>(
                    value: method,
                    child: Text(method.option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMethod = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
