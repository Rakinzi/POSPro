import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constant.dart';
import '../../generated/l10n.dart' as lang;
import 'model/payment_type_model.dart';
import 'repo/payment_type_repo.dart';

class ManagePaymentTypeView extends ConsumerStatefulWidget {
  const ManagePaymentTypeView({super.key, this.editModel});

  final PaymentTypeModel? editModel;

  bool get isEditMode => editModel != null;

  @override
  ConsumerState<ManagePaymentTypeView> createState() => _ManagePaymentTypeViewState();
}

class _ManagePaymentTypeViewState extends ConsumerState<ManagePaymentTypeView> {
  late final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isActive = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditMode) {
        setState(() {
          nameController.text = widget.editModel?.name ?? '';
          isActive = widget.editModel?.status == 1;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEditMode ? 'Edit Payment Type' : 'Add New Payment Type',
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Payment Type Name
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelText: 'Payment Type',
                  hintText: 'Enter a payment type name',
                ),
              ),
              const SizedBox.square(dimension: 8),
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
                  disabledBackgroundColor: _theme.colorScheme.primary.withValues(
                    alpha: 0.15,
                  ),
                ),
                onPressed: () async {
                  if (formKey.currentState?.validate() == true) {
                    PaymentTypeRepo paymentTypeRepo = PaymentTypeRepo();
                    final _data = (widget.editModel ?? PaymentTypeModel()).copyWith(
                      name: nameController.text,
                      status: isActive ? 1 : 0,
                    );

                    return await paymentTypeRepo.managePaymentType(
                      ref: ref,
                      context: context,
                      data: _data,
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
            ],
          ),
        ),
      ),
    );
  }
}
