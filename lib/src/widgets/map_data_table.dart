/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MapDataTable extends StatelessWidget {
  final Map<String, String> map;
  final Widget columnKeyHeader;
  final Widget columnValueHeader;
  final TextStyle rowCell0Style;
  final TextStyle rowCell1Style;
  final double headingRowHeight;
  final bool selectLastRow;
  MapDataTable(this.map,
      {this.columnKeyHeader,
        this.columnValueHeader,
        this.rowCell0Style,
        this.rowCell1Style,
        this.headingRowHeight = 1,
        this.selectLastRow = false})
      : assert(map != null);

  List<DataRow> _getRows(context) {
    List<DataRow> list = <DataRow>[];
    int index = 0;
    bool selected = false;
    for (final key in map.keys) {
      selected = (selectLastRow) ? (index == (map.keys.length - 1)) : false;
      list.add(DataRow(cells: <DataCell>[
        DataCell(Text(key, style: rowCell0Style)),
        DataCell(Text(map[key], style: rowCell1Style))
      ], selected: selected));
      index++;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: headingRowHeight,
      columns: <DataColumn>[
        DataColumn(label: columnKeyHeader ?? Text('')),
        DataColumn(label: columnValueHeader ?? Text(''))
      ],
      rows: _getRows(context),
    );
  }
}
