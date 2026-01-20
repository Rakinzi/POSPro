import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Currency/Provider/currency_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import 'Model/currency_model.dart';
import 'Repo/currency_repo.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key}) ;

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  CurrencyModel selectedCurrency = CurrencyModel(name: currencyName, symbol: currency);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final currencyData = ref.watch(currencyProvider);
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).currency,
              //'Currency',
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
          ),
          body: currencyData.when(
            data: (currencyList) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currencyList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: selectedCurrency.name == currencyList[index].name ? kMainColor : kWhite,
                            boxShadow: [
                              BoxShadow(color: const Color(0xff0C1A4B).withValues(alpha: 0.24), blurRadius: 1),
                              BoxShadow(color: const Color(0xff473232).withValues(alpha: 0.05), offset: const Offset(0, 3), spreadRadius: -1, blurRadius: 8)
                            ],
                          ),
                          child: ListTile(
                            selected: selectedCurrency.name == currencyList[index].name,
                            selectedColor: Colors.white,
                            onTap: () {
                              setState(() {
                                selectedCurrency = currencyList[index];
                              });
                            },
                            title: Text('${currencyList[index].name} - ${currencyList[index].symbol}'),
                            trailing: const Icon(
                              (Icons.arrow_forward_ios),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            error: (error, stackTrace) {
              return null;
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                try {
                  EasyLoading.show();

                  final isSet = await CurrencyRepo().setDefaultCurrency(id: selectedCurrency.id!);
                  if (!context.mounted) return;
                  if (isSet) {
                    await CurrencyMethods().saveCurrencyDataInLocalDatabase(
                      selectedCurrencyName: selectedCurrency.name,
                      selectedCurrencySymbol: selectedCurrency.symbol,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  } else {
                    EasyLoading.showError('Something went wrong');
                  }
                } catch (e) {
                  EasyLoading.showError('An error occurred: $e');
                } finally {
                  EasyLoading.dismiss();
                }
              },
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: kMainColor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    lang.S.of(context).save,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
