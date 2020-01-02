/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:flutter/material.dart';

import '../wait_for_animation.dart';

class SearchDialog {
  final BuildContext context;
  String _searchText = '';

  SearchDialog(this.context) : assert(context != null);

  Future<String> show(
      {String buttonText, String labelText, String hintText}) async {
    return showDialog<String>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            contentPadding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 5),
                child: Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(25.0),
                  child: TextFormField(
                    autocorrect: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      contentPadding: (labelText == null)
                          ? EdgeInsets.only(left: 15.0, top: 15.0)
                          : EdgeInsets.only(left: 15.0, top: 5.0),
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: labelText,
                    ),
                    onFieldSubmitted: (text) {
                      _searchText = text;
                    },
                    //just in case the user press the button without committing
                    onChanged: (text) {
                      _searchText = text;
                    },
                  ),
                ),
              ),
              RaisedButton(
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                child: Text(buttonText ?? 'Search'),
                onPressed: () {
                  waitForRippleAnimation(() {
                    Navigator.of(context).pop(_searchText);
                  });
                },
              ),
            ],
          );
        });
  }
}
