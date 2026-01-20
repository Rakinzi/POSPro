import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Repository/check_addon_providers.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../Provider/profile_provider.dart';
import '../../../Repository/API/business_info_update_repo.dart';
import '../../../constant.dart';

class PrintingInvoiceScreen extends ConsumerStatefulWidget {
  const PrintingInvoiceScreen({super.key});

  @override
  ConsumerState<PrintingInvoiceScreen> createState() => _PrintingInvoiceScreenState();
}

class _PrintingInvoiceScreenState extends ConsumerState<PrintingInvoiceScreen> {
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final noteLevelController = TextEditingController();
  final noteController = TextEditingController();
  final gratitudeController = TextEditingController();
  Map<String, String> invoiceSizeOptions = {
    '3_inch_80mm': '3 inch 80mm',
    '2_inch_58mm': '2 inch 58mm',
  };
  @override
  void initState() {
    super.initState();
    printing = isPrintEnable;
    ref.read(businessInfoProvider).when(
          data: (data) {
            nameController.text = data.companyName ?? '';
            phoneController.text = data.phoneNumber ?? '';
            addressController.text = data.address ?? '';
            noteLevelController.text = data.invoiceNoteLevel ?? '';
            noteController.text = data.invoiceNote ?? '';
            gratitudeController.text = data.postSaleMassage ?? '';
            selectedThermalPrinter = data.invoiceSize;
          },
          error: (error, stackTrace) {},
          loading: () {},
        );
  }

  bool printing = false;

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  File imageFile = File('No File');

  final GlobalKey<FormState> _formKey = GlobalKey();

  String? selectedThermalPrinter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _lang = lang.S.of(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            _lang.printingInvoice,
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            spacing: 10,
            children: [
              Row(
                children: [
                  Text(
                    _lang.invoiceLogo,
                    style: theme.textTheme.bodyLarge?.copyWith(),
                  ),
                ],
              ),

              ///__________Image_section________________________________________
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
                                      if (pickedImage == null) return;
                                      setState(() {
                                        imageFile = File(pickedImage!.path);
                                      });
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
                                        Text(
                                          lang.S.of(context).gallery,
                                          // 'Gallery',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: kGreyTextColor,
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
                                      if (pickedImage == null) return;
                                      setState(() {
                                        imageFile = File(pickedImage!.path);
                                      });
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
                                          // 'Camera',
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
                        border: Border.all(color: Colors.black54, width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(120)),
                        image: pickedImage == null
                            ? ref.watch(businessInfoProvider).value?.invoiceLogo == null
                                ? const DecorationImage(
                                    image: AssetImage(logo),
                                    fit: BoxFit.cover,
                                  )
                                : DecorationImage(
                                    image: NetworkImage(APIConfig.domain + ref.watch(businessInfoProvider).value!.invoiceLogo.toString()),
                                    fit: BoxFit.cover,
                                  )
                            : DecorationImage(
                                image: FileImage(imageFile),
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
              const SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  spacing: 25,
                  children: [
                    AppTextField(
                      controller: nameController, // Optional
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          //return 'Please enter a valid business name';
                          return lang.S.of(context).pleaseEnterAValidBusinessName;
                        }
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).businessName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    AppTextField(
                      controller: phoneController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.PHONE,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).phone,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    AppTextField(
                      controller: addressController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: lang.S.of(context).address,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    AppTextField(
                      controller: noteLevelController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: 'Note Level',
                        hintText: 'Enter Your Note Level',
                      ),
                    ),
                    AppTextField(
                      controller: noteController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: 'Note',
                        hintText: 'Enter your Note',
                      ),
                    ),
                    AppTextField(
                      controller: gratitudeController,
                      validator: (value) {
                        return null;
                      },
                      textFieldType: TextFieldType.NAME,
                      decoration: kInputDecoration.copyWith(
                        labelText: 'Post Sale Message',
                        hintText: 'Enter your Post Sale Message',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_lang.printingOption, style: theme.textTheme.titleMedium),
                  SizedBox(
                    width: 44,
                    height: 22,
                    child: Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        activeTrackColor: kMainColor,
                        value: printing,
                        onChanged: (bool value) async {
                          setState(() => printing = value);
                        },
                      ),
                    ),
                  )
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity(vertical: -4, horizontal: -4),
                title: Text(
                  'Thermal Printer Page Size',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: ref.watch(invoice80mmAddonCheckProvider).when(
                      data: (data) {
                        if (!data) {
                          invoiceSizeOptions = {
                            '2_inch_58mm': '2 inch 58mm',
                          };
                        }
                        return SizedBox(
                          width: 105,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(

                                // isDense: true,
                                isExpanded: true,
                                padding: EdgeInsets.zero,
                                items: invoiceSizeOptions.entries.map((entry) {
                                  return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(
                                        entry.value,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ));
                                }).toList(),
                                value: selectedThermalPrinter ?? '2_inch_58mm',
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedThermalPrinter = value;
                                  });
                                }),
                          ),
                        );
                      },
                      error: (error, stackTrace) => Text(error.toString()),
                      loading: () => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 105,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton.icon(
            icon: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
            label: Text(lang.S.of(context).continueButton),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final businessRepository = BusinessUpdateRepository();
                final isProfileUpdated = await businessRepository.updateProfile(
                  id: ref.watch(businessInfoProvider).value?.id.toString() ?? '',
                  name: nameController.text,
                  categoryId: ref.watch(businessInfoProvider).value?.category?.id.toString() ?? '',
                  address: addressController.text,
                  invoiceLogo: pickedImage != null ? File(pickedImage!.path) : null,
                  phone: phoneController.text,
                  invoiceNoteLevel: noteLevelController.text,
                  invoiceNote: noteController.text,
                  gratitudeMessage: gratitudeController.text,
                  ref: ref,
                  invoiceSize: selectedThermalPrinter,
                  context: context,
                  fromInvoiceLogo: true,
                );
                if (!context.mounted) return;
                if (isProfileUpdated) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isPrintEnable', printing);
                  if (!context.mounted) return;
                  isPrintEnable = printing;
                  ref.invalidate(businessInfoProvider);
                  ref.invalidate(businessSettingProvider);
                  Navigator.pop(context);
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
