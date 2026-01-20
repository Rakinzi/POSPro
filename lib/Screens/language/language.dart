import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../Home/home.dart';
import 'language_provider.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key, this.alreadySelectedLanguage}) ;
  final String? alreadySelectedLanguage;

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  Future<void> saveData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', data);
  }

  Future<void> getInit() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguageCode = prefs.getString('lang') ?? 'en'; // Default to English code
    if (!mounted) return;
    setState(() {
      selectedLanguage = savedLanguageCode;
    });

    // Update provider with the saved language code
    context.read<LanguageChangeProvider>().changeLocale(savedLanguageCode);
  }

  @override
  void initState() {
    super.initState();
    getInit();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('-----language length--${languageMap.length}----------------');
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: kWhite,
          elevation: 0,
          backgroundColor: Colors.white,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              FeatherIcons.x,
              color: kTitleColor,
            ),
          ),
          centerTitle: true,
          title: Text(
            lang.S.of(context).selectLang,
            style: const TextStyle(color: kTitleColor),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
                itemCount: languageMap.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) {
                  var entry = languageMap.entries.toList()[index];
                  String languageName = entry.key;
                  String languageCode = entry.value;
                  return StatefulBuilder(
                    builder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              selectedLanguage = languageCode;
                            });
                          },
                          contentPadding: const EdgeInsets.only(left: 10, right: 10.0),
                          horizontalTitleGap: 10,
                          title: Text(languageName),
                          trailing: Icon(
                            selectedLanguage == languageCode ? Icons.radio_button_checked_outlined : Icons.circle_outlined,
                            color: selectedLanguage == languageCode ? kMainColor : Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
              onPressed: () async {
                // Update locale in the provider
                if (selectedLanguage != null) {
                  // Save the selected language
                  await saveData(selectedLanguage!);
                  if (!context.mounted) return;

                  // Update locale in the provider
                  context.read<LanguageChangeProvider>().changeLocale(selectedLanguage!);

                  // Navigate to Home
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                }
              },
              child: Text(lang.S.of(context).save)),
        ),
      ),
    );
  }
}
