import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TestNumericAxisChart extends StatefulWidget {
  const TestNumericAxisChart({super.key}) ;

  @override
  State<TestNumericAxisChart> createState() => _TestNumericAxisChartState();
}

class _TestNumericAxisChartState extends State<TestNumericAxisChart> {
  final List<ChartData> chartData = [
    ChartData('Sat', 20000, 15000),
    ChartData('Sun', 10000, 25000),
    ChartData('Mon', 5000, 5000),
    ChartData('Tues', 45000, 35000),
    ChartData('Wed', 25000, 30000),
    ChartData('Thurs', 20000, 10000),
    ChartData('Fri', 25000, 20000),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 50000,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _getBottomTitles,
                    reservedSize: 42,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _getLeftTitles,
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(
                    color: Color(0xffD1D5DB),
                    dashArray: [5, 5],
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: _buildBarGroups(),
            ),
          ),
        ),
      ),
    );
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
            width: 10,
            borderRadius: BorderRadius.circular(0),
          ),
          BarChartRodData(
            toY: data.y1,
            color: Colors.red,
            width: 10,
            borderRadius: BorderRadius.circular(0),
          ),
        ],
        barsSpace: 10,
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final style = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );

    String text = chartData[value.toInt()].x;

    return SideTitleWidget(
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
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    return SideTitleWidget(
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
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y1);

  final String x;
  final double y;
  final double y1;
}
