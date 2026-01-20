import 'package:flutter/material.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

import '../../constant.dart';

class EditSocialmedia extends StatefulWidget {
  const EditSocialmedia({super.key});

  @override  State<EditSocialmedia> createState() => _EditSocialmediaState();
}

class _EditSocialmediaState extends State<EditSocialmedia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).editSocailMedia,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaEditCard(
              iconWidget: const Image(
                image: AssetImage('images/fb.png'),
              ),
              socialMediaName: lang.S.of(context).facebook,
              //'Facebook',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaEditCard(
              iconWidget: const Image(
                image: AssetImage('images/twitter.png'),
              ),
              socialMediaName: lang.S.of(context).twitter,
              // 'Twitter',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaEditCard(
              iconWidget: const Image(
                image: AssetImage('images/insta.png'),
              ),
              socialMediaName: lang.S.of(context).instagram,
              //'Instagram',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaEditCard(
              iconWidget: const Image(
                image: AssetImage('images/linkedin.png'),
              ),
              socialMediaName: lang.S.of(context).linkedIN,
              //'LinkedIN',
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class SocialMediaEditCard extends StatelessWidget {
  SocialMediaEditCard({
    super.key,
    required this.iconWidget,
    required this.socialMediaName,
  });

  Widget iconWidget;
  final String socialMediaName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        iconWidget,
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            socialMediaName,
            style: theme.textTheme.titleLarge,
          ),
        ),
        const Spacer(),
        Container(
          width: 95,
          height: 40,
          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
          decoration: kButtonDecoration.copyWith(color: kMainColor),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: Colors.white,
              ),
              Text(
                lang.S.of(context).link,
                //'Link',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 30.0,
        ),
      ],
    );
  }
}