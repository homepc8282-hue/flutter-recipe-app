import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'recipe_detail.dart';
import 'package:recipe_app/country_recipes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("World Famous Recipes"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("recipes").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No recipes found!"));
          }

          final allRecipes = snapshot.data!.docs
              .map((doc) => RecipeModel.fromFirestore(doc))
              .toList();

          final uniqueCategories = allRecipes
              .map((recipe) =>
                  (recipe.recipeCategory ?? "").trim().toLowerCase())
              .where((cat) => cat.isNotEmpty)
              .toSet()
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: uniqueCategories.length,
            itemBuilder: (context, index) {
              final rawCat = uniqueCategories[index];
              final originalCat = allRecipes
                      .firstWhere((r) =>
                          (r.recipeCategory ?? "").trim().toLowerCase() ==
                          rawCat)
                      .recipeCategory ??
                  "";

              final countryRecipes = allRecipes
                  .where((recipe) =>
                      (recipe.recipeCategory ?? "").trim().toLowerCase() ==
                      rawCat)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(originalCat,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CountryRecipesScreen(
                                      countryName: originalCat,
                                      recipes: countryRecipes)));
                        },
                        child: const Text("All",
                            style:
                                TextStyle(color: Colors.orange, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: countryRecipes.length,
                      itemBuilder: (context, recipeIndex) {
                        final recipe = countryRecipes[recipeIndex];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeDetail(model: recipe)));
                          },
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 10),
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8)),
                                      child: (recipe.dishImage != null &&
                                              recipe.dishImage!.isNotEmpty)
                                          ? Image.network(recipe.dishImage!,
                                              fit: BoxFit.cover)
                                          : const Icon(Icons.restaurant,
                                              color: Colors.orange, size: 40),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(recipe.recipeName ?? "No Name",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 2),
                                        Text("${recipe.cookTime ?? 0} mins",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
