import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:practice_firebase_note/models/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:practice_firebase_note/providers/note_provider.dart';
import 'package:practice_firebase_note/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

class AddEditNotePage extends StatefulWidget {
  final Note note;

  const AddEditNotePage({Key key, this.note}) : super(key: key);

  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled; //enum
  String _title, _desc;

  void _submit(String mode) async {
    setState(() {
      autovalidateMode = AutovalidateMode.always;
    });

    if(!_formKey.currentState.validate()) return;
    _formKey.currentState.save();

    try {
      final noteOwnerId = context.read<firebaseAuth.User>().uid;

      if(mode == 'add') {   /** 노트를 새로 추가하는 경우. **/
        final newNote = Note(
          title: _title,
          desc: _desc,
          noteOwnerId: noteOwnerId,
          timestamp: Timestamp.fromDate(DateTime.now()),
        );
        await context.read<NoteList>().addNote(newNote);
      }
      else {                /** 노트를 수정하는 경우. **/
        final newNote = Note(
          id: widget.note.id,
          title: _title,
          desc: _desc,
          noteOwnerId: noteOwnerId,
          timestamp: widget.note.timestamp,
        );
        await context.read<NoteList>().updateNote(newNote);
      }

      Navigator.pop(context,true);
    } catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteList = context.watch<NoteList>().state;

    return Scaffold(
      appBar: AppBar(
        title: widget.note == null ? Text('Add Note') : Text('Edit Note'),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            autovalidateMode: autovalidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 10),
                  child: TextFormField(
                    initialValue:
                        widget.note != null ? widget.note.title : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'Title',
                    ),
                    validator: (val) =>
                        val.trim().isEmpty ? 'Title required' : null,
                    onSaved: (val) => _title = val,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    initialValue:
                        widget.note != null ? widget.note.desc : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      labelText: 'Description',
                    ),
                    validator: (val) =>
                        val.trim().isEmpty ? 'Description required' : null,
                    onSaved: (val) => _desc = val,
                  ),
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                  onPressed: noteList.loading ? null : () =>
                  _submit(widget.note == null ? 'add' : 'edit'),
                  child: Text(widget.note == null ? 'Add Note' : 'Edit Note',
                  style: TextStyle(fontSize: 20),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
