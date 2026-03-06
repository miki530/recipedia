import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/categories_provider.dart';
import '../models/recipe.dart';
import '../widgets/image_input_widget.dart';
import '../theme/app_colors.dart';

class RecipeFormScreen extends StatefulWidget {
  final String? recipeId;

  const RecipeFormScreen({super.key, this.recipeId});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  String _category = 'Obiad';
  int _prepTime = 15;
  int _cookTime = 30;
  int _servings = 4;
  String _difficulty = 'średni';
  List<String> _ingredients = [''];
  List<String> _steps = [''];
  String _image = '';
  List<String> _tags = [];
  bool _isFavorite = false;

  Map<String, String> _errors = {};

  bool get _isEditing => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecipe());
    }
  }

  void _loadRecipe() {
    final recipe = context.read<RecipesProvider>().getRecipe(widget.recipeId!);
    if (recipe != null) {
      setState(() {
        _titleController.text = recipe.title;
        _descriptionController.text = recipe.description;
        _category = recipe.category;
        _prepTime = recipe.prepTime;
        _cookTime = recipe.cookTime;
        _servings = recipe.servings;
        _difficulty = recipe.difficulty;
        _ingredients = List.from(recipe.ingredients);
        _steps = List.from(recipe.steps);
        _image = recipe.image;
        _tags = List.from(recipe.tags);
        _isFavorite = recipe.isFavorite;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  bool _validate() {
    final errs = <String, String>{};
    if (_titleController.text.trim().isEmpty) errs['title'] = 'Tytuł jest wymagany';
    if (_descriptionController.text.trim().isEmpty) errs['description'] = 'Opis jest wymagany';
    if (_ingredients.where((i) => i.trim().isNotEmpty).isEmpty) {
      errs['ingredients'] = 'Dodaj co najmniej jeden składnik';
    }
    if (_steps.where((s) => s.trim().isNotEmpty).isEmpty) {
      errs['steps'] = 'Dodaj co najmniej jeden krok';
    }
    setState(() => _errors = errs);
    return errs.isEmpty;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final recipe = Recipe(
      id: widget.recipeId ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      prepTime: _prepTime,
      cookTime: _cookTime,
      servings: _servings,
      difficulty: _difficulty,
      ingredients: _ingredients.where((i) => i.trim().isNotEmpty).toList(),
      steps: _steps.where((s) => s.trim().isNotEmpty).toList(),
      image: _image,
      createdAt: DateTime.now().toIso8601String(),
      tags: _tags,
      isFavorite: _isFavorite,
    );

    final provider = context.read<RecipesProvider>();
    if (_isEditing) {
      await provider.updateRecipe(widget.recipeId!, recipe);
      if (mounted) Navigator.of(context).pop();
    } else {
      final id = await provider.addRecipe(recipe);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoriesProvider>().categories;

    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: kOrangeGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edytuj przepis' : 'Nowy przepis',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark),
                ),
                Text(
                  _isEditing ? 'Zmień dane przepisu' : 'Wypełnij formularz',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Basic info
            _card(
              title: 'Podstawowe informacje',
              children: [
                _label('Nazwa przepisu *'),
                _textField(
                  controller: _titleController,
                  hint: 'np. Spaghetti Bolognese',
                  error: _errors['title'],
                ),
                const SizedBox(height: 14),
                _label('Krótki opis *'),
                _textField(
                  controller: _descriptionController,
                  hint: 'Opisz swój przepis w kilku zdaniach...',
                  maxLines: 3,
                  error: _errors['description'],
                ),
                const SizedBox(height: 14),
                _label('Kategoria'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final selected = _category == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _category = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected ? kOrangeGradient : null,
                          color: selected ? null : kOrangeLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected ? Colors.white : const Color(0xFFC2410C),
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _label('Zdjęcie'),
                ImageInputWidget(
                  value: _image,
                  onChange: (v) => setState(() => _image = v),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Time & servings
            _card(
              title: 'Czas i porcje',
              children: [
                Row(
                  children: [
                    Expanded(child: _numberField('Przygotowanie (min)', _prepTime,
                        (v) => setState(() => _prepTime = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _numberField('Gotowanie (min)', _cookTime,
                        (v) => setState(() => _cookTime = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _numberField('Porcje', _servings,
                        (v) => setState(() => _servings = v))),
                  ],
                ),
                const SizedBox(height: 14),
                _label('Poziom trudności'),
                Row(
                  children: ['łatwy', 'średni', 'trudny'].map((d) {
                    final selected = _difficulty == d;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setState(() => _difficulty = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? difficultyBg(d) : kOrangeLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? difficultyColor(d).withOpacity(0.5) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(d,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: selected ? difficultyColor(d) : kTextMuted,
                                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                  )),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Ingredients
            _card(
              title: 'Składniki',
              trailing: Text('${_ingredients.where((i) => i.trim().isNotEmpty).length} pozycji',
                  style: const TextStyle(fontSize: 12, color: kTextMuted)),
              children: [
                if (_errors['ingredients'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_errors['ingredients']!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                  ),
                ..._ingredients.asMap().entries.map((e) {
                  final i = e.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: kOrangeLight,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    fontSize: 11, color: kOrange, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        Expanded(
                          child: _inlineTextField(
                            value: _ingredients[i],
                            hint: 'Składnik ${i + 1}...',
                            onChanged: (v) => setState(() => _ingredients[i] = v),
                            onSubmit: () {
                              setState(() => _ingredients.add(''));
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                          onPressed: _ingredients.length <= 1
                              ? null
                              : () => setState(() => _ingredients.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => setState(() => _ingredients.add('')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kOrangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Color(0xFFC2410C)),
                        SizedBox(width: 4),
                        Text('Dodaj składnik',
                            style: TextStyle(fontSize: 13, color: Color(0xFFC2410C))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Steps
            _card(
              title: 'Kroki przygotowania',
              trailing: Text('${_steps.where((s) => s.trim().isNotEmpty).length} kroków',
                  style: const TextStyle(fontSize: 12, color: kTextMuted)),
              children: [
                if (_errors['steps'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(_errors['steps']!,
                        style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626))),
                  ),
                ..._steps.asMap().entries.map((e) {
                  final i = e.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8, top: 10),
                          decoration: const BoxDecoration(
                            gradient: kOrangeGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        Expanded(
                          child: _inlineTextField(
                            value: _steps[i],
                            hint: 'Krok ${i + 1}...',
                            onChanged: (v) => setState(() => _steps[i] = v),
                            maxLines: 3,
                            onSubmit: () => setState(() => _steps.add('')),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                          onPressed: _steps.length <= 1
                              ? null
                              : () => setState(() => _steps.removeAt(i)),
                        ),
                      ],
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () => setState(() => _steps.add('')),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kOrangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Color(0xFFC2410C)),
                        SizedBox(width: 4),
                        Text('Dodaj krok', style: TextStyle(fontSize: 13, color: Color(0xFFC2410C))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tags
            _card(
              title: 'Tagi',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _inlineTextField(
                        value: '',
                        controller: _tagController,
                        hint: 'np. włoskie, szybkie...',
                        onChanged: (_) {},
                        onSubmit: () {
                          final tag = _tagController.text.trim().toLowerCase();
                          if (tag.isNotEmpty && !_tags.contains(tag)) {
                            setState(() => _tags.add(tag));
                          }
                          _tagController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final tag = _tagController.text.trim().toLowerCase();
                        if (tag.isNotEmpty && !_tags.contains(tag)) {
                          setState(() => _tags.add(tag));
                        }
                        _tagController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: kOrangeGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Dodaj',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                if (_tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kOrangeLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#$tag', style: const TextStyle(fontSize: 12, color: Color(0xFFC2410C))),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _tags.remove(tag)),
                            child: const Icon(Icons.close, size: 14, color: Color(0xFFC2410C)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Submit buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kOrangeBorder),
                      ),
                      child: const Center(
                        child: Text('Anuluj',
                            style: TextStyle(fontSize: 14, color: kTextMuted, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: kOrangeGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: kOrange.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isEditing ? 'Zapisz zmiany' : 'Dodaj przepis',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card({required String title, Widget? trailing, required List<Widget> children}) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, color: kTextBrown, fontWeight: FontWeight.w500)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: error != null ? const Color(0xFFFCA5A5) : kOrangeBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kOrange, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error, style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
          ),
      ],
    );
  }

  Widget _inlineTextField({
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
    VoidCallback? onSubmit,
    TextEditingController? controller,
  }) {
    final ctrl = controller ?? TextEditingController(text: value);
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: kTextDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      onChanged: onChanged,
      onSubmitted: (_) => onSubmit?.call(),
    );
  }

  Widget _numberField(String label, int value, ValueChanged<int> onChanged) {
    final ctrl = TextEditingController(text: value.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: kTextBrown, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          onChanged: (v) => onChanged(int.tryParse(v) ?? value),
        ),
      ],
    );
  }
}
