import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:practice_firebase_note/pages/home_page.dart';
import 'package:practice_firebase_note/pages/notes_page.dart';
import 'package:practice_firebase_note/pages/signin_page.dart';
import 'package:practice_firebase_note/pages/signup_page.dart';
import 'package:practice_firebase_note/providers/auth_provider.dart';
import 'package:practice_firebase_note/providers/note_provider.dart';
import 'package:practice_firebase_note/providers/profile_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  Widget IsAuthenticated(BuildContext context) {
    if(context.watch<firebaseAuth.User>() != null)
      return HomePage();
    return SigninPage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<firebaseAuth.User>.value(
            value: firebaseAuth.FirebaseAuth.instance.authStateChanges()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<NoteList>(
          create: (context) => NoteList(),
        ),
        ChangeNotifierProvider<ProfileProvider>(create: (context) => ProfileProvider(),),
      ],
      child: MaterialApp(
          title: 'Note',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),

          /***** Builder를 안쓰면, context가 최상위라 에러남. context는 그 위에 context를 찾아가는거라. *****/
          home: Builder(builder: (context) => IsAuthenticated(context)),
          routes: {
            SigninPage.routeName: (context) => SigninPage(),
            SignupPage.routeName: (context) => SignupPage(),
            NotesPage.routeName: (context) => NotesPage(),
          }),
    );
  }
}
