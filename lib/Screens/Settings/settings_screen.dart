import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Screens/DashBoard/dashboard.dart';
import 'package:mobile_pos/Screens/Profile%20Screen/profile_details.dart';
import 'package:mobile_pos/Screens/Settings/printing_invoice/printing_invoice_screen.dart';
import 'package:mobile_pos/Screens/Settings/sales%20settings/sales_settings_screen.dart';
import 'package:mobile_pos/Screens/User%20Roles/user_role_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/page_navigation_list/_page_navigation_list.dart';
import '../Authentication/Repo/logout_repo.dart';
import '../Currency/currency_screen.dart';
import '../barcode/gererate_barcode.dart';
import '../language/language.dart';
import '../payment_type/payment_type_list_screen.dart';
import '../subscription/package_screen.dart';
import 'delete_acount_allart_dialog.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen> {
  bool expanded = false;
  bool expandedHelp = false;
  bool expandedAbout = false;
  bool selected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      printerIsEnable();
    });
  }

  void printerIsEnable() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() => isPrintEnable = prefs.getBool('isPrintEnable') ?? true);
  }

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return SafeArea(
      child: Consumer(
        builder: (context, ref, _) {
          final businessInfo = ref.watch(businessInfoProvider);
          return GlobalPopup(
            child: Scaffold(
              backgroundColor: kWhite,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Builder(
                    builder: (_) {
                      final _details = businessInfo.value;
                      return ListTile(
                        leading: GestureDetector(
                          onTap: () => const ProfileDetails().launch(context),
                          child: Container(
                            constraints: BoxConstraints.tight(
                              const Size.square(54),
                            ),
                            decoration: BoxDecoration(
                              image: _details?.pictureUrl == null
                                  ? const DecorationImage(
                                      image: AssetImage('images/no_shop_image.png'),
                                      fit: BoxFit.cover,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(
                                        APIConfig.domain + _details!.pictureUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        title: Text(
                          _details?.user?.role == 'staff' ? '${_details?.companyName ?? ''} [${_details?.user?.name ?? ''}]' : _details?.companyName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        titleTextStyle: _theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        subtitle: Text(
                          _details?.category?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitleTextStyle: _theme.textTheme.bodyLarge?.copyWith(
                          color: kGreyTextColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
              body: PageNavigationListView(
                navTiles: navItems,
                onTap: (value) async {
                  if (value.type == PageNavigationListTileType.navigation && value.route != null) {
                    if (value.route is SelectLanguage) {
                      final prefs = await SharedPreferences.getInstance();
                      final data = prefs.getString('lang');
                      if (!context.mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SelectLanguage(
                            alreadySelectedLanguage: data,
                          ),
                        ),
                      );
                      return;
                    }

                    final _previousCurrency = currency;
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => value.route!)).then(
                          (_) {
                            if (!context.mounted) return;
                            if (_previousCurrency != currency) {
                              setState(() {});
                            }
                          },
                        );
                  }

                  if (!context.mounted) return;
                  if (value.type == PageNavigationListTileType.function) {
                    if (value.value == 'logout') {
                      if (!context.mounted) return;
                      ref.invalidate(businessInfoProvider);
                      EasyLoading.show(status: lang.S.of(context).logOut);
                      LogOutRepo repo = LogOutRepo();
                      await repo.signOutApi(context: context, ref: ref);
                    }
                    if (value.value == 'delete_account') {
                      if (!context.mounted) return;
                      showDeleteAccountDialog(context, ref);
                    }
                  }
                },
                // footer: Padding(
                //   padding: const EdgeInsetsDirectional.only(
                //     start: 24,
                //     top: 8,
                //   ),
                //   child: Text(
                //     'POSPro V-$appVersion',
                //     style: _theme.textTheme.bodyLarge?.copyWith(
                //       color: kGreyTextColor,
                //     ),
                //   ),
                // ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<PageNavigationNavTile<dynamic>> get navItems {
    final businessData = ref.watch(businessInfoProvider).value;
    return [
      PageNavigationNavTile(
        title: lang.S.of(context).profile,
        svgIconPath: 'assets/profile.svg',
        route: const ProfileDetails(),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).printingInvoice,
        svgIconPath: 'assets/print.svg',
        route: PrintingInvoiceScreen(),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).salesSetting,
        svgIconPath: 'assets/sales.svg',
        route: SalesSettingsScreen(),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).subscription,
        svgIconPath: 'assets/subscription.svg',
        route: const PackageScreen(),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).dashboard,
        svgIconPath: 'assets/dashboard.svg',
        route: const DashboardScreen(),
      ),
      if (businessData?.user?.role == "shop-owner")
        PageNavigationNavTile(
          title: lang.S.of(context).userRole,
          svgIconPath: 'assets/userRole.svg',
          route: const UserRoleScreen(),
        ),
      PageNavigationNavTile(
        title: lang.S.of(context).currency,
        svgIconPath: 'assets/currency.svg',
        route: const CurrencyScreen(),
        trailing: Text.rich(
          TextSpan(
            text: '($currency)  ',
            children: const [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: kGreyTextColor,
                ),
              ),
            ],
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).barcodeGenerator,
        svgIconPath: 'assets/barcode.svg',
        route: const BarcodeGeneratorScreen(),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).selectLang,
        svgIconPath: 'assets/language.svg',
        route: const SelectLanguage(),
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).paymentTypes,
        svgIconPath: 'assets/payment_type.svg',
        route: const PaymentTypeScreen(),
      ),
      PageNavigationNavTile(
        title: 'Delete Account',
        svgIconPath: 'assets/account_delete.svg',
        value: 'delete_account',
        hideTrailing: true,
        type: PageNavigationListTileType.function,
      ),
      PageNavigationNavTile(
        title: lang.S.of(context).logOut,
        svgIconPath: 'assets/logout.svg',
        value: 'logout',
        hideTrailing: true,
        type: PageNavigationListTileType.function,
      ),
    ];
  }
}
