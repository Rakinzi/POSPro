import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/DashBoard/dashboard.dart';
import 'package:mobile_pos/Screens/Home/components/grid_items.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/sync_status_indicator.dart';
import '../../model/business_info_model.dart' as business;
import '../Customers/Provider/customer_provider.dart';
import '../DashBoard/global_container.dart';
import '../Home/Model/banner_model.dart' as b;
import '../subscription/package_screen.dart';
import 'Provider/banner_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController(initialPage: 0, viewportFraction: 0.8);

  bool _isRefreshing = false;

  Future<void> refreshAllProviders({required WidgetRef ref}) async {
    if (_isRefreshing) return; // Prevent multiple refresh calls

    _isRefreshing = true;
    try {
      ref.invalidate(summaryInfoProvider);
      ref.invalidate(bannerProvider);
      ref.invalidate(businessInfoProvider);
      ref.invalidate(businessSettingProvider);
      ref.invalidate(partiesProvider);
      ref.invalidate(getExpireDateProvider(ref));
      await Future.delayed(const Duration(seconds: 3));
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(builder: (_, ref, __) {
      final businessInfo = ref.watch(businessInfoProvider);
      final summaryInfo = ref.watch(summaryInfoProvider);
      final banner = ref.watch(bannerProvider);
      return businessInfo.when(data: (details) {
        return Scaffold(
            backgroundColor: kBackgroundColor,
            appBar: AppBar(
              backgroundColor: kWhite,
              titleSpacing: 5,
              surfaceTintColor: kWhite,
              actions: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SyncStatusIndicator(),
                ),
                IconButton(onPressed: () async => refreshAllProviders(ref: ref), icon: const Icon(Icons.refresh)),
              ],
              leading: Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () {
                    const ProfileDetails().launch(context);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: details.pictureUrl == null
                        ? BoxDecoration(
                            image: const DecorationImage(image: AssetImage('images/no_shop_image.png'), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          )
                        : BoxDecoration(
                            image: DecorationImage(image: NetworkImage('${APIConfig.domain}${details.pictureUrl}'), fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(50),
                          ),
                  ),
                ),
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.user?.role == 'staff' ? '${details.companyName ?? ''} [${details.user?.name ?? ''}]' : details.companyName ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    // onTap: () {
                    //   showDialog(
                    //       context: context,
                    //       builder: (BuildContext context) {
                    //         return goToPackagePagePopup(
                    //             context: context,
                    //             enrolledPlan: details.enrolledPlan);
                    //       });
                    // },
                    child: Text.rich(
                        TextSpan(
                          text: '${details.enrolledPlan?.plan?.subscriptionName ?? 'No Active'} Plan',
                          children: [
                            // if (details.enrolledPlan?.duration != null &&
                            //     details.enrolledPlan!.duration! <= 7)
                            //   TextSpan(
                            //     text: ' (${getDayLeftInExpiring(
                            //       expireDate: details.willExpire,
                            //       shortMSG: false,
                            //     )})',
                            //     style: theme.textTheme.bodySmall?.copyWith(
                            //       fontSize: 13,
                            //       color: kPeraColor,
                            //     ),
                            //   ),
                          ],
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: kPeraColor,
                          fontWeight: FontWeight.w500,
                        )),
                  )
                ],
              ),
            ),
            resizeToAvoidBottomInset: true,
            body: RefreshIndicator.adaptive(
              onRefresh: () async => refreshAllProviders(ref: ref),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: details.user?.visibility?.dashboardPermission ?? true,
                        child: summaryInfo.when(data: (summary) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Quick Overview',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: kWhite,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen())),
                                      child: Text(
                                        'View All',
                                        style: theme.textTheme.bodySmall?.copyWith(color: kWhite, fontSize: 16),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        minTileHeight: 0,
                                        titlePadding: EdgeInsets.zero,
                                        // isShadow: true,
                                        textColor: true,
                                        title: 'Sales',
                                        subtitle: '$currency${formatAmount(summary.data!.sales.toString())}',
                                      ),
                                    ),
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        minTileHeight: 0,
                                        // isShadow: true,
                                        textColor: true,
                                        alainRight: true,
                                        titlePadding: EdgeInsets.zero,
                                        title: 'Purchased',
                                        subtitle: '$currency${formatAmount(summary.data!.purchase.toString())}',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        textColor: true,
                                        minTileHeight: 0,
                                        titlePadding: EdgeInsets.zero,
                                        title: 'Income',
                                        subtitle: '$currency${formatAmount(summary.data!.income.toString())}',
                                      ),
                                    ),
                                    Flexible(
                                      child: GlobalContainer(
                                        minVerticalPadding: 0,
                                        minTileHeight: 0,
                                        textColor: true,
                                        alainRight: true,
                                        titlePadding: EdgeInsets.zero,
                                        title: 'Expense',
                                        subtitle: '$currency${formatAmount(summary.data!.expense.toString())}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                          // return Container(
                          //   padding: const EdgeInsets.all(10),
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(8),
                          //       color: kMainColor),
                          //   child: Column(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Row(
                          //         children: [
                          //           Expanded(
                          //             flex: 3,
                          //             child: Text(
                          //               lang.S.of(context).todaySummary,
                          //               //'Today’s Summary',
                          //               style: theme.textTheme.titleLarge
                          //                   ?.copyWith(
                          //                       fontWeight: FontWeight.w600,
                          //                       color: kWhite,
                          //                       fontSize: 18),
                          //               maxLines: 1,
                          //               overflow: TextOverflow.ellipsis,
                          //             ),
                          //           ),
                          //           const Spacer(),
                          //           Expanded(
                          //             flex: 1,
                          //             child: GestureDetector(
                          //                 onTap: () {
                          //                   Navigator.push(
                          //                       context,
                          //                       MaterialPageRoute(
                          //                           builder: (context) =>
                          //                               const DashboardScreen()));
                          //                 },
                          //                 child: Text(
                          //                   lang.S.of(context).sellAll,
                          //
                          //                   //'Sell All >',
                          //                   style: const TextStyle(
                          //                       color: kWhite,
                          //                       fontWeight: FontWeight.w500),
                          //                   maxLines: 1,
                          //                 )),
                          //           ),
                          //         ],
                          //       ),
                          //       const SizedBox(height: 10),
                          //       Row(
                          //         children: [
                          //           Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               Text(
                          //                 lang.S.of(context).sales,
                          //                 //'Sales',
                          //                 style: theme.textTheme.bodyMedium
                          //                     ?.copyWith(color: kWhite),
                          //               ),
                          //               Text(
                          //                 '$currency${summary.data?.sales?.toStringAsFixed(2) ?? 0.00}',
                          //                 style: theme.textTheme.titleSmall
                          //                     ?.copyWith(color: kWhite),
                          //               ),
                          //               const SizedBox(
                          //                 height: 10,
                          //               ),
                          //               Text(
                          //                 summary.data!.income! >= 0
                          //                     ? 'Profit'
                          //                     : 'Loss',
                          //                 style: theme.textTheme.bodyMedium
                          //                     ?.copyWith(color: kWhite),
                          //               ),
                          //               Text(
                          //                 '$currency${summary.data?.income?.abs().toStringAsFixed(2) ?? 0.00}',
                          //                 style: theme.textTheme.bodyMedium
                          //                     ?.copyWith(
                          //                         color: kWhite,
                          //                         fontWeight: FontWeight.w600),
                          //               ),
                          //             ],
                          //           ),
                          //           const Spacer(),
                          //           Column(
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               Text(
                          //                 lang.S.of(context).purchased,
                          //                 // 'Purchased',
                          //                 style: theme.textTheme.bodyMedium
                          //                     ?.copyWith(color: kWhite),
                          //               ),
                          //               Text(
                          //                 '$currency${summary.data?.purchase?.toStringAsFixed(2) ?? 0.00}',
                          //                 style: theme.textTheme.titleSmall
                          //                     ?.copyWith(
                          //                         color: kWhite,
                          //                         fontWeight: FontWeight.bold),
                          //               ),
                          //               const SizedBox(
                          //                 height: 10,
                          //               ),
                          //               Text(
                          //                 //'Expense',
                          //                 lang.S.of(context).expense,
                          //                 style: theme.textTheme.bodyMedium
                          //                     ?.copyWith(color: kWhite),
                          //               ),
                          //               Text(
                          //                 '$currency${summary.data?.expense?.toStringAsFixed(2) ?? 0.00}',
                          //                 style: theme.textTheme.bodyMedium
                          //                     ?.copyWith(
                          //                         color: kWhite,
                          //                         fontWeight: FontWeight.w600),
                          //               ),
                          //             ],
                          //           ),
                          //           const SizedBox(
                          //             width: 30,
                          //           ),
                          //         ],
                          //       )
                          //     ],
                          //   ),
                          // );
                        }, error: (e, stack) {
                          return Text(e.toString());
                        }, loading: () {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }),
                      ),
                      SizedBox(height: 16),
                      Visibility(
                        visible: details.user?.visibility?.dashboardPermission ?? true,
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          childAspectRatio: 3.0,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 2,
                          children: List.generate(
                            getFreeIcons(context: context).length,
                            (index) => HomeGridCards(
                              gridItems: getFreeIcons(context: context)[index],
                              visibility: businessInfo.value?.user?.visibility,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///________________Banner_______________________________________
                      banner.when(data: (imageData) {
                        List<b.Banner> images = [];
                        if (imageData.isNotEmpty) {
                          images.addAll(imageData.where(
                            (element) => element.status == 1,
                          ));
                        }

                        if (images.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.S.of(context).whatNew,
                                textAlign: TextAlign.start,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                height: 150,
                                width: MediaQuery.of(context).size.width,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemCount: images.length,
                                  itemBuilder: (_, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        const PackageScreen().launch(context);
                                      },
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.only(end: 10), // Spacing between items
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Image.network(
                                            "${APIConfig.domain}${images[index].imageUrl}",
                                            width: MediaQuery.of(context).size.width * 0.7, // 80% width
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        } else {
                          return Center(
                            child: Container(
                              height: 150,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), image: DecorationImage(fit: BoxFit.cover, image: AssetImage('images/banner1.png'))),
                            ),
                          );
                        }
                      }, error: (e, stack) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: Text(
                              lang.S.of(context).noDataFound,
                              style: theme.textTheme.titleMedium,
                              //'No Data Found'
                            ),
                          ),
                        );
                      }, loading: () {
                        return const CircularProgressIndicator();
                      }),
                    ],
                  ),
                ),
              ),
            ));
      }, error: (e, stack) {
        return Text(e.toString());
      }, loading: () {
        return const Center(child: CircularProgressIndicator());
      });
    });
  }
}

