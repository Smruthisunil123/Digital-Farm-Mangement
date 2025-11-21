
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AuthorityDashboardScreen extends StatelessWidget {
  final String officerName;
  final String region;

  const AuthorityDashboardScreen({
    super.key,
    required this.officerName,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Authority Node"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Blockchain connection indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent),
            ),
            child: const Row(
              children: [
                Icon(Icons.link, size: 16, color: Colors.greenAccent),
                SizedBox(width: 5),
                Text("Ledger Live", style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Block Info Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue[50],
              child: Text(
                "Latest Block: #992834...ac2 | Region: $region",
                style: TextStyle(fontFamily: 'Courier', color: Colors.blue[900], fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            Text("Welcome, $officerName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 2. Stats Cards
            const Row(
              children: [
                Expanded(child: _StatCard(title: "Smart Contracts", value: "1,204", icon: Icons.description, color: Colors.purple)),
                SizedBox(width: 10),
                Expanded(child: _StatCard(title: "Antibiotic Alerts", value: "5", icon: Icons.warning_amber, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 30),

            // 3. ANTIBIOTIC USAGE PIE CHART
            const Text("Antibiotic Usage (Immutable Ledger Data)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
              child: Column(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          // REMOVED 'const' from here
                          PieChartSectionData(color: Colors.blue, value: 45, title: '45%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(color: Colors.orange, value: 30, title: '30%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          PieChartSectionData(color: Colors.teal, value: 25, title: '25%', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Legend
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _LegendItem(color: Colors.blue, text: "Amoxicillin"),
                      _LegendItem(color: Colors.orange, text: "Tetracycline"),
                      _LegendItem(color: Colors.teal, text: "Enrofloxacin"),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 4. DOSAGE TREND BAR CHART
            const Text("Dosage Violations Recorded on Chain", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  // REMOVED 'const' from gridData
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    // REMOVED 'const' from AxisTitles
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0: return const Text('Wk 1');
                            case 1: return const Text('Wk 2');
                            case 2: return const Text('Wk 3');
                            case 3: return const Text('Wk 4');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 2, color: Colors.blue[300])]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: Colors.blue[300])]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 12, color: Colors.red[400])]), // High Violation
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 3, color: Colors.blue[300])]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
