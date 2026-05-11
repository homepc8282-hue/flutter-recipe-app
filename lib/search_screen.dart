import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'recipe_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RecipeModel> _allRecipes = [];
  List<RecipeModel> _filteredRecipes = [];
  bool _isLoading = true;

  final List<String> _topSearchedTags = [
    "Pakistani",
    "Italian",
    "Indian",
    "Chinese",
    "Mexican",
    "Arabic",
    "Breakfast",
    "Dinner",
    "Dessert",
    "Vegetarian",
    "Chicken",
    "Beef"
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecipesFromFirebase();
    _searchController.addListener(_filterRecipesByCountry);
  }

  Future<void> _fetchRecipesFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("recipes").get();

      setState(() {
        _allRecipes =
            snapshot.docs.map((doc) => RecipeModel.fromFirestore(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading recipes: $e")),
        );
      }
    }
  }

  void _filterRecipesByCountry() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRecipes.clear();
      } else {
        _filteredRecipes = _allRecipes.where((recipe) {
          return recipe.recipeCategory?.toLowerCase().contains(query) ?? false;
        }).toList();
      }
    });
  }

  void _filterByTag(String tag) {
    setState(() {
      _searchController.text = tag;
      _filteredRecipes = _allRecipes.where((recipe) {
        return (recipe.recipeCategory?.toLowerCase() == tag.toLowerCase()) ||
            (recipe.recipeCategory?.toLowerCase() == tag.toLowerCase()) ||
            (recipe.tags?.any((t) => t.toLowerCase() == tag.toLowerCase()) ??
                false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Recipes"),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search country, cuisine or dish...",
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.orange),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filteredRecipes.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (_searchController.text.isEmpty) ...[
                    // ⭐ Top Liked Recipes
                    const Text(
                      "⭐ Top Liked Recipes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _allRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _allRecipes[index];
                          return _TopLikedRecipeCard(
                            recipe: recipe,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetail(model: recipe),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🏷️ Top Searched Tags
                    const Text(
                      "🏷️ Top Searched Tags",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _topSearchedTags.map((tag) {
                        return _SearchTagChip(
                          text: tag,
                          onTap: () => _filterByTag(tag),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 30),

                  if (_searchController.text.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Results for '${_searchController.text}'",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_filteredRecipes.isEmpty)
                          const Center(
                            child: Text(
                              "No recipes found!",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _filteredRecipes[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    recipe.recipeName ?? "No Name",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "${recipe.recipeCategory ?? "Unknown"} • ${recipe.prepTime ?? 0} min",
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios,
                                      color: Colors.orange),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetail(model: recipe),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

// 🌟 Top Liked Recipe Card Widget
class _TopLikedRecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const _TopLikedRecipeCard({
    required this.recipe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant,
                color: Colors.orange,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                recipe.recipeName ?? "Recipe",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                recipe.recipeCategory ?? "Unknown",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🏷️ Search Tag Chip Widget
class _SearchTagChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SearchTagChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
