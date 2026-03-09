import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/categories_provider.dart';
import '../providers/recipes_provider.dart';
import '../theme/app_colors.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _addController = TextEditingController();
  String? _editingName;
  final _editController = TextEditingController();
  String? _deleteConfirm;
  String _addError = '';
  String _editError = '';

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = context.watch<CategoriesProvider>();
    final recipesProvider = context.watch<RecipesProvider>();
    final categories = categoriesProvider.categories;

    int recipeCount(String cat) =>
        recipesProvider.recipes.where((r) => r.category == cat).length;

    return Scaffold(
      backgroundColor: kBgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white.withOpacity(0.95),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: kOrangeGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.label_outline, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kategorie',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark)),
                    Text('${categories.length} kategorii',
                        style: const TextStyle(fontSize: 11, color: kTextMuted)),
                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: kCardBorder),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add category card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kCardBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Dodaj nową kategorię',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _addController,
                                style: const TextStyle(fontSize: 14, color: kTextDark),
                                decoration: InputDecoration(
                                  hintText: 'Nazwa kategorii...',
                                  hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: kOrangeBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: kOrange, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onSubmitted: (_) => _handleAdd(categoriesProvider),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => _handleAdd(categoriesProvider),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: kOrangeGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 16, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Dodaj',
                                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_addError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(_addError,
                                style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9F5),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: Border.all(color: kCardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: kOrangeMid),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kategorie używane w przepisach nie mogą być usunięte.',
                            style: TextStyle(fontSize: 11, color: kTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category list
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(
                        left: BorderSide(color: kCardBorder),
                        right: BorderSide(color: kCardBorder),
                        bottom: BorderSide(color: kCardBorder),
                      ),
                    ),
                    child: categories.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.label_outline, size: 32, color: kOrangeMid),
                                  SizedBox(height: 8),
                                  Text('Brak kategorii', style: TextStyle(color: kTextMuted)),
                                ],
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            onReorder: (from, to) {
                              if (to > from) to--;
                              categoriesProvider.reorder(from, to);
                            },
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final count = recipeCount(cat);
                              final isEditing = _editingName == cat;
                              final isDeleting = _deleteConfirm == cat;

                              return _buildCategoryItem(
                                key: ValueKey(cat),
                                cat: cat,
                                count: count,
                                isEditing: isEditing,
                                isDeleting: isDeleting,
                                isLast: index == categories.length - 1,
                                categoriesProvider: categoriesProvider,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem({
    required Key key,
    required String cat,
    required int count,
    required bool isEditing,
    required bool isDeleting,
    required bool isLast,
    required CategoriesProvider categoriesProvider,
  }) {
    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDeleting
            ? const Color(0xFFFEF2F2)
            : isEditing
                ? const Color(0xFFFFF8F0)
                : Colors.white,
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: kCardBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, size: 18, color: Color(0xFFD6C4BB)),
          const SizedBox(width: 10),
          const SizedBox(width: 10),
          if (isEditing)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _editController,
                          autofocus: true,
                          style: const TextStyle(fontSize: 13, color: kTextDark),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: kOrangeBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: kOrange, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onSubmitted: (_) => _confirmEdit(categoriesProvider),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFF16A34A), size: 20),
                        onPressed: () => _confirmEdit(categoriesProvider),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: kTextMuted, size: 20),
                        onPressed: () => setState(() {
                          _editingName = null;
                          _editError = '';
                        }),
                      ),
                    ],
                  ),
                  if (_editError.isNotEmpty)
                    Text(_editError,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                ],
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  Text(cat, style: const TextStyle(fontSize: 14, color: kTextDark)),
                  const SizedBox(width: 8),
                  Text(
                    count > 0
                        ? '$count przepis${count == 1 ? '' : count < 5 ? 'y' : 'ów'}'
                        : 'brak przepisów',
                    style: const TextStyle(fontSize: 11, color: kTextMuted),
                  ),
                ],
              ),
            ),
          if (!isEditing)
            if (isDeleting)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Usunąć?',
                      style: TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      categoriesProvider.deleteCategory(cat);
                      setState(() => _deleteConfirm = null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Tak',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _deleteConfirm = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Nie',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingName = cat;
                        _editController.text = cat;
                        _editError = '';
                        _deleteConfirm = null;
                      });
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_outlined, size: 18, color: kOrange),
                    ),
                  ),
                  GestureDetector(
                    onTap: count > 0
                        ? null
                        : () => setState(() {
                              _deleteConfirm = cat;
                              _editingName = null;
                            }),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: count > 0 ? const Color(0xFFD6C4BB) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  void _handleAdd(CategoriesProvider provider) {
    final name = _addController.text.trim();
    if (name.isEmpty) {
      setState(() => _addError = 'Podaj nazwę kategorii');
      return;
    }
    final ok = provider.addCategory(name);
    if (!ok) {
      setState(() => _addError = 'Taka kategoria już istnieje');
      return;
    }
    _addController.clear();
    setState(() => _addError = '');
  }

  void _confirmEdit(CategoriesProvider provider) {
    if (_editingName == null) return;
    final newName = _editController.text.trim();
    if (newName.isEmpty) {
      setState(() => _editError = 'Nazwa nie może być pusta');
      return;
    }
    final ok = provider.editCategory(_editingName!, newName);
    if (!ok) {
      setState(() => _editError = 'Taka kategoria już istnieje');
      return;
    }
    setState(() {
      _editingName = null;
      _editError = '';
    });
  }
}
