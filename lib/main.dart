// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'splash.dart';

late SharedPreferences sharedPreferences;


class MapsDemo extends StatefulWidget {
  static const String ACCESS_TOKEN =
      "pk.eyJ1Ijoic2FuZHktcGFya2VyIiwiYSI6ImNsbWtvYnFrZjA0dnIyanFncTZsc3BwNmkifQ.giPjydmN8Iv6Gj_-zWJBEA";

  @override
  State<MapsDemo> createState() => _MapsDemoState();
}

class _MapsDemoState extends State<MapsDemo> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MapboxMaps examples')),
    );
  }

  Widget buildAccessTokenWarning() {
    return Container(
      color: Colors.red[900],
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Please pass in your access token with",
            "--dart-define=ACCESS_TOKEN=ADD_YOUR_TOKEN_HERE",
            "passed into flutter run or add it to args in vscode's launch.json",
          ]
              .map((text) => Padding(
            padding: EdgeInsets.all(8),
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ))
              .toList(),
        ),
      ),
    );
  }
}

void main() async{
  sharedPreferences = await SharedPreferences.getInstance();
  runApp(MaterialApp(themeMode: ThemeMode.dark, theme: ThemeData.dark(), home: Splash()));
}