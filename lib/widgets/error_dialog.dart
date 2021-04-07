
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void errorDialog(BuildContext context, Exception e) {
  String errorTitle;
  String errorPlugin;
  String errorMessage;

  if( e is FirebaseAuthException) {
    errorTitle = e.code;
    errorMessage = e.message;
    errorPlugin = e.plugin;
  } else {
    errorTitle = 'Exception';
    errorPlugin = 'flutter_error/server_error';
    errorMessage = e.toString();
  }
  if(Platform.isIOS) {
//빌드를 하고있는데 다이어로그(또 다른 빌드)를 띄울 때 에러가 날 수 있음.??
  //그래서 세이프가드로 아래 함수안에다 다이어로그를 넣어준다.!
    //지금 하고 있는 빌드가 다 끝난 후에 시작이 될 수 있도록 보장해주는 함수.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCupertinoDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: Text(errorTitle),
          content: Text(errorPlugin + '\n' + errorMessage),
          actions: [
            CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: Text('OK'),)
          ],
        );
      });
    });

  }else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
          barrierDismissible: false, // 반드시 버튼을 눌려야지만 사라지는 기능?
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(errorTitle),
              content: Text(errorPlugin + '\n' + errorMessage),
              actions: [
                FlatButton(onPressed: () => Navigator.pop(context), child: Text('OK'),)
              ],
            );
          }
      );
    });

  }
}