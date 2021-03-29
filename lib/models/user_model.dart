import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;

  User({this.id, this.name, this.email});

  factory User.fromDoc(DocumentSnapshot userDoc) {
    final userData = userDoc.data();

    return User(
      id: userDoc.id,           //DocumentSnapshot 는 유저 정보 가져오는것인듯.
      name: userData['name'],
      email: userData['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      id: id,
      name: name,
      email: email,
    };
  }

  @override
  List<Object> get props =>
      [id, name, email]; //오브젝트가 내용물이 같은지 확인하기 쉽게 하기 위한 패키지.
//원래는 오브젝트 내용이 같더라도 따로 생성되면 다른 객체였는데 요걸로 비교하면 그런거 없어짐
}
