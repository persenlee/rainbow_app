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
import 'package:Rainbow/supplemental/config_storage.dart';
import 'package:Rainbow/page/profile.dart';
import 'package:Rainbow/page/setting.dart';
import 'package:Rainbow/page/favorite.dart';
import 'package:Rainbow/supplemental/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:Rainbow/api/http_manager.dart';

class ShrineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _loadConfig();
    _baseUrlChange(context);
    return MaterialApp(
      title: 'Rainbow',
      home: HomePage(),
      onGenerateRoute: _getRoute,
    );
  }

  _loadConfig() async{
    ConfigStorage storage = await ConfigStorage.getInstance();
    storage.loadFromNetwork();
  }

  _baseUrlChange(BuildContext context) {
    if (Util.buildMode() ==BuildMode.debug) {
      
      Util.listenMotionShake((result){
        if (result) {
          CupertinoActionSheet sheet = CupertinoActionSheet(
            title: Text('API http domain switch'),
            message: Text(''),
            cancelButton: CupertinoActionSheetAction(
              child: Text('Cancel'),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            actions: 
          <Widget>[
            CupertinoActionSheetAction(
              child: Text('Company [http://192.168.0.200:8000]'),
              onPressed: (){

              }),
            CupertinoActionSheetAction(
              child: Text('Home [http://192.168.0.200:8000]'),
              onPressed: (){

              }),
          ]);
          showCupertinoModalPopup(
            context: context,
            builder:(BuildContext context) => sheet
          ).then((value){
            HttpManager.sharedInstance().resetBaseUrl(value);
          });
          
        }
      });
    }
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
      default:
    }
    return MaterialPageRoute<void>(
      settings: settings,
      builder: builder,
      fullscreenDialog: true,
    );
  }
}
