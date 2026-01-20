import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../constant.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key}) ;

  @override  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool showProgress = false;
  late String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  lang.S.of(context).forgotPassword,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    lang.S.of(context).enterEmail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: kGreyTextColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: lang.S.of(context).email,
                        border: const OutlineInputBorder(),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'example@example.com'),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {},
                    // onPressed: () async {
                    //   setState(() {
                    //     showProgress = true;
                    //   });
                    //   try {
                    //     await FirebaseAuth.instance.sendPasswordResetEmail(
                    //       email: email,
                    //     );
                    //     // ScaffoldMessenger.of(context).showSnackBar(
                    //     //   const SnackBar(
                    //     //     content: Text('Check your Inbox'),
                    //     //     duration: Duration(seconds: 3),
                    //     //   ),
                    //     // );
                    //     if (!mounted) return;
                    //     const LoginForm(
                    //       isEmailLogin: true,
                    //     ).launch(context);
                    //   } on FirebaseAuthException catch (e) {
                    //     if (e.code == 'user-not-found') {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text('No user found for that email.'),
                    //           duration: Duration(seconds: 3),
                    //         ),
                    //       );
                    //     } else if (e.code == 'wrong-password') {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text('Wrong password provided for that user.'),
                    //           duration: Duration(seconds: 3),
                    //         ),
                    //       );
                    //     }
                    //   } catch (e) {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //         content: Text(e.toString()),
                    //         duration: const Duration(seconds: 3),
                    //       ),
                    //     );
                    //   }
                    //   setState(
                    //     () {
                    //       showProgress = false;
                    //     },
                    //   );
                    // },
                    child: Text(lang.S.of(context).sendLink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}