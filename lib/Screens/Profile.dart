import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Screens/UserPage.dart';
import 'package:untitled/Models/Utils.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "", veg = "", cuisine = "";

  final TextEditingController _nameController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  final formkey1 = GlobalKey<FormState>();

  final VegList = [
    "None",
    "Vegetarian",
    "Non-vegetarian",
    "Vegan",
  ];
  final CuisineList = [
    "None",
    "African",
    "American",
    "British",
    "Cajun",
    "Caribbean",
    "Chinese",
    "Eastern European",
    "European",
    "French",
    "German",
    "Greek",
    "Indian",
    "Irish",
    "Italian",
    "Japanese",
    "Jewish",
    "Korean",
    "Latin American",
    "Mediterranean",
    "Mexican",
    "Middle Eastern",
    "Nordic",
    "Southern",
    "Spanish",
    "Thai",
    "Vietnamese"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readUser(),
      builder: (context, snapshot) {
        return Form(
            key: formkey1,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/blacked.jpg"),
                      fit: BoxFit.cover,
                      opacity: 0.5)),
              child: SafeArea(
                child: Center(
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: GestureDetector(
                      onTap: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(children: [
                            SizedBox(
                              width: 20.0,
                              height: 30.0,
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 300.0),
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserPage()));
                                  },
                                  icon: Icon(Icons.arrow_back_sharp),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 35.0, right: 35.0),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 20.0,
                                    height: 40.0,
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "Profile",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(20.0)),
                                  Container(
                                    child: user.photoURL == null
                                        ? CircleAvatar(
                                            radius: 60,
                                            backgroundImage:
                                                AssetImage("assets/profile.jpg"))
                                        : CircleAvatar(
                                            radius: 60,
                                            backgroundImage:
                                                NetworkImage(user.photoURL!),
                                          ),
                                  ),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  snapshot.data?.Name == null
                                      ? TextFormField(
                                          controller: _nameController,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(13),
                                              fillColor: Colors.white,
                                              filled: true,
                                              hintText: "Name",
                                              hintStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                              errorStyle: TextStyle(
                                                color: Colors.red,
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7.0),
                                                  borderSide: BorderSide.none)),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Name is required';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            name = value!;
                                          },
                                        )
                                      : TextFormField(
                                          controller: TextEditingController(
                                              text: snapshot.data?.Name),
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(13),
                                              fillColor: Colors.white,
                                              filled: true,
                                              hintText: snapshot.data?.Name,
                                              hintStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey),
                                              errorStyle: TextStyle(
                                                color: Colors.red,
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7.0),
                                                  borderSide: BorderSide.none)),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Name is required';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            name = value!;
                                          },
                                        ),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  DropdownButtonFormField(
                                    items: VegList.map((e) {
                                      return DropdownMenuItem(
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey),
                                        ),
                                        value: e,
                                      );
                                    }).toList(),
                                    value: snapshot.data?.Veg == null
                                        ? VegList[0]
                                        : LoopVeg(snapshot.data?.Veg),
                                    onChanged: (val) {},
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(13),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                            borderSide: BorderSide.none)),
                                    onSaved: (value) {
                                      veg = value!;
                                    },
                                  ),
                                  Padding(padding: EdgeInsets.all(10.0)),
                                  DropdownButtonFormField(
                                    items: CuisineList.map((e) {
                                      return DropdownMenuItem(
                                        child: Text(
                                          e,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey),
                                        ),
                                        value: e,
                                      );
                                    }).toList(),
                                    value: snapshot.data?.Cuisine == null
                                        ? CuisineList[0]
                                        : LoopCuisine(snapshot.data?.Cuisine),
                                    onChanged: (val) {},
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(13),
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                            borderSide: BorderSide.none)),
                                    onSaved: (value) {
                                      cuisine = value!;
                                    },
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                    height: 50.0,
                                  ),
                                  Container(
                                      width: 135.0,
                                      height: 40.0,
                                      color: Colors.green,
                                      child: TextButton(
                                        onPressed: () {
                                          formkey1.currentState!.save();
                                          if (formkey1.currentState!.validate()) {
                                            createUser();
                                            Utils.showSnackBar1("Profile saved!");
                                          }
                                        },
                                        child: Text(
                                          "Save Profile",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )),
                                  SizedBox(width: 20.0, height: 50),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  Future<User?> readUser() async {
    var doc = await FirebaseFirestore.instance
        .collection("Email Users")
        .doc(user.uid)
        .get();
    if (doc.exists) {
      return User.fromJson(doc.data()!);
    }
  }

  Future createUser() async {
    await FirebaseFirestore.instance
        .collection("Email Users")
        .doc(user.uid)
        .set({'Name': name, 'Veg': veg, 'Cuisine': cuisine});
  }

  String LoopVeg(String? veg) {
    for (int i = 0; i < VegList.length; i++) {
      if (VegList[i] == veg) {
        return VegList[i];
      }
    }
    return "Loading";
  }

  String LoopCuisine(String? cuisine) {
    for (int i = 0; i < CuisineList.length; i++) {
      if (CuisineList[i] == cuisine) {
        return CuisineList[i];
      }
    }
    return "Loading";
  }
}

class User {
  final String Name;
  final String Cuisine;
  final String Veg;

  User({
    required this.Cuisine,
    required this.Name,
    required this.Veg,
  });

  Map<String, dynamic> toJson() => {
        'Name': Name,
        'Veg': Veg,
        'Cuisine': Cuisine,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        Name: json["Name"],
        Veg: json["Veg"],
        Cuisine: json["Cuisine"],
      );
}
