import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconly/iconly.dart';
import 'package:mobile_pos/Const/api_config.dart';
import 'package:mobile_pos/Provider/add_to_cart_purchase.dart';
import 'package:mobile_pos/Provider/profile_provider.dart';
import 'package:mobile_pos/Screens/Customers/add_customer.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../../constant.dart';
import '../../currency.dart';
import '../../widgets/empty_widget/_empty_widget.dart';
import '../Customers/Provider/customer_provider.dart';
import 'add_and_edit_purchase.dart';

class PurchaseContacts extends StatefulWidget {
  const PurchaseContacts({super.key});

  @override
  State<PurchaseContacts> createState() => _PurchaseContactsState();
}

class _PurchaseContactsState extends State<PurchaseContacts> {
  Color color = Colors.black26;
  String searchCustomer = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, __) {
      final _theme = Theme.of(context);
      final providerData = ref.watch(partiesProvider);
      final businessInfo = ref.watch(businessInfoProvider);
      return businessInfo.when(data: (details) {
        return GlobalPopup(
          child: Scaffold(
            backgroundColor: kWhite,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                lang.S.of(context).chooseSupplier,
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0.0,
            ),
            body: SingleChildScrollView(
              child: providerData.when(data: (customer) {
                return customer.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.name,
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
                                  searchCustomer = value.toLowerCase().trim();
                                });
                              },
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: customer.length,
                              itemBuilder: (_, index) {
                                customer[index].type == 'Supplier' ? color = const Color(0xFFA569BD) : Colors.white;
                                return customer[index].name!.toLowerCase().trim().contains(searchCustomer) && customer[index].type!.contains('Supplier')
                                    ? ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        onTap: () async {
                                          ref.invalidate(cartNotifierPurchaseNew);
                                          AddAndUpdatePurchaseScreen(customerModel: customer[index]).launch(context);
                                        },
                                        leading: customer[index].image != null
                                            ? Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.grey.shade50, width: 0.3),
                                                  image: DecorationImage(
                                                      image: NetworkImage(
                                                        '${APIConfig.domain}${customer[index].image}',
                                                      ),
                                                      fit: BoxFit.cover),
                                                ),
                                              )
                                            : CircleAvatarWidget(name: customer[index].name),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                customer[index].name ?? '',
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
                                              '$currency${customer[index].due}',
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
                                                customer[index].type ?? '',
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
                                              customer[index].due != null && customer[index].due != 0 ? lang.S.of(context).due : 'No Due',
                                              style: _theme.textTheme.bodyMedium?.copyWith(
                                                color: customer[index].due != null && customer[index].due != 0 ? const Color(0xFFff5f00) : const Color(0xff7B787B),
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          IconlyLight.arrow_right_2,
                                          size: 18,
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: EmptyWidget(
                          message: TextSpan(
                            text: lang.S.of(context).noSupplier,
                          ),
                        ),
                      );
              }, error: (e, stack) {
                return Text(e.toString());
              }, loading: () {
                return const Center(child: CircularProgressIndicator());
              }),
            ),
            floatingActionButton: FloatingActionButton(
                backgroundColor: kMainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Icon(
                  Icons.add,
                  color: kWhite,
                ),
                onPressed: () async {
                  const AddParty().launch(context);
                }),
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
