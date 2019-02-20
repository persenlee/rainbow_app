import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Rainbow/supplemental/network_image_cache_manager.dart';
import 'package:share/share.dart';
import 'webview.dart';
import 'package:Rainbow/api/http_manager.dart';
import 'package:path/path.dart' as p;

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {

  double _cacheSize;
  @override
  void initState() {
    _cacheSize = 0;
    super.initState();
    _getCacheSize().then((double size){
      setState(() {
        _cacheSize = size;
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
                    Text( _cacheSize.toStringAsFixed(2)+'MB'),
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
                    _about(context);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Future<double> _getCacheSize() async{
    int bytes = imageCache.currentSizeBytes ~/ 1024;
    bytes +=await NetworkImageCacheManager().cacheSize();
    return bytes / 1024.0;
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

  _about(BuildContext context){
    HttpManager.sharedInstance().then((manager){
      String baseUrl =manager.baseUrl;
      String url =  p.join(baseUrl,' system/about'); 
      Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return new WebviewPage(title: 'About Rainbow',url: url);
                }));
    }) ;
  }
}