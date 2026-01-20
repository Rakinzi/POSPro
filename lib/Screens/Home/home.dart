import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/Screens/DashBoard/dashboard.dart';
import 'package:mobile_pos/Screens/Home/home_screen.dart';
import 'package:mobile_pos/Screens/Report/reports.dart';
import 'package:mobile_pos/Screens/Settings/settings_screen.dart';
import 'package:mobile_pos/Screens/pos_sale/pos_sale.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:mobile_pos/model/business_info_model.dart' as visible;

import '../../GlobalComponents/glonal_popup.dart';
import '../../Provider/profile_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _tabIndex = 0;
  late final PageController pageController = PageController(initialPage: _tabIndex);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index, BuildContext context, visible.Visibility? visibility) {
    if ((index == 1 && !(visibility?.dashboardPermission ?? true)) || (index == 2 && !(visibility?.reportsPermission ?? true))) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Access Denied'),
          content: Text('You do not have permission to access this section.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
      return;
    }
    setState(() => _tabIndex = index);
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(lang.S.of(context).areYouSure),
                content: Text(lang.S.of(context).doYouWantToExitTheApp),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text(lang.S.of(context).no)),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text(lang.S.of(context).yes)),
                ],
              ),
            ) ??
            false;
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Consumer(builder: (context, ref, __) {
        final visibility = ref.watch(businessInfoProvider).value?.user?.visibility;
        ref.watch(getExpireDateProvider(ref));

        return GlobalPopup(
          child: Scaffold(
            body: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (v) => setState(() => _tabIndex = v),
              children: [
                HomeScreen(),
                PosSaleScreen(),
                DashboardScreen(),
                Reports(),
                SettingScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _tabIndex,
              backgroundColor: Colors.white,
              onTap: (i) => _handleNavigation(i, context, visibility),
              items: [
                _buildNavItem(index: 0, activeIcon: 'cHome', icon: 'home', label: lang.S.of(context).home),
                _buildNavItem(
                  index: 1,
                  activeIcon: 'cPos',
                  icon: 'pos',
                  label: 'Pos',
                ),
                _buildNavItem(
                  index: 2,
                  activeIcon: 'dashbord1',
                  icon: 'dashbord',
                  label: lang.S.of(context).dashboard,
                ),
                _buildNavItem(
                  index: 3,
                  activeIcon: 'cFile',
                  icon: 'file',
                  label: lang.S.of(context).reports,
                ),
                _buildNavItem(
                  index: 4,
                  activeIcon: 'cSetting',
                  icon: 'setting',
                  label: lang.S.of(context).setting,
                ),
              ],
              type: BottomNavigationBarType.fixed,
              selectedItemColor: kMainColor,
              unselectedItemColor: kGreyTextColor,
              selectedLabelStyle: const TextStyle(fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }),
    );
  }

  BottomNavigationBarItem _buildNavItem({required int index, required String activeIcon, required String icon, required String label}) {
    return BottomNavigationBarItem(
      icon: _tabIndex == index
          ? SvgPicture.asset('assets/$activeIcon.svg', height: 28, width: 28, fit: BoxFit.scaleDown)
          : SvgPicture.asset('assets/$icon.svg', colorFilter: const ColorFilter.mode(kGreyTextColor, BlendMode.srcIn), height: 24, width: 24),
      label: label,
    );
  }
}
