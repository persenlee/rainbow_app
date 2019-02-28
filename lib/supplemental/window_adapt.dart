import 'package:flutter/material.dart';
import 'dart:ui';


class WindowAdapt {
    static MediaQueryData mediaQuery = MediaQueryData.fromWindow(window);
    static double _width = mediaQuery.size.width;
    static double _height = mediaQuery.size.height;
    static EdgeInsets _inset = mediaQuery.padding;
    static double _pixelRatio = mediaQuery.devicePixelRatio;
    static var _ratio;
    static int defaultReferWidth = 750;
    static int referWidth = 750;
    static init(int number){
        int uiwidth = number is int ? number : defaultReferWidth;
        _ratio = _width / uiwidth;
    }
    static px(number){
        if(!(_ratio is double || _ratio is int)){
          WindowAdapt.init(referWidth);
        }
        return number * _ratio;
    }
    static onepx(){
        return 1/_pixelRatio;
    }
    static screenWidth(){
        return _width;
    }
    static screenHeight(){
        return _height;
    }
    static screenInset(){
        return _inset;
    }
}