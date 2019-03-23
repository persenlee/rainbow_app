import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter/services.dart';
import 'package:store_rate/store_rate.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AboutPageState();
  }
}

class _AboutPageState extends State<AboutPage> {
  final GlobalKey<ScaffoldState> _scaffoldState = new GlobalKey();
  final String _des = 'A better gallery for bear group';
  final String twitterAccount = '@Bearhub';
  final String weiboAccount = 'Bearhub';
  final String wechatAccount = 'Bearhub';
  final String emailAccount = 'Bearhub01@gmail.com';
   String _version = '';
  @override
  void initState() {
    _getVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text('About'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 60.0),
            Column(
              children: <Widget>[
                Image.asset('assets/bear.png',width: 61.2,height: 66.6,),
                SizedBox(height: 16.0),
                Text('Bearhub',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color.fromRGBO(0x2f, 0x5a, 0x7f, 1)),),
                SizedBox(height: 16.0),
                Text(_des),
              ],
            ),
            SizedBox(height: 36,),
            Divider(),
            ListTile(
              title: Text('Rate For Bearhub'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: (){
                StoreRate.rate(RateType.RateTypeInApp, null);
              },
            ),
            Divider(),
            ListTile(
              title: Text('Weibo'),
              trailing: Text(weiboAccount),
            ),
            Divider(),
            ListTile(
              title: Text('WeChat Group'),
              trailing: Text(wechatAccount),
            ),
            Divider(),
            ListTile(
              title: Text('Twitter'),
              trailing: Text(twitterAccount),
            ),
            Divider(),
            ListTile(
              title: Text('Email'),
              trailing: Text(emailAccount),
              onLongPress: (){
                _copyText(context, emailAccount);
              },
            ),
            Divider(),
            SizedBox(height: 48,),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: <Widget>[
                  Text(_version,style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(height: 24,),
                  Text('Copyright © 2019 Bearhub. All rights reserved'),
                  SizedBox(height: 12,)
                ],
              )
            ),
           
          ],
        ),
      ),
    );
  }

  _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version ?? '';
    String buildNumber = packageInfo.buildNumber ?? '';
    setState(() {
      _version = 'Version ' + version + '(' + buildNumber + ')';
    });
  }

  _copyText(BuildContext context,String text){
    ClipboardData data =ClipboardData(text:text);
    Clipboard.setData(data);
    final snackBar = SnackBar(
                          content: Text('Copied to Clipboard'),
                        );
    _scaffoldState.currentState.showSnackBar(snackBar);
  }
}
