/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:matokeo_core_flutter/src/routes/app_route_data.dart';
import 'package:matokeo_core_flutter/src/routes/app_routes.dart';
import 'package:matokeo_core_flutter/src/wait_for_animation.dart';

import 'page_constats.dart';

enum BackMenuState { opened, closed }
final pageBackMenuAnimationDuration = Duration(milliseconds: 500);

class Page extends StatefulWidget {
  final AppRouteData routeData;
  final WidgetBuilder builder;
  final AppRoutes appRoutes;

  Page.builder(
      {Key key,
      @required this.appRoutes,
      @required this.routeData,
      @required this.builder})
      : super(key: key);

  @override
  _PageState createState() => _PageState();

  static void closeBackMenu(BuildContext context) {
    if (context != null) {
      _PageStateProvider.getPageState(context)?.closeBackMenu();
    }
  }

  static void openBackMenu(BuildContext context) {
    if (context != null) {
      _PageStateProvider.getPageState(context)?.openBackMenu();
    }
  }

  static void toggleBackMenu(BuildContext context) {
    if (context != null) {
      _PageStateProvider.getPageState(context)?.toggleBackMenu();
    }
  }

  static bool isBackMenuOpen(BuildContext context) {
    if (context != null) {
      return _PageStateProvider.getPageState(context)?.isBackMenuOpen ?? false;
    } else {
      return false;
    }
  }

  static bool shouldShowBackMenuIcon(BuildContext context) {
    if (context != null) {
      return _PageStateProvider.getPageState(context)?.shouldShowBackMenuIcon ??
          false;
    } else {
      return false;
    }
  }
}

class _PageStateProvider extends InheritedWidget {
  final _PageState pageState;
  const _PageStateProvider(this.pageState, {Key key, Widget child})
      : super(key: key, child: child);
  @override
  bool updateShouldNotify(_PageStateProvider oldWidget) => true;

  static _PageState getPageState(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_PageStateProvider)
            as _PageStateProvider)
        .pageState;
  }
}

class _PageState extends State<Page> {
  bool _isOpen = false;
  StreamController<BackMenuState> _backMenuStreamController;
  StreamSink<BackMenuState> _backMenuStreamSink;
  Stream<BackMenuState> _backMenuStream;
  Stream<BackMenuState> _backMenuBroadcastStream;
  StreamSubscription<BackMenuState> _previousSubscription;
  @override
  void initState() {
    super.initState();
    _backMenuStreamController = StreamController();
    _backMenuStreamSink = _backMenuStreamController.sink;
    _backMenuStream = _backMenuStreamController.stream;

    _backMenuBroadcastStream = _backMenuStream.asBroadcastStream(
      onListen: (StreamSubscription<BackMenuState> subscription) {
        if (_previousSubscription != null) {
          _previousSubscription.cancel();
        }
        _previousSubscription = subscription;
      },
    );
  }

  List<AppRouteData> get _previousRouteData {
    List<AppRouteData> list = <AppRouteData>[];
    var p = widget.routeData.previous;
    while (p != null) {
      list.add(p);
      p = p.previous;
    }
    return list;
  }

  void toggleBackMenu() {
    _isOpen ? closeBackMenu() : openBackMenu();
  }

  ///Return a broadcast stream to deal with pages that may have more than one PageBackMenu
  ///foe example when a page  return an error page  that uses its own PageBackMenu
  Stream<BackMenuState> get onBackMenuStateChanged => _backMenuBroadcastStream;

  bool get isBackMenuOpen => _isOpen;

  bool get shouldShowBackMenuIcon => _previousRouteData.isNotEmpty;

  void closeBackMenu() {
    if (_isOpen) {
      _backMenuStreamSink.add(BackMenuState.closed);

      //wait for animation to complete, then show the menu
      Future.delayed(pageBackMenuAnimationDuration, () {
        setState(() {
          _isOpen = false;
        });
      });
    }
  }

  void openBackMenu() {
    if (!_isOpen) {
      _backMenuStreamSink.add(BackMenuState.opened);

      Future.delayed(pageBackMenuAnimationDuration, () {
        setState(() {
          _isOpen = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: _PageStateProvider(this, child: Builder(
        builder: (context) {
          return Stack(
            children: <Widget>[
              Listener(
                  onPointerDown: (e) {
                    if (_isOpen && (e.position.dy > statusBarMaxHeight)) {
                      closeBackMenu();
                    }
                  },
                  onPointerMove: (e) {
                    if (_isOpen && (e.position.dy > statusBarMaxHeight)) {
                      closeBackMenu();
                    }
                  },
                  onPointerUp: (e) {
                    if (_isOpen && (e.position.dy > statusBarMaxHeight)) {
                      closeBackMenu();
                    }
                  },
                  child: widget.builder(context)),
              _isOpen
                  ? Positioned(
                      left: 5.0,
                      top: statusBarMaxHeight,
                      child: Container(
                        width: size.width * 0.8,
                        height: size.height * 0.38,
                        child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _previousRouteData.length,
                            itemBuilder: (context, index) {
                              var text =
                                  _previousRouteData[index].routeNameAlias;
                              if (text == null) {
                                text = _previousRouteData[index].routeName;
                              }
                              return RaisedButton(
                                elevation: 15,
                                padding: EdgeInsets.zero,
                                child: Text(text),
                                onPressed: () {
                                  waitForRouteAnimation(() {
                                    widget.appRoutes
                                        .of(context)
                                        .gotoPreviousPage(
                                            previous:
                                                _previousRouteData[index]);
                                    closeBackMenu();
                                  });
                                },
                              );
                            }),
                      ),
                    )
                  : SizedBox(
                      height: 1,
                    )
            ],
          );
        },
      )),
    );
  }

  @override
  void dispose() {
    _backMenuStreamController.close();
    super.dispose();
  }
}

class PageBackMenu extends StatefulWidget {
  @override
  _PageBackMenuState createState() => _PageBackMenuState();
}

class _PageBackMenuState extends State<PageBackMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  bool _isListeningToStream = false;
  StreamSubscription<BackMenuState> _subscription;

  static Stream<BackMenuState> onBackMenuStateChanged(BuildContext context) {
    if (context != null) {
      return _PageStateProvider.getPageState(context)?.onBackMenuStateChanged ??
          null;
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: pageBackMenuAnimationDuration, vsync: this);
    _animation = Tween<double>(begin: 0.0, end: -(math.pi / 2))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _animation.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isListeningToStream && Page.shouldShowBackMenuIcon(context)) {
      final onMenuBackStateChanged = onBackMenuStateChanged(context);
      assert(onMenuBackStateChanged != null,
          '_PageStateProvider is not available in this context');
      if (onMenuBackStateChanged != null) {
        _subscription = onMenuBackStateChanged.listen((state) {
          if (state == BackMenuState.opened) {
            if (_controller.status == AnimationStatus.dismissed) {
              _controller.forward();
            } else {
              _controller.reset();
            }
          } else {
            if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            } else {
              _controller.reset();
            }
          }
        });
      }
      _isListeningToStream = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Page.shouldShowBackMenuIcon(context)
        ? Transform.rotate(
            angle: _animation.value,
            child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Page.toggleBackMenu(context);
                }),
          )
        : SizedBox(
            height: 1,
            width: 1,
          );
  }

  @override
  void dispose() {
    if (_subscription != null) {
      _subscription.cancel();
    }
    _controller.dispose();
    super.dispose();
  }
}
