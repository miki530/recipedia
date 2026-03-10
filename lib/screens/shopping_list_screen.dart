import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _addController = TextEditingController();
  String? _editingId;
  final _editController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListProvider>();
    final items = provider.items;
    final totalCount = provider.totalCount;
    final checkedCount = provider.checkedCount;
    final progress = totalCount > 0 ? checkedCount / totalCount : 0.0;

    // Group items
    final Map<String, List<ShoppingItem>> grouped = {};
    for (final item in items) {
      final key = item.fromRecipeId ?? '__manual__';
      grouped.putIfAbsent(key, () => []).add(item);
    }

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
                  child: const Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lista zakupów',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark)),
                    Text('$checkedCount/$totalCount produktów kupiono',
                        style: const TextStyle(fontSize: 11, color: kTextMuted)),
                  ],
                ),
                const Spacer(),
                if (checkedCount > 0)
                  GestureDetector(
                    onTap: () => provider.clearChecked(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kOrangeBorder),
                      ),
                      child: const Text('Usuń kupione',
                          style: TextStyle(fontSize: 11, color: kTextMuted)),
                    ),
                  ),
                if (totalCount > 0) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showClearDialog(context, provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: const Icon(Icons.close, size: 14, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(height: 1, color: kCardBorder),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Progress bar
                  if (totalCount > 0) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        height: 8,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: kOrangeBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress == 1.0 ? const Color(0xFF22C55E) : kDarkOrange,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    if (progress == 1.0) ...[
                      const SizedBox(height: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
                            SizedBox(width: 6),
                            Text('Wszystko kupione! 🎉',
                                style: TextStyle(
                                    color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],

                  // Add item input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kCardBorder),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _addController,
                            style: const TextStyle(fontSize: 14, color: kTextDark),
                            decoration: const InputDecoration(
                              hintText: 'Dodaj produkt ręcznie...',
                              hintStyle: TextStyle(color: kTextMuted, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            onSubmitted: (v) {
                              if (v.trim().isNotEmpty) {
                                provider.addSingleItem(v);
                                _addController.clear();
                              }
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_addController.text.trim().isNotEmpty) {
                              provider.addSingleItem(_addController.text);
                              _addController.clear();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  ),
                ],
              ),
            ),
          ),

          // Empty state
          if (totalCount == 0)
            SliverToBoxAdapter(
              child: Padding(
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
                      child: const Icon(Icons.inventory_2_outlined, size: 40, color: kOrangeMid),
                    ),
                    const SizedBox(height: 16),
                    const Text('Lista jest pusta',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: kTextDark)),
                    const SizedBox(height: 8),
                    const Text(
                      'Dodaj produkty ręcznie lub z przepisu kliknij „Dodaj do listy zakupów".',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: kTextMuted),
                    ),
                  ],
                ),
              ),
            ),

          // Grouped items
          ...grouped.entries.map((entry) {
            final groupKey = entry.key;
            final groupItems = entry.value;
            final isManual = groupKey == '__manual__';
            final label = isManual ? 'Dodane ręcznie' : groupItems.first.fromRecipeName ?? 'Przepis';
            final groupChecked = groupItems.where((i) => i.checked).length;

            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            isManual ? Icons.add_circle_outline : Icons.restaurant_outlined,
                            size: 14,
                            color: isManual ? kTextMuted : kDarkOrange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              color: isManual ? kTextMuted : kDarkOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('($groupChecked/${groupItems.length})',
                              style: const TextStyle(fontSize: 11, color: Color(0xFFC4A99A))),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kCardBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groupItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: kCardBorder),
                        itemBuilder: (context, index) {
                          final item = groupItems[index];
                          return _buildItem(context, item, provider);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, ShoppingItem item, ShoppingListProvider provider) {
    final isEditing = _editingId == item.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: item.checked ? const Color(0xFFF9FAFB) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => provider.toggleItem(item.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.checked ? const Color(0xFF22C55E) : Colors.white,
                border: Border.all(
                  color: item.checked ? const Color(0xFF22C55E) : kOrangeBorder,
                  width: 2,
                ),
              ),
              child: item.checked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _editController,
                          autofocus: true,
                          style: const TextStyle(fontSize: 14, color: kTextDark),
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
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) provider.updateItem(item.id, v.trim());
                            setState(() => _editingId = null);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFF22C55E), size: 20),
                        onPressed: () {
                          if (_editController.text.trim().isNotEmpty) {
                            provider.updateItem(item.id, _editController.text.trim());
                          }
                          setState(() => _editingId = null);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: kTextMuted, size: 20),
                        onPressed: () => setState(() => _editingId = null),
                      ),
                    ],
                  )
                : GestureDetector(
                    onDoubleTap: () {
                      setState(() {
                        _editingId = item.id;
                        _editController.text = item.name;
                      });
                    },
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: item.checked ? kTextMuted : kTextDark,
                        decoration: item.checked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
          ),
          if (!isEditing)
            GestureDetector(
              onTap: () => provider.removeItem(item.id),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.red.withOpacity(0.5)),
              ),
            ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, ShoppingListProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Wyczyść listę', style: TextStyle(color: kTextDark)),
        content: const Text('Czy na pewno chcesz usunąć wszystkie produkty z listy?',
            style: TextStyle(color: kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anuluj', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.of(ctx).pop();
            },
            child: const Text('Wyczyść', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}
