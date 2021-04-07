import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice_firebase_note/models/note_model.dart';
import 'package:practice_firebase_note/providers/note_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

import 'add_edit_note_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController;
  Future<List<QuerySnapshot>> _notes;
  String userId, searchTerm;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<FirebaseAuth.User>();
      userId = user.uid;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _notes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(color: Colors.white),
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            filled: true,
            border: InputBorder.none,
            hintText: 'search...',
            hintStyle: TextStyle(color: Colors.white),
            prefixIcon: Icon(
              Icons.search,
              size: 30.0,
              color: Colors.white,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                size: 30.0,
                color: Colors.white,
              ),
              onPressed: _clearSearch,
            ),
          ),
          onSubmitted: (val) {  //엔터버튼을 눌렀을 때.
            setState(() {
              _notes = context.read<NoteList>().searchNotes(userId, searchTerm);
            });
          },
        ),
      ),
      body: _notes == null
          ? Center(
        child: Text(
          'Search for Notes',
          style: TextStyle(fontSize: 18.0),
        ),
      )
          : FutureBuilder(
        future: _notes,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          print(snapshot.data[0]);

          List<Note> foundNotes = [];

          for (int i = 0; i < snapshot.data.length; i++) {
            for (int j = 0; j < snapshot.data[i].docs.length; j++) {
              foundNotes.add(Note.fromDoc(snapshot.data[i].docs[j]));
            }
          }

          foundNotes = [
            ...{...foundNotes}
          ];

          if (foundNotes.length == 0) {
            return Center(
              child: Text(
                'No note found, please try again',
                style: TextStyle(fontSize: 18.0),
              ),
            );
          }
          return ListView.builder(
            itemCount: foundNotes.length,
            itemBuilder: (BuildContext context, int index) {
              final Note note = foundNotes[index];

              //TODO 카드를 분리해서, noteItem 으로 만드는게 좋겠구만.
              return Card(
                child: ListTile(
                  onTap: () async {
                    //여기서도 노트를 클릭하면 상세화면으로 가 지는데,
                    //상세화면에서 노트를 수정하면 검색화면에서도 반영이 되도록 하기위함.
                    final modified = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AddEditNotePage(note: note);
                        },
                      ),
                    );
                    if (modified == true) {
                      //TODO 리빌드하면 적용되는게 아닌가? 굳이 다시 불러들여와야해? -- watch가 아니구만. 바꿔볼까..
                      setState(() {
                        _notes = context
                            .read<NoteList>()
                            .searchNotes(userId, searchTerm);
                      });
                    }
                  },
                  title: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
//                  subtitle: Text(
//                    DateFormat('yyyy-MM-dd, hh:mm:ss')
//                        .format(note.timestamp.toDate()),
//                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
