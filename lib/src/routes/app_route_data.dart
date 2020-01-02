/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'dart:convert';
import 'package:equatable/equatable.dart';

enum AppRouteDataType { cached, url, other }

class AppRouteData extends Equatable {
  final String routeName;
  final String routeNameAlias;
  final String cacheName;
  final String url;
  final dynamic other;
  final AppRouteData previous;

  @override
  List<Object> get props => [
    routeName,
    routeNameAlias,
    cacheName,
    url,
    other
  ]; //do not put previous in the list

  AppRouteData(
      {this.routeName,
        this.routeNameAlias,
        this.cacheName,
        this.url,
        this.other,
        this.previous});

  bool get isValid => ((routeName != null) &&
      ((cacheName != null) || (url != null) || (other != null)));

  AppRouteData copyWith(
      {String routeName,
        String routeNameAlias,
        String cacheName,
        String url,
        dynamic other,
        AppRouteData previous}) {
    return AppRouteData(
        routeName: routeName ?? this.routeName,
        routeNameAlias: routeNameAlias ?? this.routeNameAlias,
        cacheName: cacheName ?? this.cacheName,
        url: url ?? this.url,
        other: other ?? this.other,
        previous: previous ?? this.previous);
  }

  AppRouteDataType get type {
    if (cacheName != null) {
      return AppRouteDataType.cached;
    } else if (url != null) {
      return AppRouteDataType.url;
    } else {
      return AppRouteDataType.other;
    }
  }

  @override
  String toString() {
    var pr = jsonEncode({
      'routeName': previous?.routeName,
      'routeNameAlias': previous?.routeNameAlias,
      'cacheName': previous?.cacheName,
      'url': previous?.url,
      'other': other?.toString()
    });

    return jsonEncode({
      'routeName': routeName,
      'routeNameAlias': routeNameAlias,
      'cacheName': cacheName,
      'url': url,
      'other': other?.toString(),
      'previous': pr
    });
  }
}
