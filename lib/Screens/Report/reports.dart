import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_pos/Screens/Report/Screens/due_report_screen.dart';
import 'package:mobile_pos/Screens/Report/Screens/expense_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/expire_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/purchase_report.dart';
import 'package:mobile_pos/Screens/Report/Screens/sales_report_screen.dart';
import 'package:mobile_pos/Screens/stock_list/low_stock.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/generated/l10n.dart' as lang;
import 'package:nb_utils/nb_utils.dart';

import '../../GlobalComponents/glonal_popup.dart';
import '../Loss_Profit/loss_profit_screen.dart';
import '../stock_list/stock_list_main.dart';
import 'Screens/income_report.dart';
import 'Screens/purchase_return_report.dart';
import 'Screens/sales_return_report_screen.dart';

class Reports extends StatefulWidget {
  const Reports({super.key}) ;

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return GlobalPopup(
      child: Scaffold(
        backgroundColor: kWhite,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: Text(
            lang.S.of(context).reports,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ///__________Sales_report__________________________________________
                ReportCard(
                    pressed: () {
                      const SalesReportScreen().launch(context);
                    },
                    iconPath: 'assets/salesReport.svg',
                    title: lang.S.of(context).salesReport),
                const SizedBox(height: 16),

                ///___________Purchase_report______________________________________
                ReportCard(
                    pressed: () {
                      const PurchaseReportScreen().launch(context);
                    },
                    iconPath: 'assets/purchaseReport.svg',
                    title: lang.S.of(context).purchaseReport),
                const SizedBox(height: 16),

                ///___________Due_report____________________________________________
                ReportCard(
                    pressed: () {
                      const DueReportScreen().launch(context);
                    },
                    iconPath: 'assets/duereport.svg',
                    title: lang.S.of(context).dueReport),
                const SizedBox(height: 16),

                ///_______________Stock_report________________________________________________________________
                ReportCard(
                    pressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const StockList(
                                    isFromReport: true,
                                  )));
                    },
                    iconPath: 'assets/stock.svg',
                    //title: 'Stock Report'
                    title: lang.S.of(context).stockReport),
                const SizedBox(height: 16),

                ///_______________Low Stock________________________________________________________________
                ReportCard(
                    pressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LowStock(isFromReport: true)));
                    },
                    iconPath: 'assets/stock.svg',
                    //title: 'Stock Report'
                    title: 'Low Stock Report'),
                const SizedBox(height: 16),

                ///_______________Expired_report________________________________________________________________
                ReportCard(
                    pressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpiredList()));
                    },
                    iconPath: 'assets/expenseReport.svg',
                    title: lang.S.of(context).expiredList),
                const SizedBox(height: 16),

                ///_______________Loss/Profit________________________________________________________________
                ReportCard(
                    pressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LossProfitScreen()));
                    },
                    iconPath: 'assets/lossprofit.svg',
                    //title: 'Loss/Profit Report'
                    title: lang.S.of(context).lossProfitReport),
                const SizedBox(
                  height: 16,
                ),

                ///_______________Income_report________________________________________________________________
                ReportCard(
                  pressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const IncomeReport()));
                  },
                  iconPath: 'assets/incomeReport.svg',
                  // title: 'Income Report',
                  title: lang.S.of(context).incomeReport,
                ),
                const SizedBox(height: 16),

                ///__________________Expense Report____________________________________________________________
                ReportCard(
                  pressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseReport()));
                  },
                  iconPath: 'assets/expenseReport.svg',
                  //title: 'Expense Report'
                  title: lang.S.of(context).expenseReport,
                ),
                const SizedBox(height: 16),

                ///__________Sales_return_report__________________________________________
                ReportCard(
                  pressed: () {
                    const SalesReturnReportScreen().launch(context);
                  },
                  iconPath: 'assets/salesReport.svg',
                  // title: "Sales Return Report",
                  title: lang.S.of(context).salesReturnReport,
                ),
                const SizedBox(height: 16),

                ///___________Purchase_return_report______________________________________
                ReportCard(
                  pressed: () {
                    const PurchaseReturnReportScreen().launch(context);
                  },
                  iconPath: 'assets/purchaseReport.svg',
                  title: lang.S.of(context).purchaseReturnReport,
                  // title: 'Purchase Return Report',
                ),
                const SizedBox(height: 16),

                ///__________Deleted_Invoice_report______________________________________
                // ReportCard(
                //   pressed: () {
                //     const PurchaseReportScreen().launch(context);
                //   },
                //   iconPath: 'assets/purchaseReport.svg',
                //   title: 'Deleted Invoices',
                // ),
                // const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ReportCard extends StatelessWidget {
  ReportCard({
    super.key,
    required this.pressed,
    required this.iconPath,
    required this.title,
  }) ;

  final VoidCallback pressed;
  String iconPath, title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pressed,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: kWhite, boxShadow: [
          BoxShadow(color: const Color(0xff473232).withValues(alpha: 0.05), blurRadius: 8, spreadRadius: -1, offset: const Offset(0, 3)),
          BoxShadow(color: const Color(0xff0C1A4B).withValues(alpha: 0.24), blurRadius: 1)
        ]),
        child: ListTile(
          horizontalTitleGap: 16,
          visualDensity: const VisualDensity(horizontal: -4),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: SvgPicture.asset(
            iconPath,
            height: 38,
            width: 38,
          ),
          title: Text(
            title,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: kMainColor,
            size: 18,
          ),
        ),
      ),
    );
  }
}
