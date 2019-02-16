import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:Rainbow/model/feed.dart';
import 'package:Rainbow/api/system_api.dart';
import 'package:Rainbow/api/base_api.dart';

class ConfigStorage{
  static ConfigStorage _instance;
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
    for (Tag tag in _tags){
      if(tag.id == id){
        return tag.name;
      }
    }
    return null;
  }

  reportReasonById(int id){
    for (Report report in _reports){
      if(report.id == id){
        return report.reason;
      }
      return null;
    }
  }
  
}