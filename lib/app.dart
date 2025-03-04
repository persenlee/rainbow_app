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
import 'package:Rainbow/page/home.dart';
import 'package:Rainbow/page/login.dart';
import 'package:Rainbow/page/register.dart';
import 'package:Rainbow/page/profile.dart';
import 'package:Rainbow/page/setting.dart';
import 'package:Rainbow/page/favorite.dart';
import 'package:Rainbow/page/about.dart';

class RainbowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bearhub',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          brightness: Brightness.dark,
          color: Color.fromRGBO(0x2f, 0x5a, 0x7f, 1)
        ),
        
      ),
      home: HomePage(),
      onGenerateRoute: _getRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  //Navigator.of(context).pushNamed('/login');
  Route<dynamic> _getRoute(RouteSettings settings) {
    WidgetBuilder builder;
    switch (settings.name) {
      case '/login':
        builder = (BuildContext context) => LoginPage();
        break;
      case '/register':
        builder = (BuildContext context) => RegisterPage();
        break;
      case '/profile':
        builder = (BuildContext context) => ProfilePage();
        break;
      case '/setting':
        builder = (BuildContext context) => SettingPage();
        break;
      case '/favorite':
        builder = (BuildContext context) => FavoritePage();
        break;
      case '/about':
        builder = (BuildContext context) => AboutPage();
        break;
      default:
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: builder,
      fullscreenDialog: false,
    );
  }
}
