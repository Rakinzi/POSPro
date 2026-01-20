// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../Home/home.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.email}) ;

  final String? email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, _) {
      final userRoleData = ref.watch(businessInfoProvider);
      ref.watch(getExpireDateProvider(ref));
      return userRoleData.when(data: (data) {
        return GlobalPopup(
          child: Scaffold(
              backgroundColor: kWhite,
              resizeToAvoidBottomInset: true,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(image: AssetImage('images/success.png')),
                  const SizedBox(height: 40.0),
                  Text(
                    lang.S.of(context).congratulation,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris cras",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        const Home().launch(context);
                        // Navigator.pushNamed(context, '/home');
                      },
                      child: Text(lang.S.of(context).continueButton),
                    ),
                  )
                ],
                // ),
                // bottomNavigationBar: ButtonGlobalWithoutIcon(
                //   buttontext: lang.S.of(context).continueButton,
                //   buttonDecoration: kButtonDecoration.copyWith(color: kMainColor),
                //   onPressed: () {
                //     const Home().launch(context);
                //     // Navigator.pushNamed(context, '/home');
                //   },
                //   buttonTextColor: Colors.white,
                // ),
              )),
        );
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}
