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

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<_CategoryTab> _categories = [
    _CategoryTab('All', Icons.grid_view_rounded, null),
    _CategoryTab('Protein', Icons.egg_outlined, '🥩'),
    _CategoryTab('Carbs', Icons.rice_bowl_outlined, '🍚'),
    _CategoryTab('Veggies', Icons.eco_outlined, '🥬'),
    _CategoryTab('Dairy', Icons.water_drop_outlined, '🥛'),
    _CategoryTab('Fruits', Icons.apple, '🍎'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FoodItem> _filter(List<FoodItem> items, int tabIndex) {
    var filtered = items;
    if (tabIndex > 0) {
      final cat = _categories[tabIndex].label;
      filtered = filtered.where((i) =>
          i.category.toLowerCase().contains(cat.toLowerCase())).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((i) =>
          i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Food',
            style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        actions: [
          if (inventory.isScanning)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: 'Scan Fridge',
              onPressed: () => inventory.scanLatestImage(),
            ),
        ],
      ),
      body: inventory.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 100),
                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search food...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),

                // Category tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primaryBlue,
                  tabAlignment: TabAlignment.start,
                  tabs: _categories.map((c) => Tab(
                    child: Row(
                      children: [
                        Icon(c.icon, size: 16),
                        const SizedBox(width: 6),
                        Text(c.label),
                      ],
                    ),
                  )).toList(),
                  onTap: (_) => setState(() {}),
                ),

                // Food list
                Expanded(
                  child: AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final items = _filter(
                          inventory.items, _tabController.index);
                      if (items.isEmpty) return _buildEmpty();
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length + 1, // +1 for recipe suggestion
                        itemBuilder: (ctx, i) {
                          if (i == items.length) {
                            return _buildRecipeSuggestion(items);
                          }
                          return _buildFoodCard(items[i]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFoodCard(FoodItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Food emoji
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCatColor(item.category).withValues(alpha: 0.1),
                    _getCatColor(item.category).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(_getEmoji(item.name, item.category),
                    style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('${item.quantity.toStringAsFixed(0)}g • ${item.category}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${item.totalCalories.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 17,
                        fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                const Text('cal', style: TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── DEFAULT RECIPE SUGGESTION ──────────────────────────────
  Widget _buildRecipeSuggestion(List<FoodItem> items) {
    if (items.isEmpty) return const SizedBox();
    final names = items.take(3).map((e) => e.name).join(', ');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🍳', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('Quick Recipe Idea', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue)),
            ],
          ),
          const SizedBox(height: 10),
          Text('With $names, you could make:',
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text(_generateRecipeName(items),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Tap Chef AI tab for full recipe →',
              style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
        ],
      ),
    );
  }

  String _generateRecipeName(List<FoodItem> items) {
    final hasProtein = items.any((i) => i.category == 'Protein');
    final hasCarbs = items.any((i) => i.category == 'Carbs');
    final hasVeg = items.any((i) => i.category == 'Vegetables');

    if (hasProtein && hasCarbs && hasVeg) return 'Stir-Fry Bowl';
    if (hasProtein && hasCarbs) return 'Protein Rice Bowl';
    if (hasProtein && hasVeg) return 'Grilled Protein & Veggies';
    if (hasProtein) return 'Simple Protein Plate';
    if (hasCarbs) return 'Quick Carb Bowl';
    return 'Chef\'s Special Mix';
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🍽️', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('No items found', style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w500)),
          SizedBox(height: 6),
          Text('Scan your fridge to detect food',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Color _getCatColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'protein': return AppTheme.errorRed;
      case 'carbs': return AppTheme.accentOrange;
      case 'vegetables': return AppTheme.successGreen;
      case 'dairy': return AppTheme.infoBlue;
      case 'fruits': return const Color(0xFFEC4899);
      case 'condiments': return AppTheme.warningYellow;
      default: return AppTheme.textSecondary;
    }
  }

  String _getEmoji(String name, String category) {
    final n = name.toLowerCase();
    if (n.contains('egg')) return '🥚';
    if (n.contains('rice')) return '🍚';
    if (n.contains('chicken')) return '🍗';
    if (n.contains('milk')) return '🥛';
    if (n.contains('butter')) return '🧈';
    if (n.contains('salmon') || n.contains('fish')) return '🐟';
    if (n.contains('beef') || n.contains('steak') || n.contains('pork')) return '🥩';
    if (n.contains('tofu')) return '🫘';
    if (n.contains('pepper') || n.contains('bell')) return '🫑';
    if (n.contains('onion') || n.contains('scallion')) return '🧅';
    if (n.contains('tomato')) return '🍅';
    if (n.contains('apple')) return '🍎';
    if (n.contains('banana')) return '🍌';
    if (n.contains('lemon')) return '🍋';
    if (n.contains('cheese')) return '🧀';
    if (n.contains('bread')) return '🍞';
    if (n.contains('sauce') || n.contains('soy')) return '🫙';
    if (n.contains('pizza')) return '🍕';
    if (n.contains('cake')) return '🎂';
    switch (category.toLowerCase()) {
      case 'protein': return '🥩';
      case 'carbs': return '🍚';
      case 'vegetables': return '🥬';
      case 'dairy': return '🥛';
      case 'fruits': return '🍎';
      default: return '🍽️';
    }
  }
}

class _CategoryTab {
  final String label;
  final IconData icon;
  final String? emoji;
  const _CategoryTab(this.label, this.icon, this.emoji);
}
