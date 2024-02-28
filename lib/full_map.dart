import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'carousel_card.dart';
import 'directions.dart';
import 'shared_funtions.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

import 'main.dart';
import 'page.dart';
import 'POI.dart';
import 'dart:ui_web';

class FullMapPage extends ExamplePage {
  FullMapPage() : super(const Icon(Icons.map), 'Full screen map');

  @override
  Widget build(BuildContext context) {
    return const FullMap();
  }
}

class FullMap extends StatefulWidget {
  const FullMap();

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  late MapboxMapController mapController;
  var isLight = true;
  late final LatLng currentLatLng;
  late List<CameraPosition> _POI;
  List<Map> carouselData = [];

  int pageIndex = 0;
  bool accessed = false;
  late List<Widget> carouselItems;

  void pushPage() async {
    final location = Location();
    if (!kIsWeb) {
      final hasPermissions = await location.hasPermission();
      if (hasPermissions != PermissionStatus.granted) {
        await location.requestPermission();
      }
    }
    LocationData _locationData = await location.getLocation();
    currentLatLng = LatLng(_locationData.latitude!, _locationData.longitude!);
    sharedPreferences.setDouble('latitude', currentLatLng!.latitude);
    sharedPreferences.setDouble('longitude', currentLatLng.longitude!);

    for (int i = 0; i < POI.length; i++) {
      Map modifiedResponse = await getDirectionsAPIResponse(currentLatLng, i);
      saveDirectionsAPIResponse(i, json.encode(modifiedResponse));
    }
  }

  @override
  void initState() {
    super.initState();
    pushPage();

    // Calculate the distance and time from data in SharedPreferences

    for (int index = 0; index < POI.length; index++) {
      num distance = getDistanceFromSharedPrefs(index) / 1000;
      num duration = getDurationFromSharedPrefs(index) / 60;
      carouselData
          .add({'index': index, 'distance': distance, 'duration': duration});
    }
    carouselData.sort((a, b) => a['duration'] < b['duration'] ? 0 : 1);

    // Generate the list of carousel widgets
    carouselItems = List<Widget>.generate(
        POI.length,
            (index) => carouselCard(carouselData[index]['index'],
            carouselData[index]['distance'], carouselData[index]['duration']));

    // initialize map symbols in the same order as carousel widgets
    _POI = List<CameraPosition>.generate(
        POI.length,
            (index) => CameraPosition(
            target: getLatLngFromRestaurantData(carouselData[index]['index']),
            zoom: 19));
  }

  _addSourceAndLineLayer(int index, bool removeLayer) async {
    // Can animate camera to focus on the item
    mapController.animateCamera(CameraUpdate.newCameraPosition(_POI[index]));

    // Add a polyLine between source and destination
    Map geometry = getGeometryFromSharedPrefs(carouselData[index]['index']);
    final _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": geometry,
        },
      ],
    };

    // Remove lineLayer and source if it exists
    if (removeLayer == true) {
      await mapController.removeLayer("lines");
      await mapController.removeSource("fills");
    }

    // Add new source and lineLayer
    await mapController.addSource(
        "fills", GeojsonSourceProperties(data: _fills));
    await mapController.addLineLayer(
      "fills",
      "lines",
      LineLayerProperties(
        lineColor: Colors.green.toHexStringRGB(),
        lineCap: "round",
        lineJoin: "round",
        lineWidth: 2,
      ),
    );
  }

  _onMapCreated(MapboxMapController controller) {
    mapController = controller;
  }

  _onStyleLoadedCallback() async {
    for (CameraPosition _kRestaurant in _POI) {
      await mapController.addSymbol(
        SymbolOptions(
          geometry: _kRestaurant.target,
          iconSize: 0.2,
          iconImage: "assets/icon/food.png",
        ),
      );
    }
    _addSourceAndLineLayer(0, false);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(32.0),
          child: FloatingActionButton(
            child: Icon(Icons.swap_horiz),
            onPressed: () => setState(
                  () => isLight = !isLight,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(children: [
            MapboxMap(
              styleString:
              isLight ? MapboxStyles.MAPBOX_STREETS : MapboxStyles.DARK,
              accessToken: MapsDemo.ACCESS_TOKEN,
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(12.986908, 79.972217), zoom: 15),
              onStyleLoadedCallback: _onStyleLoadedCallback,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
              //minMaxZoomPreference: const MinMaxZoomPreference(14, 20),
            ),
            CarouselSlider(
              items: carouselItems,
              options: CarouselOptions(
                height: 100,
                viewportFraction: 0.6,
                initialPage: 0,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
                onPageChanged:
                    (int index, CarouselPageChangedReason reason) async {
                  setState(() {
                    pageIndex = index;
                  });
                  _addSourceAndLineLayer(index, true);
                },
              ),
            ),
          ]),
        ));
  }
}