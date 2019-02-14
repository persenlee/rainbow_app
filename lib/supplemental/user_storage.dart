import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Shrine/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  // static final UserStorage instance = new UserStorage._internal();
  static final UserStorage instance = new UserStorage();
  final storage = new FlutterSecureStorage();
  final User user = null;
  // factory UserStorage() {
  //   return instance;
  // }

  // UserStorage._internal();

  static getInstance() {
    return instance;
  }

  readUser() async {
    String value = await storage.read(key: 'user');
    User user = User();
    if (value != null) {
      user.id = int.parse(value);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      user.avatar = prefs.getString('avatar');
      user.age = prefs.getInt('age');
      user.gender = prefs.getInt('gender');
      user.userName = prefs.getString('userName');
    } else {
      user.id = 0;
    }
    return user;
  }

  saveUser(User user) async{
    storage.write(key: 'user' ,value: user.id.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.userName);
    prefs.setString('avatar',user.avatar);
    prefs.setInt('age', user.age);
    prefs.setInt('gender', user.gender);
  }
}
