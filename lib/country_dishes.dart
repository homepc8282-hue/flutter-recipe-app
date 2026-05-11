import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/models/recipe_model.dart';
import 'package:recipe_app/components/dish_card.dart';

class CountryDishes extends StatelessWidget {
  final String countryName;

  const CountryDishes({super.key, required this.countryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$countryName Dishes")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("recipes")
            .where("recipeCategory", isEqualTo: countryName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No dishes found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];

              final recipe = RecipeModel.fromFirestore(doc);

              return DishCard(
                recipe: recipe,
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}
