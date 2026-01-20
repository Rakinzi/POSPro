import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/product_model/provider/models_provider.dart';
import 'package:mobile_pos/Screens/product_model/repo/product_models_repo.dart';

import '../../constant.dart';
import 'model/product_models_model.dart';

class AddProductModel extends ConsumerStatefulWidget {
  const AddProductModel({super.key, this.editData});

  final Data? editData;

  bool get isEditMode => editData != null;

  @override
  ConsumerState<AddProductModel> createState() => _AddProductModelState();
}

class _AddProductModelState extends ConsumerState<AddProductModel> {
  late final TextEditingController nameController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditMode) {
        setState(() {
          nameController.text = widget.editData?.name ?? '';
          isActive = widget.editData?.status == 1;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.isEditMode ? 'Edit Model' : 'Add New Model'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Model Name Input
              TextFormField(
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Model Name',
                  hintText: 'Enter a Model Name',
                ),
              ),
              const SizedBox(height: 8),

              // Status Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Status'),
                  SizedBox(
                    height: 32,
                    width: 44,
                    child: FittedBox(
                      child: Switch.adaptive(
                        value: isActive,
                        onChanged: (value) => setState(() => isActive = value),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  disabledBackgroundColor: theme.colorScheme.primary.withAlpha(40),
                ),
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    final repo = ProductModelsRepo();
                    final data = CreateModelsModel(
                      name: nameController.text,
                      status: isActive ? '1' : '0',
                      modelId: widget.editData?.id.toString(),
                    );

                    bool success = widget.isEditMode ? await repo.updateModels(data: data) : await repo.createModels(data: data);

                    if (success) {
                      EasyLoading.showSuccess(
                        widget.isEditMode ? 'Model Updated Successfully!' : 'Model Created Successfully!',
                      );
                      ref.invalidate(fetchModelListProvider);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(
                  'Save',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateModelsModel {
  CreateModelsModel({
    this.modelId,
    this.name,
    this.status,
  });
  String? modelId;
  String? name;
  String? status;
}
