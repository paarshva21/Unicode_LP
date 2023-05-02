import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'RecipesDisplay.dart';
import 'UserPage.dart';
import 'package:provider/provider.dart';
import '../HomePage.dart';
import '../Login/Signup/GoogleClassSignIn.dart';
import '../Models/Models.dart';
import '../Models/Utils.dart';
import 'AboutUs.dart';
import 'Profile.dart';
import 'RecipesDisplay.dart';
import 'Setting.dart';

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

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[buildHeader(context), buildMenuItems(context)],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) => Container(
    padding: EdgeInsets.only(top: 20.0),
  );

  Widget buildMenuItems(BuildContext context) => Container(
      padding: EdgeInsets.all(24.0),
      child: Wrap(runSpacing: 16, children: [
        Column(children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.person,
              color: Colors.green,
              size: 30,
            ),
            title: Text(
              "Profile",
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Profile()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.info,
              color: Colors.green,
              size: 30,
            ),
            title: Text("About Us",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => AboutUs()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Colors.green,
              size: 30,
            ),
            title: Text("Settings",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Setting()));
            },
          ),
          Divider(
            color: Colors.green,
            thickness: 1,
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.green,
              size: 30,
            ),
            title: Text("Logout",
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              try {
                if (user?.photoURL != null) {
                  final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
                  provider.googleLogout();
                } else {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => HomePage()),
                    ModalRoute.withName('/'),
                  );
                }
              } on FirebaseAuthException catch (e) {
                print(e.message);
                Utils.showSnackBar(e.message);
              }
            },
          ),
        ]),
      ]));
}
