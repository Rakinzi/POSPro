// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: unused_result

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import 'Repo/parties_repo.dart';

class AddParty extends StatefulWidget {
  const AddParty({super.key});

  @override  State<AddParty> createState() => _AddPartyState();
}

class _AddPartyState extends State<AddParty> {
  String groupValue = 'Retailer';
  bool expanded = false;
  final ImagePicker _picker = ImagePicker();
  bool showProgress = false;
  XFile? pickedImage;
  String? phoneNumber;

  // TextEditingController phoneController = TextEditingController();
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

  final GlobalKey<FormState> _formKay = GlobalKey();
  FocusNode focusNode = FocusNode();
  String? selectedBillingCountry;
  String? selectedDShippingCountry;
  String? selectedBalanceType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: kWhite,
            backgroundColor: Colors.white,
            title: Text(
              'Add Parties',
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            elevation: 0.0,
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(
                  height: 1,
                  thickness: 1,
                )),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Form(
                  key: _formKay,
                  child: Column(
                    children: [
                      ///_________Phone_______________________
                      IntlPhoneField(
                        // controller: phoneController,
                        dropdownIcon: Icon(Icons.keyboard_arrow_down),
                        decoration: InputDecoration(
                          labelText: lang.S.of(context).phoneNumber,
                          hintText: lang.S.of(context).phoneNumber,
                          counterText: '',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                        initialCountryCode: 'BD',
                        onChanged: (phone) {
                          phoneNumber = phone.completeNumber;
                        },
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
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelText: lang.S.of(context).name,
                          hintText: lang.S.of(context).enterYourName,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      // SizedBox(height: 20),
                      //
                      // ///_________opening balance_______________________
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
                    ],
                  ),
                ),
                SizedBox(height: 20),

                ///_______Type___________________________
                RadioGroup<String>(
                  groupValue: groupValue,
                  onChanged: (value) {
                    if (value == null) return;
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
                                'Customer',
                                maxLines: 1,
                                style: theme.textTheme.bodyMedium,
                              ),
                              value: 'Retailer',
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
                                style: theme.textTheme.bodyMedium,
                              ),
                              value: 'Dealer',
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
                                style: theme.textTheme.bodyMedium,
                              ),
                              value: 'Wholesaler',
                            ),
                          ),
                          Expanded(
                            child: RadioListTile(
                              contentPadding: EdgeInsets.zero,
                              activeColor: kMainColor,
                              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                              fillColor: WidgetStateProperty.resolveWith(
                                (states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return kMainColor;
                                  }
                                  return kPeraColor;
                                },
                              ),
                              title: Text(
                                lang.S.of(context).supplier,
                                maxLines: 1,
                                style: theme.textTheme.bodyMedium,
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
                  expandedHeaderPadding: EdgeInsets.zero,
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      expanded == false ? expanded = true : expanded = false;
                    });
                  },
                  animationDuration: const Duration(milliseconds: 500),
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
                                style: theme.textTheme.titleSmall?.copyWith(color: Colors.red),
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
                                      backgroundColor: kWhite,
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
                                                  Future.delayed(const Duration(milliseconds: 100), () {
                                                    if (!context.mounted) return;
                                                    Navigator.pop(context);
                                                  });
                                                },
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.photo_library_rounded,
                                                      size: 60.0,
                                                      color: kMainColor,
                                                    ),
                                                    Text(
                                                      lang.S.of(context).gallery,
                                                      //'Gallery',
                                                      style: theme.textTheme.titleMedium?.copyWith(
                                                        color: kMainColor,
                                                      ),
                                                    ),
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
                                                  Future.delayed(const Duration(milliseconds: 100), () {
                                                    if (!context.mounted) return;
                                                    Navigator.pop(context);
                                                  });
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
                                                      //'Camera',
                                                      style: theme.textTheme.titleMedium?.copyWith(
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
                                    shape: BoxShape.circle,
                                    image: pickedImage == null
                                        ? const DecorationImage(
                                            image: AssetImage('images/no_shop_image.png'),
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

                          ///__________email__________________________
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).email,
                                //hintText: 'Enter your email address',
                                hintText: lang.S.of(context).hintEmail),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                labelText: lang.S.of(context).address,
                                //hintText: 'Enter your address'
                                hintText: lang.S.of(context).hintEmail),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: dueController,
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelText: lang.S.of(context).previousDue,
                              hintText: lang.S.of(context).amount,
                            ),
                          ),
                          SizedBox(height: 16),
                          // TextFormField(
                          //   controller: dueController,
                          //   inputFormatters: [
                          //     FilteringTextInputFormatter.allow(
                          //         RegExp(r'^\d*\.?\d{0,2}'))
                          //   ],
                          //   keyboardType: TextInputType.number,
                          //   decoration: InputDecoration(
                          //       border: const OutlineInputBorder(),
                          //       floatingLabelBehavior:
                          //           FloatingLabelBehavior.always,
                          //       labelText: lang.S.of(context).previousDue,
                          //       hintText: lang.S.of(context).amount),
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
                      if (!nameController.text.isEmptyOrNull && !phoneNumber.isEmptyOrNull) {
                        final partyRepo = PartyRepository();
                        await partyRepo.addParty(
                          ref: ref,
                          context: context,
                          name: nameController.text,
                          phone: phoneNumber ?? '',
                          type: groupValue,
                          image: pickedImage != null ? File(pickedImage!.path) : null,
                          address: addressController.text.isEmptyOrNull ? null : addressController.text,
                          email: emailController.text.isEmptyOrNull ? null : emailController.text,
                          due: dueController.text.isEmptyOrNull ? null : dueController.text,
                        );
                      } else {
                        EasyLoading.showError(lang.S.of(context).pleaseEnterValidPhoneAndNameFirst
                            //'Please Enter valid phone and name first'
                            );
                      }
                    },
                    child: Text(lang.S.of(context).save)),
              ],
            ),
          ),
        ),
      );
    });
  }
}