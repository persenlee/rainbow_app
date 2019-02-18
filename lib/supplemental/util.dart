import 'dart:core';
import 'package:sensors/sensors.dart';

enum BuildMode { release, profile, debug }

typedef MotionShakeDetectCallback = void Function(bool);

class Util {
  static final MotionShakeDetector shakeDetector =MotionShakeDetector();
  static String genderConvert(int gender) {
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

  static BuildMode buildMode() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return BuildMode.release;
    } else {
      return BuildMode.release;
    }
  }

  static listenMotionShake(MotionShakeDetectCallback callback){
    Util.shakeDetector.detectShake(callback);
  }
}



class MotionShakeDetector {
  static final int SHAKE_THRESHOLD = 800;
  double lastX, lastY, lastZ;
  int lastUpdate = 0;
  detectShake(MotionShakeDetectCallback callback) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      int curTime = DateTime.now().millisecond;
      // only allow one update every 100ms.
      if ((curTime - lastUpdate) > 100) {
        int diffTime = (curTime - lastUpdate);
        lastUpdate = curTime;

        double x = event.x;
        double y = event.y;
        double z = event.x;

        double speed =
            (x + y + z - lastX - lastY - lastZ).abs() / diffTime * 10000;

        if (speed > SHAKE_THRESHOLD) {
          callback(true);
        }
        lastX = x;
        lastY = y;
        lastZ = z;
      }
    });
  }
}
