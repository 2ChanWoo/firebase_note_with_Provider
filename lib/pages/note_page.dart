import 'package:flutter/material.dart';
import 'package:practice_firebase_note/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  static const String routeName = 'notes-page';
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(icon: Icon(Icons.exit_to_app), onPressed: () {
            context.read<AuthProvider>().signOut();
          })
        ],
      ),
    );
  }
}