class HomeGridCards extends StatefulWidget {
  const HomeGridCards({
    super.key,
    required this.gridItems,
    this.visibility,
  });

  final GridItems gridItems;
  final business.Visibility? visibility;

  @override
  State<HomeGridCards> createState() => _HomeGridCardsState();
}

class _HomeGridCardsState extends State<HomeGridCards> {
  bool checkPermission({required String item}) {
    if (item == 'Sales' && (widget.visibility?.salePermission ?? true)) {
      return true;
    } else if (item == 'Parties' && (widget.visibility?.partiesPermission ?? true)) {
      return true;
    } else if (item == 'Purchase' && (widget.visibility?.purchasePermission ?? true)) {
      return true;
    } else if (item == 'Products' && (widget.visibility?.productPermission ?? true)) {
      return true;
    } else if (item == 'Due List' && (widget.visibility?.dueListPermission ?? true)) {
      return true;
    } else if (item == 'Stock' && (widget.visibility?.stockPermission ?? true)) {
      return true;
    } else if (item == 'Reports' && (widget.visibility?.reportsPermission ?? true)) {
      return true;
    } else if (item == 'Sales List' && (widget.visibility?.salesListPermission ?? true)) {
      return true;
    } else if (item == 'Purchase List' && (widget.visibility?.purchaseListPermission ?? true)) {
      return true;
    } else if (item == 'Loss/Profit' && (widget.visibility?.lossProfitPermission ?? true)) {
      return true;
    } else if (item == 'Expense' && (widget.visibility?.addExpensePermission ?? true)) {
      return true;
    } else if (item == 'Income' && (widget.visibility?.addIncomePermission ?? true)) {
      return true;
    } else if (item == 'tax') {
      return true;
    } else if (item == 'hrm') {
      return true;
    } else if (item == 'customPrint') {
      return true;
    }
    // else if (item == 'warehouse') {
    //   return true;
    // }
    else if (item == 'Pos Sale') {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      return GestureDetector(
        onTap: () async {
          if (checkPermission(item: widget.gridItems.route)) {
            Navigator.of(context).pushNamed('/${widget.gridItems.route}');
          } else {
            EasyLoading.showError(
              lang.S.of(context).permissionNotGranted,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: kWhite,
              boxShadow: [BoxShadow(color: const Color(0xff171717).withValues(alpha: 0.07), offset: const Offset(0, 3), blurRadius: 50, spreadRadius: -4)]),
          child: Row(
            children: [
              SvgPicture.asset(
                widget.gridItems.icon.toString(),
                height: 40,
                width: 40,
              ),
              const SizedBox(
                width: 8,
              ),
              Flexible(
                  child: Text(
                widget.gridItems.title.toString(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: DAppColors.kNeutral700),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ))
            ],
          ),
        ),
      );
    });
  }
}

