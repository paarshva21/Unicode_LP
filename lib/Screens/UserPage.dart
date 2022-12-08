import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:untitled/HomePage.dart';
import 'package:untitled/Login/Login.dart';
import 'package:untitled/Login/Signup/GoogleClassSignIn.dart';
import 'package:untitled/Screens/Profile.dart';
import 'package:untitled/Screens/RecipesDisplay.dart';
import 'package:untitled/Models/Utils.dart';
import 'package:untitled/Screens/Setting.dart';
import 'AboutUs.dart';
import 'Desserts.dart';
import 'Favorites.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  final screens = [
    RecipesDisplay(),
    Cuisines(),
    Favorites(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: screens[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.green,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedFontSize: 18,
          unselectedFontSize: 14,
          iconSize: 27,
          showUnselectedLabels: false,
          currentIndex: currentIndex,
          onTap: (index) => setState(() {
            currentIndex = index;
          }),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.fastfood,
                color: Colors.white,
              ),
              label: "Recipes",
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                Icons.icecream,
                color: Colors.white,
              ),
              label: "Desserts",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: Colors.white,
              ),
              label: "Favourites",
            ),
          ],
        ),
        drawer: NavigationDrawer(),
      ),
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
