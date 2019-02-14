

class Validator {
  static bool isEmail(String email){
    if(email == null || email.trim().length < 5) {
      return false;
    }
    String regexStr = r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$';
    RegExp regex = RegExp(regexStr);
    return regex.hasMatch(email);
  }
}