class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> categories;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final String image;
  final String createdAt;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.categories,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.image,
    required this.createdAt,
    required this.isFavorite,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? categories,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    List<String>? ingredients,
    List<String>? steps,
    String? image,
    String? createdAt,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categories: categories ?? this.categories,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'categories': categories,
        'prepTime': prepTime,
        'cookTime': cookTime,
        'servings': servings,
        'difficulty': difficulty,
        'ingredients': ingredients,
        'steps': steps,
        'image': image,
        'createdAt': createdAt,
        'isFavorite': isFavorite,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        categories: json.containsKey('categories')
            ? List<String>.from(json['categories'] as List)
            : [(json['category'] as String? ?? 'Inne')],
        prepTime: json['prepTime'] as int,
        cookTime: json['cookTime'] as int,
        servings: json['servings'] as int,
        difficulty: json['difficulty'] as String,
        ingredients: List<String>.from(json['ingredients'] as List),
        steps: List<String>.from(json['steps'] as List),
        image: json['image'] as String,
        createdAt: json['createdAt'] as String,
        isFavorite: json['isFavorite'] as bool,
      );
}


