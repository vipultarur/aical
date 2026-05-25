import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:calcount/core/constants/app_routes.dart';
import 'package:calcount/core/constants/app_assets.dart';
import 'package:calcount/core/services/gemini_service.dart';
import 'package:calcount/core/services/local_storage_service.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/features/food_log/models/food_search_item.dart';
import 'package:calcount/features/food_log/presentation/widgets/food_search_result_tile.dart';
import 'package:calcount/features/food_log/presentation/widgets/food_detail_bottom_sheet.dart';
import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/common/models/meal_type.dart';
import 'package:calcount/common/providers/mock_data_provider.dart';
import 'package:calcount/features/dashboard/providers/dashboard_summary_provider.dart';
import 'package:calcount/features/food_log/presentation/widgets/meal_selector_bottom_sheet.dart';
import 'package:calcount/features/food_log/presentation/widgets/added_items_dialog.dart';
import 'package:calcount/features/food_log/presentation/widgets/food_search_shimmer_tile.dart';
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, this.initialSlot});

  final String? initialSlot;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  late final TextEditingController _searchController;
  late MealType _selectedSlot;
  String _searchQuery = '';
  String _selectedTab = 'All';

  // AI search results state
  List<FoodSearchItem> _aiResults = [];
  bool _isSearching = false;

  // Personalized suggestions (shown on 'All' tab by default)
  List<FoodSearchItem> _personalizedSuggestions = [];
  bool _isLoadingSuggestions = true;

  // Session-added food items
  final List<FoodEntry> _addedEntriesThisSession = [];

  // Custom foods from scanned items
  List<FoodSearchItem> _customFoods = [];

  // Debounce timer for AI search
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedSlot = MealType.values.firstWhere(
      (slot) => slot.name == widget.initialSlot,
      orElse: () => MealType.current(),
    );
    // Load personalized suggestions after first frame (so ref is available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersonalizedSuggestions();
      _loadCustomFoods();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPersonalizedSuggestions() async {
    if (!mounted) return;
    setState(() => _isLoadingSuggestions = true);

    final profile = ref.read(userProfileProvider);
    final macroTotals = ref.read(dashboardMacroTotalsProvider);

    final suggestions = await GeminiService.getPersonalizedSuggestions(
      goal: profile.mainGoal,
      activityLevel: profile.activityLevel,
      dietPrefs: profile.dietPrefs,
      calorieTarget: profile.calorieTarget,
      caloriesConsumed: macroTotals.calories,
      mealType: _selectedSlot == MealType.snacks
          ? 'Snack'
          : _selectedSlot.displayName,
      weight: profile.weight,
      weightUnit: profile.weightUnit,
      targetWeight: profile.targetWeight,
    );

    if (mounted) {
      setState(() {
        _personalizedSuggestions = suggestions;
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> _loadCustomFoods() async {
    final foods = await LocalStorageService.loadCustomFoods();
    if (mounted) {
      setState(() => _customFoods = foods);
    }
  }

  void _updateQuery(String query) {
    setState(() => _searchQuery = query);
    _searchDebounce?.cancel();
    if (query.length >= 2) {
      // Debounce: wait 500ms after the user stops typing before calling Gemini
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        _runAiSearch(query);
      });
    } else if (query.isEmpty) {
      setState(() => _aiResults = []);
    }
  }

  Future<void> _runAiSearch(String query) async {
    setState(() => _isSearching = true);
    final results = await GeminiService.searchFood(query);
    if (mounted && _searchQuery == query) {
      setState(() {
        _aiResults = results;
        _isSearching = false;
      });
    }
  }

  void _clearQuery() {
    _searchController.clear();
    _updateQuery('');
    setState(() {
      _aiResults = [];
      _isSearching = false;
    });
  }

  void _showMealSelectorBottomSheet() {
    MealSelectorBottomSheet.show(
      context: context,
      currentSlot: _selectedSlot,
      onSlotSelected: (slot) {
        setState(() {
          _selectedSlot = slot;
        });
        _loadPersonalizedSuggestions();
      },
    );
  }

  void _showAddedItemsDialog() {
    if (_addedEntriesThisSession.isEmpty) return;

    AddedItemsDialog.show(
      context: context,
      selectedSlot: _selectedSlot,
      addedEntries: _addedEntriesThisSession,
      onRemove: (index) {
        final entry = _addedEntriesThisSession[index];
        setState(() {
          _addedEntriesThisSession.removeAt(index);
          ref.read(foodLogProvider.notifier).removeFood(entry.id);
        });
      },
      onUpdate: (index, newEntry) {
        final oldEntry = _addedEntriesThisSession[index];
        setState(() {
          _addedEntriesThisSession.removeAt(index);
          _addedEntriesThisSession.insert(index, newEntry);
          ref.read(foodLogProvider.notifier).removeFood(oldEntry.id);
        });
      },
    );
  }

  List<FoodSearchItem> _getFilteredFoods(List<FoodEntry> allLogs) {
    // When searching, return AI query results
    if (_searchQuery.isNotEmpty) {
      return _aiResults;
    }

    // Build food items from logged entries for Recents/Starred/Customize tabs
    FoodSearchItem entryToSearchItem(FoodEntry e) => FoodSearchItem(
      name: e.name,
      brand: e.brand,
      calories: e.calories,
      protein: e.protein,
      carbs: e.carbs,
      fat: e.fat,
      fiber: e.fiber,
      servingAmount: e.servingAmount,
      servingUnit: e.servingUnit,
    );

    if (_selectedTab == 'Recents') {
      final seen = <String>{};
      return allLogs.reversed
          .where((e) => seen.add(e.name))
          .take(10)
          .map(entryToSearchItem)
          .toList();
    } else if (_selectedTab == 'Custom') {
      return _customFoods;
    }

    // 'All' tab — return personalized AI suggestions
    return _personalizedSuggestions;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allLogs = ref.watch(foodLogProvider);
    final filteredFoods = _getFilteredFoods(allLogs);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: GestureDetector(
          onTap: _showMealSelectorBottomSheet,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedSlot == MealType.snacks
                    ? 'Snack'
                    : _selectedSlot.displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.grey.shade400 : const Color(0xFF0F172A),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search field Row (Camera button is now in the bottom floating dock)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: _updateQuery,
                style: TextStyle(color: colors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.xCircle, size: 18),
                          onPressed: _clearQuery,
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? colors.surfaceContainerLowest
                      : const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Horizontal Filters Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['All', 'Custom', 'Recents'].map((tab) {
                  final isSelected = _selectedTab == tab;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = tab;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          Text(
                            tab,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? const Color(0xFF1E60D4)
                                  : (isDark
                                        ? Colors.grey.shade400
                                        : const Color(0xFF64748B)),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isSelected)
                            Container(
                              width: 16,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E60D4),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Food List
            Expanded(
              child: _buildFoodList(isDark, filteredFoods),
            ),
          ],
        ),
      ),
      // Floating Summary Bar and Camera Dock
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Capsule Container (floating pill)
              Expanded(
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Stats sections (counter + Added + calories + kcal)
                      Expanded(
                        child: GestureDetector(
                          onTap: _showAddedItemsDialog,
                          behavior: HitTestBehavior.opaque,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                // Item count bubble
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE8EDF5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_addedEntriesThisSession.length}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Added',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Calorie bubble
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_addedEntriesThisSession.fold(0, (sum, e) => sum + e.calories)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'kcal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Done Checkmark circular button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF22C55E),
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                color: Color(0xFF15803D),
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),




                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Floating Action Button for Barcode Scanner
              GestureDetector(
                onTap: () => context.push(AppRoutes.barcodeScanner),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.cameraButton,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList(bool isDark, List<FoodSearchItem> foods) {
    // Show searching indicator for explicit queries
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E60D4)),
              strokeCap: StrokeCap.round,
            ),
            SizedBox(height: 12),
            Text(
              'Searching with AI...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Show loading shimmer for 'All' tab initial suggestions
    if (_isLoadingSuggestions && _selectedTab == 'All' && _searchQuery.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.sparkles,
                  size: 15,
                  color: Color(0xFF1E60D4),
                ),
                const SizedBox(width: 6),
                Text(
                  'Generating personalized picks...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, i) => const FoodSearchShimmerTile(),
            ),
          ),
        ],
      );
    }

    // Empty state for tabs other than 'All' or for failed search
    if (foods.isEmpty) {
      String message;
      IconData icon;
      if (_searchQuery.isNotEmpty) {
        message = 'No results for "$_searchQuery"\nTry a different keyword';
        icon = LucideIcons.searchX;
      } else if (_selectedTab == 'Recents') {
        message = 'No recent foods yet\nStart logging meals to see them here';
        icon = LucideIcons.clock;
      } else if (_selectedTab == 'Custom') {
        message = 'No scanned foods yet\nUse the camera to scan barcodes,\nphotos, or ingredients';
        icon = LucideIcons.camera;
      } else {
        message = 'Could not load suggestions\nCheck your connection and retry';
        icon = LucideIcons.wifiOff;
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              if (_selectedTab == 'All' && _searchQuery.isEmpty) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _loadPersonalizedSuggestions,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E60D4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.refreshCw, size: 14, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Try again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Header label
    final String headerLabel;
    if (_searchQuery.isNotEmpty) {
      headerLabel = '${foods.length} results for "$_searchQuery"';
    } else if (_selectedTab == 'All') {
      headerLabel = 'Recommended for You  ✦ AI';
    } else if (_selectedTab == 'Recents') {
      headerLabel = 'Recent Foods';
    } else if (_selectedTab == 'Custom') {
      headerLabel = 'Scanned Foods  📷';
    } else {
      headerLabel = 'Custom Foods';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              if (_selectedTab == 'All' && _searchQuery.isEmpty)
                const Icon(
                  LucideIcons.sparkles,
                  size: 14,
                  color: Color(0xFF1E60D4),
                ),
              if (_selectedTab == 'All' && _searchQuery.isEmpty)
                const SizedBox(width: 5),
              Text(
                headerLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
              ),
              if (_selectedTab == 'All' && _searchQuery.isEmpty) ...[
                const Spacer(),
                GestureDetector(
                  onTap: _loadPersonalizedSuggestions,
                  child: Icon(
                    LucideIcons.refreshCw,
                    size: 14,
                    color: isDark
                        ? Colors.grey.shade500
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Food list
        Expanded(
          child: ListView.builder(
            itemCount: foods.length,
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 4,
              bottom: 90,
            ),
            itemBuilder: (context, index) {
              final item = foods[index];
              return FoodSearchResultTile(
                item: item,
                onTap: () => context.push(
                  AppRoutes.foodDetail(item.name),
                  extra: item,
                ),
                onAdd: () async {
                  final entry = await FoodDetailBottomSheet.show(
                    context,
                    item,
                    _selectedSlot,
                  );
                  if (entry != null) {
                    setState(() {
                      _addedEntriesThisSession.add(entry);
                    });
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

}
