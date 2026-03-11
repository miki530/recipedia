import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';

class ImportExportService {
  static Future<void> exportRecipes(
      List<Recipe> recipes, List<String> categories) async {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories,
      'recipes': recipes.map((r) => r.toJson()).toList(),
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/recipedia_backup.recipedia');
    await file.writeAsString(jsonStr);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Eksport przepisów Recipedia',
    );
  }

  static Future<ImportResult?> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      if (path == null) return null;

      final jsonStr = await File(path).readAsString();
      final data = jsonDecode(jsonStr);

      List<Recipe> recipes = [];
      List<String> categories = [];

      if (data is Map) {
        if (data.containsKey('recipes')) {
          recipes = (data['recipes'] as List)
              .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (data.containsKey('categories')) {
          categories = List<String>.from(data['categories'] as List);
        }
      } else if (data is List) {
        recipes = data
            .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Zawsze wyciągnij kategorie z przepisów jako uzupełnienie
      final fromRecipes = recipes
          .expand((r) => r.categories)
          .where((c) => c.trim().isNotEmpty)
          .toSet();
      for (final cat in fromRecipes) {
        if (!categories.any((c) => c.toLowerCase() == cat.toLowerCase())) {
          categories.add(cat);
        }
      }

      return ImportResult(recipes: recipes, categories: categories);
    } catch (_) {
      return null;
    }
  }
}

class ImportResult {
  final List<Recipe> recipes;
  final List<String> categories;
  const ImportResult({required this.recipes, required this.categories});
}
