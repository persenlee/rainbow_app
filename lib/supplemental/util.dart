
class Util {
  static String genderConvert(int gender){
    String genderStr = 'Male';
    switch (gender) {
      case 0:
        genderStr = 'Male';
        break;
      case 1:
        genderStr = 'Femal';
        break;
      case 2:
        genderStr = 'Others';
        break;
      default:
    }
    return genderStr;
  }
}