// import 'package:flutter/material.dart';
// import '../../model/business_info_model.dart' as business;
// import '../Screens/subscription/purchase_premium_plan_screen.dart';
//
// Future<void> checkSubscriptionAndNavigate(
//   BuildContext context,
//   String? subscriptionDate,
//   String expireDate,
//   business.EnrolledPlan? enrolledPlan,
// ) async {
//   debugPrint('Subscription plan: Expire date : $expireDate');
//   DateTime expireDate2 = DateTime.parse(expireDate);
//   if (DateTime.now().isAfter(expireDate2)) {
//     await navigateToPurchasePremiumPlanScreen(context, true, expireDate, enrolledPlan);
//   }
//   if (subscriptionDate == null || enrolledPlan == null) {
//     await navigateToPurchasePremiumPlanScreen(context, true, expireDate, enrolledPlan);
//     return;
//   }
//
//   DateTime parsedSubscriptionDate = DateTime.parse(subscriptionDate);
//   num duration = enrolledPlan.duration ?? 0;
//   DateTime expirationDate = parsedSubscriptionDate.add(Duration(days: duration.toInt()));
//   num daysLeft = expirationDate.difference(DateTime.now()).inDays;
//
//   if (daysLeft < 0) {
//     await navigateToPurchasePremiumPlanScreen(context, true, expireDate, enrolledPlan);
//   }
// }
//
// Future<void> navigateToPurchasePremiumPlanScreen(
//   BuildContext context,
//   bool isExpired,
//   String expireDate,
//   business.EnrolledPlan? enrolledPlan,
// ) async {
//   await Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => PurchasePremiumPlanScreen(
//         isExpired: true,
//         isCameBack: true,
//         enrolledPlan: enrolledPlan,
//         willExpire: expireDate,
//       ),
//     ),
//   );
// }
