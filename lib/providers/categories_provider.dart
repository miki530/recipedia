import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStorageKey = 'recipedia_categories';

const List<String> kDefaultCategories = [
  'Śniadanie', 'Obiad', 'Kolacja', 'Zupa', 'Sałatka', 'Deser', 'Przekąska', 'Inne', 'Ogólne',
];

const String kFallbackCategory = 'Ogólne';

class CategoriesProvider extends ChangeNotifier {
  List<String> _categories = [];

  // new initialized flag for async loading
  bool _initialized = false;
  bool get initialized => _initialized;

  List<String> get categories => _categories;

  CategoriesProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kStorageKey);
    if (stored != null) {
      try {
        _categories = List<String>.from(jsonDecode(stored) as List);
      } catch (_) {
        _categories = List.from(kDefaultCategories);
      }
    } else {
      _categories = List.from(kDefaultCategories);
    }
    if (!_categories.contains(kFallbackCategory)) {
      _categories.add(kFallbackCategory);
    }
    // mark as initialized before notifying listeners
    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, jsonEncode(_categories));
  }

  bool addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > 15) return false;
    if (_categories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) return false;
    _categories.add(trimmed);
    notifyListeners();
    _save();
    return true;
  }

  bool editCategory(String oldName, String newName) {
    if (oldName == kFallbackCategory) return false;
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.length > 15) return false;
    if (_categories.any((c) => c.toLowerCase() == trimmed.toLowerCase() && c != oldName)) return false;
    final idx = _categories.indexOf(oldName);
    if (idx != -1) {
      _categories[idx] = trimmed;
      notifyListeners();
      _save();
    }
    return true;
  }

  void deleteCategory(String name) {
    if (name == kFallbackCategory) return;
    _categories.remove(name);
    notifyListeners();
    _save();
  }

  void reorder(int from, int to) {
    final item = _categories.removeAt(from);
    _categories.insert(to, item);
    notifyListeners();
    _save();
  }

  Future<void> bulkImport(List<String> incoming) async {
    bool changed = false;
    for (final name in incoming) {
      final trimmed = name.trim();
      if (trimmed.isEmpty) continue;
      // Nie sprawdzaj limitu 15 znaków przy imporcie — przepis mógł mieć dłuższą nazwę
      if (_categories.any((c) => c.toLowerCase() == trimmed.toLowerCase())) continue;
      // Wstaw przed kFallbackCategory żeby "Ogólne" zawsze było na końcu
      final fallbackIdx = _categories.indexOf(kFallbackCategory);
      if (fallbackIdx != -1) {
        _categories.insert(fallbackIdx, trimmed);
      } else {
        _categories.add(trimmed);
      }
      changed = true;
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
  }
}
