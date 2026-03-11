import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../widgets/recipe_card.dart';
import '../theme/app_colors.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipesProvider = context.watch<RecipesProvider>();
    final favorites = recipesProvider.recipes.where((r) => r.isFavorite).toList();

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white.withValues(alpha: 0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite, size: 20, color: Color(0xFFEF4444)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ulubione przepisy',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark)),
                    Text(
                      favorites.isEmpty
                          ? 'Nie masz jeszcze ulubionych'
                          : '${favorites.length} ulubionych przepisów',
                      style: const TextStyle(fontSize: 11, color: kTextMuted),
                    ),
                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: kCardBorder),
            ),
          ),
          if (favorites.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(Icons.favorite_border, size: 40, color: Color(0xFFFCA5A5)),
                    ),
                    const SizedBox(height: 16),
                    const Text('Brak ulubionych',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextDark)),
                    const SizedBox(height: 8),
                    const Text(
                      'Kliknij serduszko na karcie przepisu, aby dodać do ulubionych.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: kTextMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              sliver: SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final recipe = favorites[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15, top: 10), // ostepmiedzy kartami
                        child: RecipeCard(
                          recipe: recipe,
                          onToggleFavorite: () =>
                              context.read<RecipesProvider>().toggleFavorite(recipe.id),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(recipeId: recipe.id),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: favorites.length,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
