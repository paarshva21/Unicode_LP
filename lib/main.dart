import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/Login/Login.dart';
import 'package:untitled/Login/Signup/GoogleClassSignIn.dart';
import 'package:untitled/HomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Models/Utils.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => GoogleSignInProvider(),
    child: MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark
      ),
      themeMode: ThemeMode.system,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  ));
}
