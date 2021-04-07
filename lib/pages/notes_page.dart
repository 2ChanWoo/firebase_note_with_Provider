import 'package:flutter/material.dart';
import 'package:practice_firebase_note/pages/add_edit_note_page.dart';
import 'package:practice_firebase_note/pages/search_page.dart';
import 'package:practice_firebase_note/providers/auth_provider.dart';
import 'package:practice_firebase_note/providers/note_provider.dart';
import 'package:practice_firebase_note/widgets/error_dialog.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;

class NotesPage extends StatefulWidget {
  static const String routeName = 'notes-page';

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String userId;

  @override
  void initState() {
    super.initState();
    //TODO 여기서는 addPostFrameCallback 을 왜 쓸까??
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = context.read<firebaseAuth.User>();
      userId = user.uid;
      try {
        await context.read<NoteList>().getAllNotes(userId);
      } catch (e) {
        errorDialog(context, e);
      }
    });
  }

  Widget _buildBody(NoteListState noteList) {
    if (noteList.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (noteList.notes.length == 0)
      return Center(child: Text('Add some', style: TextStyle(fontSize: 20)));

    Widget showDismissibleBackground(int secondary) {
      return Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        alignment:
            secondary == 0 ? Alignment.centerLeft : Alignment.centerRight,
        child: Icon(
          Icons.delete,
          size: 30,
          color: Colors.white,
        ),
      );
    }

    return ListView.builder(
      itemCount: noteList.notes.length,
      itemBuilder: (BuildContext ctx, int index) {
        final note = noteList.notes[index];
        return Dismissible(
          //[독행소년] 에서는 Key(아이템이름) 으로 생성함.
          //Key생성자는 String값을 아규먼트로 받아서 고유한 키를 생성한다고 함.
          key: ValueKey(note.id),
          onDismissed: (_) async {
            //(_) 여기서 Swipe된 방향을 받을 수 있음.
            try {
              await context.read<NoteList>().removeNote(note);
            } catch (e) {
              errorDialog(context, e);
            }
          },
          confirmDismiss: (_) {
            return showDialog(
                barrierDismissible: false,
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text('Once done, cannot be recovered|'),
                    actions: [
                      FlatButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text('YES')),
                      FlatButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('NO')),
                    ],
                  );
                });
          },
          background: showDismissibleBackground(0),
          secondaryBackground: showDismissibleBackground(1),
          child: Card(
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AddEditNotePage(
                    note: note,
                  );
                }));
              },
              title: Text(
                note.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(note.timestamp.toDate().toIso8601String()),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteList =
        context.watch<NoteList>().state; //???????위에서 read했는데 watch를 또해?
    //이건 위에 read랑은 다르게 .state 가 붙는데 NoteList의 state변수만 watch한다는 건가??

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SearchPage();
                      },
                      fullscreenDialog: true, //이걸 통해 push/present를 구분할 수 있습니다.
                      //라고 되어있는데 쉽게말해 true면 전체화면 다이얼로그형태??
                      //그래서 back버튼(push할떄의 뒤로가기버튼) 대신에 close버튼이 생겨난다!
                    ));
              }),
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return AddEditNotePage();
                  },
                ));
              }),
        ],
      ),
      body: _buildBody(noteList),
    );
  }
}
