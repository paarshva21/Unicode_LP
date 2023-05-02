import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    notifyListeners();

    //checks if users already exists or not in Firestore before creating a user
    if (await checkIfDocExists == false) {
      createUsers();
      print(await checkIfDocExists);
    }
  }

  Future googleLogout() async {
    try {
      await googleSignIn.disconnect();
    } catch (e) {
      print(e);
    }
    await FirebaseAuth.instance.signOut();
  }

  //creates users in Firestore
  Future createUsers() async {
    await FirebaseFirestore.instance
        .collection("Email Users")
        .doc(_user?.id)
        .set({'Email': _user?.email, 'Password': 'NA'});
  }

  //checks if doc exists or not, so as to not create duplicates in Firestore
  Future<bool> checkIfDocExists() async {
    var doc = await FirebaseFirestore.instance
        .collection("Email Users")
        .doc(_user?.id)
        .get();
    try {
      return doc.exists;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
