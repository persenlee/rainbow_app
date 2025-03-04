import 'package:flutter/material.dart';
import 'package:Rainbow/api/user_api.dart';
import 'package:Rainbow/api/base_api.dart';
import 'package:Rainbow/supplemental/validate.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();
  final _registerButtonKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
  String _email;
  String _password;
  String _confirm;
  String _emailErrorText = '';
  String _passwordErrorText = '';
  String _confirmErrorText = '';

  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    _usernameController.addListener(() {
      _email = _usernameController.text;
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
    });
    _confirmController.addListener(() {
      _confirm = _confirmController.text;
    });
    return new Scaffold(
      key: _scaffoldState,
      body: SafeArea(
          child: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Stack(
                children: <Widget>[
                  ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    children: <Widget>[
                      SizedBox(height: 80.0),
                      Column(
                        children: <Widget>[
                          Image.asset('assets/bear.png',width: 61.2,height: 66.6,),
                          SizedBox(height: 16.0),
                          Text('Bearhub',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color.fromRGBO(0x2f, 0x5a, 0x7f, 1)),),
                        ],
                      ),
                      SizedBox(height: 90.0),
                      TextField(
                        controller: _usernameController,
                        focusNode: _userNameFocusNode,
                        decoration: InputDecoration(
                            hintText: 'Email',
                            errorText: _emailErrorText,
                            filled: true,
                            labelStyle: TextStyle(
                              fontSize: 15,
                            )),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          if (_checkEmail()) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          }
                        },
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: 'Password',
                            errorText: _passwordErrorText,
                            filled: true,
                            labelStyle: TextStyle(
                              fontSize: 15,
                            )),
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          if (_checkPassword()) {
                            FocusScope.of(context)
                                .requestFocus(_confirmFocusNode);
                          }
                        },
                      ),
                      SizedBox(height: 18),
                      TextField(
                        controller: _confirmController,
                        focusNode: _confirmFocusNode,
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            errorText: _confirmErrorText,
                            filled: true,
                            labelStyle: TextStyle(
                              fontSize: 15,
                            )),
                        onEditingComplete: () {
                          if(_checkConfirmPassword()){
                            _doRegister();
                          }
                        },
                      ),
                      SizedBox(height: 18),
                      Container(
                        height: 46,
                        child: RaisedButton(
                          key: _registerButtonKey,
                          child: Text('Sign Up'),
                          textColor: Colors.white,
                          color: Color.fromRGBO(0x2f, 0x5a, 0x7f, 1),
                          onPressed: () {
                            _doRegister();
                          },
                        ),
                      )
                    ],
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedOpacity(
                      opacity: _loading ? 1 : 0,
                      child: CircularProgressIndicator(),
                      duration: Duration(milliseconds: 100),
                    ),
                  ),
                  new Align(
                    alignment: FractionalOffset.topLeft,
                    child: new Container(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          semanticLabel: 'back',
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ))),
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

  bool _checkPassword() {
    if (_password.length < 6) {
      setState(() {
        _passwordErrorText = 'inscure password length (length > 6)';
      });
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      return false;
    } else {
      setState(() {
        _passwordErrorText = '';
      });
      return true;
    }
  }

  bool _checkConfirmPassword() {
    if (_confirm != _password) {
      setState(() {
        _confirmErrorText = 'confirm password error';
      });
      // FocusScope.of(context).requestFocus(_passwordFocusNode);
      Scrollable.ensureVisible(_registerButtonKey.currentContext);
      return false;
    } else {
      setState(() {
        _confirmErrorText = '';
      });
      return true;
    }
  }

  _doRegister() {
    if (!_checkEmail()) return;

    if (!_checkPassword()) return;

    if (!_checkConfirmPassword()) return;

    //dismiss keyboard
    FocusScope.of(context).requestFocus(new FocusNode());

    setState(() {
      _loading = true;
    });
    UserAPI.register(_email, _password).then((response) {
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
        // UserStorage.getInstance().saveUser(response.result);
        // UserStorage.getInstance().saveLastEmail(_email);
        Navigator.pop(context, _email);
      }
    }).catchError((error) {
      print(error);
    });
  }
}
