import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/categories_provider.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import '../theme/app_colors.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  String _selectedCategory = 'Wszystkie';
  String _sortBy = 'newest';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Recipe> _filter(List<Recipe> recipes, List<String> categories) {
    var list = [...recipes];
    final q = _search.toLowerCase().trim();

    if (q.isNotEmpty) {
      list = list.where((r) {
        return r.title.toLowerCase().contains(q) ||
            r.description.toLowerCase().contains(q) ||
            r.tags.any((t) => t.toLowerCase().contains(q)) ||
            r.ingredients.any((i) => i.toLowerCase().contains(q));
      }).toList();
    }

    if (_selectedCategory != 'Wszystkie') {
      list = list.where((r) => r.category == _selectedCategory).toList();
    }

    if (_sortBy == 'newest') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortBy == 'oldest') {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else if (_sortBy == 'az') {
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final recipesProvider = context.watch<RecipesProvider>();
    final categoriesProvider = context.watch<CategoriesProvider>();
    final allCategories = ['Wszystkie', ...categoriesProvider.categories];
    final filtered = _filter(recipesProvider.recipes, categoriesProvider.categories);

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            floating: true,
            snap: true,
            pinned: false,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: kOrangeGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Recipedia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: kOrangeGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Nowy', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: kCardBorder),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero text
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Twoje przepisy',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: kTextDark)),
                            SizedBox(height: 2),
                            Text('Przeglądaj, szukaj i gotuj!',
                                style: TextStyle(fontSize: 14, color: kTextMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: kOrangeLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${recipesProvider.recipes.length} przepisów',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFC2410C), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search + Sort row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kOrangeBorder),
                          ),
                          child: Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 12),
                                child: Icon(Icons.search, color: kOrangeMid, size: 20),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(fontSize: 14, color: kTextDark),
                                  decoration: const InputDecoration(
                                    hintText: 'Szukaj przepisu, składnika...',
                                    hintStyle: TextStyle(color: kTextMuted, fontSize: 13),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  ),
                                  onChanged: (v) => setState(() => _search = v),
                                ),
                              ),
                              if (_search.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() => _search = '');
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.close, color: kTextMuted, size: 18),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kOrangeBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            icon: const Icon(Icons.tune, size: 16, color: kOrangeMid),
                            style: const TextStyle(fontSize: 13, color: kTextBrown),
                            items: const [
                              DropdownMenuItem(value: 'newest', child: Text('Najnowsze')),
                              DropdownMenuItem(value: 'oldest', child: Text('Najstarsze')),
                              DropdownMenuItem(value: 'az', child: Text('A–Z')),
                            ],
                            onChanged: (v) => setState(() => _sortBy = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          // Category filter
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: index < allCategories.length - 1 ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected ? kOrangeGradient : null,
                          color: selected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? Colors.transparent : kOrangeBorder,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(color: kOrange.withOpacity(0.3), blurRadius: 8)]
                              : [],
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? Colors.white : kTextBrown,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Grid
          if (filtered.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final recipe = filtered[index];
                    return RecipeCard(
                      recipe: recipe,
                      onToggleFavorite: () =>
                          context.read<RecipesProvider>().toggleFavorite(recipe.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.72,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilter = _search.isNotEmpty || _selectedCategory != 'Wszystkie';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: kOrangeLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.restaurant, size: 40, color: kOrangeMid),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'Brak wyników' : 'Brak przepisów',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextDark),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Nie znaleziono przepisów pasujących do wyszukiwania.'
                : 'Dodaj swój pierwszy przepis!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: kTextMuted),
          ),
          const SizedBox(height: 20),
          if (hasFilter)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _search = '';
                  _selectedCategory = 'Wszystkie';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: kOrangeGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Wyczyść filtry',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}
