import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Customers/Model/parties_model.dart';
import 'package:mobile_pos/Screens/Due%20Calculation/due_collection_screen.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../Const/api_config.dart';
import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart' as d_app_colors;
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Customers/Provider/customer_provider.dart';

class DueCalculationContactScreen extends StatefulWidget {
  const DueCalculationContactScreen({super.key});

  @override
  State<DueCalculationContactScreen> createState() => _DueCalculationContactScreenState();
}

class _DueCalculationContactScreenState extends State<DueCalculationContactScreen> {
  late Color color;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            lang.S.of(context).dueList,
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Consumer(builder: (context, ref, __) {
            final providerData = ref.watch(partiesProvider);
            final businessInfo = ref.watch(businessInfoProvider);

            return providerData.when(data: (parties) {
              List<Party> dueCustomerList = [];

              for (var party in parties) {
                if ((party.due ?? 0) > 0) {
                  dueCustomerList.add(party);
                }
              }
              return dueCustomerList.isNotEmpty
                  ? businessInfo.when(data: (details) {
                      return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dueCustomerList.length,
                          itemBuilder: (_, index) {
                            dueCustomerList[index].type == 'Retailer' ? color = const Color(0xFF56da87) : Colors.white;
                            dueCustomerList[index].type == 'Wholesaler' ? color = const Color(0xFF25a9e0) : Colors.white;
                            dueCustomerList[index].type == 'Dealer' ? color = const Color(0xFFff5f00) : Colors.white;
                            dueCustomerList[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;

                            return ListTile(
                              visualDensity: const VisualDensity(vertical: -2),
                              contentPadding: EdgeInsets.zero,
                              onTap: () async {
                                DueCollectionScreen(customerModel: dueCustomerList[index]).launch(context);
                              },
                              leading: dueCustomerList[index].image != null
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: d_app_colors.kBorder, width: 0.3),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            '${APIConfig.domain}${dueCustomerList[index].image ?? ''}',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : CircleAvatarWidget(name: dueCustomerList[index].name ?? 'n/a'),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      dueCustomerList[index].name ?? '',
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$currency ${dueCustomerList[index].due}',
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      dueCustomerList[index].type ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: _theme.textTheme.bodyMedium?.copyWith(
                                        color: color,
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dueCustomerList[index].due != null && dueCustomerList[index].due != 0 ? lang.S.of(context).due : 'No Due',
                                    style: _theme.textTheme.bodyMedium?.copyWith(
                                      color: dueCustomerList[index].due != null && dueCustomerList[index].due != 0 ? const Color(0xFFff5f00) : const Color(0xff808191),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                IconlyLight.arrow_right_2,
                                size: 18,
                              ),
                            );
                          });
                    }, error: (e, stack) {
                      return const CircularProgressIndicator();
                    }, loading: () {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    })
                  : Center(
                      child: Text(
                        lang.S.of(context).noDataAvailabe,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                    );
            }, error: (e, stack) {
              return Text(e.toString());
            }, loading: () {
              return const Center(child: CircularProgressIndicator());
            });
          }),
        ),
      ),
    );
  }
}
