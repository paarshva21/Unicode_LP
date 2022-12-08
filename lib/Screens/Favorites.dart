import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'RecipesDisplay.dart';
import 'UserPage.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  @override
  void initState() {
    super.initState();
  }

  //Reads the Favorites stored in Firestore
  Stream<List<Fav>> readFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection("Email Users")
        .doc(user?.uid)
        .collection('Favorites')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Fav.fromJson(doc.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<List<Fav>>(
          stream: readFavorites(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Error occured!"),
              );
            } else if (snapshot.hasData) {
              final favs = snapshot.data!;
              return ListView(
                children: favs.map(buildFavs).toList(),
              );
            } else if(!snapshot.hasData){
              return Center(
                child: Text("You have not selected any favourites!"),
              );
            }
            else{
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      drawer: NavigationDrawer(),
    ));
  }

  //Creates a ListTile for each recipe stored as Favorites
  Widget buildFavs(Fav favs) {
    return RecipeCards(
      title: favs.title,
      image: favs.image,
      isVeg: favs.isVeg,
      time: favs.time,
      summary: favs.Summary,
      fav: true,
      c: 1,
      docID: favs.id,
      instructions: favs.instructions,
    );
  }
}

