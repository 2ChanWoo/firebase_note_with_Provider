import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
// ㄴ> 별명을 지어준 이유는.. user_model 에서의 혼동가능성이 있기 때문에??
import 'package:provider/provider.dart';

class AuthProgressState extends Equatable {
  final bool loading;

  AuthProgressState({this.loading});

  //이 state자체를 immutable하게 하는 거??
  //value를 직접 true-false로 바꿔주는 게 아니라, 매번 새로운 object를 만드는것? - state가 바뀔때마다
  AuthProgressState copyWIth({bool loading}) {
    return AuthProgressState(loading: loading ?? this.loading);
  }

  @override
  List<Object> get props => [loading];
}

class AuthProvider extends ChangeNotifier {
  final _auth = firebaseAuth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  AuthProgressState state = AuthProgressState(loading: false);

  Future<void> signUp({String name, String email, String password}) async {
    state = state.copyWIth(loading: true);
    notifyListeners();

    try{
      firebaseAuth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      firebaseAuth.User signedInUser = userCredential.user;

      await _firestore.collection('users').doc(signedInUser.uid).set({
        'name': name,
        'email': email,
      });
      state =state.copyWIth(loading: false);
      notifyListeners();
    }catch (e) {
      state = state.copyWIth(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signIn({String email, String password}) async {
    state = state.copyWIth(loading: true);
    notifyListeners();

    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = state.copyWIth(loading: false);
      notifyListeners();
    } catch (e) {
      state = state.copyWIth(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _auth.signOut();
  }
}
