import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EnergyChartCard extends StatelessWidget {
  final double currentWatts;
  final double dailyKwh;
  final List<double> weeklyHistory;
  final bool energySaveMode;

  const EnergyChartCard({
    super.key,
    required this.currentWatts,
    required this.dailyKwh,
    required this.weeklyHistory,
    required this.energySaveMode,
  });

  @override
  Widget build(BuildContext context) {
    final weeklyTotal =
        weeklyHistory.fold(0.0, (sum, val) => sum + val);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppTheme.accentOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Energy Usage',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (energySaveMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco, size: 14,
                            color: AppTheme.successGreen),
                        SizedBox(width: 4),
                        Text(
                          'Eco Mode',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _buildStatColumn(
                  '${currentWatts.toStringAsFixed(0)}W',
                  'Current',
                  AppTheme.accentOrange,
                ),
                _buildStatColumn(
                  '${dailyKwh.toStringAsFixed(1)} kWh',
                  'Today',
                  AppTheme.infoBlue,
                ),
                _buildStatColumn(
                  '${weeklyTotal.toStringAsFixed(1)} kWh',
                  'This Week',
                  AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: weeklyHistory.reduce((a, b) => a > b ? a : b) * 1.3,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: weeklyHistory.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: entry.key == weeklyHistory.length - 1
                              ? AppTheme.primaryGreen
                              : AppTheme.primaryGreen.withValues(alpha: 0.4),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
