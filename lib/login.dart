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
import './api/user_api.dart';
import './api/base_api.dart';
import 'package:Shrine/supplemental/validate.dart';
import 'package:Shrine/supplemental/user_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _loginButtonKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
  String _email;
  String _password;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    _usernameController.addListener(() {
      _email = _usernameController.text;
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
    });
    return Scaffold(
      key: _scaffoldState,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              new Align(
                alignment: FractionalOffset.topLeft,
                child: new Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      semanticLabel: 'close',
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
              SizedBox(height: 100.0),
              TextField(
                focusNode: _userNameFocusNode,
                decoration: InputDecoration(
                    filled: true,
                    hintText: 'Email',
                    errorText: _emailErrorText),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                controller: _usernameController,
                autofocus: true,
                enabled: !_loading,
                onEditingComplete: () {
                  if(_checkEmail()) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  }
                },
              ),
              // spacer
              SizedBox(height: 24.0),
              // [Password]
              TextField(
                focusNode: _passwordFocusNode,
                decoration: InputDecoration(
                    filled: true,
                    hintText: 'Password',
                    errorText: _passwordErrorText),
                obscureText: true,
                enabled: !_loading,
                controller: _passwordController,
                onEditingComplete: () {
                  if(_checkPassword()){
                    // _doLogin();
                  }
                },
              ),
              SizedBox(height: 24.0),
              RaisedButton(
                key: _loginButtonKey,
                child: Text('Sign In'),
                textColor: Colors.white,
                color: Colors.lightBlue,
                onPressed: () {
                  _doLogin();
                },
              ),
              SizedBox(height: 24.0),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: Text('No Account Yet？Click to Sign Up',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue)),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
              opacity: _loading ? 1 : 0,
              child: CircularProgressIndicator(),
              duration: Duration(milliseconds: 100),
            ),
          )
        ],
      )),
    );
  }

  bool _checkEmail() {
    if (Validator.isEmail(_email)) {
      setState(() {
        _emailErrorText = ''; 
      });
      
      return true;
    } else {
      setState(() {
        _emailErrorText = 'invalidate email format';
      });
      FocusScope.of(context).requestFocus(_userNameFocusNode);
      return false;
    }
  }

  bool _checkPassword(){
    if (_password.length < 6) {
      setState(() {
        _passwordErrorText = 'inscure password length (length > 6)';
      });
      // FocusScope.of(context).requestFocus(_passwordFocusNode);
      Scrollable.ensureVisible(_loginButtonKey.currentContext);
      return false;
    } else {
      setState(() {
        _passwordErrorText = '';
      });
      return true;
    }
  }

  _doLogin() {
    if (!_checkEmail()) return;

    if(!_checkPassword()) return;

    //dismiss keyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    setState(() {
      _loading = true;
    });
    LoginAPI.login(_email, _password).then((response) {
      setState(() {
        _loading = false;
      });
      if (response.code == WrapCode.Fail) {
        final SnackBar snackbar = SnackBar(
          content: Text(response.msg),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        );
        //BuildContext 在 Scaffold之前会报错
        //https://docs.flutter.io/flutter/material/Scaffold/of.html
        // Scaffold.of(context).showSnackBar(snackbar);
        _scaffoldState.currentState.showSnackBar(snackbar);
      } else {
        UserStorage.getInstance().saveUser(response.result);
        Navigator.pop(context);
      }
    }).catchError((error) {
      print(error);
    });
  }
}
