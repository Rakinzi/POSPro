import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/constant.dart';

import '../Authentication/Repo/logout_repo.dart';
import 'account detele/repo/delete_account_repo.dart';

void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isChecked = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Delete Account"),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Are you sure you want to delete your account? This action will permanently erase all your data.",
                    style: TextStyle(color: kMainColor),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Enter your password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  CheckboxListTile(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.all(0),
                    title: Text("I agree to delete my account permanently."),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                onPressed: isChecked
                    ? () async {
                        if (formKey.currentState!.validate()) {
                          final bool isDeleted = await DeleteAccountRepository()
                              .deleteAccount(businessId: ref.watch(businessInfoProvider).value?.id.toString() ?? '', password: passwordController.text);

                          if (isDeleted) {
                            await LogOutRepo().signOut();
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kMainColor,
                  foregroundColor: Colors.white,
                ),
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    },
  );
}
