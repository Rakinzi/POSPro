import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_model/warehouse_list_model.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
import 'package:mobile_pos/Screens/warehouse/warehouse_repo/warehouse_repo.dart';
import 'package:mobile_pos/constant.dart';

class AddNewWarehouse extends ConsumerStatefulWidget {
  const AddNewWarehouse({super.key, this.editData});
  final Data? editData;

  @override
  ConsumerState<AddNewWarehouse> createState() => _AddNewWarehouseState();
}

class _AddNewWarehouseState extends ConsumerState<AddNewWarehouse> {
  final warehouseNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  String? selectedValue;
  GlobalKey<FormState> key = GlobalKey();

  @override
  void dispose() {
    warehouseNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.editData != null) {
      warehouseNameController.text = widget.editData?.name.toString() ?? '';
      emailController.text = widget.editData?.email?.toString() ?? '';
      phoneNumberController.text = widget.editData?.phone ?? '';
      addressController.text = widget.editData?.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.editData != null ? 'Edit Warehouse' : 'Add New Warehouse',
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 2,
            color: kBackgroundColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: warehouseNameController,
                decoration: InputDecoration(
                  labelText: 'Warehouse Name',
                  hintText: 'Enter warehouse name',
                ),
                validator: (value) => value!.isEmpty ? 'Enter warehouse name' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: phoneNumberController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter phone number',
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email address (optional)',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null; // Valid (either empty or valid email)
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your address',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if ((key.currentState?.validate() ?? false)) {
                    WarehouseRepo warehouse = WarehouseRepo();
                    bool success;
                    CreateWareHouseModel data = CreateWareHouseModel(
                        address: addressController.text,
                        email: emailController.text,
                        name: warehouseNameController.text,
                        phone: phoneNumberController.text,
                        warehouseId: widget.editData?.id.toString());
                    if (widget.editData != null) {
                      debugPrint('update');
                      success = await warehouse.updateWareHouse(data: data);
                    } else {
                      debugPrint('create');
                      success = await warehouse.createWareHouse(data: data);
                    }
                    if (!context.mounted) return;
                    if (success) {
                      EasyLoading.showSuccess(widget.editData != null ? 'Warehouse Updated Successfully!' : 'Warehouse created successfully!');
                      ref.invalidate(fetchWarehouseListProvider);
                      Navigator.pop(context);
                    } else {
                      EasyLoading.showError('Please Try Again!');
                    }
                  }
                },
                child: Text(widget.editData != null ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateWareHouseModel {
  CreateWareHouseModel({
    this.warehouseId,
    this.name,
    this.phone,
    this.email,
    this.address,
  });
  String? warehouseId;
  String? name;
  String? phone;
  String? email;
  String? address;
}
