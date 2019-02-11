import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24),
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
              decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  labelStyle: TextStyle(
                    fontSize: 15,
                  )),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 24),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  labelStyle: TextStyle(
                    fontSize: 15,
                  )),
            ),
            SizedBox(height: 24),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Confirm password',
                  filled: true,
                  labelStyle: TextStyle(
                    fontSize: 15,
                  )),
            ),
            SizedBox(height: 24),
            RaisedButton(
              child: Text('Sign Up'),
              textColor: Colors.white,
              color: Colors.lightBlueAccent,
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
