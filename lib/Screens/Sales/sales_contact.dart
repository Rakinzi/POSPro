import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Provider/add_to_cart.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/Screens/Sales/add_sales.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../model/business_info_model.dart' as business;
import '../Customers/Provider/customer_provider.dart';

class SalesContact extends StatefulWidget {
  const SalesContact({super.key});

  @override
  SalesContactState createState() => SalesContactState();
}

class SalesContactState extends State<SalesContact> {
  Color color = Colors.black26;
  String searchCustomer = '';

  String? subscriptionDate;
  String expireDate = '';
  business.EnrolledPlan? enrolledPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (context, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      final providerData = ref.watch(partiesProvider);
      return businessInfo.when(data: (details) {
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                lang.S.of(context).chooseCustomer,
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: providerData.when(data: (customer) {
                  return customer.isNotEmpty
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: lang.S.of(context).search,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: kGreyTextColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    searchCustomer = value;
                                  });
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                AddSalesScreen(customerModel: null).launch(context);
                                ref.invalidate(cartNotifier);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 50.0,
                                      width: 50.0,
                                      child: CircleAvatar(
                                        foregroundColor: Colors.blue,
                                        backgroundColor: Colors.white,
                                        radius: 70.0,
                                        child: ClipOval(
                                          child: Image.asset(
                                            'images/no_shop_image.png',
                                            fit: BoxFit.cover,
                                            width: 120.0,
                                            height: 120.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.S.of(context).walkInCustomer,
                                          //'Walk-in Customer',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Text(
                                          lang.S.of(context).guest,
                                          //'Guest',
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    const SizedBox(width: 20),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: kGreyTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: customer.length,
                                itemBuilder: (_, index) {
                                  customer[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                                  customer[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                                  customer[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                                  customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;
                                  return ((customer[index].name?.contains(searchCustomer) ?? false) || (customer[index].phone!.contains(searchCustomer))) &&
                                          !customer[index].type!.contains('Supplier')
                                      ? GestureDetector(
                                          onTap: () async {
                                            AddSalesScreen(customerModel: customer[index]).launch(context);
                                            ref.invalidate(cartNotifier);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 50.0,
                                                        width: 50.0,
                                                        child: CircleAvatar(
                                                          foregroundColor: Colors.blue,
                                                          backgroundColor: Colors.white,
                                                          radius: 70.0,
                                                          child: ClipOval(
                                                            child: customer[index].image == null
                                                                ? Image.asset(
                                                                    'images/no_shop_image.png',
                                                                    fit: BoxFit.cover,
                                                                    width: 120.0,
                                                                    height: 120.0,
                                                                  )
                                                                : Image.network(
                                                                    '${APIConfig.domain}${customer[index].image}',
                                                                    fit: BoxFit.cover,
                                                                    width: 120.0,
                                                                    height: 120.0,
                                                                  ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10.0),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              customer[index].name ?? '',
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                              style: theme.textTheme.titleMedium,
                                                            ),
                                                            Text(
                                                              customer[index].type ?? '',
                                                              style: theme.textTheme.bodyLarge,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // const Spacer(),
                                                Row(
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          '$currency ${customer[index].due}',
                                                          style: theme.textTheme.bodyLarge,
                                                        ),
                                                        Text(
                                                          lang.S.of(context).due,
                                                          style: theme.textTheme.bodyLarge,
                                                        ),
                                                      ],
                                                    ).visible(customer[index].due != null && customer[index].due != 0),
                                                    const SizedBox(width: 20),
                                                    const Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: kGreyTextColor,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container();
                                }),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            AddSalesScreen(customerModel: null).launch(context);
                            ref.invalidate(cartNotifier);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  width: 50.0,
                                  child: CircleAvatar(
                                    foregroundColor: Colors.blue,
                                    backgroundColor: Colors.white,
                                    radius: 70.0,
                                    child: ClipOval(
                                      child: Image.asset(
                                        'images/no_shop_image.png',
                                        fit: BoxFit.cover,
                                        width: 120.0,
                                        height: 120.0,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang.S.of(context).walkInCustomer,
                                      //'Walk-in Customer',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    Text(
                                      lang.S.of(context).guest,
                                      //'Guest',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const SizedBox(width: 20),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: kGreyTextColor,
                                ),
                              ],
                            ),
                          ),
                        );
                }, error: (e, stack) {
                  return Text(e.toString());
                }, loading: () {
                  return const Center(child: CircularProgressIndicator());
                }),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: kMainColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              child: const Icon(
                Icons.add,
                color: kWhite,
              ),
              onPressed: () async {
                // await checkSubscriptionAndNavigate(context, details.subscriptionDate, details.willExpire, details.enrolledPlan);
                if (details.subscriptionDate != null && details.enrolledPlan != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddParty()));
                }
              },
              // onPressed: () async {
              //   await checkSubscriptionAndNavigate(context, details.subscriptionDate, details.willExpire, details.enrolledPlan);
              //   debugPrint("Before checking subscription:");
              //   debugPrint("subscriptionDate: ${details.subscriptionDate}");
              //   debugPrint("expireDate: ${details.willExpire}");
              //   debugPrint("enrolledPlan: ${details.enrolledPlan?.duration}");
              //
              //   // Check if the subscription is valid after navigating
              //   if (details.subscriptionDate != null && details.enrolledPlan != null) {
              //     DateTime parsedSubscriptionDate = DateTime.parse(details.subscriptionDate!);
              //     num duration = details.enrolledPlan!.duration ?? 0;
              //     DateTime expirationDate = parsedSubscriptionDate.add(Duration(days: duration.toInt()));
              //     num daysLeft = expirationDate.difference(DateTime.now()).inDays;
              //     if (daysLeft >= 0) {
              //       Navigator.push(context, MaterialPageRoute(builder: (context) => const AddParty()));
              //     }
              //   }
              // },
            ),
          ),
        );
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
    });
  }
}
