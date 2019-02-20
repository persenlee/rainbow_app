import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Rainbow/supplemental/network_image_cache_manager.dart';
import 'package:share/share.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {

  int _cacheSize;
  @override
  void initState() {
    _cacheSize = 0;
    super.initState();
    _getCacheSize().then((size){
      setState(() {
        _cacheSize =size;
      });
    });
  }
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
                    Text( _cacheSize.toString()+'MB'),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[350],
                    )
                  ],
                ),
                onTap: () {
                  _cleanCache();
                },
              ),
              Divider(),
              ListTile(
                title: Text('Share Rainbow To Friends'),
                onTap: () {
                  _share();
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

  _getCacheSize() async{
    int bytes = imageCache.currentSizeBytes;
    bytes +=await NetworkImageCacheManager().cacheSize();
    return bytes / 1024;
  }

  _cleanCache(){
    imageCache.clear();
    NetworkImageCacheManager().clean();
    setState(() {
      _cacheSize = 0;
    });
  }

  _share(){
    Share.share('Share Rainbow To Friends');
  }
}