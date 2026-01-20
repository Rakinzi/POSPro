import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class CheckEMail extends StatefulWidget {
  const CheckEMail({super.key});

  @override  State<CheckEMail> createState() => _CheckEMailState();
}

class _CheckEMailState extends State<CheckEMail> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 100.0,
                      width: 100.0,
                      child: Image(
                        image: AssetImage('images/mailbox.png'),
                      ),
                    ),
                    Text(
                      lang.S.of(context).gotEmail,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        lang.S.of(context).sendEmail,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'example@johndoe.com',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: null,
                      child: Text(lang.S.of(context).checkEmail),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/otp');
                      },
                      child: Text(
                        lang.S.of(context).checkEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: kMainColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}