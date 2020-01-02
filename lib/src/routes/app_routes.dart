/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:flutter/material.dart';
import 'app_route_data.dart';

abstract class AppRoutes {
  BuildContext _context;

  BuildContext get context => _context;

  set context(BuildContext context) {
    if (context != null) {
      _context = context;
    }
  }

  AppRoutes();

  AppRoutes of(BuildContext context) {
    this.context = context;
    return this;
  }

  void gotoNextPage(AppRouteData routeData,
      {String cacheName, String url, dynamic other});

  void gotoPreviousPage({AppRouteData previous});
}
