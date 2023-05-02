import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../HomePage.dart';
import '../Login/Signup/GoogleClassSignIn.dart';
import '../Models/Models.dart';
import '../Models/Utils.dart';
import 'AboutUs.dart';
import 'Profile.dart';
import 'RecipesDisplay.dart';
import 'Setting.dart';
import 'UserPage.dart';

//A specialised desserts page, showing only bakery items etc
class Cuisines extends StatefulWidget {
  const Cuisines({Key? key}) : super(key: key);

  @override
  State<Cuisines> createState() => _CuisinesState();
}

class _CuisinesState extends State<Cuisines> {
  bool fav = false;
  String? summary;
  String? instructions;
  String? query;
  String? title;
  String? image;
  int? time;
  bool? isVeg;
  RecipesMain? recipesMain;
  List<Recipes>? _recipesList;

  @override
  void initState() {
    getRecipes(query);
    super.initState();
  }

  //api call only returns desserts
  getRecipes(String? query) async {
    String url =
        "https://api.spoonacular.com/recipes/random?apiKey=8cf793ad3c1947e2bcc4a1a76a6025f2&number=2&tags=desserts";
    http.Response response = await http.get(Uri.parse(url));
    var data = jsonDecode(response.body);
    try {
      if (response.statusCode == 200) {
        title = data['recipes'][0]['title'];
        image = data['recipes'][0]['image'];
        isVeg = data['recipes'][0]['vegetarian'];
        time = data['recipes'][0]['readyInMinutes'];
        summary = data['recipes'][0]['summary'];
        instructions = data['recipes'][0]['instructions'];
        var recipesMain = RecipesMain.fromJson(data);
        _recipesList = recipesMain.recipes;
        if (query != null) {
          _recipesList = _recipesList!
              .where((element) =>
                  element.title!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
      } else {
        print(response.statusCode);
      }
      return _recipesList;
    } catch (e) {
      print(e);
    }
    print(response.statusCode);
    log(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Desserts"),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context, delegate: CustomSearchDelegate1());
                },
                icon: Icon(Icons.search_outlined)),
          ],
        ),
        body: StreamBuilder(
            stream: getRecipes(query).asStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error occurred!"),
                );
              }
              return _recipesList != null
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: _recipesList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        Recipes recipe = _recipesList![index];
                        return recipe.image != null
                            ? RecipeCards(
                                title: recipe.title!,
                                image: recipe.image!,
                                isVeg: recipe.vegetarian,
                                time: recipe.preparationMinutes,
                                summary: summary!,
                                fav: fav,
                                c: 0,
                                docID: recipe.id.toString(),
                                instructions: instructions!,
                              )
                            : RecipeCards(
                                title: recipe.title!,
                                image: "assets/unavailable-image.jpg",
                                isVeg: recipe.vegetarian,
                                time: recipe.preparationMinutes,
                                summary: summary!,
                                fav: fav,
                                c: 0,
                                docID: recipe.id.toString(),
                                instructions: instructions!,
                              );
                      })
                  : Center(
                      child: Text("Sorry! That's all the recipes you "
                          "can view today."),
                    );
            }),
        drawer: NavigationDrawer(),
      ),
    );
  }
}

class CustomSearchDelegate1 extends SearchDelegate {
  List<Recipes>? searchterms;
  getRecipeData({required String? query}) async {
    try {
      searchterms = await _CuisinesState().getRecipes(query);
      print(searchterms!.length);
    } catch (e) {
      print(e);
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back_sharp));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: getRecipeData(query: query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error occurred!"),
            );
          }
          return searchterms != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchterms!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Recipes recipe = searchterms![index];
                    return recipe.image != null
                        ? RecipeCards(
                            title: recipe.title!,
                            image: recipe.image!,
                            isVeg: recipe.vegetarian,
                            time: recipe.preparationMinutes,
                            summary: recipe.summary!,
                            fav: false,
                            docID: recipe.id.toString(),
                            c: 0,
                            instructions: recipe.instructions!,
                          )
                        : RecipeCards(
                            title: recipe.title!,
                            image: "assets/unavailable-image.jpg",
                            isVeg: recipe.vegetarian,
                            time: recipe.preparationMinutes,
                            summary: recipe.summary!,
                            fav: false,
                            docID: recipe.id.toString(),
                            c: 0,
                            instructions: recipe.instructions!,
                          );
                  })
              : Center(
                  child: Text("No results obtained"),
                );
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        future: getRecipeData(query: query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error occurred!"),
            );
          }
          return searchterms != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchterms!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Recipes recipe = searchterms![index];
                    return recipe.image != null
                        ? RecipeCards(
                            title: recipe.title!,
                            image: recipe.image!,
                            isVeg: recipe.vegetarian,
                            time: recipe.preparationMinutes,
                            summary: recipe.summary!,
                            fav: false,
                            docID: recipe.id.toString(),
                            c: 0,
                            instructions: recipe.instructions!,
                          )
                        : RecipeCards(
                            title: recipe.title!,
                            image: "assets/unavailable-image.jpg",
                            isVeg: recipe.vegetarian,
                            time: recipe.preparationMinutes,
                            summary: recipe.summary!,
                            fav: false,
                            docID: recipe.id.toString(),
                            c: 0,
                            instructions: recipe.instructions!,
                          );
                  })
              : Center(
                  child: Text("No results obtained"),
                );
        });
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
