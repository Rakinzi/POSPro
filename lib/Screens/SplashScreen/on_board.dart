import 'package:flutter/material.dart';
import 'package:mobile_pos/core/theme/_app_colors.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../constant.dart';
import '../Authentication/Sign In/sign_in_screen.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key}) ;

  @override  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  PageController pageController = PageController(initialPage: 0);
  int currentIndexPage = 0;
  String buttonText = 'Next';

  List<Map<String, dynamic>> getSlider({required BuildContext context}) {
    List<Map<String, dynamic>> sliderList = [
      {
        "icon": onboard1,
        "title": lang.S.of(context).easyToUseThePos,
        "description": lang.S.of(context).easytheusedesciption,
      },
      {
        "icon": onboard2,
        "title": lang.S.of(context).choseYourFeature,
        "description": lang.S.of(context).choseyourfeatureDesciption,
      },
      {
        "icon": onboard3,
        "title": lang.S.of(context).allBusinessSolutions,
        "description": lang.S.of(context).allBusinessolutionDescrip,
      },
    ];
    return sliderList;
  }

  List<Map<String, dynamic>> sliderList = [];

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    sliderList = getSlider(context: context);
    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignIn(),
                    ));
              },
              child: Text(
                lang.S.of(context).skip,
                style: _theme.textTheme.titleMedium,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            height: 550,
            width: context.width(),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  itemCount: sliderList.length,
                  controller: pageController,
                  onPageChanged: (int index) => setState(() => currentIndexPage = index),
                  itemBuilder: (_, index) {
                    return Column(
                      children: [
                        const SizedBox(height: 30),
                        Image.asset(sliderList[index]['icon'], fit: BoxFit.fill, width: context.width() - 100, height: context.width() - 100),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            sliderList[index]['title'].toString(),
                            style: _theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: SizedBox(
                            width: context.width(),
                            child: Text(
                              sliderList[index]['description'].toString(),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: _theme.textTheme.bodyLarge?.copyWith(
                                color: DAppColors.kNeutral700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Center(
            child: SmoothPageIndicator(
              controller: pageController,
              count: sliderList.length,
              effect: ExpandingDotsEffect(dotColor: kMainColor.withValues(alpha: 0.2), activeDotColor: kMainColor, dotHeight: 8, dotWidth: 8),
            ),
          ),
          // DotIndicator(
          //   currentDotSize: 25,
          //   dotSize: 6,
          //   pageController: pageController,
          //   pages: sliderList,
          //   indicatorColor: kMainColor,
          //   unselectedIndicatorColor: Colors.grey,
          // ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              style: OutlinedButton.styleFrom(
                maximumSize: const Size(double.infinity, 48),
                minimumSize: const Size(double.infinity, 48),
                disabledBackgroundColor: _theme.colorScheme.primary.withValues(alpha: 0.15),
                disabledForegroundColor: const Color(0xff567DF4).withValues(alpha: 0.05),
              ),
              onPressed: () {
                setState(
                  () {
                    currentIndexPage < 2
                        ? pageController.nextPage(duration: const Duration(microseconds: 1000), curve: Curves.bounceInOut)
                        : Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignIn(),
                            ));
                    // : const SignInScreen().launch(context);
                  },
                );
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              iconAlignment: IconAlignment.end,
              label: Text(
                lang.S.of(context).next,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _theme.textTheme.bodyMedium?.copyWith(
                  color: _theme.colorScheme.primaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
