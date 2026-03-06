class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final String image;
  final String createdAt;
  final List<String> tags;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    required this.image,
    required this.createdAt,
    required this.tags,
    required this.isFavorite,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? difficulty,
    List<String>? ingredients,
    List<String>? steps,
    String? image,
    String? createdAt,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'prepTime': prepTime,
        'cookTime': cookTime,
        'servings': servings,
        'difficulty': difficulty,
        'ingredients': ingredients,
        'steps': steps,
        'image': image,
        'createdAt': createdAt,
        'tags': tags,
        'isFavorite': isFavorite,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        prepTime: json['prepTime'] as int,
        cookTime: json['cookTime'] as int,
        servings: json['servings'] as int,
        difficulty: json['difficulty'] as String,
        ingredients: List<String>.from(json['ingredients'] as List),
        steps: List<String>.from(json['steps'] as List),
        image: json['image'] as String,
        createdAt: json['createdAt'] as String,
        tags: List<String>.from(json['tags'] as List),
        isFavorite: json['isFavorite'] as bool,
      );
}

final List<Recipe> sampleRecipes = [
  Recipe(
    id: '1',
    title: 'Spaghetti Bolognese',
    description:
        'Klasyczne włoskie spaghetti z mięsnym sosem bolońskim. Aromatyczne, sycące danie idealne na rodzinny obiad.',
    category: 'Obiad',
    prepTime: 15,
    cookTime: 45,
    servings: 4,
    difficulty: 'średni',
    image:
        'https://images.unsplash.com/photo-1604367285668-73d5dea642de?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ingredients: [
      '400g spaghetti',
      '500g mielonego mięsa wołowego',
      '1 cebula',
      '2 ząbki czosnku',
      '400g passaty pomidorowej',
      '2 łyżki oliwy z oliwek',
      'sól, pieprz do smaku',
      'bazylia świeża',
      '50g parmezanu',
    ],
    steps: [
      'Ugotuj spaghetti al dente zgodnie z instrukcją na opakowaniu.',
      'Na rozgrzanej oliwie podsmaż posiekaną cebulę i czosnek przez 3-4 minuty.',
      'Dodaj mięso mielone i smaż do zrumienienia, rozbijając grudki.',
      'Wlej passatę, dopraw solą i pieprzem. Gotuj na wolnym ogniu 30 minut.',
      'Podaj sos na spaghetti, posyp parmezanem i świeżą bazylią.',
    ],
    createdAt: '2024-01-15T10:00:00Z',
    tags: ['włoskie', 'pasta', 'mięso'],
    isFavorite: true,
  ),
  Recipe(
    id: '2',
    title: 'Zupa pomidorowa',
    description:
        'Tradycyjna polska zupa pomidorowa z ryżem. Kremowa, rozgrzewająca i pełna smaku.',
    category: 'Zupa',
    prepTime: 10,
    cookTime: 30,
    servings: 6,
    difficulty: 'łatwy',
    image:
        'https://images.unsplash.com/photo-1620416328738-dae3168e6890?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ingredients: [
      '1,5l bulionu drobiowego',
      '400g passaty pomidorowej',
      '3 łyżki koncentratu pomidorowego',
      '200ml śmietany 18%',
      '100g ryżu',
      'sól, cukier do smaku',
      'bazylia, oregano',
    ],
    steps: [
      'W garnku podgrzej bulion z marchewką i pietruszką.',
      'Dodaj passatę i koncentrat pomidorowy, wymieszaj.',
      'Wsyp ryż i gotuj 20 minut na wolnym ogniu.',
      'Wlej śmietanę, dopraw solą i cukrem do smaku.',
      'Podgrzewaj jeszcze 5 minut, podaj z pieczywem.',
    ],
    createdAt: '2024-01-20T14:00:00Z',
    tags: ['polska', 'zupa', 'wegetariańska'],
    isFavorite: false,
  ),
  Recipe(
    id: '3',
    title: 'Ciasto czekoladowe',
    description:
        'Wilgotne i intensywnie czekoladowe ciasto. Idealne na każdą okazję – proste w przygotowaniu.',
    category: 'Deser',
    prepTime: 20,
    cookTime: 40,
    servings: 8,
    difficulty: 'średni',
    image:
        'https://images.unsplash.com/photo-1607257882338-70f7dd2ae344?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ingredients: [
      '200g ciemnej czekolady',
      '150g masła',
      '150g cukru',
      '3 jajka',
      '100g mąki',
      '2 łyżki kakao',
      '1 łyżeczka proszku do pieczenia',
    ],
    steps: [
      'Roztop czekoladę z masłem w kąpieli wodnej.',
      'Ubij jajka z cukrem na puszystą masę.',
      'Połącz czekoladę z jajkami, dodaj mąkę, kakao i proszek.',
      'Przelej do formy, piecz w 180°C przez 35-40 minut.',
      'Ostudź, udekoruj bitą śmietaną.',
    ],
    createdAt: '2024-02-01T16:00:00Z',
    tags: ['czekolada', 'ciasto', 'deser'],
    isFavorite: true,
  ),
  Recipe(
    id: '4',
    title: 'Sałatka z grillowanym kurczakiem',
    description:
        'Lekka i sycąca sałatka z soczyście grillowanym kurczakiem i dressingiem cytrynowym.',
    category: 'Sałatka',
    prepTime: 20,
    cookTime: 15,
    servings: 2,
    difficulty: 'łatwy',
    image:
        'https://images.unsplash.com/photo-1760888549075-0b9727e07735?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
    ingredients: [
      '2 piersi z kurczaka',
      '150g mieszanki sałat',
      '1 awokado',
      '200g pomidorków koktajlowych',
      '3 łyżki oliwy z oliwek',
      'sok z 1 cytryny',
      '50g parmezanu w wiórach',
    ],
    steps: [
      'Kurczaka marynuj w oliwie, soku z cytryny i przyprawach.',
      'Grilluj na rozgrzanej patelni po 6-7 minut z każdej strony.',
      'Pokrój kurczaka, awokado i ogórek.',
      'Wymieszaj dressing z oliwy i soku z cytryny.',
      'Ułóż sałatę, warzywa, kurczaka, polej dressingiem.',
    ],
    createdAt: '2024-02-10T12:00:00Z',
    tags: ['zdrowe', 'kurczak', 'fit'],
    isFavorite: false,
  ),
  Recipe(
    id: '5',
    title: 'Naleśniki z dżemem',
    description:
        'Puchate i cienkie naleśniki – klasyczne śniadanie lub deser z dżemem i śmietaną.',
    category: 'Śniadanie',
    prepTime: 10,
    cookTime: 20,
    servings: 4,
    difficulty: 'łatwy',
    image:
        'https://images.unsplash.com/photo-1739897091734-0f4af03cace2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=800',
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
    createdAt: '2024-02-15T08:00:00Z',
    tags: ['śniadanie', 'szybkie', 'słodkie'],
    isFavorite: false,
  ),
];
