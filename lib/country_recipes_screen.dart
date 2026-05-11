import 'package:flutter/material.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'recipe_detail.dart';

class CountryRecipesScreen extends StatelessWidget {
  final String countryName;
  final List<RecipeModel> recipes;

  const CountryRecipesScreen({
    super.key,
    required this.countryName,
    required this.recipes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$countryName Recipes"),
        backgroundColor: Colors.orange,
      ),
      body: recipes.isEmpty
          ? const Center(
              child: Text(
                "No recipes available for this country",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetail(model: recipe),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            child: (recipe.dishImage != null &&
                                    recipe.dishImage!.isNotEmpty)
                                ? Image.network(
                                    recipe.dishImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => const Icon(
                                      Icons.restaurant,
                                      color: Colors.orange,
                                    ),
                                  )
                                : const Icon(Icons.restaurant,
                                    color: Colors.orange),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.recipeName ?? "No Name",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                "${recipe.cookTime ?? 0} mins",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 9),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
