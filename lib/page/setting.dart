import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
                title: Text('Clean Cache'),
                trailing: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('0.00MB'),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[350],
                    )
                  ],
                ),
                onTap: () {

                },
              ),
              Divider(),
              ListTile(
                title: Text('Share Rainbow To Friends'),
                onTap: () {
                  
                },
                trailing:Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[350],
                    )
              ),
              Divider(),
              ListTile(
                  title: Text(
                    'About Rainbow'
                  ),
                  trailing:Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[350],
                    ),
                  onTap: (){

                  },
                ),
          ],
        ),
      ),
    );
  }
}