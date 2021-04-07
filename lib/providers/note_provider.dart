import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:practice_firebase_note/constants/db_contants.dart';
import 'package:practice_firebase_note/models/note_model.dart';

/***
 * 유저와 노트를 나누는 방식 중에서, (순서대로 컬렉션-도큐먼트-컬렉션/필드 ... 인 파베 형식이라 했을 때)
 * notes - 유저'들'의 note들 - 각 노트마다 userId에 대한 정보를 가지고 있게하기.
 *
 * notes - userID - userNotes - 한 유저의 노트들            <== 이 방식으로 할거임.
 *  이 경우, 한사람의 노트에 대한 정보만 필요할경우 용이함.
 * ***/

class NoteListState extends Equatable {
  final bool loading; // 삭제나 생성할 때?
  final List<Note> notes;

  NoteListState({this.loading, this.notes});

  NoteListState copyWith({bool loading, List<Note> notes}) {
    return NoteListState(
      loading: loading ?? this.loading,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool get stringify => true; //프린트 할 때 보기 편하게 나오게 하기 위한.

  @override
  List<Object> get props => [loading, notes];
}

class NoteList extends ChangeNotifier {
  NoteListState state = NoteListState(loading: false, notes: []);

  void handleError(Exception e) {
    print(e);
    state = state.copyWith(loading: false);
    notifyListeners();
  }

  /** notesRef 는 db_content에 있는 FirebaseFirestore.instance.collection('notes') 이다. **/
  Future<void> getAllNotes(String userId) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      QuerySnapshot userNotesSnapshot = await notesRef
          .doc(userId)
          .collection('userNotes')
          .orderBy('timestamp', descending: true)
          .get();

      List<Note> notes = userNotesSnapshot.docs.map((noteDoc) {
        return Note.fromDoc(noteDoc);
      }).toList();

      state = state.copyWith(loading: false, notes: notes);
      notifyListeners();
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  Future<List<QuerySnapshot>> searchNotes(
      String userId,
      String searchTerm,
      ) async {
    try {
      final snapshotOne = notesRef
          .doc(userId)
          .collection('userNotes')
          .where('title', isGreaterThanOrEqualTo: searchTerm);

      final snapshotTwo = notesRef
          .doc(userId)
          .collection('userNotes')
          .where('desc', isGreaterThanOrEqualTo: searchTerm);

      final userNotesSnapshot =
      await Future.wait([snapshotOne.get(), snapshotTwo.get()]);
      //ㄴ> awaut Future.wait => 여러개의 Future작업 기다리기.

      return userNotesSnapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addNote(Note newNote) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      DocumentReference docRef =
          await notesRef
              .doc(newNote.noteOwnerId)
              .collection('userNotes')
              .add({
        'title': newNote.title,
        'desc': newNote.desc,
        'noteOwnerId': newNote.noteOwnerId,
        'timestamp': newNote.timestamp,
      });

      //TODO 여기서부터 copyWith랑 요 위에 DocumentReference 변수저장은 왜 한거냐?? 위 add에서 ID를 몰라서?
      //아... ID는 자동으로 생성되는걸로 하니까, 그 아이디를 알려고?
      // 그런가보넹~ userNotes 컬렉션에서 document이름을 정하지 않고 바로 add했으니까 자동ID생성이니까~
      //그래도 아직 이 아래 note에 저장해두는건 아직도 의중을 모르겠구나..
      final note = Note(
        id: docRef.id,
        title: newNote.title,
        desc: newNote.desc,
        noteOwnerId: newNote.noteOwnerId,
        timestamp: newNote.timestamp,
      );
      state = state.copyWith(loading: false, notes: [
        note,
        ...state.notes, //이렇게 해도 이전 state의notes들이 들어가는군.
      ]);
      notifyListeners();
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await notesRef
          .doc(note.noteOwnerId)
          .collection('userNotes')
          .doc(note.id)
          .update({
        'title': note.title,
        'desc': note.desc,
      });

      final notes = state.notes.map((n) {
        return n.id == note.id
            ? Note(
                id: n.id,
                title: note.title,
                desc: note.desc,
                timestamp: note.timestamp,
              )
            : n;
      }).toList();

      state = state.copyWith(loading: false, notes: notes);
      notifyListeners();
      //print(state.notes); 함수시작부분에서는 notes 안써줘서 초기화되는거 아닌가 했는데,
      // copyWith에서 this.note라서 초기화되지는 않지.
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  Future<void> removeNote(Note note) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await notesRef.doc(note.noteOwnerId)
          .collection('userNotes')
          .doc(note.id)
          .delete();

      final notes = state.notes.where((n) => n.id != note.id).toList();
      state = state.copyWith(loading: false, notes: notes);
      notifyListeners();
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }
}
