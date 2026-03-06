class ShoppingItem {
  final String id;
  final String name;
  final bool checked;
  final String? fromRecipeId;
  final String? fromRecipeName;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.checked,
    this.fromRecipeId,
    this.fromRecipeName,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? checked,
    String? fromRecipeId,
    String? fromRecipeName,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      checked: checked ?? this.checked,
      fromRecipeId: fromRecipeId ?? this.fromRecipeId,
      fromRecipeName: fromRecipeName ?? this.fromRecipeName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'checked': checked,
        'fromRecipeId': fromRecipeId,
        'fromRecipeName': fromRecipeName,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        checked: json['checked'] as bool,
        fromRecipeId: json['fromRecipeId'] as String?,
        fromRecipeName: json['fromRecipeName'] as String?,
      );
}
