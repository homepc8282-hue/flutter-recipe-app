import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_app/login_screen.dart';
import 'package:recipe_app/models/recipe_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final recipeNameCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();
  final prepTimeCtrl = TextEditingController();
  final cookTimeCtrl = TextEditingController();
  final ingredientsCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  bool existingFavStatus = false;

  late Stream<QuerySnapshot> userRecipeStream;

  @override
  void initState() {
    super.initState();

    userRecipeStream = _fireStore
        .collection("recipes")
        .where("userId", isEqualTo: userId)
        .snapshots();
  }

  @override
  void dispose() {
    recipeNameCtrl.dispose();
    categoryCtrl.dispose();
    imageUrlCtrl.dispose();
    prepTimeCtrl.dispose();
    cookTimeCtrl.dispose();
    ingredientsCtrl.dispose();
    instructionsCtrl.dispose();
    tagsCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> addOrUpdateRecipe({String? docId}) async {
    if (userId == null) return;

    if (recipeNameCtrl.text.isEmpty ||
        categoryCtrl.text.isEmpty ||
        prepTimeCtrl.text.isEmpty ||
        cookTimeCtrl.text.isEmpty ||
        ingredientsCtrl.text.isEmpty ||
        instructionsCtrl.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fill all required fields")),
        );
      }
      return;
    }

    List<String> ingredientsList = ingredientsCtrl.text.split(",");
    List<String> instructionsList = instructionsCtrl.text.split(",");
    List<String> tagsList =
        tagsCtrl.text.isNotEmpty ? tagsCtrl.text.split(",") : [];

    RecipeModel recipe = RecipeModel(
      userId: userId,
      recipeName: recipeNameCtrl.text.trim(),
      recipeCategory: categoryCtrl.text.trim(),
      dishImage: imageUrlCtrl.text.trim(),
      prepTime: int.parse(prepTimeCtrl.text.trim()),
      cookTime: int.parse(cookTimeCtrl.text.trim()),
      ingredients: ingredientsList,
      instructions: instructionsList,
      isFavorite: docId == null ? false : existingFavStatus,
      tags: tagsList,
      description: descriptionCtrl.text.trim(),
    );

    try {
      if (docId == null) {
        await _fireStore.collection("recipes").add(recipe.toFirestore());
      } else {
        await _fireStore
            .collection("recipes")
            .doc(docId)
            .set(recipe.toFirestore(), SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(docId == null
                  ? "Recipe Added Successfully ✅"
                  : "Recipe Updated Successfully ✅")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    clearAllControllers();
  }

  Future<void> deleteRecipe(String docId) async {
    await _fireStore.collection("recipes").doc(docId).delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe Deleted")),
      );
    }
  }

  void clearAllControllers() {
    recipeNameCtrl.clear();
    categoryCtrl.clear();
    imageUrlCtrl.clear();
    prepTimeCtrl.clear();
    cookTimeCtrl.clear();
    ingredientsCtrl.clear();
    instructionsCtrl.clear();
    tagsCtrl.clear();
    descriptionCtrl.clear();
    existingFavStatus = false;
  }

  void showRecipeDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      recipeNameCtrl.text = data["recipeName"] ?? "";
      categoryCtrl.text = data["recipeCategory"] ?? "";
      imageUrlCtrl.text = data["dishImage"] ?? "";
      prepTimeCtrl.text = data["prepTime"].toString();
      cookTimeCtrl.text = data["cookTime"].toString();
      ingredientsCtrl.text = (data["ingredients"] as List).join(",");
      instructionsCtrl.text = (data["instructions"] as List).join(",");
      tagsCtrl.text =
          (data["tags"] != null) ? (data["tags"] as List).join(",") : "";
      descriptionCtrl.text = data["description"] ?? "";
      existingFavStatus = data["isFavorite"] ?? false;
    } else {
      clearAllControllers();
    }

    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: Text(doc == null ? "Add New Recipe" : "Edit Recipe"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: recipeNameCtrl,
                enableInteractiveSelection: true,
                decoration: const InputDecoration(labelText: "Recipe Name"),
              ),
              TextFormField(
                controller: categoryCtrl,
                enableInteractiveSelection: true,
                decoration:
                    const InputDecoration(labelText: "Country / Category"),
              ),
              TextFormField(
                controller: imageUrlCtrl,
                enableInteractiveSelection: true,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: "Image URL (Optional)",
                  hintText: "https://example.com/image.jpg",
                ),
              ),
              TextFormField(
                controller: prepTimeCtrl,
                keyboardType: TextInputType.number,
                enableInteractiveSelection: true,
                decoration:
                    const InputDecoration(labelText: "Prep Time (Mins)"),
              ),
              TextFormField(
                controller: cookTimeCtrl,
                keyboardType: TextInputType.number,
                enableInteractiveSelection: true,
                decoration:
                    const InputDecoration(labelText: "Cook Time (Mins)"),
              ),
              TextFormField(
                controller: ingredientsCtrl,
                maxLines: 2,
                enableInteractiveSelection: true,
                decoration: const InputDecoration(
                    labelText: "Ingredients (Comma Separated)"),
              ),
              TextFormField(
                controller: instructionsCtrl,
                maxLines: 3,
                enableInteractiveSelection: true,
                decoration: const InputDecoration(
                    labelText: "Instructions (Comma Separated)"),
              ),
              TextFormField(
                controller: tagsCtrl,
                enableInteractiveSelection: true,
                decoration:
                    const InputDecoration(labelText: "Tags (Comma Separated)"),
              ),
              TextFormField(
                controller: descriptionCtrl,
                maxLines: 2,
                enableInteractiveSelection: true,
                decoration:
                    const InputDecoration(labelText: "Recipe Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () => addOrUpdateRecipe(docId: doc?.id),
              child: Text(doc == null ? "Add" : "Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Recipe Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => showRecipeDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Recipes",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: userRecipeStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.orange));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text(
                            "No recipes added yet!\nTap + button to add new recipe",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 16, color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      RecipeModel recipe = RecipeModel.fromFirestore(doc);

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: (recipe.dishImage != null &&
                                  recipe.dishImage!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: recipe.dishImage!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.restaurant,
                                  size: 50, color: Colors.orange),
                          title: Text(recipe.recipeName ?? "",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "${recipe.recipeCategory}\nPrep: ${recipe.prepTime} Mins"),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        showRecipeDialog(doc: doc)),
                                IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => deleteRecipe(doc.id))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
