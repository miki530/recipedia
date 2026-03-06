import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

const _kStorageKey = 'recipedia_shopping_list';

class ShoppingListProvider extends ChangeNotifier {
  List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => _items;
  int get totalCount => _items.length;
  int get checkedCount => _items.where((i) => i.checked).length;
  int get pendingCount => totalCount - checkedCount;

  ShoppingListProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kStorageKey);
    if (stored != null) {
      try {
        final list = jsonDecode(stored) as List;
        _items = list.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {
        _items = [];
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStorageKey, jsonEncode(_items.map((i) => i.toJson()).toList()));
  }

  void addItems(List<String> names, {String? fromRecipeId, String? fromRecipeName}) {
    for (final name in names) {
      if (name.trim().isEmpty) continue;
      _items.add(ShoppingItem(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_items.length}',
        name: name.trim(),
        checked: false,
        fromRecipeId: fromRecipeId,
        fromRecipeName: fromRecipeName,
      ));
    }
    notifyListeners();
    _save();
  }

  void addSingleItem(String name) {
    if (name.trim().isEmpty) return;
    _items.add(ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      checked: false,
    ));
    notifyListeners();
    _save();
  }

  void toggleItem(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(checked: !_items[idx].checked);
      notifyListeners();
      _save();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
    _save();
  }

  void updateItem(String id, String name) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(name: name);
      notifyListeners();
      _save();
    }
  }

  void clearChecked() {
    _items.removeWhere((i) => i.checked);
    notifyListeners();
    _save();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
    _save();
  }
}
