// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: unused_result
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import 'Provider/customer_provider.dart';
import 'Repo/parties_repo.dart';

// ignore: must_be_immutable
class EditCustomer extends StatefulWidget {
  EditCustomer({super.key, required this.customerModel});

  Party customerModel;

  @override  State<EditCustomer> createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  String groupValue = '';
  bool expanded = false;
  final ImagePicker _picker = ImagePicker();
  bool showProgress = false;
  XFile? pickedImage;

  @override
  void initState() {
    phoneController.text = widget.customerModel.phone ?? '';
    nameController.text = widget.customerModel.name ?? '';
    emailController.text = widget.customerModel.email ?? '';
    dueController.text = (widget.customerModel.due ?? 0).toString();
    addressController.text = widget.customerModel.address ?? '';
    groupValue = widget.customerModel.type ?? '';
    super.initState();
  }

  final GlobalKey<FormState> _formKay = GlobalKey();

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dueController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  final partyCreditLimitController = TextEditingController();
  final partyGstController = TextEditingController();
  final billingAddressController = TextEditingController();
  final billingCityController = TextEditingController();
  final billingStateController = TextEditingController();
  final billingCountryController = TextEditingController();
  final shippingAddressController = TextEditingController();
  final shippingCityController = TextEditingController();
  final shippingStateController = TextEditingController();
  final shippingCountryController = TextEditingController();
  final billingZipCodeCountryController = TextEditingController();
  final shippingZipCodeCountryController = TextEditingController();
  final openingBalanceController = TextEditingController();

