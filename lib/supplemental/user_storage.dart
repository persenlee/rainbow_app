import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Shrine/model/user.dart';
// import 'package:shared_preferences/shared_preferences.dart';

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
    } else {
      user.id = 0;
    }
    return user;
  }
}
