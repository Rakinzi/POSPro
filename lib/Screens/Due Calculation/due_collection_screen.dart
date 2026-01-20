// ignore_for_file: unused_result
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Model/due_collection_model.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/Repo/due_repo.dart';
import 'package:mobile_pos/Screens/invoice_details/due_invoice_details.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/payment_type/_payment_type_dropdown.dart';
import '../Customers/Model/parties_model.dart';
import 'Model/due_collection_invoice_model.dart';
import 'Providers/due_provider.dart';

class DueCollectionScreen extends StatefulWidget {
  const DueCollectionScreen({super.key, required this.customerModel});

  @override
  State<DueCollectionScreen> createState() => _DueCollectionScreenState();
  final Party customerModel;
}

class _DueCollectionScreenState extends State<DueCollectionScreen> {
  num paidAmount = 0;
  num remainDueAmount = 0;
  num dueAmount = 0;

  num calculateDueAmount({required num total}) {
    if (total < 0) {
      remainDueAmount = 0;
    } else {
      remainDueAmount = dueAmount - total;
    }
    return dueAmount - total;
  }

  TextEditingController paidText = TextEditingController();
  TextEditingController dateController = TextEditingController(text: DateTime.now().toString());

  SalesDuesInvoice? selectedInvoice;
  int? paymentType;

  // List of items in our dropdown menu

  int count = 0;

  @override
  Widget build(BuildContext context) {
    count++;
    return Consumer(builder: (context, consumerRef, __) {
      // final printerData = consumerRef.watch(printerDueProviderNotifier);
      final personalData = consumerRef.watch(businessInfoProvider);
      final dueInvoiceData = consumerRef.watch(dueInvoiceListProvider(widget.customerModel.id?.round() ?? 0));
      final _theme = Theme.of(context);
      return personalData.when(data: (data) {
        List<SalesDuesInvoice> items = [];
        num openingDueAmount = 0;
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                lang.S.of(context).collectDue,
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            dueInvoiceData.when(data: (data) {
                              num totalDueInInvoice = 0;
                              if (data.salesDues?.isNotEmpty ?? false) {
                                for (var element in data.salesDues!) {
                                  totalDueInInvoice += element.dueAmount ?? 0;
                                  items.add(element);
                                }
                              }
                              openingDueAmount = (data.due ?? 0) - totalDueInInvoice;
                              if (selectedInvoice == null) {
                                dueAmount = openingDueAmount;
                              }

                              return Expanded(
                                child: DropdownButtonFormField<SalesDuesInvoice>(
                                  isExpanded: true,
                                  initialValue: selectedInvoice,
                                  hint: Text(
                                    lang.S.of(context).selectAInvoice,
                                    //'Select a invoice'
                                  ),
                                  icon: selectedInvoice != null
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedInvoice = null;
                                            });
                                          },
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        )
                                      : const Icon(Icons.keyboard_arrow_down, color: kGreyTextColor),
                                  items: items.map((SalesDuesInvoice invoice) {
                                    return DropdownMenuItem(
                                      value: invoice,
                                      child: Text(
                                        invoice.invoiceNumber.toString(),
                                        style: _theme.textTheme.bodyMedium,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      dueAmount = newValue?.dueAmount ?? 0;
                                      paidAmount = 0;
                                      paidText.clear();
                                      selectedInvoice = newValue;
                                    });
                                  },
                                  decoration: const InputDecoration(),
                                ),
                              );
                            }, error: (e, stack) {
                              return Text(e.toString());
                            }, loading: () {
                              return const Center(child: CircularProgressIndicator());
                            }),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                readOnly: true,
                                controller: dateController,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).date,
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      final DateTime? picked = await showDatePicker(
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2015, 8),
                                        lastDate: DateTime(2101),
                                        context: context,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          dateController.text = picked.toString();
                                        });
                                      }
                                    },
                                    icon: const Icon(FeatherIcons.calendar),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                  text: "${lang.S.of(context).totalDueAmount}: ",
                                  style: _theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: DAppColors.kSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.customerModel.due == null ? '$currency${0}' : '$currency${widget.customerModel.due}',
                                      style: const TextStyle(color: Color(0xFFFF8C34)),
                                    ),
                                  ]),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          initialValue: widget.customerModel.name,
                          decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText: lang.S.of(context).customerName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        ///_____Total______________________________
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5),
                            ),
                            color: _theme.colorScheme.primaryContainer,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff000000).withValues(alpha: 0.08),
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xffFEF0F1),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(5),
                                    topLeft: Radius.circular(5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).totalAmount,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      dueAmount.toStringAsFixed(2),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).paidAmount,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: context.width() / 4,
                                      height: 30,
                                      child: TextFormField(
                                        controller: paidText,
                                        onChanged: (value) {
                                          if (value == '') {
                                            setState(() {
                                              paidAmount = 0;
                                            });
                                          } else {
                                            if (value.toDouble() <= dueAmount) {
                                              setState(() {
                                                paidAmount = double.parse(value);
                                              });
                                            } else {
                                              paidText.clear();
                                              setState(() {
                                                paidAmount = 0;
                                              });
                                              EasyLoading.showError(
                                                lang.S.of(context).youCanNotPayMoreThenDue,
                                                // 'You can\'t pay more then due'
                                              );
                                            }
                                          }
                                        },
                                        textAlign: TextAlign.right,
                                        decoration: const InputDecoration(
                                          hintText: '0',
                                          hintStyle: TextStyle(color: kNeutralColor),
                                          border: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: kBorder)),
                                          focusedBorder: UnderlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      lang.S.of(context).dueAmount,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      calculateDueAmount(total: paidAmount).toStringAsFixed(2),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  ///__________Payment_Type_______________________________________
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Divider(height: 20),
                        PaymentTypeSelectorDropdown(
                          value: paymentType,
                          onChanged: (value) => setState(
                            () => paymentType = value,
                          ),
                        ),
                        const Divider(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        maximumSize: const Size(double.infinity, 48),
                        minimumSize: const Size(double.infinity, 48),
                        disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      child: Text(
                        lang.S.of(context).cancel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                        maximumSize: const Size(double.infinity, 48),
                        minimumSize: const Size(double.infinity, 48),
                        disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                      ),
                      onPressed: () async {
                        if (paidAmount > 0 && dueAmount > 0) {
                          if (paymentType == null) {
                            EasyLoading.showError('Please select a payment type');
                          } else {
                            EasyLoading.show();
                            DueRepo repo = DueRepo();
                            DueCollection? dueData;
                            dueData = await repo.dueCollect(
                              ref: consumerRef,
                              context: context,
                              partyId: widget.customerModel.id ?? 0,
                              invoiceNumber: selectedInvoice?.invoiceNumber,
                              paymentDate: dateController.text,
                              paymentType: paymentType?.toString() ?? '',
                              payDueAmount: paidAmount,
                            );
                            debugPrint('due collection: $dueData');

                            if (!context.mounted) return;
                            if (dueData != null) {
                              DueInvoiceDetails(
                                dueCollection: dueData,
                                personalInformationModel: data,
                                isFromDue: true,
                              ).launch(context);
                            }
                          }
                        } else {
                          EasyLoading.showError(
                            lang.S.of(context).noDueSelected,
                            //'No Due Selected'
                          );
                        }
                      },
                      child: Text(
                        lang.S.of(context).save,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _theme.textTheme.bodyMedium?.copyWith(
                          color: _theme.colorScheme.primaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }, error: (e, stack) {
        return Center(
          child: Text(e.toString()),
        );
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}
