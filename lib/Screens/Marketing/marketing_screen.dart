import 'package:flutter/material.dart';
import 'package:mobile_pos/Screens/Marketing/edit_social_media.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../constant.dart';

class MarketingScreen extends StatefulWidget {
  const MarketingScreen({super.key}) ;

  @override  State<MarketingScreen> createState() => _MarketingScreenState();
}

class _MarketingScreenState extends State<MarketingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).socialMarketing,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: GestureDetector(
              onTap: () {
                const EditSocialmedia().launch(context);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.edit,
                    color: kMainColor,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    lang.S.of(context).edit,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: kMainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaCard(
              iconWidget: const Image(
                image: AssetImage('images/fb.png'),
              ),
              socialMediaName: lang.S.of(context).facebook,
              //'Facebook',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaCard(
              iconWidget: const Image(
                image: AssetImage('images/twitter.png'),
              ),
              socialMediaName: lang.S.of(context).twitter,
              //'Twitter',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaCard(
              iconWidget: const Image(
                image: AssetImage('images/insta.png'),
              ),
              socialMediaName: lang.S.of(context).instagram,
              //'Instagram',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 10.0),
            child: SocialMediaCard(
              iconWidget: const Image(
                image: AssetImage('images/linkedin.png'),
              ),
              socialMediaName: lang.S.of(context).linkedIN,
              // 'LinkedIN',
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class SocialMediaCard extends StatelessWidget {
  SocialMediaCard({
    super.key,
    required this.iconWidget,
    required this.socialMediaName,
  }) ;

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
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
            ),
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
              Text(
                lang.S.of(context).share,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
              const Icon(
                Icons.share,
                color: Colors.white,
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