// String getDayLeftInExpiring({
//   required String? expireDate,
//   required bool shortMSG,
// }) {
//   if (expireDate == null) {
//     return shortMSG ? 'N/A' : 'Subscribe Now';
//   }
//
//   DateTime expiringDay =
//       DateTime.parse(expireDate).add(const Duration(days: 1));
//   Duration remaining = expiringDay.difference(DateTime.now());
//
//   if (remaining.isNegative) {
//     return 'Expired';
//   }
//
//   if (remaining.inDays < 1) {
//     int hoursLeft = remaining.inHours;
//     return shortMSG ? 'Left $hoursLeft\nHours' : 'Left $hoursLeft Hours';
//   } else if (remaining.inDays <= 7) {
//     int daysLeft = remaining.inDays;
//     return shortMSG ? 'Left $daysLeft\nDays' : 'Left $daysLeft Days';
//   }
//
//   // If more than 7 days, return empty or optional message
//   return '';
// }

String getSubscriptionExpiring({required String? expireDate, required bool shortMSG}) {
  if (expireDate == null) {
    return shortMSG ? 'N/A' : 'Subscribe Now';
  }
  DateTime expiringDay = DateTime.parse(expireDate).add(const Duration(days: 1));
  if (expiringDay.isBefore(DateTime.now())) {
    return 'Expired';
  }
  if (expiringDay.difference(DateTime.now()).inDays < 1) {
    return shortMSG ? '${expiringDay.difference(DateTime.now()).inHours}\nHours Left' : '${expiringDay.difference(DateTime.now()).inHours} Hours Left';
  } else {
    return shortMSG ? '${expiringDay.difference(DateTime.now()).inDays}\nDays Left' : '${expiringDay.difference(DateTime.now()).inDays} Days Left';
  }
}
