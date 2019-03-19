import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/api/system_api.dart';
import 'package:Rainbow/api/base_api.dart';

class ConfigStorage{
  static ConfigStorage _instance;
  final _tagsJsonArray = [
    {'id' : 1,'name': 'muscle'},
    {'id' : 2,'name': 'chubby'},
    {'id' : 3,'name': 'daddy'},
    {'id' : 4,'name': 'suit'},
    ];
  final _reportsJsonArray = [
    {'id' : 1,'reason' : 'low quality'},
    {'id' : 2,'reason' : 'no bear in picture'},
    {'id' : 3,'reason' : 'infringement'},
    {'id' : 4,'reason' : 'porn'},
    {'id' : 5,'reason' : 'uncomfortable'},
  ];
  String _config;
  List<Tag> _tags;
  List<Report> _reports;
  static getInstance() async{
    if(_instance == null){
      _instance = ConfigStorage();
      _instance._config = await _instance.readConfig();
      _instance.reload();
    }
    return _instance;
  }

  saveConfig(String config) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('config', config);
    _config = config;
    reload();
  }

  readConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('config');
  }

  reload() {
    if(_config != null){
      Map map = json.decode(_config);
      List<Map<String,dynamic>> tagsList =  List<Map<String,dynamic>>.from(map['tags']) ;
      List<Map<String,dynamic>> reportsList = List<Map<String,dynamic>>.from(map['reports']);
      _tags = tagsList.map((map){
        return Tag.fromJson(map);
      }).toList();
      _reports = reportsList.map((map){
        return Report.fromJson(map);
      }).toList();
    } else {
      _tags = _tagsJsonArray.map((Map<String,dynamic>json){
        return Tag.fromJson(json);
      }).toList();
      _reports =_reportsJsonArray.map((Map<String,dynamic>json){
        return Report.fromJson(json);
      }).toList();
    }
  }

  loadFromNetwork() {
    SystemAPI.config().then((response){
      if (response.code == WrapCode.Ok && response.result != null) {
        saveConfig(response.result);
      } 
    });
  }

  tagNameById(int id){
    if (_tags != null ) {
      for (Tag tag in _tags){
      if(tag.id == id){
        return tag.name;
      }
    }
    }
    return null;
  }

  reportReasonById(int id){
    if (_reports !=null) {
      for (Report report in _reports){
      if(report.id == id){
        return report.reason;
      }
      return null;
    }
    }
  }

  reports() {
    return _reports;
  }

  tags() {
    return _tags;
  }
  
}