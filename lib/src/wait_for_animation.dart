/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:flutter/foundation.dart';

void waitForRippleAnimation(VoidCallback cb) {
  if (cb == null) return;
  Future.delayed(Duration(milliseconds: 180), () {
    cb();
  });
}

void waitForRouteAnimation(VoidCallback cb) {
  if (cb == null) return;
  Future.delayed(Duration(milliseconds: 250), () {
    cb();
  });
}