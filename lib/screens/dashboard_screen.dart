import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../providers/fridge_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final fridge = context.watch<FridgeProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pantry Sync',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: inventory.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(top: 100, bottom: 24),
              children: [
                // ═══ LIVE FRIDGE PHOTO ═══
                _buildLivePhoto(context),
                const SizedBox(height: 20),

                // ═══ DOOR STATUS ═══
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildDoorStatus(fridge),
                ),
                const SizedBox(height: 20),

                // ═══ SENSOR CHART (4 params) ═══
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSensorChart(fridge),
                ),
                const SizedBox(height: 20),

                // ═══ FRIDGE & FREEZER MODE ═══
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildFridgeModes(fridge),
                ),
                const SizedBox(height: 20),

                // ═══ ENERGY USAGE CHART ═══
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildEnergyChart(fridge),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  // ─── LIVE FRIDGE PHOTO ──────────────────────────────────────
  Widget _buildLivePhoto(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
        ),
        child: Stack(
          children: [
            // Placeholder — replace with real image from Supabase Storage
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded,
                      size: 48, color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    'Live Fridge View',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Photo updates on each door close',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Live badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.white),
                    SizedBox(width: 4),
                    Text('LIVE', style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DOOR STATUS ────────────────────────────────────────────
  Widget _buildDoorStatus(FridgeProvider fridge) {
    final isOpen = fridge.status.doorOpen;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isOpen
            ? AppTheme.warningYellow.withValues(alpha: 0.08)
            : AppTheme.successGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? AppTheme.warningYellow.withValues(alpha: 0.3)
              : AppTheme.successGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isOpen ? AppTheme.warningYellow : AppTheme.successGreen)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOpen ? Icons.door_front_door : Icons.door_sliding,
              size: 28,
              color: isOpen ? AppTheme.warningYellow : AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOpen ? 'Door Opened' : 'Door Closed',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isOpen ? AppTheme.warningYellow : AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOpen ? 'Camera scanning...' : 'Everything secure ✓',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen ? AppTheme.warningYellow : AppTheme.successGreen,
              boxShadow: [
                BoxShadow(
                  color: (isOpen ? AppTheme.warningYellow : AppTheme.successGreen)
                      .withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── INTERACTIVE SENSOR CHART (Voltage, Pressure, Temp, Humidity) ───
  Widget _buildSensorChart(FridgeProvider fridge) {
    final status = fridge.status;
    // Mock sensor values for demonstration
    final voltage = 12.2; // Volts
    final pressure = 1.2; // Bar (compressor)
    final temp = status.fridgeTemperature;
    final humid = status.humidity;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Sensor Readings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),

            // 4 sensor gauges
            Row(
              children: [
                _buildGauge('⚡ Voltage', '${voltage.toStringAsFixed(1)}V',
                    voltage / 15, AppTheme.accentCyan),
                const SizedBox(width: 10),
                _buildGauge('🔵 Pressure', '${pressure.toStringAsFixed(1)} bar',
                    pressure / 3, AppTheme.primaryBlue),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGauge('🌡️ Temp', '${temp.toStringAsFixed(1)}°C',
                    ((temp + 5) / 15).clamp(0, 1), AppTheme.infoBlue),
                const SizedBox(width: 10),
                _buildGauge('💧 Humidity', '${humid.toStringAsFixed(0)}%',
                    humid / 100, AppTheme.lightBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String label, String value, double progress, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── FRIDGE & FREEZER MODE ──────────────────────────────────
  Widget _buildFridgeModes(FridgeProvider fridge) {
    final status = fridge.status;
    return Row(
      children: [
        Expanded(
          child: _buildModeCard(
            icon: Icons.thermostat,
            title: 'Fridge',
            value: '${status.fridgeTemperature.toStringAsFixed(1)}°C',
            subtitle: 'Normal Mode',
            color: AppTheme.infoBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModeCard(
            icon: Icons.severe_cold,
            title: 'Freezer',
            value: '${status.freezerTemperature.toStringAsFixed(1)}°C',
            subtitle: status.energySaveMode ? 'Eco Mode' : 'Normal Mode',
            color: AppTheme.accentCyan,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(
            fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(
            fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  // ─── ENERGY USAGE CHART ─────────────────────────────────────
  Widget _buildEnergyChart(FridgeProvider fridge) {
    final history = fridge.energyHistory;
    final weeklyTotal = history.fold(0.0, (sum, v) => sum + v);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.lightGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Energy Usage',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${weeklyTotal.toStringAsFixed(1)} kWh',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
                    const Text('this week',
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bar chart
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: history.reduce((a, b) => a > b ? a : b) * 1.3,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(2)} kWh',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(days[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: history.asMap().entries.map((entry) {
                    final isToday = entry.key == history.length - 1;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          gradient: isToday
                              ? const LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                                )
                              : null,
                          color: isToday ? null : AppTheme.primaryBlue.withValues(alpha: 0.25),
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
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
}
