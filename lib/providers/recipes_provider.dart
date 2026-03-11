import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import 'categories_provider.dart'; // dodaj tę linię

const _kStorageKey = 'recipedia_recipes';

class RecipesProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];
  bool _initialized = false;

  List<Recipe> get recipes => _recipes;

  RecipesProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kStorageKey);
    if (stored != null) {
      try {
        final list = jsonDecode(stored) as List;
        _recipes = list.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _recipes = [
          Recipe(
            id: 'default_1',
            title: 'Naleśniki z dżemem',
            description: 'Puchate i cienkie naleśniki – klasyczne śniadanie lub deser z dżemem i śmietaną.',
            categories: ['Deser'],
            prepTime: 10,
            cookTime: 20,
            servings: 4,
            difficulty: 'łatwy',
            image: 'https://images.unsplash.com/photo-1739897091734-0f4af03cace2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
            ingredients: [
              '2 jajka',
              '500ml mleka',
              '200g mąki pszennej',
              '1 łyżka cukru',
              'szczypta soli',
              '2 łyżki masła',
              'dżem truskawkowy do podania',
            ],
            steps: [
              'Zmiksuj jajka z mlekiem, dodaj mąkę, cukier i sól.',
              'Miksuj do uzyskania gładkiego ciasta.',
              'Odstaw ciasto na 15-20 minut.',
              'Smaż cienkie naleśniki po ok. 1 minucie z każdej strony.',
              'Podawaj z dżemem posypane cukrem pudrem.',
            ],
            createdAt: DateTime.now().toIso8601String(),
            isFavorite: false,
          ),
        ];
      }
    } else {
      _recipes = [
        Recipe(
          id: 'default_1',
          title: 'Naleśniki z dżemem',
          description: 'Puchate i cienkie naleśniki – klasyczne śniadanie lub deser z dżemem i śmietaną.',
          categories: ['Deser'],
          prepTime: 10,
          cookTime: 20,
          servings: 4,
          difficulty: 'łatwy',
          image: 'https://images.unsplash.com/photo-1739897091734-0f4af03cace2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
          ingredients: [
            '2 jajka',
            '500ml mleka',
            '200g mąki pszennej',
            '1 łyżka cukru',
            'szczypta soli',
            '2 łyżki masła',
            'dżem truskawkowy do podania',
          ],
          steps: [
            'Zmiksuj jajka z mlekiem, dodaj mąkę, cukier i sól.',
            'Miksuj do uzyskania gładkiego ciasta.',
            'Odstaw ciasto na 15-20 minut.',
            'Smaż cienkie naleśniki po ok. 1 minucie z każdej strony.',
            'Podawaj z dżemem posypane cukrem pudrem.',
          ],
          createdAt: DateTime.now().toIso8601String(),
          isFavorite: false,
        ),
      ];
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, jsonEncode(_recipes.map((r) => r.toJson()).toList()));
  }

  bool get initialized => _initialized;

  Recipe? getRecipe(String id) {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<String> addRecipe(Recipe recipe) async {
    final newRecipe = recipe.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now().toIso8601String(),
    );
    _recipes.insert(0, newRecipe);
    notifyListeners();
    await _save();
    return newRecipe.id;
  }

  Future<void> updateRecipe(String id, Recipe updated) async {
    final idx = _recipes.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recipes[idx] = updated.copyWith(id: id);
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _recipes.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _recipes[idx] = _recipes[idx].copyWith(isFavorite: !_recipes[idx].isFavorite);
      notifyListeners();
      await _save();
    }
  }

  Future<void> updateCategoryInRecipes(String oldName, String newName) async {
    bool changed = false;
    for (int i = 0; i < _recipes.length; i++) {
      final idx = _recipes[i].categories.indexOf(oldName);
      if (idx != -1) {
        final updated = List<String>.from(_recipes[i].categories);
        updated[idx] = newName;
        _recipes[i] = _recipes[i].copyWith(categories: updated);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
  }

  Future<void> removeCategoryFromRecipes(String categoryName) async {
    bool changed = false;
    for (int i = 0; i < _recipes.length; i++) {
      if (_recipes[i].categories.contains(categoryName)) {
        final updated = List<String>.from(_recipes[i].categories)
          ..remove(categoryName);
        _recipes[i] = _recipes[i].copyWith(categories: updated);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
  }

  Future<void> reassignDeletedCategory(String deletedName) async {
    bool changed = false;
    for (int i = 0; i < _recipes.length; i++) {
      if (_recipes[i].categories.contains(deletedName)) {
        final updated = List<String>.from(_recipes[i].categories);
        updated.remove(deletedName);
        if (updated.isEmpty) {
          updated.add(kFallbackCategory);
        }
        _recipes[i] = _recipes[i].copyWith(categories: updated);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
  }

  Future<int> bulkImport(List<Recipe> incoming) async {
    int imported = 0;
    final base = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < incoming.length; i++) {
      final r = incoming[i];
      // Pomiń jeśli istnieje przepis o tym samym tytule i dacie utworzenia
      final isDuplicate = _recipes.any((existing) =>
          existing.title.trim().toLowerCase() ==
              r.title.trim().toLowerCase() &&
          existing.createdAt == r.createdAt);
      if (isDuplicate) continue;
      _recipes.insert(0, r.copyWith(id: '${base}_imp_$i'));
      imported++;
    }
    if (imported > 0) {
      notifyListeners();
      await _save();
    }
    return imported;
  }
}
