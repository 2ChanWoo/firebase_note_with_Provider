import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practice_firebase_note/pages/note_page.dart';
import 'package:practice_firebase_note/pages/signin_page.dart';
import 'package:practice_firebase_note/pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
        home: SigninPage(),
      routes: {
        SigninPage.routeName: (context) => SigninPage(),
        SignupPage.routeName: (context) => SignupPage(),
        NotesPage.routeName: (context) => NotesPage(),
      }
    );
  }
}
