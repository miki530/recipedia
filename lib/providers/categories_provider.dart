import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStorageKey = 'recipedia_categories';

const List<String> kDefaultCategories = [
  'Śniadanie', 'Obiad', 'Kolacja', 'Zupa', 'Sałatka', 'Deser', 'Przekąska', 'Inne',
];

class CategoriesProvider extends ChangeNotifier {
  List<String> _categories = [];

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
}
