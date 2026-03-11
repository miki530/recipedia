import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipes_provider.dart';
import '../providers/categories_provider.dart';
import '../models/recipe.dart';
import '../widgets/image_input_widget.dart';
import '../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class RecipeFormScreen extends StatefulWidget {
  final String? recipeId;

  const RecipeFormScreen({super.key, this.recipeId});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<String> _selectedCategories = ['Obiad'];
  int? _prepTime;
  int? _cookTime;
  int? _servings;
  String _difficulty = 'średni';
  List<String> _ingredients = [''];
  List<String> _steps = [''];
  List<TextEditingController> _ingControllers = [];
  List<TextEditingController> _stepControllers = [];
  String _image = '';
  bool _isFavorite = false;
  String? _originalCreatedAt;

  Map<String, String> _errors = {};

  bool get _isEditing => widget.recipeId != null;

  @override
  void initState() {
    super.initState();
    _ingControllers = [TextEditingController()];
    _stepControllers = [TextEditingController()];
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecipe());
    }
  }

  void _loadRecipe() {
    final recipe = context.read<RecipesProvider>().getRecipe(widget.recipeId!);
    if (recipe != null) {
      for (final c in _ingControllers) {
        c.dispose();
      }
      for (final c in _stepControllers) {
        c.dispose();
      }
      setState(() {
        _titleController.text = recipe.title;
        _descriptionController.text = recipe.description;
        _originalCreatedAt = recipe.createdAt;
        _selectedCategories = List.from(recipe.categories);
        _prepTime = recipe.prepTime;
        _cookTime = recipe.cookTime;
        _servings = recipe.servings;
        _difficulty = recipe.difficulty;
        _ingredients = List.from(recipe.ingredients);
        _steps = List.from(recipe.steps);
        _ingControllers = _ingredients.map((v) => TextEditingController(text: v)).toList();
        _stepControllers = _steps.map((v) => TextEditingController(text: v)).toList();
        _image = recipe.image;
        _isFavorite = recipe.isFavorite;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _ingControllers) {
      c.dispose();
    }
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _scanOcr({required bool isIngredients}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: kOrangeBorder,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              const Text('Skanuj tekst',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark)),
              const SizedBox(height: 4),
              Text(
                isIngredients
                    ? 'Skieruj aparat na listę składników'
                    : 'Skieruj aparat na kroki przepisu',
                style: const TextStyle(fontSize: 12, color: kTextMuted),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(width: 40, height: 40,
                    decoration: BoxDecoration(gradient: kOrangeGradient,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)),
                title: const Text('Aparat'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(width: 40, height: 40,
                    decoration: BoxDecoration(color: kOrangeLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.photo_library_outlined, color: kOrange, size: 20)),
                title: const Text('Galeria'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: kOrange)),
      );
    }

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await textRecognizer.processImage(
          InputImage.fromFilePath(picked.path));
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      final rawText = recognized.text.trim();
      if (rawText.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie rozpoznano żadnego tekstu')));
        }
        return;
      }

      final parsed = isIngredients
          ? _parseIngredients(rawText)
          : _parseSteps(rawText);

      if (parsed.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie udało się przetworzyć tekstu')));
        }
        return;
      }

      if (!mounted) return;
      final confirmed = await _showOcrPreviewDialog(parsed, isIngredients: isIngredients);
      if (confirmed == true && mounted) {
        setState(() {
          if (isIngredients) {
            for (final c in _ingControllers.where((c) => c.text.trim().isEmpty)) {
              c.dispose();
            }
            _ingControllers.removeWhere((c) => c.text.trim().isEmpty);
            _ingredients.removeWhere((i) => i.trim().isEmpty);
            for (final line in parsed) {
              _ingredients.add(line);
              _ingControllers.add(TextEditingController(text: line));
            }
          } else {
            for (final c in _stepControllers.where((c) => c.text.trim().isEmpty)) {
              c.dispose();
            }
            _stepControllers.removeWhere((c) => c.text.trim().isEmpty);
            _steps.removeWhere((s) => s.trim().isEmpty);
            for (final step in parsed) {
              _steps.add(step);
              _stepControllers.add(TextEditingController(text: step));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd OCR: $e')));
      }
    } finally {
      textRecognizer.close();
    }
  }

  List<String> _parseIngredients(String text) {
    return text
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'^\s*[-•*·]\s*'), '').trim())
        .where((l) => l.length > 1)
        .toList();
  }

  List<String> _parseSteps(String text) {
    // Próbuj wykryć numerowane kroki (1. / 1) / Krok 1)
    final numPattern = RegExp(r'(?:^|\n)\s*(?:\d+[\.\):]|[Kk]rok\s*\d+[\.:]?)\s*');
    if (numPattern.hasMatch(text)) {
      final parts = text.split(RegExp(r'(?=(?:\d+[\.\):]|[Kk]rok\s*\d+))', multiLine: true));
      return parts
          .map((p) => p
              .replaceAll(RegExp(r'^(?:\d+[\.\):]|[Kk]rok\s*\d+[\.:]?)\s*'), '')
              .replaceAll('\n', ' ')
              .trim())
          .where((p) => p.length > 5)
          .toList();
    }
    // Podziel po podwójnych nowych liniach lub dużych literach na początku linii
    return text
        .split(RegExp(r'\n{2,}|\n(?=[A-ZŁŻŹĆĄĘÓŚŃ])'))
        .map((p) => p.replaceAll('\n', ' ').trim())
        .where((p) => p.length > 5)
        .toList();
  }

  Future<bool?> _showOcrPreviewDialog(List<String> items,
      {required bool isIngredients}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isIngredients ? 'Rozpoznane składniki' : 'Rozpoznane kroki',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kTextDark),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22, height: 22,
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: const BoxDecoration(
                        gradient: kOrangeGradient, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${i + 1}',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Expanded(
                    child: Text(items[i],
                        style: const TextStyle(fontSize: 13, color: kTextDark)),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Anuluj', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dodaj',
                style: TextStyle(color: kOrange, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
      categories: _selectedCategories.isEmpty ? ['Inne'] : _selectedCategories,
      prepTime: _prepTime ?? 0,
      cookTime: _cookTime ?? 0,
      servings: _servings ?? 0,
      difficulty: _difficulty,
      ingredients: _ingredients.where((i) => i.trim().isNotEmpty).toList(),
      steps: _steps.where((s) => s.trim().isNotEmpty).toList(),
      image: _image,
      createdAt: _originalCreatedAt ?? DateTime.now().toIso8601String(),
      isFavorite: _isFavorite,
    );

    final provider = context.read<RecipesProvider>();
    if (_isEditing) {
      await provider.updateRecipe(widget.recipeId!, recipe);
      if (mounted) Navigator.of(context).pop();
    } else {
      await provider.addRecipe(recipe);
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
                _label('Kategoria (możesz wybrać kilka)'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final selected = _selectedCategories.contains(cat);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          if (_selectedCategories.length > 1) {
                            _selectedCategories.remove(cat);
                          }
                        } else {
                          _selectedCategories.add(cat);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected ? kOrangeGradient : null,
                          color: selected ? null : kOrangeLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.check, size: 13, color: Colors.white),
                              ),
                            Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                color: selected ? Colors.white : const Color(0xFFC2410C),
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ],
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

            _card(
              title: 'Czas i porcje',
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _numberField('Przygot. (min)', _prepTime,
                          (v) => setState(() => _prepTime = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _numberField('Gotowanie (min)', _cookTime,
                          (v) => setState(() => _cookTime = v))),
                      const SizedBox(width: 10),
                      Expanded(child: _numberField('Porcje', _servings,
                          (v) => setState(() => _servings = v))),
                    ],
                  ),
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
                                color: selected ? difficultyColor(d).withValues(alpha: 0.5) : Colors.transparent,
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
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final ing = _ingredients.removeAt(oldIndex);
                      _ingredients.insert(newIndex, ing);
                      final ctrl = _ingControllers.removeAt(oldIndex);
                      _ingControllers.insert(newIndex, ctrl);
                    });
                  },
                  itemCount: _ingControllers.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      key: ValueKey('ing_${i}_${_ingControllers[i].hashCode}'),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_handle, size: 18, color: Color(0xFFD6C4BB)),
                          const SizedBox(width: 6),
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: const BoxDecoration(
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
                            child: TextField(
                              controller: _ingControllers[i],
                              style: const TextStyle(fontSize: 13, color: kTextDark),
                              decoration: InputDecoration(
                                hintText: 'Składnik ${i + 1}...',
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
                              onChanged: (v) => _ingredients[i] = v,
                              onSubmitted: (_) {
                                setState(() {
                                  _ingredients.add('');
                                  _ingControllers.add(TextEditingController());
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                            onPressed: _ingControllers.length <= 1
                                ? null
                                : () => setState(() {
                                      _ingControllers[i].dispose();
                                      _ingControllers.removeAt(i);
                                      _ingredients.removeAt(i);
                                    }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _ingredients.add('');
                        _ingControllers.add(TextEditingController());
                      }),
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
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _scanOcr(isIngredients: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: kOrangeGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.document_scanner_outlined, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Skanuj OCR',
                                style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

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
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final step = _steps.removeAt(oldIndex);
                      _steps.insert(newIndex, step);
                      final ctrl = _stepControllers.removeAt(oldIndex);
                      _stepControllers.insert(newIndex, ctrl);
                    });
                  },
                  itemCount: _stepControllers.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      key: ValueKey('step_${i}_${_stepControllers[i].hashCode}'),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Icon(Icons.drag_handle, size: 18, color: Color(0xFFD6C4BB)),
                          ),
                          const SizedBox(width: 6),
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
                            child: TextField(
                              controller: _stepControllers[i],
                              maxLines: 3,
                              minLines: 1,
                              style: const TextStyle(fontSize: 13, color: kTextDark),
                              decoration: InputDecoration(
                                hintText: 'Krok ${i + 1}...',
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
                              onChanged: (v) => _steps[i] = v,
                              onSubmitted: (_) {
                                setState(() {
                                  _steps.add('');
                                  _stepControllers.add(TextEditingController());
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                            onPressed: _stepControllers.length <= 1
                                ? null
                                : () => setState(() {
                                      _stepControllers[i].dispose();
                                      _stepControllers.removeAt(i);
                                      _steps.removeAt(i);
                                    }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        _steps.add('');
                        _stepControllers.add(TextEditingController());
                      }),
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
                            Text('Dodaj krok',
                                style: TextStyle(fontSize: 13, color: Color(0xFFC2410C))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _scanOcr(isIngredients: false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: kOrangeGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.document_scanner_outlined, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Skanuj OCR',
                                style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

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
                            color: kOrange.withValues(alpha: 0.35),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
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
      child: Text(text,
          style: const TextStyle(
              fontSize: 13, color: kTextBrown, fontWeight: FontWeight.w500)),
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
            child: Text(error,
                style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626))),
          ),
      ],
    );
  }

  Widget _numberField(String label, int? value, ValueChanged<int?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: kTextBrown, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value != null ? value.toString() : '',
          keyboardType: TextInputType.number,
          maxLength: 4,
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
          onChanged: (v) {
            final parsed = int.tryParse(v);
            onChanged(parsed);
          },
        ),
      ],
    );
  }
}
