import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Rainbow/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Rainbow/api/user_api.dart';
import 'package:Rainbow/api/base_api.dart';

class UserStorage {
  // static final UserStorage instance = new UserStorage._internal();
  static final UserStorage instance = new UserStorage();
  final storage = new FlutterSecureStorage();
  User user;
  // factory UserStorage() {
  //   return instance;
  // }

  // UserStorage._internal();

  static  UserStorage getInstance() {
    return instance;
  }

  readUser() async {
    if (user != null) return user;
    String value = await storage.read(key: 'user');
    if (value != null) {
      user = User();
      user.id = int.parse(value);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      user.avatar = prefs.getString('avatar');
      user.age = prefs.getInt('age');
      user.gender = prefs.getInt('gender');
      user.name = prefs.getString('userName');
      user.email = prefs.getString('email');
    }
    return user;
  }

  saveUser(User user) async {
    storage.write(key: 'user', value: user.id.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.name);
    prefs.setString('avatar', user.avatar);
    prefs.setInt('age', user.age);
    prefs.setInt('gender', user.gender);
    prefs.setString('email', user.email);
    this.user = user;
  }

  deleteUser() async {
      storage.delete(key: 'user');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', null);
      prefs.setString('avatar', null);
      prefs.setInt('age', null);
      prefs.setInt('gender', null);
      prefs.setString('email', null);
      user = null;
  }

  saveLastEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_email', user.email);
  }

  readLastEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('last_email');
    return email;
  }

  Future<User> syncUserProfile() async {
    User user = await readUser();
    if (user !=null) {
      WrapResponse response =await UserAPI.profile();
      if (response.result != null) {
        saveUser(response.result);
      }
    }
    return user;
  }
}
