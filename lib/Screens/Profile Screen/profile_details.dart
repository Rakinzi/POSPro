import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/edit_profile.dart';
import 'package:mobile_pos/currency.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../Authentication/change password/change_password_screen.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key});

  @override
  ProfileDetailsState createState() => ProfileDetailsState();
}

class ProfileDetailsState extends State<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      return businessInfo.when(data: (details) {
        TextEditingController addressController = TextEditingController(text: details.address);
        TextEditingController openingBalanceController = TextEditingController(text: details.shopOpeningBalance.toString());
        TextEditingController phoneController = TextEditingController(text: details.phoneNumber);
        TextEditingController nameController = TextEditingController(text: details.companyName);
        TextEditingController categoryController = TextEditingController(text: details.category?.name);
        TextEditingController vatGstTitleController = TextEditingController(text: details.vatName);
        TextEditingController vatGstNumberController = TextEditingController(text: details.vatNumber);
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            appBar: AppBar(
              title: Text(
                lang.S.of(context).profile,
              ),
              actions: [
                Visibility(
                  visible: details.user?.visibility?.profileEditPermission ?? true,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                profile: details,
                                ref: ref,
                              ),
                            ));
                        if (!mounted) return;
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.edit,
                            color: kMainColor,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            lang.S.of(context).edit,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: kMainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              iconTheme: const IconThemeData(color: Colors.black),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                label: Text(lang.S.of(context).changePassword),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(),
                      ));
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 100.0,
                        width: 100.0,
                        decoration: details.pictureUrl == null
                            ? BoxDecoration(
                                image: const DecorationImage(image: AssetImage('images/no_shop_image.png'), fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(50),
                              )
                            : BoxDecoration(
                                image: DecorationImage(image: NetworkImage(APIConfig.domain + details.pictureUrl.toString()), fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(50),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10.0),

                    ///________Name___________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: nameController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).name,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///________Email__________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        initialValue: details.user?.email,
                        cursorColor: kGreyTextColor,
                        decoration: kInputDecoration.copyWith(
                          //labelText: "Email",
                          labelText: lang.S.of(context).email,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///_____________Category__________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: categoryController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).businessCat,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///_____________Phone_________________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: phoneController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).phone,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///__________Address_________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: addressController,
                        decoration: kInputDecoration.copyWith(
                          labelText: lang.S.of(context).address,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    ///_______Gst_number____________________________
                    Row(
                      children: [
                        ///_______title__________________________________
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
                            child: AppTextField(
                              readOnly: true,
                              validator: (value) {
                                return null;
                              },
                              controller: vatGstTitleController,
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: "VAT/GST Title",
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),

                        ///______Vat_and_Gst_Number__________________________________
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: AppTextField(
                              readOnly: true,
                              validator: (value) {
                                return null;
                              },
                              controller: vatGstNumberController,
                              // Optional
                              textFieldType: TextFieldType.NAME,
                              decoration: kInputDecoration.copyWith(
                                labelText: 'VAT/GST Number',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    ///__________Opening_Balance________________________
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: AppTextField(
                        readOnly: true,
                        cursorColor: kGreyTextColor,
                        controller: openingBalanceController,
                        decoration: kInputDecoration.copyWith(
                          prefixText: '$currency ',
                          labelText: lang.S.of(context).shopOpeningBalance,
                          border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                          hoverColor: kGreyTextColor,
                          fillColor: kGreyTextColor,
                        ),
                        textFieldType: TextFieldType.NAME,
                      ),
                    ),

                    // ///__________Remaining_Balance________________________
                    // Padding(
                    //   padding: const EdgeInsets.all(10.0),
                    //   child: AppTextField(
                    //     readOnly: true,
                    //     cursorColor: kGreyTextColor,
                    //     controller: remainingBalanceController,
                    //     decoration: kInputDecoration.copyWith(
                    //       prefixText: '$currency ',
                    //       labelText: lang.S.of(context).shopRemainingBalance,
                    //       border: const OutlineInputBorder().copyWith(borderSide: const BorderSide(color: kGreyTextColor)),
                    //       hoverColor: kGreyTextColor,
                    //       fillColor: kGreyTextColor,
                    //     ),
                    //     textFieldType: TextFieldType.NAME,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return const CircularProgressIndicator();
      });
    });
  }
}
