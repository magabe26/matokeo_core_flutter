/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

abstract class MagabeDb {
  String get name;

  int get version;

  Completer<Database> _dbOpenCompleter;

  FutureOr<void> onCreate(Database database, int version);

  FutureOr<void> onUpgrade(Database database, int oldVersion, int newVersion) {}

  FutureOr<void> onDowngrade(
      Database database, int oldVersion, int newVersion) {}

  Future<Database> get db async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDb();
    }

    return _dbOpenCompleter.future;
  }

  void _openDb() async {
    var path;
    try {
      path = join(await getDatabasesPath(), '$name');
    } catch (_) {
      path = join((await getApplicationDocumentsDirectory()).path, '$name');
    }

    final database = await openDatabase(
      path,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      version: version,
    );

    _dbOpenCompleter.complete(database);
  }
}
