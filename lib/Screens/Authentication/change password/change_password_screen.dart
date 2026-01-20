import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mobile_pos/Screens/Authentication/change%20password/repo/change_pass_repo.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../../GlobalComponents/glonal_popup.dart';
import '../../../constant.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isClicked = false;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool showOldPassword = true;
  bool showPassword = true;
  bool showConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: kWhite,
          backgroundColor: kWhite,
          centerTitle: true,
          titleSpacing: 16,
          title: Text(
            lang.S.of(context).changePassword,
            //'Create New Password',
            style: textTheme.titleMedium?.copyWith(fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 0.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   lang.S.of(context).setUpNewPassword,
                  //   // 'Set Up New Password',
                  //   style: textTheme.titleMedium?.copyWith(fontSize: 24.0),
                  // ),
                  // const SizedBox(height: 8.0),
                  // Text(
                  //   lang.S.of(context).resetPassword,
                  //   //'Reset your password to recovery and log in your account',
                  //   style: textTheme.bodyMedium?.copyWith(color: kGreyTextColor, fontSize: 16), textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 24.0),
                  TextFormField(
                    controller: _oldPasswordController,
                    keyboardType: TextInputType.text,
                    obscureText: showOldPassword,
                    decoration: kInputDecoration.copyWith(
                      // border: const OutlineInputBorder(),
                      hintText: '********',
                      labelText: 'Old Password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showOldPassword = !showOldPassword;
                          });
                        },
                        icon: Icon(
                          showOldPassword ? FeatherIcons.eyeOff : FeatherIcons.eye,
                          color: kGreyTextColor,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Old Password can\'t be empty';
                      } else if (value.length < 6) {
                        //return 'Please enter a bigger password';
                        return lang.S.of(context).pleaseEnterABiggerPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _newPasswordController,
                    keyboardType: TextInputType.text,
                    obscureText: showPassword,
                    decoration: kInputDecoration.copyWith(
                      // border: const OutlineInputBorder(),
                      hintText: '********',
                      //labelText: 'New Password',
                      labelText: lang.S.of(context).newPassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        icon: Icon(
                          showPassword ? FeatherIcons.eyeOff : FeatherIcons.eye,
                          color: kGreyTextColor,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        //return 'Password can\'t be empty';
                        return lang.S.of(context).passwordCannotBeEmpty;
                      } else if (value.length < 6) {
                        //return 'Please enter a bigger password';
                        return lang.S.of(context).pleaseEnterABiggerPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    controller: _confirmPasswordController,
                    keyboardType: TextInputType.text,
                    obscureText: showConfirmPassword,
                    decoration: kInputDecoration.copyWith(
                      border: const OutlineInputBorder(),
                      //labelText: 'Confirm Password',
                      labelText: lang.S.of(context).confirmPassword,
                      hintText: '********',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            showConfirmPassword = !showConfirmPassword;
                          });
                        },
                        icon: Icon(
                          showConfirmPassword ? FeatherIcons.eyeOff : FeatherIcons.eye,
                          color: kGreyTextColor,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        //return 'Password can\'t be empty';
                        return lang.S.of(context).passwordCannotBeEmpty;
                      } else if (value != _newPasswordController.text) {
                        //return 'Passwords do not match';
                        return lang.S.of(context).passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () async {
                      if (isClicked) {
                        return;
                      }
                      if (_formKey.currentState?.validate() ?? false) {
                        isClicked = true;
                        EasyLoading.show();
                        ChangePassRepo repo = ChangePassRepo();
                        if (await repo.changePass(oldPass: _oldPasswordController.text, newPass: _confirmPasswordController.text, context: context)) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        } else {
                          isClicked = false;
                        }
                      }
                    },
                    child: Text(lang.S.of(context).save),
                    //'Save',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
