// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './api/user_api.dart';
import './api/base_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  String _email;
  String _password;
  @override
  Widget build(BuildContext context) {
    _usernameController.addListener(() {
      _email = _usernameController.text;
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
    });
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            new Align(
              alignment: FractionalOffset.topLeft,
              child: new Container(
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    semanticLabel: 'back',
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                SizedBox(height: 16.0),
                Text('Rainbow'),
              ],
            ),
            SizedBox(height: 120.0),
            TextField(
              focusNode: _userNameFocusNode,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              controller: _usernameController,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
            ),
            // spacer
            SizedBox(height: 24.0),
            // [Password]
            TextField(
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
              controller: _passwordController,
            ),
            SizedBox(height: 24.0),
            RaisedButton(
              child: Text('Sign In'),
              textColor: Colors.white,
              color: Colors.lightBlue,
              onPressed: () {
                if (_email.length == 0) {
                  FocusScope.of(context).requestFocus(_userNameFocusNode);
                  return;
                }
                if (_password.length == 0) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                  return;
                }
                LoginAPI.login(_email, _password).then((response) {
                  if (response.code == WrapCode.Fail) {
                    Fluttertoast.showToast(
                        msg: response.msg,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIos: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                }).catchError((error) {});
              },
            ),
            SizedBox(height: 24.0),
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushNamed('/register');
              },
              child: Text(
                'No Account Yet？Clike to Sign Up',
                style: TextStyle(decoration: TextDecoration.underline,color: Colors.blue)

              ),
            )
          ],
        ),
      ),
    );
  }
}

