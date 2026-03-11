import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../theme/app_colors.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final Set<int> _checkedSteps = {};
  final Set<int> _checkedIngredients = {};
  bool _confirmDelete = false;
  bool _addedToCart = false;

  void _toggleStep(int i) => setState(() {
        _checkedSteps.contains(i)
            ? _checkedSteps.remove(i)
            : _checkedSteps.add(i);
      });

  void _toggleIngredient(int i) => setState(() {
        _checkedIngredients.contains(i)
            ? _checkedIngredients.remove(i)
            : _checkedIngredients.add(i);
      });

  @override
  Widget build(BuildContext context) {
    final recipesProvider = context.watch<RecipesProvider>();
    final recipe = recipesProvider.getRecipe(widget.recipeId);

    if (recipe == null) {
      return const Scaffold(
        backgroundColor: kBgLight,
        body: Center(child: Text('Przepis nie znaleziony')),
      );
    }

    final stepProgress =
        recipe.steps.isEmpty ? 1.0 : _checkedSteps.length / recipe.steps.length;

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: kTextDark),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => recipesProvider.toggleFavorite(recipe.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: recipe.isFavorite
                        ? const Color(0xFFEF4444)
                        : kTextMuted,
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(recipe.image),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + title
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kOrangeLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.categories.join(' • '),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC2410C),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(recipe.title,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: kTextDark)),
                  const SizedBox(height: 8),
                  Text(recipe.description,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF7C5C4E), height: 1.6)),
                  const SizedBox(height: 16),

                  // Stats grid
                  DecoratedBox(

                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xffffffff)),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(5),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 15,
                        childAspectRatio: 2,
                        children: [
                          _statCard(Icons.access_time, 'Przygotowanie',
                              formatTime(recipe.prepTime), kOrange),
                          _statCard(Icons.timer_outlined, 'Gotowanie',
                              formatTime(recipe.cookTime), kOrange),
                          _statCard(Icons.people_outline, 'Porcje',
                              '${recipe.servings} os.', kOrange),
                          _statCard(
                              Icons.restaurant_menu,
                              'Trudność',
                              recipe.difficulty,
                              difficultyColor(recipe.difficulty)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.edit_outlined,
                          label: 'Edytuj',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    RecipeFormScreen(recipeId: recipe.id)),
                          ),
                          gradient: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          icon: _confirmDelete
                              ? Icons.warning_amber
                              : Icons.delete_outline,
                          label: _confirmDelete ? 'Potwierdź' : 'Usuń',
                          onTap: () {
                            if (_confirmDelete) {
                              recipesProvider.deleteRecipe(recipe.id);
                              Navigator.of(context).pop();
                            } else {
                              setState(() => _confirmDelete = true);
                              Future.delayed(
                                  const Duration(seconds: 4),
                                  () => mounted
                                      ? setState(() => _confirmDelete = false)
                                      : null);
                            }
                          },
                          color: _confirmDelete
                              ? const Color(0xFFDC2626)
                              : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Ingredients section
                  _sectionCard(
                    header: Row(
                      children: [
                        const Text('Składniki',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kTextDark)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kOrangeLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${recipe.ingredients.length} pozycji',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFFC2410C))),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            final shoppingProvider =
                                context.read<ShoppingListProvider>();
                            final toAdd = recipe.ingredients
                                .asMap()
                                .entries
                                .where(
                                    (e) => !_checkedIngredients.contains(e.key))
                                .map((e) => e.value)
                                .toList();
                            shoppingProvider.addItems(
                              toAdd,
                              fromRecipeId: recipe.id,
                              fromRecipeName: recipe.title,
                            );
                            setState(() => _addedToCart = true);
                            Future.delayed(
                                const Duration(seconds: 3),
                                () => mounted
                                    ? setState(() => _addedToCart = false)
                                    : null);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: _addedToCart ? null : kOrangeGradient,
                              color:
                                  _addedToCart ? const Color(0xFFF0FDF4) : null,
                              borderRadius: BorderRadius.circular(10),
                              border: _addedToCart
                                  ? Border.all(color: const Color(0xFF86EFAC))
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _addedToCart
                                      ? Icons.check
                                      : Icons.shopping_cart_outlined,
                                  size: 14,
                                  color: _addedToCart
                                      ? const Color(0xFF16A34A)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _addedToCart ? 'Dodano!' : 'Do listy',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _addedToCart
                                        ? const Color(0xFF16A34A)
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: recipe.ingredients.asMap().entries.map((e) {
                      final i = e.key;
                      final ing = e.value;
                      final checked = _checkedIngredients.contains(i);
                      return _listItem(
                        onTap: () => _toggleIngredient(i),
                        checked: checked,
                        text: ing,
                        number: null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Steps section
                  _sectionCard(
                    header: Row(
                      children: [
                        const Text('Przygotowanie',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: kTextDark)),
                        const Spacer(),
                        Text(
                          '${_checkedSteps.length}/${recipe.steps.length} kroków',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFC2410C)),
                        ),
                      ],
                    ),
                    extraHeader: Column(
                      children: [
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: stepProgress,
                            backgroundColor: kOrangeBorder,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                kDarkOrange),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                    children: [
                      ...recipe.steps.asMap().entries.map((e) {
                        final i = e.key;
                        final step = e.value;
                        final checked = _checkedSteps.contains(i);
                        return _listItem(
                          onTap: () => _toggleStep(i),
                          checked: checked,
                          text: step,
                          number: i + 1,
                        );
                      }),
                      if (_checkedSteps.length == recipe.steps.length &&
                          recipe.steps.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('🎉 Gotowe! Smacznego!',
                                style: TextStyle(
                                    color: Color(0xFF16A34A),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kOrangeLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 8, color: kTextMuted),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: color),
                textAlign: TextAlign.center,
                maxLines: 1),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool gradient = false,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient ? kOrangeGradient : null,
          color: gradient ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: gradient ? null : Border.all(color: kOrangeBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18, color: gradient ? Colors.white : color ?? kTextMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: gradient ? Colors.white : color ?? kTextMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required Widget header,
    Widget? extraHeader,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          if (extraHeader != null) extraHeader,
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _listItem({
    required VoidCallback onTap,
    required bool checked,
    required String text,
    int? number,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFF0FDF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (number != null)
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  gradient: checked ? null : kOrangeGradient,
                  color: checked ? const Color(0xFF22C55E) : null,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: checked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('$number',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 2),
                child: Icon(
                  checked ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: checked ? const Color(0xFF22C55E) : kOrangeBorder,
                ),
              ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: checked ? kTextMuted : kTextDark,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageStr) {
    if (imageStr.isEmpty) {
      return Container(
        color: kOrangeLight,
        child: const Center(
            child: Icon(Icons.restaurant, size: 64, color: kOrangeMid)),
      );
    }
    if (imageStr.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imageStr.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(color: kOrangeLight);
      }
    }
    return Image.network(
      imageStr,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: kOrangeLight),
    );
  }
}
