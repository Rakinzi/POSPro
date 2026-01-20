import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';

// ignore: must_be_immutable
class ButtonGlobal extends StatelessWidget {
  final IconData iconWidget;
  final String buttontext;
  final Color iconColor;
  final Decoration? buttonDecoration;

  final VoidCallback onPressed;

  const ButtonGlobal({
    super.key,
    required this.iconWidget,
    required this.buttontext,
    required this.iconColor,
    this.buttonDecoration,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration ?? BoxDecoration(borderRadius: BorderRadius.circular(8), color: kMainColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttontext,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(
              width: 2,
            ),
            Icon(
              iconWidget,
              color: iconColor,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ButtonGlobalWithoutIcon extends StatelessWidget {
  final String buttontext;
  final Decoration buttonDecoration;

  final VoidCallback onPressed;
  final Color buttonTextColor;

  const ButtonGlobalWithoutIcon({
    super.key,
    required this.buttontext,
    required this.buttonDecoration,
    required this.onPressed,
    required this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: buttonDecoration,
        child: Text(
          buttontext,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: buttonTextColor),
        ),
      ),
    );
  }
}

///-----------------------name with logo------------------
class NameWithLogo extends StatelessWidget {
  const NameWithLogo({super.key, this.imageAsset = logo});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75,
          width: 66,
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(imageAsset))),
        ),
        const Text(
          appsName,
          style: TextStyle(color: kTitleColor, fontWeight: FontWeight.bold, fontSize: 28),
        ),
      ],
    );
  }
}

///-------------------update button--------------------------------

class UpdateButton extends StatelessWidget {
  const UpdateButton({super.key, required this.text, required this.onpressed});
  final String text;
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: kMainColor,
        ),
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(color: kWhite),
        ),
      ),
    );
  }
}
