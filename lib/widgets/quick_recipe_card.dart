import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../services/ai_chef_service.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';

class QuickRecipeCard extends StatefulWidget {
  final List<FoodItem> inventory;

  const QuickRecipeCard({super.key, required this.inventory});

  @override
  State<QuickRecipeCard> createState() => _QuickRecipeCardState();
}

class _QuickRecipeCardState extends State<QuickRecipeCard> {
  Recipe? _recipe;
  bool _loading = false;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    setState(() => _loading = true);
    final recipe = await AiChefService().suggestRecipe(widget.inventory);
    if (mounted) {
      setState(() {
        _recipe = recipe;
        _loading = false;
      });
    }
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
                const Icon(Icons.auto_awesome,
                    color: AppTheme.accentOrange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Suggested Recipe',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadRecipe,
                  tooltip: 'New suggestion',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Based on what\'s in your fridge right now',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_recipe != null) ...[
              // Recipe title
              Text(
                _recipe!.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _recipe!.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),

              // Quick info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildChip(
                    Icons.timer,
                    '${_recipe!.totalTimeMinutes} min',
                  ),
                  _buildChip(
                    Icons.restaurant,
                    _recipe!.difficulty,
                  ),
                  _buildChip(
                    Icons.local_fire_department,
                    '${_recipe!.nutrition.calories.toStringAsFixed(0)} cal',
                  ),
                  _buildChip(
                    Icons.fitness_center,
                    '${_recipe!.nutrition.protein.toStringAsFixed(0)}g protein',
                  ),
                ],
              ),

              // Expandable steps
              const SizedBox(height: 12),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        _expanded ? 'Hide steps' : 'Show steps',
                        style: const TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),

              if (_expanded) ...[
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ...(_recipe!.ingredients.map((ing) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text('• $ing',
                          style: const TextStyle(fontSize: 13)),
                    ))),
                const SizedBox(height: 12),
                const Text(
                  'Steps:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                ...(_recipe!.steps.asMap().entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(
                          left: 8, bottom: 6),
                      child: Text(
                        '${entry.key + 1}. ${entry.value}',
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ))),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
