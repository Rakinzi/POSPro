import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile_pos/constant.dart';
import 'package:mobile_pos/model/dashboard_overview_model.dart';

import 'chart_data.dart';

class DashboardChart extends StatefulWidget {
  const DashboardChart({super.key, required this.model}) ;

  final DashboardOverviewModel model;

  @override
  State<DashboardChart> createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    getData(widget.model);
  }

  void getData(DashboardOverviewModel model) {
    chartData = [];
    for (int i = 0; i < model.data!.sales!.length; i++) {
      chartData.add(ChartData(
        model.data!.sales![i].date!,
        model.data!.sales![i].amount!.toDouble(),
        model.data!.purchases![i].amount!.toDouble(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: chartData.length * 50.0, // Adjust width based on the number of data points
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(),
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _getBottomTitles(value, meta),
                              );
                            },
                            reservedSize: 42,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false, reservedSize: 20),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getLeftTitles,
                            reservedSize: _getLeftTitleReservedSize(),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: Color(0xffD1D5DB),
                            dashArray: [4, 4],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      barGroups: _buildBarGroups(),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 42),
                        child: CustomPaint(
                          size: Size(
                              chartData.length * 50.0 - _getLeftTitleReservedSize(), // Adjust to match the width of the BarChart exactly
                              0.1),
                          painter: DashedBarPainter(
                            barHeight: 1,
                            barColor: const Color(0xffD1D5DB),
                            dashWidth: 4,
                            dashSpace: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    double maxY = 0;
    for (var data in chartData) {
      maxY = maxY > data.y ? maxY : data.y;
      maxY = maxY > data.y1 ? maxY : data.y1;
    }
    return maxY + 10;
  }

  double _getLeftTitleReservedSize() {
    double maxY = _getMaxY();
    if (maxY < 999) {
      return 32;
    } else if (maxY < 1000) {
      return 35;
    } else if (maxY < 10000) {
      return 54;
    } else {
      return 50; // Add more cases if needed
    }
  }

  List<BarChartGroupData> _buildBarGroups() {
    return chartData.asMap().entries.map((entry) {
      int index = entry.key;
      ChartData data = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.y,
            color: Colors.green,
            width: 6,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          BarChartRodData(
            toY: data.y1,
            color: kMainColor,
            width: 6,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ],
        barsSpace: 8,
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff4D4D4D),
      fontSize: 12,
    );

    String text = chartData[value.toInt()].x;

    return SideTitleWidget(
      space: 8,
      meta: TitleMeta(
        min: meta.min,
        max: meta.max,
        parentAxisSize: meta.parentAxisSize,
        axisPosition: meta.axisPosition,
        appliedInterval: meta.appliedInterval,
        sideTitles: meta.sideTitles,
        formattedValue: meta.formattedValue,
        axisSide: meta.axisSide,
        rotationQuarterTurns: meta.rotationQuarterTurns,
      ),
      child: Text(text, style: style),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    // Skip the highest value (already handled in your code)
    double maxY = _getMaxY();
    if (value == maxY) {
      return const SizedBox.shrink();
    }

    // Format the number
    String formattedValue;
    if (value >= 1e9) {
      formattedValue = '${(value / 1e9).toStringAsFixed(1)}B';
    } else if (value >= 1e6) {
      formattedValue = '${(value / 1e6).toStringAsFixed(1)}M';
    } else if (value >= 1e3) {
      formattedValue = '${(value / 1e3).toStringAsFixed(1)}K';
    } else {
      formattedValue = value.toInt().toString();
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        formattedValue,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }
}

///---------------------------------dash line-------------------------------

class DashedBarPainter extends CustomPainter {
  final double barHeight;
  final Color barColor;
  final double dashWidth;
  final double dashSpace;

  DashedBarPainter({
    required this.barHeight,
    required this.barColor,
    this.dashWidth = 4.0,
    this.dashSpace = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = barHeight;

    final dashPath = Path();
    for (double i = 0; i < size.width; i += dashWidth + dashSpace) {
      dashPath.addRect(Rect.fromLTWH(i, 0, dashWidth, size.height));
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
