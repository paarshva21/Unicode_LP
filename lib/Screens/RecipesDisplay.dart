import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Models/Utils.dart';
import '../Models/models.dart';
import 'RecipeInfo.dart';
import 'UserPage.dart';
import 'package:http/http.dart' as http;

class RecipesDisplay extends StatefulWidget {
  @override
  State<RecipesDisplay> createState() => _RecipesDisplayState();
}

class _RecipesDisplayState extends State<RecipesDisplay> {
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

  //gets recipes list from spoonacular API
  getRecipes(String? query) async {
    String url =
        "https://api.spoonacular.com/recipes/random?apiKey=8cf793ad3c1947e2bcc4a1a76a6025f2&number=2";
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
          title: Text("Recipes"),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
                onPressed: () {
                  showSearch(
                      context: context, delegate: CustomSearchDelegate());
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
                      itemCount: _recipesList?.length,
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

//makes a ListTile for each recipe called from api
class RecipeCards extends StatefulWidget {
  final user = FirebaseAuth.instance.currentUser;
  String instructions;
  String docID;
  int c;
  bool fav;
  String title;
  String image;
  int time;
  bool isVeg;
  String summary;

  RecipeCards(
      {Key? key,
      required this.title,
      required this.image,
      required this.time,
      required this.isVeg,
      required this.summary,
      required this.fav,
      required this.c,
      required this.docID,
      required this.instructions})
      : super(key: key);

  @override
  State<RecipeCards> createState() => _RecipeCardsState();
}

class _RecipeCardsState extends State<RecipeCards> {
  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 50,
        shadowColor: Colors.green,
        borderOnForeground: true,
        margin: EdgeInsets.all(10),
        child: SizedBox(
          height: 100,
          child: ListTile(
              isThreeLine: true,
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.all(7)),
                    widget.isVeg
                        ? Container(
                            child: Text(
                              "Vegeterian",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : Container(
                            child: Text(
                              "Non Vegetarian",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                    widget.time != -1
                        ? Container(
                            child: Text(
                              "Preparation Time : " +
                                  widget.time.toString() +
                                  " mins",
                              style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        : Container(
                            child: Text(
                              "Preparation Time : NA",
                              style: TextStyle(
                                  color: Colors.yellowAccent[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                  ]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RecipeInfo(
                          title: widget.title,
                          image: widget.image,
                          isVeg: widget.isVeg,
                          time: widget.time,
                          summary: widget.summary,
                          docID: widget.docID,
                          c: 0,
                          fav: widget.fav,
                          instructions: widget.instructions,
                        )));
              },
              title: SizedBox(
                height: 20,
                child: Text(
                  widget.title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              leading: widget.image != "assets/unavailable-image.jpg"
                  ? Container(
                      width: 90,
                      height: 150,
                      padding: EdgeInsets.only(top: 5000, left: 80),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: NetworkImage(widget.image),
                        fit: BoxFit.contain,
                      )),
                      child: Text(""))
                  : Container(
                      width: 90,
                      height: 150,
                      padding: EdgeInsets.only(top: 5000, left: 80),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage("assets/unavailable-image.jpg"),
                        fit: BoxFit.contain,
                      )),
                      child: Text("")),
              trailing: InkWell(
                onTap: () async {
                  setState(() {
                    widget.fav = !widget.fav;
                  });
                  widget.fav
                      ? Utils.showSnackBar2("Added to favourites!")
                      : Utils.showSnackBar2("Removed from favourites!");
                  //Creates a favorite
                  if (widget.fav == true && widget.c == 0) {
                    await FirebaseFirestore.instance
                        .collection("Email Users")
                        .doc(widget.user?.uid)
                        .collection('Favorites')
                        .doc(widget.docID)
                        .set({
                      'id': widget.docID,
                      'Summary': widget.summary,
                      'isVeg': widget.isVeg,
                      'time': widget.time,
                      'title': widget.title,
                      'image': widget.image,
                      'instructions': widget.instructions
                    });
                    widget.c = widget.c + 1;
                  }
                  //Deletes a favorite
                  if (widget.fav == false && widget.c > 0) {
                    await FirebaseFirestore.instance
                        .collection("Email Users")
                        .doc(widget.user?.uid)
                        .collection('Favorites')
                        .doc(widget.docID)
                        .delete();
                  }
                },
                child: !widget.fav
                    ? Icon(
                        Icons.favorite_outline,
                        size: 25.0,
                      )
                    : Icon(
                        Icons.favorite,
                        size: 25.0,
                        color: Colors.red,
                      ),
              )),
        ));
  }
}

//Search bar functionality
class CustomSearchDelegate extends SearchDelegate {
  List<Recipes>? searchterms;
  getRecipeData({required String? query}) async {
    try {
      searchterms = await _RecipesDisplayState().getRecipes(query);
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
                      c: 0,
                      docID: recipe.id.toString(),
                      instructions: recipe.instructions!,
                    )
                        : RecipeCards(
                      title: recipe.title!,
                      image: "assets/unavailable-image.jpg",
                      isVeg: recipe.vegetarian,
                      time: recipe.preparationMinutes,
                      summary: recipe.summary!,
                      fav: false,
                      c: 0,
                      docID: recipe.id.toString(),
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
                      c: 0,
                      docID: recipe.id.toString(),
                      instructions: recipe.instructions!,
                    )
                        : RecipeCards(
                      title: recipe.title!,
                      image: "assets/unavailable-image.jpg",
                      isVeg: recipe.vegetarian,
                      time: recipe.preparationMinutes,
                      summary: recipe.summary!,
                      fav: false,
                      c: 0,
                      docID: recipe.id.toString(),
                      instructions: recipe.instructions!,
                    );
                  })
              : Center(
                  child: Text("No results obtained"),
                );
        });
  }
}

//Fav object created to aid in mapping to and from Json data
class Fav {
  String id;
  final String Summary;
  final String image;
  final String title;
  final bool isVeg;
  final int time;
  final String instructions;

  Fav(
      {this.id = '',
      required this.Summary,
      required this.image,
      required this.isVeg,
      required this.time,
      required this.title,
      required this.instructions});

  Map<String, dynamic> toJson() => {
        'id': id,
        'Summary': Summary,
        'isVeg': isVeg,
        'time': time,
        'title': title,
        'image': image,
        'instructions': instructions
      };

  static Fav fromJson(Map<String, dynamic> json) => Fav(
      Summary: json["Summary"],
      isVeg: json["isVeg"],
      time: json["time"],
      title: json["title"],
      image: json["image"],
      id: json['id'],
      instructions: json['instructions']);
}
