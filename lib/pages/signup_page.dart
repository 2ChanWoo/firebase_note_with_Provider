import 'package:flutter/material.dart';
import 'package:practice_firebase_note/pages/signin_page.dart';
import 'package:practice_firebase_note/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  static const String routeName = 'signup-page';

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _fkey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  //한번 submit을 하고나면 항상 오토메틱하게 에러를 체킹할 수 있도록?
  // 아~~~ 아무것도 입력 안했는데 빨간불뜨면 이상하니까, submit이후부터 validate를 체크하도록 해준다는거구나!

  final TextEditingController _passwordController = TextEditingController();


  String _name, _email, _password;

  void _submit() async {
    setState( () {
      autovalidateMode = AutovalidateMode.always;
    });

    if(!_fkey.currentState.validate()) return;

    _fkey.currentState.save();

    print('name: $_name, email: $_email, password: $_password');

    try{
      await context
          .read<AuthProvider>() //context.read 는 provider.of 에서 listen:false 와 비슷한 것!
          .signUp(context, name: _name, email: _email, password: _password);

    }catch (e) {
      print(e); //autn_provider에서 rethrow를 해서 여기서 또 받을 수 있다라는거?
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your Notes',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Form(
                key: _fkey,
                autovalidateMode: autovalidateMode,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        //벨리데이터 라는 패키지나 레귤러 익스프레셔? 로 정교하게 설장할 수 있다?!
                        validator: (String val) {
                          if (val.trim().isEmpty) {
                            return 'Name required';
                          }
                          return null;
                        },
                        onSaved: (val) => _name = val,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        //벨리데이터 라는 패키지나 레귤러 익스프레셔? 로 정교하게 설장할 수 있다?!
                        validator: (String val) {
                          if (!val.trim().contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                        onSaved: (val) => _email = val,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true, //글자 별모양으로 표시.
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.security),
                        ),
                        //벨리데이터 라는 패키지나 레귤러 익스프레셔? 로 정교하게 설장할 수 있다?!
                        validator: (String val) {
                          if (val.trim().length < 6) {
                            return 'Password must be at least 1 long';
                          }
                          return null;
                        },
                        onSaved: (val) => _password = val,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 10.0),
                      child: TextFormField(
                        obscureText: true, //글자 별모양으로 표시.
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.security),
                        ),
                        //벨리데이터 라는 패키지나 레귤러 익스프레셔? 로 정교하게 설장할 수 있다?!
                        validator: (String val) {
                          if (_passwordController.text != val) {
                            return 'Password not match';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'SIGN UP',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'GO SIGN IN',
                        style: TextStyle(
                          shadows: [  //그림자를 활용한 Text밑줄과의 간격 벌리기!
                            Shadow(color: Colors.black, offset: Offset(0,-5))
                          ],
                          fontSize: 18.0,
                          color: Colors.transparent,  //투명색
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
