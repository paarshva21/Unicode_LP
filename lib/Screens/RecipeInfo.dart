import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Models/Utils.dart';
import 'UserPage.dart';

//creates a recipe info widget for each recipe
class RecipeInfo extends StatefulWidget {
  var user = FirebaseAuth.instance.currentUser;
  final String instructions;
  final String docID;
  int c;
  bool fav;
  final String title;
  final String image;
  final int time;
  final bool isVeg;
  final String summary;
  RecipeInfo(
      {Key? key,
      required this.title,
      required this.image,
      required this.time,
      required this.isVeg,
      required this.summary,
      required this.docID,
      required this.c,
      required this.fav,
      required this.instructions})
      : super(key: key);

  @override
  State<RecipeInfo> createState() => _RecipeInfoState();
}

class _RecipeInfoState extends State<RecipeInfo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserPage()));
                  },
                ),
                title: Text("Recipe Information"),
                backgroundColor: Colors.green,
                actions: [
                  Container(
                    padding: EdgeInsets.only(right: 10.0),
                    child: StatefulBuilder(
                      builder: (BuildContext context,
                          void Function(void Function()) setState) {
                        return InkWell(
                          onTap: () async {
                            setState(() {
                              widget.fav = !widget.fav;
                            });
                            widget.fav
                                ? Utils.showSnackBar2("Added to favourites!")
                                : Utils.showSnackBar2(
                                    "Removed from favourites!");
                            if (widget.fav == true) {
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
                            if (widget.fav == false) {
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
                        );
                      },
                    ),
                  )
                ]),
            body: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Container(
                    height: 270,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: NetworkImage(widget.image),
                      fit: BoxFit.contain,
                    ))),
                Container(
                    child: Column(children: [
                  Text(
                    widget.title,
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(
                    "About Recipe",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0,
                        decoration: TextDecoration.underline),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(
                    widget.summary,
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                        fontSize: 15.0),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(
                    "Instructions",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.0,
                        decoration: TextDecoration.underline),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(
                    widget.instructions,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                      fontSize: 15.0,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                  ),
                ]))
              ]),
            ))));
  }
}
