// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mobile_pos/Screens/warehouse/add_new_warehouse.dart';
// import 'package:mobile_pos/Screens/warehouse/tab_item/transfer_list.dart';
// import 'package:mobile_pos/Screens/warehouse/warehouse_model/warehouse_list_model.dart';
// import 'package:mobile_pos/Screens/warehouse/warehouse_provider/warehouse_provider.dart';
// import 'package:mobile_pos/Screens/warehouse/warehouse_repo/warehouse_repo.dart';
// import 'package:mobile_pos/constant.dart';
// import 'package:mobile_pos/currency.dart';
//
// class WarehouseScreen extends ConsumerStatefulWidget {
//   const WarehouseScreen({super.key});
//   @override
//   ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
// }
//
// class _WarehouseScreenState extends ConsumerState<WarehouseScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final _theme = Theme.of(context);
//     final warehouse = ref.watch(fetchWarehouseListProvider);
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: kWhite,
//         appBar: AppBar(
//           title: Text('Warehouse'),
//           centerTitle: true,
//           bottom: PreferredSize(
//               preferredSize: Size.fromHeight(45),
//               child: Column(
//                 children: [
//                   Divider(
//                     height: 2,
//                     color: kBackgroundColor,
//                   ),
//                   Theme(
//                     data: _theme.copyWith(
//                       tabBarTheme: TabBarThemeData(dividerColor: kBackgroundColor),
//                     ),
//                     child: TabBar(
//                         labelStyle: _theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                         labelColor: Colors.red,
//                         unselectedLabelColor: kPeraColor,
//                         indicatorSize: TabBarIndicatorSize.tab,
//                         tabs: [
//                           Tab(
//                             text: 'Warehouse List',
//                           ),
//                           Tab(
//                             text: 'Transfer List',
//                           )
//                         ]),
//                   ),
//                 ],
//               )),
//         ),
//         body: TabBarView(children: [
//           warehouse.when(
//             data: (snapshot) {
//               return snapshot.data?.isNotEmpty ?? false
//                   ? ListView.separated(
//                       padding: EdgeInsets.zero,
//                       itemBuilder: (_, index) {
//                         final warehouseList = snapshot.data?[index];
//                         return ListTile(
//                           onTap: () {
//                             showEditDeletePopUp(
//                                 context: context,
//                                 item: {
//                                   "Name": warehouseList?.name?.toString() ?? 'n/a',
//                                   "Phone": warehouseList?.phone?.toString() ?? 'n/a',
//                                   "Email": warehouseList?.email?.toString() ?? 'n/a',
//                                   "Address": warehouseList?.address?.toString() ?? 'n/a',
//                                   // "Category": "120",
//                                   "Stock Qty": warehouseList?.totalQuantity?.toString() ?? '0',
//                                   "Stock Value": "$currency${warehouseList?.totalValue?.toString() ?? '0'}",
//                                 },
//                                 editData: warehouseList,
//                                 ref: ref);
//                           },
//                           visualDensity: VisualDensity(horizontal: -4, vertical: -4),
//                           title: Padding(
//                             padding: const EdgeInsets.only(bottom: 6),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   warehouseList?.name?.toString() ?? '',
//                                   style: _theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   "$currency${warehouseList?.totalValue?.toString() ?? '0'}",
//                                   style: _theme.textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                           subtitle: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 warehouseList?.phone?.toString() ?? 'n/a',
//                                 style: _theme.textTheme.bodyMedium?.copyWith(
//                                   color: kPeraColor,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 'Stock Value',
//                                 style: _theme.textTheme.bodyMedium?.copyWith(
//                                   color: kPeraColor,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                       separatorBuilder: (_, __) => Divider(
//                             color: kBackgroundColor,
//                             height: 2,
//                           ),
//                       itemCount: snapshot.data?.length ?? 0)
//                   : emptyWidget(_theme);
//             },
//             error: (e, stack) => Center(child: Text(e.toString())),
//             loading: () => const Center(child: CircularProgressIndicator()),
//           ),
//           ListView.separated(
//               padding: EdgeInsets.zero,
//               itemBuilder: (_, index) {
//                 return transferWidget(
//                   invoiceNumber: transferList[index]['inv'] ?? 'n/a',
//                   date: transferList[index]['date'] ?? 'n/a',
//                   stockValue: transferList[index]['stock'] ?? 'n/a',
//                   quantity: transferList[index]['quantity'] ?? 'n/a',
//                   from: transferList[index]['from'] ?? 'n/a',
//                   to: transferList[index]['to'] ?? 'n/a',
//                   context: context,
//                 );
//               },
//               separatorBuilder: (_, __) => Divider(
//                     color: kBackgroundColor,
//                     height: 2,
//                   ),
//               itemCount: warehouseList.length),
//         ]),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//         floatingActionButton: Container(
//           height: 48,
//           width: 190,
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0xFFC52127).withValues(alpha: 0.2), // #C5212733 (33 is ~20% opacity)
//                 offset: Offset(0, 11),
//                 blurRadius: 14,
//                 spreadRadius: 0,
//               ),
//             ],
//           ),
//           child: FloatingActionButton(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadiusGeometry.circular(8),
//             ),
//             isExtended: true,
//             backgroundColor: kMainColor,
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewWarehouse()));
//             },
//             child: Text(
//               '+ Add Warehouse',
//               style: _theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // empty widget
//   Column emptyWidget(ThemeData _theme) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         SizedBox(height: 50),
//         SvgPicture.asset(
//           width: 319,
//           height: 250,
//           'images/empty_image.svg',
//         ),
//         SizedBox(height: 30),
//         Text(
//           'Ooph... it\'s empty in here',
//           style: _theme.textTheme.bodyMedium?.copyWith(
//             color: kTitleColor,
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Text(
//           'Add some warehouse first',
//           style: _theme.textTheme.bodyMedium?.copyWith(
//             color: Color(0xff4B5563),
//             fontSize: 16,
//             fontWeight: FontWeight.w400,
//           ),
//         )
//       ],
//     );
//   }
//
//   List<Map<String, String>> transferList = [
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//     {"inv": "65324", "date": "15 Jan 2025 10:35AM", "from": "Warehouse 1", "to": "Warehouse 2", "quantity": "30", "stock": "\$6000.00"},
//   ];
//
//   List<Map<String, String>> warehouseList = [
//     {
//       "title": "Warehouse 1",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 2",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 3",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 4",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 5",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 6",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 7",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 8",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 9",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//     {
//       "title": "Warehouse 10",
//       "amount": "\$5,00,000",
//       "phone": "017123456789",
//     },
//   ];
// }
//
// Future<void> showEditDeletePopUp({required BuildContext context, required Map<String, String> item, Data? editData, required WidgetRef ref}) async {
//   final _theme = Theme.of(context);
//   return await showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext dialogContext) {
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.all(
//                 Radius.circular(8),
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: EdgeInsetsDirectional.only(start: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'View Details',
//                         style: _theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 18,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () => Navigator.pop(context),
//                         icon: Icon(Icons.close, size: 18),
//                       )
//                     ],
//                   ),
//                 ),
//                 Divider(color: kBorderColor, height: 1),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Column(
//                     children: item.entries.map((entry) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 4.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Flexible(
//                               fit: FlexFit.tight,
//                               flex: 2,
//                               child: Text(
//                                 '${entry.key} ',
//                                 style: _theme.textTheme.bodyLarge?.copyWith(
//                                   color: kNeutral800,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Flexible(
//                               fit: FlexFit.tight,
//                               flex: 4,
//                               child: Text(
//                                 ': ${entry.value}',
//                                 style: _theme.textTheme.bodyLarge,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () async {
//                             await Future.delayed(Duration.zero);
//                             WarehouseRepo repo = WarehouseRepo();
//                             bool success;
//                             success = await repo.deleteWarehouse(
//                               id: editData?.id.toString() ?? '',
//                             );
//                             if (success) {
//                               ref.invalidate(fetchWarehouseListProvider);
//                               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted Successfully')));
//                               Navigator.pop(context);
//                             }
//                           },
//                           child: Text('Delete'),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             Navigator.pop(context);
//                             await Future.delayed(Duration.zero);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => AddNewWarehouse(editData: editData),
//                               ),
//                             );
//                           },
//                           child: Text('Edit'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
