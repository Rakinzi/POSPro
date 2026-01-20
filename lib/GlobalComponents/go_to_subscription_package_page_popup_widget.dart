import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../constant.dart';
import '../generated/l10n.dart' as lang;
import '../model/business_info_model.dart';

Widget goToPackagePagePopup({required BuildContext context, required EnrolledPlan? enrolledPlan}) {
  return AlertDialog(
    backgroundColor: kWhite,
    surfaceTintColor: kWhite,
    elevation: 0.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    contentPadding: const EdgeInsets.all(20),
    titlePadding: const EdgeInsets.all(0),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Spacer(),
            IconButton(
                padding: EdgeInsets.zero,
                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close,
                  color: kGreyTextColor,
                )),
          ],
        ),
        SvgPicture.asset(
          'assets/upgradePlan.svg',
          height: 198,
          width: 238,
        ),
        const SizedBox(height: 20),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            // lang.S.of(context).endYourFreePlan,
            textAlign: TextAlign.center,
            enrolledPlan?.plan?.subscriptionName != null ? 'End your ${enrolledPlan?.plan?.subscriptionName} plan?' : "No active plan!",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: kTitleColor),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          enrolledPlan?.plan?.subscriptionName != null
              ? 'Your ${enrolledPlan?.plan?.subscriptionName} plan is almost done, buy your next plan Thanks.'
              : 'You don’t have an active plan! buy your next plan now, Thanks',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kGreyTextColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
            child: Text(lang.S.of(context).upgradeNow),
            onPressed: () {
              Navigator.pop(context);
            }),
        const SizedBox(height: 5),
      ],
    ),
  );
}
