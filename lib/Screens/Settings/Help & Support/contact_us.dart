import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;

class ContactUs extends StatefulWidget {
  const ContactUs({super.key}) ;

  @override  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.S.of(context).contactUs,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Center(
            child: SizedBox(
              height: 150.0,
              width: MediaQuery.of(context).size.width - 40,
              child: TextField(
                keyboardType: TextInputType.name,
                maxLines: 30,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: lang.S.of(context).writeYourMessageHere,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SizedBox(
                      height: 350.0,
                      width: MediaQuery.of(context).size.width - 80,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Spacer(),
                              IconButton(
                                color: kGreyTextColor,
                                icon: const Icon(Icons.cancel_outlined),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          Container(
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              color: kDarkWhite,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: const Center(
                              child: Image(
                                image: AssetImage('images/emailsent.png'),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Center(
                            child: Text(
                              lang.S.of(context).sendYourEmail,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                lang.S.of(context).loremIpsumDolorSitAmetConsecteturElitInterdumCons,
                                //'Lorem ipsum dolor sit amet, consectetur elit. Interdum cons.',
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: kGreyTextColor,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(lang.S.of(context).backToHome),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              child: Text(lang.S.of(context).sendMessage),
            ),
          ),
        ],
      ),
    );
  }
}
