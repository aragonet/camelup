import 'package:flutter/material.dart';
import 'dart:math';

class SizeUtil {
  static const RATIO = 2.2; // Multiply for width. Divide for height

  //logic size in device
  static Size _logicSize;

  //device pixel radio.

  static get width {
    return _logicSize.width;
  }

  static get height {
    return _logicSize.height;
  }

  static set size(Size size) {
    var expectedWidth = RATIO * size.height;
    var expectedHeight = size.width / RATIO;
    if (expectedWidth > size.width) {
      _logicSize = Size(size.width, expectedHeight);
      return;
    }
    _logicSize = Size(expectedWidth, size.height);
  }

  static double getX(double wPercent) {
    return (wPercent * width) / 100;
  }

  static double getY(double hPercent) {
    return (hPercent * height) / 100;
  }

  // // diagonal direction value with design size s.
  static double getAxisBoth(double s) {
    return (s * sqrt(width * width + height * height)) / 100;
  }
}