  FocusNode focusNode = FocusNode();
  String? selectedBillingCountry;
  String? selectedDShippingCountry;
  String? selectedBalanceType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, cRef, __) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              lang.S.of(context).updateContact,
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
          ),
          body: Consumer(builder: (context, ref, __) {
            // ignore: unused_local_variable
            final customerData = ref.watch(partiesProvider);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Form(
                      key: _formKay,
                      child: Column(
                        children: [
                          ///_________Phone_______________________
                          TextFormField(
                            controller: phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // return 'Please enter a valid phone number';
                                return lang.S.of(context).pleaseEnterAValidPhoneNumber;
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).phone,
                              hintText: lang.S.of(context).enterYourPhoneNumber,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 20),

                          ///_________Name_______________________
                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                // return 'Please enter a valid Name';
                                return lang.S.of(context).pleaseEnterAValidName;
                              }
                              // You can add more validation logic as needed
                              return null;
                            },
                            decoration: InputDecoration(
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).name,
                              hintText: lang.S.of(context).enterYourName,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    ///_________opening balance_______________________
                    // TextFormField(
                    //   controller: openingBalanceController,
                    //   keyboardType: TextInputType.name,
                    //   decoration: InputDecoration(
                    //       labelText: lang.S.of(context).openingBalance,
                    //       hintText: lang.S.of(context).enterOpeningBalance,
                    //       suffixIcon: Padding(
                    //         padding: const EdgeInsets.all(1.0),
                    //         child: Container(
                    //           padding: EdgeInsets.symmetric(horizontal: 10),
                    //           decoration: BoxDecoration(
                    //               color: kBackgroundColor,
                    //               borderRadius: BorderRadius.only(
                    //                 topRight: Radius.circular(4),
                    //                 bottomRight: Radius.circular(4),
                    //               )),
                    //           child: DropdownButtonHideUnderline(
                    //             child: DropdownButton(
                    //                 icon: Icon(
                    //                   Icons.keyboard_arrow_down,
                    //                   color: kPeraColor,
                    //                 ),
                    //                 items: ['Advanced', 'Due'].map((entry) {
                    //                   return DropdownMenuItem(value: entry, child: Text(entry, style: theme.textTheme.bodyLarge?.copyWith(color: kTitleColor)));
                    //                 }).toList(),
                    //                 value: selectedBalanceType ?? 'Advanced',
                    //                 onChanged: (String? value) {
                    //                   setState(() {
                    //                     selectedBalanceType = value;
                    //                   });
                    //                 }),
                    //           ),
                    //         ),
                    //       )),
                    // ),
                    // SizedBox(height: 20),
                    RadioGroup<String>(
                      groupValue: groupValue,
                      onChanged: (value) {
                        if (value == null) return;
                        if (widget.customerModel.type == 'Supplier' && value != 'Supplier') return;
                        if (widget.customerModel.type != 'Supplier' && value == 'Supplier') return;
                        setState(() {
                          groupValue = value;
                        });
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return kMainColor;
                                      }
                                      return kPeraColor;
                                    },
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    lang.S.of(context).retailer,
                                    maxLines: 1,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  value: 'Retailer',
                                  activeColor: widget.customerModel.type == 'Supplier' ? Colors.grey : kMainColor,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return kMainColor;
                                      }
                                      return kPeraColor;
                                    },
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    lang.S.of(context).dealer,
                                    maxLines: 1,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  value: 'Dealer',
                                  activeColor: widget.customerModel.type == 'Supplier' ? Colors.grey : kMainColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return kMainColor;
                                      }
                                      return kPeraColor;
                                    },
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: kMainColor,
                                  title: Text(
                                    lang.S.of(context).wholesaler,
                                    maxLines: 1,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  value: 'Wholesaler',
                                ),
                              ),
                              Expanded(
                                child: RadioListTile(
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return kMainColor;
                                      }
                                      return kPeraColor;
                                    },
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  activeColor: kMainColor,
                                  title: Text(
                                    lang.S.of(context).supplier,
                                    maxLines: 1,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  value: 'Supplier',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: showProgress,
                      child: const CircularProgressIndicator(
                        color: kMainColor,
                        strokeWidth: 5.0,
                      ),
                    ),
                    ExpansionPanelList(
                      expandIconColor: Colors.red,
                      expansionCallback: (int index, bool isExpanded) {},
                      animationDuration: const Duration(seconds: 1),
                      elevation: 0,
                      dividerColor: Colors.white,
                      children: [
                        ExpansionPanel(
                          backgroundColor: kWhite,
                          headerBuilder: (BuildContext context, bool isExpanded) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  child: Text(
                                    lang.S.of(context).moreInfo,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: kMainColor,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      expanded == false ? expanded = true : expanded = false;
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                          body: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                          child: SizedBox(
                                            height: 200.0,
                                            width: MediaQuery.of(context).size.width - 80,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      pickedImage = await _picker.pickImage(source: ImageSource.gallery);
                                                      if (!context.mounted) return;
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(
                                                          Icons.photo_library_rounded,
                                                          size: 60.0,
                                                          color: kMainColor,
                                                        ),
                                                        Text(lang.S.of(context).gallery, style: theme.textTheme.titleLarge?.copyWith(color: kMainColor)),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 40.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      pickedImage = await _picker.pickImage(source: ImageSource.camera);
                                                      if (!context.mounted) return;
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(
                                                          Icons.camera,
                                                          size: 60.0,
                                                          color: kGreyTextColor,
                                                        ),
                                                        Text(
                                                          lang.S.of(context).camera,
                                                          style: theme.textTheme.titleLarge?.copyWith(
                                                            color: kGreyTextColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black54, width: 1),
                                        borderRadius: const BorderRadius.all(Radius.circular(120)),
                                        image: pickedImage == null
                                            ? widget.customerModel.image.isEmptyOrNull
                                                ? const DecorationImage(
                                                    image: AssetImage('images/no_shop_image.png'),
                                                    fit: BoxFit.cover,
                                                  )
                                                : DecorationImage(
                                                    image: _partyImageProvider(widget.customerModel.image),
                                                    fit: BoxFit.cover,
                                                  )
                                            : DecorationImage(
                                                image: FileImage(File(pickedImage!.path)),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white, width: 2),
                                          borderRadius: const BorderRadius.all(Radius.circular(120)),
                                          color: kMainColor,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: lang.S.of(context).email,
                                  hintText: lang.S.of(context).hintEmail,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                controller: addressController,
                                decoration: InputDecoration(
                                  labelText: lang.S.of(context).address,
                                  hintText: lang.S.of(context).enterFullAddress,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                readOnly: true,
                                controller: dueController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: lang.S.of(context).previousDue,
                                ),
                              ),
                              // TextFormField(
                              //   readOnly: true,
                              //   controller: dueController,
                              //   decoration: InputDecoration(
                              //     border: const OutlineInputBorder(),
                              //     floatingLabelBehavior:
                              //         FloatingLabelBehavior.always,
                              //     labelText: lang.S.of(context).previousDue,
                              //   ),
                              // ),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: TextFormField(
                              //         controller: partyCreditLimitController,
                              //         decoration: InputDecoration(
                              //             border: const OutlineInputBorder(),
                              //             floatingLabelBehavior: FloatingLabelBehavior.always,
                              //             labelText: 'Party Credit Limit',
                              //             //hintText: 'Enter your address'
                              //             hintText: 'Ex: 800'),
                              //       ),
                              //     ),
                              //     SizedBox(width: 20),
                              //     Expanded(
                              //       child: TextFormField(
                              //         controller: partyGstController,
                              //         decoration: InputDecoration(
                              //             border: const OutlineInputBorder(),
                              //             floatingLabelBehavior: FloatingLabelBehavior.always,
                              //             labelText: 'Party Gst',
                              //             //hintText: 'Enter your address'
                              //             hintText: 'Ex: 800'),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // SizedBox(height: 4),
                              // Theme(
                              //   data: Theme.of(context).copyWith(
                              //     dividerColor: Colors.transparent,
                              //   ),
                              //   child: ExpansionTile(
                              //     visualDensity: VisualDensity(vertical: -2, horizontal: -4),
                              //     tilePadding: EdgeInsets.zero,
                              //     trailing: SizedBox.shrink(),
                              //     title: Row(
                              //       crossAxisAlignment: CrossAxisAlignment.center,
                              //       children: [
                              //         Icon(FeatherIcons.minus, size: 20, color: Colors.red),
                              //         SizedBox(width: 8),
                              //         Text(
                              //           'Billing Address',
                              //           style: theme.textTheme.titleMedium?.copyWith(
                              //             color: kMainColor,
                              //           ),
                              //         )
                              //       ],
                              //     ),
                              //     children: [
                              //       SizedBox(height: 10),
                              //       //___________Billing Address________________
                              //       TextFormField(
                              //         controller: billingAddressController,
                              //         decoration: InputDecoration(
                              //           labelText: 'Address',
                              //           hintText: 'Enter Address',
                              //         ),
                              //       ),
                              //       SizedBox(height: 20),
                              //       //--------------billing city------------------------
                              //       TextFormField(
                              //         controller: billingCityController,
                              //         decoration: InputDecoration(
                              //           labelText: 'City',
                              //           hintText: 'Enter city',
                              //         ),
                              //       ),
                              //       SizedBox(height: 20),
                              //       //--------------billing state------------------------
                              //       TextFormField(
                              //         controller: billingStateController,
                              //         decoration: InputDecoration(
                              //           labelText: 'State',
                              //           hintText: 'Enter state',
                              //         ),
                              //       ),
                              //       SizedBox(height: 20),
                              //       Row(
                              //         children: [
                              //           //--------------billing zip code------------------------
                              //           Expanded(
                              //             child: TextFormField(
                              //               controller: billingZipCodeCountryController,
                              //               decoration: InputDecoration(
                              //                 labelText: 'Zip Code',
                              //                 hintText: 'Enter zip code',
                              //               ),
                              //             ),
                              //           ),
                              //           SizedBox(width: 20),
                              //           //--------------billing country------------------------
                              //           Expanded(
                              //             child: DropdownButtonFormField(
                              //                 isExpanded: true,
                              //                 hint: Text(
                              //                   'Select Country',
                              //                   maxLines: 1,
                              //                   style: theme.textTheme.bodyMedium?.copyWith(
                              //                     color: kPeraColor,
                              //                   ),
                              //                   overflow: TextOverflow.ellipsis,
                              //                 ),
                              //                 icon: Icon(Icons.keyboard_arrow_down, color: kPeraColor),
                              //                 items: ['Bangladesh', 'Pakisthan', 'Iran'].map((entry) {
                              //                   return DropdownMenuItem(
                              //                     value: entry,
                              //                     child: Text(
                              //                       entry,
                              //                       style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                              //                     ),
                              //                   );
                              //                 }).toList(),
                              //                 value: selectedDShippingCountry,
                              //                 onChanged: (String? value) {
                              //                   setState(() {
                              //                     selectedBillingCountry = value;
                              //                   });
                              //                 }),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // Theme(
                              //   data: Theme.of(context).copyWith(
                              //     dividerColor: Colors.transparent,
                              //   ),
                              //   child: ExpansionTile(
                              //     tilePadding: EdgeInsets.zero,
                              //     visualDensity: VisualDensity(horizontal: -4, vertical: -2),
                              //     trailing: SizedBox.shrink(),
                              //     title: Row(
                              //       crossAxisAlignment: CrossAxisAlignment.center,
                              //       children: [
                              //         Icon(FeatherIcons.plus, size: 20),
                              //         SizedBox(width: 8),
                              //         Text(
                              //           'Shipping Address',
                              //           style: theme.textTheme.titleMedium,
                              //         )
                              //       ],
                              //     ),
                              //     children: [
                              //       SizedBox(height: 10),
                              //       //___________Billing Address________________
                              //       TextFormField(
                              //         controller: billingAddressController,
                              //         decoration: InputDecoration(
                              //           labelText: 'Address',
                              //           hintText: 'Enter Address',
                              //         ),
                              //       ),
                              //       SizedBox(height: 20),
                              //       //--------------billing city------------------------
                              //       TextFormField(
                              //         controller: billingCityController,
                              //         decoration: InputDecoration(
                              //           labelText: 'City',
                              //           hintText: 'Enter city',
                              //         ),
                              //       ),
                              //       SizedBox(height: 20),
                              //       //--------------billing state------------------------
                              //       TextFormField(
                              //         controller: billingStateController,
                              //         decoration: InputDecoration(
                              //           labelText: 'State',
                              //           hintText: 'Enter state',
                              //         ),
                              //       ),
                              //       SizedBox(height: 20),
                              //       Row(
                              //         children: [
                              //           //--------------billing zip code------------------------
                              //           Expanded(
                              //             child: TextFormField(
                              //               controller: billingZipCodeCountryController,
                              //               decoration: InputDecoration(
                              //                 labelText: 'Zip Code',
                              //                 hintText: 'Enter zip code',
                              //               ),
                              //             ),
                              //           ),
                              //           SizedBox(width: 20),
                              //           //--------------billing country------------------------
                              //           Expanded(
                              //             child: DropdownButtonFormField(
                              //                 isExpanded: true,
                              //                 hint: Text(
                              //                   'Select Country',
                              //                   maxLines: 1,
                              //                   style: theme.textTheme.bodyMedium?.copyWith(
                              //                     color: kPeraColor,
                              //                   ),
                              //                   overflow: TextOverflow.ellipsis,
                              //                 ),
                              //                 icon: Icon(Icons.keyboard_arrow_down, color: kPeraColor),
                              //                 items: ['Bangladesh', 'Pakisthan', 'Iran'].map((entry) {
                              //                   return DropdownMenuItem(
                              //                     value: entry,
                              //                     child: Text(
                              //                       entry,
                              //                       style: theme.textTheme.bodyMedium?.copyWith(color: kPeraColor),
                              //                     ),
                              //                   );
                              //                 }).toList(),
                              //                 value: selectedDShippingCountry,
                              //                 onChanged: (String? value) {
                              //                   setState(() {
                              //                     selectedBillingCountry = value;
                              //                   });
                              //                 }),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // )
                            ],
                          ),
                          isExpanded: expanded,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () async {
                          if (_formKay.currentState!.validate()) {
                            try {
                              EasyLoading.show(
                                status: lang.S.of(context).updating,
                                // 'Updating...'
                              );
                              final party = PartyRepository();
                              await party.updateParty(
                                id: widget.customerModel.id.toString(),
                                // Assuming id is a property in customerModel
                                ref: ref,
                                context: context,
                                name: nameController.text,
                                phone: phoneController.text,
                                type: groupValue,
                                image: pickedImage != null ? File(pickedImage!.path) : null,
                                email: emailController.text,
                                address: addressController.text,
                                due: dueController.text,
                              );
                              EasyLoading.dismiss();
                            } catch (e) {
                              EasyLoading.dismiss();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                        child: Text(lang.S.of(context).update)),
                  ],
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

ImageProvider _partyImageProvider(String? imagePath) {
  final path = imagePath?.toString() ?? '';
  final isLocal = path.startsWith('/') || path.startsWith('file:');
  if (isLocal) {
    final filePath = path.startsWith('file:') ? path.replaceFirst('file://', '') : path;
    if (!File(filePath).existsSync()) {
      return const AssetImage('images/no_shop_image.png');
    }
    return FileImage(File(filePath));
  }
  return NetworkImage('${APIConfig.domain}${imagePath ?? ''}');
}
