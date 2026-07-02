import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  List<FoodItem> _filteredItems(List<FoodItem> items) {
    var filtered = items;
    if (_selectedCategory != null) {
      filtered =
          filtered.where((item) => item.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fridge Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Scan Fridge',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Scanning your fridge...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: inventory.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, inventory),
    );
  }

  Widget _buildBody(BuildContext context, InventoryProvider inventory) {
    final categories = inventory.itemsByCategory.keys.toList();
    final filteredItems = _filteredItems(inventory.items);

    return Column(
      children: [
        // Search bar - large and friendly
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search for food...',
              hintStyle: const TextStyle(fontSize: 16),
              prefixIcon: const Icon(Icons.search,
                  color: AppTheme.textSecondary, size: 24),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 22),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),

        // Category filter chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterChip(null, 'All', inventory.itemCount),
              ...categories.map((cat) => _buildFilterChip(
                  cat, cat, inventory.itemsByCategory[cat]!.length)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Items list
        Expanded(
          child: filteredItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(context, filteredItems[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String? category, String label, int count) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        selectedColor: AppTheme.primaryGreen,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? AppTheme.primaryGreen
                : const Color(0xFFE5E7EB),
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = isSelected ? null : category;
          });
        },
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, FoodItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetail(context, item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Food image/emoji - large and visual
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.category)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _getFoodEmoji(item.name, item.category),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Food info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity.toStringAsFixed(0)}g • ${item.category}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.totalCalories.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                  const Text(
                    'cal',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.75,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Food emoji + name
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(item.category)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _getFoodEmoji(item.name, item.category),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.category} • ${item.quantity.toStringAsFixed(0)}g',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Detection time
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Detected ${_formatAge(item.detectedAt)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Nutrition title
                const Text(
                  'Nutrition',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 16),

                // Nutrition bars - big and readable
                _buildNutritionRow(
                    '🥩 Protein', item.totalProtein, 'g', AppTheme.errorRed),
                const SizedBox(height: 12),
                _buildNutritionRow(
                    '🍚 Carbs', item.totalCarbs, 'g', AppTheme.accentOrange),
                const SizedBox(height: 12),
                _buildNutritionRow(
                    '🧈 Fat', item.totalFat, 'g', AppTheme.warningYellow),
                const SizedBox(height: 12),
                _buildNutritionRow(
                    '🔥 Calories', item.totalCalories, 'cal', AppTheme.infoBlue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionRow(
      String label, double value, String unit, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / (unit == 'cal' ? 800 : 100)).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            '${value.toStringAsFixed(1)} $unit',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _formatAge(DateTime detected) {
    final diff = DateTime.now().difference(detected);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search'
                : 'Items appear after your fridge is scanned',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Maps food names to realistic emojis
  String _getFoodEmoji(String name, String category) {
    final lower = name.toLowerCase();
    // Specific items
    if (lower.contains('egg')) return '🥚';
    if (lower.contains('rice')) return '🍚';
    if (lower.contains('chicken')) return '🍗';
    if (lower.contains('milk')) return '🥛';
    if (lower.contains('butter')) return '🧈';
    if (lower.contains('cheese')) return '🧀';
    if (lower.contains('bread')) return '🍞';
    if (lower.contains('apple')) return '🍎';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('orange')) return '🍊';
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('pepper') || lower.contains('bell')) return '🫑';
    if (lower.contains('onion') || lower.contains('scallion')) return '🧅';
    if (lower.contains('carrot')) return '🥕';
    if (lower.contains('broccoli')) return '🥦';
    if (lower.contains('fish') || lower.contains('salmon')) return '🐟';
    if (lower.contains('beef') || lower.contains('steak')) return '🥩';
    if (lower.contains('pork')) return '🥓';
    if (lower.contains('soy') || lower.contains('sauce')) return '🫙';
    if (lower.contains('yogurt')) return '🫙';
    if (lower.contains('water')) return '💧';
    if (lower.contains('juice')) return '🧃';

    // Category fallback
    switch (category.toLowerCase()) {
      case 'protein':
        return '🥩';
      case 'carbs':
        return '🍚';
      case 'vegetables':
        return '🥬';
      case 'dairy':
        return '🥛';
      case 'condiments':
        return '🫙';
      case 'fruits':
        return '🍎';
      default:
        return '🍽️';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'protein':
        return AppTheme.errorRed;
      case 'carbs':
        return AppTheme.accentOrange;
      case 'vegetables':
        return AppTheme.successGreen;
      case 'dairy':
        return AppTheme.infoBlue;
      case 'condiments':
        return AppTheme.warningYellow;
      case 'fruits':
        return const Color(0xFFEC4899);
      default:
        return AppTheme.textSecondary;
    }
  }
}
