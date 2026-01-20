// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../GlobalComponents/glonal_popup.dart';
import '../product_brand/model/brands_model.dart';
import 'brand repo/brand_repo.dart';

class AddBrands extends StatefulWidget {
  const AddBrands({super.key, this.brand});

  final Brand? brand;

  @override  State<AddBrands> createState() => _AddBrandsState();
}

class _AddBrandsState extends State<AddBrands> {
  bool showProgress = false;
  TextEditingController brandController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.brand != null ? brandController.text = widget.brand?.brandName ?? '' : null;
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      return GlobalPopup(
        child: Scaffold(
          backgroundColor: kWhite,
          appBar: AppBar(
            title: Text(
              lang.S.of(context).addBrand,
            ),
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Visibility(
                    visible: showProgress,
                    child: const CircularProgressIndicator(
                      color: kMainColor,
                      strokeWidth: 5.0,
                    ),
                  ),
                  Form(
                    key: _key,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          // return 'Please enter a valid brand name';
                          return lang.S.of(context).pleaseEnterAValidBrandName;
                        }
                        return null;
                      },
                      controller: brandController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        // hintText: 'Enter a brand name',
                        hintText: lang.S.of(context).enterABrandName,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: lang.S.of(context).brandName,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      maximumSize: const Size(double.infinity, 48),
                      minimumSize: const Size(double.infinity, 48),
                      disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                    ),
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        BrandsRepo brandRepo = BrandsRepo();
                        widget.brand == null
                            ? await brandRepo.addBrand(ref: ref, context: context, name: brandController.text)
                            : await brandRepo.editBrand(ref: ref, id: widget.brand?.id ?? 0, context: context, name: brandController.text);
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
        ),
      );
    });
  }
}