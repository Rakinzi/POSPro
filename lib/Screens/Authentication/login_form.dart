import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Screens/Authentication/register_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../constant.dart';
import 'forgot_password.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.isEmailLogin}) ;

  final bool isEmailLogin;

  @override  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool showPassword = true;
  late String email, password;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Consumer(builder: (context, ref, child) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/logoandname.png'),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Form(
                      key: globalKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).emailText,
                              hintText: lang.S.of(context).enterYourEmailAddress,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                //return 'Email can\'n be empty';
                                return lang.S.of(context).emailCannotBeEmpty;
                              } else if (!value.contains('@')) {
                                //return 'Please enter a valid email';
                                return lang.S.of(context).pleaseEnterAValidEmail;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // loginProvider.email = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            obscureText: showPassword,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: lang.S.of(context).password,
                              hintText: lang.S.of(context).pleaseEnterAPassword,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                //return 'Password can\'t be empty';
                                return lang.S.of(context).passwordCannotBeEmpty;
                              } else if (value.length < 4) {
                                //return 'Please enter a bigger password';
                                return lang.S.of(context).pleaseEnterABiggerPassword;
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // loginProvider.password = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: widget.isEmailLogin,
                    child: Row(
                      children: [
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()));
                            // const ForgotPassword().launch(context);
                          },
                          child: Text(
                            lang.S.of(context).forgotPassword,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: kGreyTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    child: Text(lang.S.of(context).logIn),
                    onPressed: () {
                      if (validateAndSave()) {
                        // loginProvider.signIn(context);
                      }
                    },
                  ),
                  Visibility(
                    visible: widget.isEmailLogin,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang.S.of(context).noAcc,
                          style: theme.textTheme.bodyLarge?.copyWith(color: kGreyTextColor),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigator.pushNamed(context, '/signup');
                            // const RegisterScreen().launch(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                          },
                          child: Text(
                            lang.S.of(context).register,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: kMainColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}