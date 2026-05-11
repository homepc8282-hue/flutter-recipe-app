import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'recipe_detail.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
          title: const Text("My Favourites"), backgroundColor: Colors.orange),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("recipes")
            .where("isFavorite", isEqualTo: true)
            .where("userId", isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(
                child: Text("No favourites yet!",
                    style: TextStyle(fontSize: 16, color: Colors.grey)));

          final list = snapshot.data!.docs
              .map((d) => RecipeModel.fromFirestore(d))
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              var recipe = list[i];
              return Dismissible(
                key: Key(recipe.recipeId ?? i.toString()),
                onDismissed: (_) async {
                  await FirebaseFirestore.instance
                      .collection("recipes")
                      .doc(recipe.recipeId)
                      .update({"isFavorite": false});
                },
                background: Container(color: Colors.red),
                child: ListTile(
                  leading:
                      (recipe.dishImage != null && recipe.dishImage!.isNotEmpty)
                          ? Image.network(recipe.dishImage!,
                              width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.restaurant),
                  title: Text(recipe.recipeName ?? ""),
                  subtitle: Text("${recipe.cookTime ?? 0} mins"),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RecipeDetail(model: recipe))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
