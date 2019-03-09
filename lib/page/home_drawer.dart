import 'package:flutter/material.dart';
import 'package:Rainbow/model/user.dart';
import 'package:Rainbow/supplemental/user_storage.dart';
import 'package:Rainbow/supplemental/window_adapt.dart';

class HomeDrawerPage extends StatefulWidget {
  @override
  _HomePageDrawerState createState() => new _HomePageDrawerState();
}

class _HomePageDrawerState extends State<HomeDrawerPage> { 
  User _user;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }
  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.lightBlue;
    _refreshUser();
    return Drawer(
      child: MediaQuery.removePadding(
          context: context,
          removeTop: false,
          child:  Container(
            color: backgroundColor,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: WindowAdapt.px(24),
                ),
                UserAccountsDrawerHeader(  
                  accountName: Text(
                    _user == null ? '--' : _user.name,
                    style: TextStyle(fontSize: 18),
                  ),
                  accountEmail: Text(
                    _user == null ? '--' : _user.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  currentAccountPicture:  
                  GestureDetector(
                      onTap: () {
                        _tapAvatar(context);
                      },
                      child: CircleAvatar(
                        backgroundImage:
                        (_user == null || _user.avatar.length == 0) 
                        ? 
                        AssetImage('assets/default-avatar.png')
                        : 
                        NetworkImage(_user.avatar),)
                    ) ,
                  decoration: BoxDecoration(color: backgroundColor),
                ),
                ListTile(
                  title: Text(
                    'Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.verified_user,
                    color: Colors.white,
                  ),
                  onTap: (){
                    _tapProfile(
                      context
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    'Favorite',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(Icons.favorite, color: Colors.white),
                  onTap: (){
                    _tapFavorite(context);
                  },
                ),
                Divider(
                  color: Colors.white,
                ),
                ListTile(
                  title: Text(
                    'Setting',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  leading: Icon(Icons.settings, color: Colors.white),
                  onTap: (){
                    _tapSetting(context);
                  },
                ),
                SizedBox(
                  height: WindowAdapt.px(24),
                ),
                Container(
                  width: 46,
                  height: 32,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                  child: _buidLoginButton(context),
                )
              ],
            ),
          )),
    );
  }
  //login or logout
  _buidLoginButton(BuildContext context) {
    return _user != null && _user.id != null && _user.id > 0
        ? RaisedButton(
            color: Colors.red[200],
            textColor: Colors.white,
            child: Text('Logout'),
            onPressed: () {
              UserStorage.getInstance().deleteUser().then(() {
                setState(() {
                  _user = null;
                });
              });
            },
          )
        : RaisedButton(
            color: Colors.red[200],
            textColor: Colors.white,
            child: Text('Login'),
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
          );
  }

 _refreshUser(){
   UserStorage.getInstance().readUser().then((user) {
      setState(() {
        _user = user;
      });
    });
 }
  _tapAvatar(BuildContext context){
    if (_user !=null) {
      
    }
  }

  _tapProfile(BuildContext context){
    UserStorage.getInstance().readUser().then((user) {
      if (user != null && user.id > 0) {
      Navigator.of(context).pushNamed('/profile').then((value){
        _refreshUser();
      });
      } else {
        Navigator.of(context).pushNamed('/login');
      }
    });
  }

  _tapFavorite(BuildContext context){
    UserStorage.getInstance().readUser().then((user) {
      if (user != null && user.id > 0) {
      Navigator.of(context).pushNamed('/favorite').then((value){
        _refreshUser();
      });
      } else {
        Navigator.of(context).pushNamed('/login');
      }
    });
  }

  _tapSetting(BuildContext context){
    Navigator.of(context).pushNamed('/setting');
  }
}