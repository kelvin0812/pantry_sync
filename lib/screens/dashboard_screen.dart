import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/inventory_provider.dart';
import '../providers/fridge_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final fridge = context.watch<FridgeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantry Sync'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      body: inventory.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // === GREETING SECTION ===
                  _buildGreeting(context),
                  const SizedBox(height: 24),

                  // === FRIDGE CONTROL (Door + Temperature) ===
                  _buildFridgeControl(context, fridge),
                  const SizedBox(height: 20),

                  // === SIMPLE SUMMARY ===
                  _buildSimpleSummary(context, inventory),
                  const SizedBox(height: 20),

                  // === ENERGY INFO (simple) ===
                  _buildEnergySimple(context, fridge),
                  const SizedBox(height: 20),

                  // === QUICK TIP ===
                  _buildQuickTip(context, inventory),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ─── Greeting ───────────────────────────────────────────────
  Widget _buildGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Good Morning';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '🌤️';
    } else {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting $emoji',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Here\'s what\'s happening with your fridge today.',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ─── Fridge Control (Door + Temperature) ────────────────────
  Widget _buildFridgeControl(BuildContext context, FridgeProvider fridge) {
    final status = fridge.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Row(
              children: [
                Icon(Icons.kitchen, color: AppTheme.primaryGreen, size: 22),
                SizedBox(width: 10),
                Text(
                  'Fridge Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Door sensor - big and clear
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status.doorOpen
                    ? AppTheme.warningYellow.withValues(alpha: 0.1)
                    : AppTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status.doorOpen
                      ? AppTheme.warningYellow.withValues(alpha: 0.3)
                      : AppTheme.successGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    status.doorOpen
                        ? Icons.door_front_door
                        : Icons.door_sliding,
                    size: 36,
                    color: status.doorOpen
                        ? AppTheme.warningYellow
                        : AppTheme.successGreen,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.doorOpen ? 'Door is Open' : 'Door is Closed',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: status.doorOpen
                                ? AppTheme.warningYellow
                                : AppTheme.successGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.doorOpen
                              ? 'Camera will scan when you close it'
                              : 'Everything is secure ✓',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status dot
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: status.doorOpen
                          ? AppTheme.warningYellow
                          : AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Temperature row - simple and large
            Row(
              children: [
                Expanded(
                  child: _buildTempBox(
                    icon: Icons.thermostat,
                    label: 'Fridge',
                    value: '${status.fridgeTemperature.toStringAsFixed(1)}°C',
                    color: AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTempBox(
                    icon: Icons.severe_cold,
                    label: 'Freezer',
                    value: '${status.freezerTemperature.toStringAsFixed(1)}°C',
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTempBox(
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: '${status.humidity.toStringAsFixed(0)}%',
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  // ─── Simple Summary (what's in your fridge) ─────────────────
  Widget _buildSimpleSummary(
      BuildContext context, InventoryProvider inventory) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant_menu,
                    color: AppTheme.accentOrange, size: 22),
                SizedBox(width: 10),
                Text(
                  'What\'s in Your Fridge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Big number
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${inventory.itemCount}',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'items detected',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Macro summary - friendly labels
            Row(
              children: [
                _buildMacroChip(
                    '🥩', '${inventory.totalProtein.toStringAsFixed(0)}g',
                    'Protein'),
                const SizedBox(width: 8),
                _buildMacroChip(
                    '🍚', '${inventory.totalCarbs.toStringAsFixed(0)}g',
                    'Carbs'),
                const SizedBox(width: 8),
                _buildMacroChip(
                    '🧈', '${inventory.totalFat.toStringAsFixed(0)}g',
                    'Fats'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  '${inventory.totalCalories.toStringAsFixed(0)} calories available',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Energy (simple) ────────────────────────────────────────
  Widget _buildEnergySimple(BuildContext context, FridgeProvider fridge) {
    final status = fridge.status;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bolt,
                  color: AppTheme.accentOrange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Energy Usage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${status.energyUsageWatts.toStringAsFixed(0)}W now • ${status.dailyEnergyKwh.toStringAsFixed(1)} kWh today',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Eco mode indicator
            if (status.energySaveMode)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.eco, size: 14, color: AppTheme.successGreen),
                    SizedBox(width: 4),
                    Text(
                      'Eco',
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
      ),
    );
  }

  // ─── Quick Tip ──────────────────────────────────────────────
  Widget _buildQuickTip(BuildContext context, InventoryProvider inventory) {
    // Simple contextual tip
    String tip;
    IconData tipIcon;
    if (inventory.itemCount > 5) {
      tip = 'You have plenty of ingredients! Ask Chef AI for a recipe idea.';
      tipIcon = Icons.lightbulb_outline;
    } else if (inventory.itemCount > 0) {
      tip = 'Running low on items. Consider restocking soon.';
      tipIcon = Icons.info_outline;
    } else {
      tip = 'Your fridge is empty. Items will appear after the next scan.';
      tipIcon = Icons.kitchen;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(tipIcon, color: AppTheme.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
