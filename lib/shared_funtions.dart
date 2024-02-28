import 'dart:convert';

import 'package:mapbox_gl/mapbox_gl.dart';

import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

import 'POI.dart';
import 'full_map.dart';
import 'main.dart';

LatLng getLatLngFromSharedPrefs() {
  return LatLng(sharedPreferences.getDouble('latitude')!,
      sharedPreferences.getDouble('longitude')!);
}

Map getDecodedResponseFromSharedPrefs(int index) {
  String key = 'restaurant--$index';
  Map response = json.decode(sharedPreferences.getString(key)!);
  return response;
}

num getDistanceFromSharedPrefs(int index) {
  num distance = getDecodedResponseFromSharedPrefs(index)['distance'];
  return distance;
}

num getDurationFromSharedPrefs(int index) {
  num duration = getDecodedResponseFromSharedPrefs(index)['duration'];
  return duration;
}

Map getGeometryFromSharedPrefs(int index) {
  Map geometry = getDecodedResponseFromSharedPrefs(index)['geometry'];
  return geometry;
}

LatLng getLatLngFromRestaurantData(int index) {
  return LatLng(double.parse(POI[index]['coordinates']['latitude']),
      double.parse(POI[index]['coordinates']['longitude']));
}