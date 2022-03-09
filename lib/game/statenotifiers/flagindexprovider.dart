import 'package:flutter/cupertino.dart';

class URLVideoState extends ChangeNotifier {
  bool flag = false;
  bool videoRepeatFlag = false;
  double scaleEffectCount = 0.0;
  double lastScaleEffectValue = 0.0;
  void setFlag(bool vFlag) {
    if (flag == vFlag) {}
    else {
      flag = vFlag;
      notifyListeners();
      print("[DEBUG] - Video state changed to " + vFlag.toString());
    }
  }
  void setVideoRepeatFlag(bool vFlag) {
    if (videoRepeatFlag == vFlag) {}
    else {
      videoRepeatFlag = vFlag;
      notifyListeners();
      print("[DEBUG] - Starts to repeat outro video, flag set to " + videoRepeatFlag.toString());
    }
  }
  void initFlag() {
    flag = false;
    videoRepeatFlag = false;
  }
}