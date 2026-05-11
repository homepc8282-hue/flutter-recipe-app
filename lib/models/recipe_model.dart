import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel {
  final String? recipeId;
  final String? userId;
  final String? recipeName;
  final String? recipeCategory;
  final String? dishImage;
  final int? prepTime;
  final int? cookTime;
  final List<String>? ingredients;
  final List<String>? instructions;
  final bool? isFavorite;
  final List<String>? tags;
  final String? description;

  RecipeModel({
    this.recipeId,
    this.userId,
    this.recipeName,
    this.recipeCategory,
    this.dishImage,
    this.prepTime,
    this.cookTime,
    this.ingredients,
    this.instructions,
    this.isFavorite,
    this.tags,
    this.description,
  });

  factory RecipeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RecipeModel(
      recipeId: doc.id,
      userId: data['userId'],
      recipeName: data['recipeName'],
      recipeCategory: data['recipeCategory'],
      dishImage: data['dishImage'],
      prepTime: data['prepTime'],
      cookTime: data['cookTime'],
      ingredients: List<String>.from(data['ingredients'] ?? []),
      instructions: List<String>.from(data['instructions'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      description: data['description'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'recipeName': recipeName,
      'recipeCategory': recipeCategory,
      'dishImage': dishImage,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'ingredients': ingredients,
      'instructions': instructions,
      'isFavorite': isFavorite,
      'tags': tags,
      'description': description,
    };
  }
}
