import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class AnalyticsPieChart extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Map<String, double> dataMap;
  final Map<String, Color> colorMap;
  final Key? chartKey;

  const AnalyticsPieChart({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.dataMap,
    required this.colorMap,
    this.chartKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dataMap.isEmpty) return const SizedBox.shrink();
    return Column(
      key: chartKey,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PieChart(
          dataMap: dataMap,
          colorList: dataMap.keys
              .map((cat) => colorMap[cat] ?? Colors.grey)
              .toList(),
          chartType: ChartType.disc,
          chartRadius: 120,
          legendOptions: const LegendOptions(
            showLegends: true,
            legendPosition: LegendPosition.right,
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValuesInPercentage: true,
            showChartValues: true,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
