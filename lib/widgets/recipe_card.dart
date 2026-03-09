import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_colors.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalTime = recipe.prepTime + recipe.cookTime;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kCardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kTextBrown,
                          ),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onToggleFavorite,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: recipe.isFavorite ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 13, color: kTextMuted),
                      const SizedBox(width: 3),
                      Text('$totalTime min',
                          style: const TextStyle(fontSize: 11, color: kTextMuted)),
                      const SizedBox(width: 10),
                      const Icon(Icons.people_outline, size: 13, color: kTextMuted),
                      const SizedBox(width: 3),
                      Text('${recipe.servings} os.',
                          style: const TextStyle(fontSize: 11, color: kTextMuted)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: difficultyBg(recipe.difficulty),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          recipe.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: difficultyColor(recipe.difficulty),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (recipe.image.isEmpty) {
      return Container(
        color: kOrangeLight,
        child: const Center(
          child: Icon(Icons.restaurant, size: 48, color: kOrangeMid),
        ),
      );
    }
    if (recipe.image.startsWith('data:image')) {
      try {
        final base64Str = recipe.image.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return Container(color: kOrangeLight);
      }
    }
    return Image.network(
      recipe.image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: kOrangeLight,
        child: const Center(child: Icon(Icons.restaurant, size: 48, color: kOrangeMid)),
      ),
    );
  }
}