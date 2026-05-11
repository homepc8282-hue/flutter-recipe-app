import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/models/recipe_model.dart';

class RecipeDetail extends StatefulWidget {
  final RecipeModel model;

  const RecipeDetail({
    super.key,
    required this.model,
  });

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  late bool isFavorite;
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.model.isFavorite ?? false;
    isLiked = false;
  }

  Future<void> _toggleFavorite() async {
    final bool updatedStatus = !isFavorite;

    setState(() {
      isFavorite = updatedStatus;
    });

    await FirebaseFirestore.instance
        .collection("recipes")
        .doc(widget.model.recipeId)
        .set({"isFavorite": updatedStatus}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.recipeName ?? "Recipe Detail"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
              color: isLiked ? Colors.blue : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
              });
            },
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (widget.model.dishImage != null &&
                        widget.model.dishImage!.isNotEmpty &&
                        Uri.parse(widget.model.dishImage!).isAbsolute)
                    ? CachedNetworkImage(
                        imageUrl: widget.model.dishImage!,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child:
                              CircularProgressIndicator(color: Colors.orange),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildDetailPlaceholder(),
                      )
                    : _buildDetailPlaceholder(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Prep Time: ${widget.model.prepTime ?? 0} mins",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              "Cooking Time: ${widget.model.cookTime ?? 0} mins",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            if (widget.model.description != null &&
                widget.model.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.model.description!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            const Text(
              "Ingredients",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const SizedBox(height: 12),
            (widget.model.ingredients != null &&
                    widget.model.ingredients!.isNotEmpty)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.model.ingredients!
                        .map((ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text("• $ingredient",
                                  style: const TextStyle(fontSize: 15)),
                            ))
                        .toList(),
                  )
                : const Text("No ingredients added yet."),
            const SizedBox(height: 24),
            const Text(
              "Instructions",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            const SizedBox(height: 12),
            Text(
              widget.model.instructions != null
                  ? widget.model.instructions!.join('\n\n')
                  : "No instructions added",
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.orange[50],
      child: Opacity(
        opacity: 0.3,
        child: Icon(Icons.restaurant, color: Colors.orange[300], size: 80),
      ),
    );
  }
}
