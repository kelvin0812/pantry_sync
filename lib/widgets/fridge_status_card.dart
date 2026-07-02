import 'package:flutter/material.dart';

import '../models/fridge_status.dart';
import '../theme/app_theme.dart';

class FridgeStatusCard extends StatefulWidget {
  final FridgeStatus status;

  const FridgeStatusCard({super.key, required this.status});

  @override
  State<FridgeStatusCard> createState() => _FridgeStatusCardState();
}

class _FridgeStatusCardState extends State<FridgeStatusCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.status;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.thermostat,
                      color: AppTheme.infoBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fridge Status',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status.doorOpen
                          ? AppTheme.warningYellow.withValues(alpha: 0.15)
                          : AppTheme.successGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          status.doorOpen
                              ? Icons.door_front_door
                              : Icons.check_circle,
                          size: 14,
                          color: status.doorOpen
                              ? AppTheme.warningYellow
                              : AppTheme.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status.doorOpen ? 'Door Open' : 'All Good',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.doorOpen
                                ? AppTheme.warningYellow
                                : AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more,
                        color: AppTheme.textSecondary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusItem(
                    context,
                    Icons.thermostat,
                    '${status.fridgeTemperature.toStringAsFixed(1)}°C',
                    'Fridge',
                    AppTheme.infoBlue,
                  ),
                  _buildStatusItem(
                    context,
                    Icons.severe_cold,
                    '${status.freezerTemperature.toStringAsFixed(1)}°C',
                    'Freezer',
                    AppTheme.primaryGreen,
                  ),
                  _buildStatusItem(
                    context,
                    Icons.water_drop_outlined,
                    '${status.humidity.toStringAsFixed(0)}%',
                    'Humidity',
                    AppTheme.accentOrange,
                  ),
                  _buildStatusItem(
                    context,
                    Icons.speed,
                    '${status.compressorSpeed}%',
                    'Compressor',
                    AppTheme.textSecondary,
                  ),
                ],
              ),

              // Expandable details
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedDetails(status),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(FridgeStatus status) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Energy Save Mode',
            status.energySaveMode ? 'Active' : 'Off',
            status.energySaveMode
                ? AppTheme.successGreen
                : AppTheme.textSecondary,
          ),
          _buildDetailRow(
            'Last Updated',
            _formatTime(status.lastUpdated),
            AppTheme.textSecondary,
          ),
          _buildDetailRow(
            'Daily Energy',
            '${status.dailyEnergyKwh.toStringAsFixed(1)} kWh',
            AppTheme.accentOrange,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTemperatureGauge(
                  'Fridge',
                  status.fridgeTemperature,
                  1.0,
                  8.0,
                  AppTheme.infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTemperatureGauge(
                  'Freezer',
                  status.freezerTemperature,
                  -24.0,
                  -12.0,
                  AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureGauge(
      String label, double value, double min, double max, Color color) {
    final ratio = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildStatusItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
