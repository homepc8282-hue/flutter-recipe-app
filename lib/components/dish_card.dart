import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:recipe_app/models/recipe_model.dart' as recipeLib;

class DishCard extends StatelessWidget {
  final recipeLib.RecipeModel recipe;
  final VoidCallback onTap;

  const DishCard({
    super.key,
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            // ✅ Null safety check added for dishImage
            if (recipe.dishImage != null &&
                recipe.dishImage!.isNotEmpty &&
                Uri.parse(recipe.dishImage!).isAbsolute)
              CachedNetworkImage(
                imageUrl: recipe.dishImage!,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (context, url, error) => _buildSmallPlaceholder(),
              )
            else
              _buildSmallPlaceholder(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Null fallback for recipeName
                  Text(
                    recipe.recipeName ?? "No Recipe Name",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ✅ Null fallback for cookTime
                  Text("Cook Time: ${recipe.cookTime ?? 0} mins",
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPlaceholder() {
    return Container(
      height: 80,
      width: 80,
      color: Colors.orange[50],
      child: Opacity(
        opacity: 0.3,
        child: Icon(Icons.restaurant, color: Colors.orange[300], size: 35),
      ),
    );
  }
}
