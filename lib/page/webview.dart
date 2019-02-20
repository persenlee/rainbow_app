import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebviewPage extends StatefulWidget 
{
  final url;
  final title;

  WebviewPage({key,this.title,this.url}):super(key:key);

  @override
  State<StatefulWidget> createState() {

    return _WebviewPageState();
  }
}

class _WebviewPageState extends State<WebviewPage> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url:  widget.url,
      appBar: new AppBar(
            title: new Text(widget.title == null ? "" :widget.title),
          ),
    );
  }
}
