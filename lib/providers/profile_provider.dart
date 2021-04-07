import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:practice_firebase_note/models/user_model.dart';
import '../constants/db_contants.dart';

class ProfileState extends Equatable {
  final bool loading;
  final User user;

  ProfileState({this.loading, this.user});

  @override
  bool get stringify => true;
  @override
  List<Object> get props => [loading, user];

  ProfileState copyWith({bool loading, User user}) {
    return ProfileState(
      loading: loading ?? this.loading,
      user: user ?? this.user,
    );
  }
}

class ProfileProvider with ChangeNotifier {
  ProfileState state = ProfileState(loading: false);

  Future<void> getUserProfile(String userId) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      DocumentSnapshot userDoc = await usersRef.doc(userId).get();
      print('userId :: $userId');
      print('user exists ?? ${userDoc.id}');
      if (userDoc.exists) {
        User user = User.fromDoc(userDoc);
        state = state.copyWith(loading: false, user: user);
        notifyListeners();
      } else {
        print('존재하지 않는 유저입니다.');
        throw Exception('Fail to get user info'); //여기서 throw하면 아래 catch로 감.
      }
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editUserProfile(
      String userId,
      String name,
      String email,
      ) async {
    state = state.copyWith(loading: true);
    notifyListeners();

    try {
      await usersRef.doc(userId).update({
        'name': name,
      });
      state = state.copyWith(
        loading: false,
        user: User(id: userId, name: name, email: email),
      );
      notifyListeners();
    } catch (e) {
      state = state.copyWith(loading: false);
      notifyListeners();
      rethrow;
    }
  }
}