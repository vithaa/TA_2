import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GrafikPertumbuhanScreen extends StatelessWidget {
  const GrafikPertumbuhanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Data pertumbuhan 12 bulan
    final List<double> beratData = [70, 72, 68, 65, 67, 70, 66, 73, 69, 71, 74, 75];
    final List<double> tinggiData = [165, 170, 168, 171, 167, 169, 166, 174, 172, 170, 173, 175];

    // Bar chart group untuk setiap bulan
    final List<BarChartGroupData> barGroups = List.generate(12, (index) {
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: tinggiData[index],
            color: Colors.orange[700],
            width: 8,
          ),
          BarChartRodData(
            toY: beratData[index],
            color: Colors.orange[300],
            width: 8,
          ),
        ],
        barsSpace: 4,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Pertumbuhan'),
        backgroundColor: Colors.blue,
      ),
      backgroundColor: const Color(0xFFF7EDF9),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Tinggi Badan & Berat Badan (12 Bulan)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Scroll horizontal untuk grafik
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800, // Lebar yang cukup untuk menampung semua batang
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    maxY: 200,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text('${value.toInt()}'),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LegendItem(color: Colors.orange[700]!, text: 'Tinggi Badan'),
                const SizedBox(width: 20),
                LegendItem(color: Colors.orange[300]!, text: 'Berat Badan'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}
