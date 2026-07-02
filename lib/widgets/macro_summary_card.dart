import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MacroSummaryCard extends StatefulWidget {
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalCalories;

  const MacroSummaryCard({
    super.key,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalCalories,
  });

  @override
  State<MacroSummaryCard> createState() => _MacroSummaryCardState();
}

class _MacroSummaryCardState extends State<MacroSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart_outline,
                    color: AppTheme.primaryGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pantry-Level Macros',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total nutrition available in your fridge',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return Row(
                  children: [
                    _buildMacroRing(
                      'Protein',
                      widget.totalProtein,
                      200, // daily target reference
                      AppTheme.errorRed,
                      Icons.fitness_center,
                    ),
                    _buildMacroRing(
                      'Carbs',
                      widget.totalCarbs,
                      300,
                      AppTheme.accentOrange,
                      Icons.grain,
                    ),
                    _buildMacroRing(
                      'Fat',
                      widget.totalFat,
                      100,
                      AppTheme.warningYellow,
                      Icons.water_drop,
                    ),
                    _buildMacroRing(
                      'Calories',
                      widget.totalCalories,
                      2500,
                      AppTheme.infoBlue,
                      Icons.local_fire_department,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRing(
      String label, double value, double max, Color color, IconData icon) {
    final ratio = (value / max).clamp(0.0, 1.0);
    final animatedRatio = ratio * _animation.value;

    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(
              painter: _RingPainter(
                progress: animatedRatio,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label == 'Calories'
                ? '${(value * _animation.value).toStringAsFixed(0)}'
                : '${(value * _animation.value).toStringAsFixed(0)}g',
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
            semanticsLabel: '$label: ${value.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    const strokeWidth = 5.0;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
