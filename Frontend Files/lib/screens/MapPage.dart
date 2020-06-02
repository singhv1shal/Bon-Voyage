import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: non_constant_identifier_names
final SERVER_IP = 'https://e0a328310508.ngrok.io';

class MapPage extends StatefulWidget {
  var tokens;

  MapPage(this.tokens);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState(tokens);
  }
}

LatLng _center = LatLng(26.7655646, 83.3714829);

//home is at 26.7655646, 83.3714829
//iet lucknow is at 26.9143243,80.9388227
//google mountain view,ca is at 37.4219996,-122.0927908
class _MyAppState extends State<MapPage> {
  var tokenValue;

  _MyAppState(this.tokenValue);

  final Completer<GoogleMapController> mapController = Completer();
  TextEditingController latController = TextEditingController();
  TextEditingController longController = TextEditingController();

  CameraPosition changeLoc = CameraPosition(
    target: LatLng(26.9143243, 80.9388227),
    zoom: 15.0,
  );

//  Position _currentPosition;
  var _formKey = GlobalKey<FormState>();
  bool visited = false;
  Set<Marker> _markers = {};
  Set<Marker> newMarkers = {};
  bool haveMarkerData = false;
  bool markerCondition = false;
  Set<Marker> fromWebsite = {};

  TextEditingController commentName = TextEditingController();

  BitmapDescriptor pinLocationIcon, toVisitIcon, usableIcon, newIcon;

  @override
  void initState() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/custompin.png')
        .then((onValue) {
      pinLocationIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/basics.png')
        .then((onValue) {
      newIcon = onValue;
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), 'assets/addLoc.png')
        .then((onValue) {
      toVisitIcon = onValue;
    });
    commentName.addListener(() {});
  }

  void onChanged(bool value) {
    setState(() {
      visited = value;
    });
  }

  LatLng newTappedPlace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Personalised Map Page',
            style: TextStyle(
              fontFamily: 'Raleway',
              color: Colors.black,
//              fontStyle: FontStyle.italic,
            ),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/image11.jpg",),
                  fit: BoxFit.fill,

                ),
              ),
              child: ClipRRect( // make sure we apply clip it properly
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Container(
//                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                      height: 350.0,
                      width: 365.0,
                      child: GoogleMap(
                        buildingsEnabled: false,
//                    indoorViewEnabled: true,
//                    liteModeEnabled: false,
                        trafficEnabled: false,
                        compassEnabled: true,
                        mapType: MapType.normal,
//                    onTap: _markers.clear(),
                        onMapCreated: (mapController) {
                          this.mapController.complete(mapController);
                        },
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 12.0,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        gestureRecognizers: Set()
                          ..add(Factory<EagerGestureRecognizer>(
                              () => EagerGestureRecognizer())),
                        zoomControlsEnabled: false,
                        markers: _markers,

                        onTap: (tappedPlace) async {
                          setState(() {
//                        _markers.clear();
                            _markers.add(
                              Marker(
                                markerId: MarkerId("New Place"),
                                position: LatLng(
                                    tappedPlace.latitude, tappedPlace.longitude),
                                infoWindow: InfoWindow(
                                  title: "New Place",
                                ),
                                icon: newIcon,
//                            onTap: () {
//                              SeperateWidget(context);
//                            }
//                            icon:
//                                usableIcon, // change this to new icon for unknown visit
                              ),
                            );
                            newTappedPlace = tappedPlace;
                            debugPrint('New tapped place found = $newTappedPlace');
                          });

                          await dataNewMarker(newTappedPlace);

                          if (correctAdd) {
                            if (visited) {
                              debugPrint('icon = visited wala');
                              usableIcon = pinLocationIcon;
                            } else {
                              usableIcon = toVisitIcon;
                              debugPrint('icon = not visited wala');
                            }
                            debugPrint('visited value: $visited');
                            debugPrint('comment is ${commentName.text}');
                            setState(() {
                              newMarkers.add(
                                Marker(
                                  markerId: MarkerId("${commentName.text}"),
                                  position: LatLng(newTappedPlace.latitude,
                                      newTappedPlace.longitude),
                                  infoWindow: InfoWindow(
                                    title: "${commentName.text}",
                                  ),
                                  icon: usableIcon,
                                ),
                              );
                              setState(() {
                                _markers = newMarkers;
                              });
                            });
                            postNewMarker(commentName.text, newTappedPlace.latitude,
                                newTappedPlace.longitude, visited);
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    height: 15.0,
                  ),
                  Container(
                    height: 15.0,
                  ),
                  Row(children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: RaisedButton(
                            child: Text('Mark your places'),
                            onPressed: () {
                              setState(() {
                                _markers.clear();
                                getMarkers();
                                _markers = newMarkers;
                              }); //set state done
                              debugPrint('Marked your places');
                            }),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RaisedButton(
                            child: Text('Go to Your Location'),
                            onPressed: () async {
                              debugPrint('Tried to go to their Location');
                              LocationData myLoc = await _getCurrentLocation();

                              final controller = await mapController.future;
                              await controller
                                  .animateCamera(CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(myLoc.latitude, myLoc.longitude),
                                  zoom: 12.0,
                                ),
                              ));

//                      debugPrint('Current location = $_currentPosition');
                            }),
                      ),
                    )
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<LocationData> _getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;

    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        debugPrint('Denied 1 time');
      }
    }
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        debugPrint('Denied 2 times');
      }
    }
    bool qq = true;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        debugPrint('Denied 3 times');
        qq = false;
      }
    }

    if (qq) {
      debugPrint('Location Granted');
      _locationData = await location.getLocation();
      var lat, long;
      lat = _locationData.latitude;
      long = _locationData.longitude;
      debugPrint('Latitude = $lat');
      debugPrint('Longitude = $long');

      return _locationData;
    } else {
      debugPrint('Location Permission denied, No location found');
      return null;
    }
  }

  Future<Set<Marker>> getMarkers() async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $tokenValue",
    };

    http.Response res = await http.get(
      "$SERVER_IP/visits",
      headers: headers,
    );

    List<dynamic> jsonInMap = jsonDecode(res.body);

    setState(() {
      _markers.clear();
    });

    for (int i = 0; i < jsonInMap.length; i++) {
      Map<dynamic, dynamic> onePlace = jsonInMap[i];
      bool visited = onePlace['visited'];
      double latitude = onePlace['latitude'];
      double longitude = onePlace['longitude'];
      String bookmarks = onePlace['comment'];
      debugPrint('$bookmarks $latitude $longitude $visited');

      if (!visited) {
        usableIcon = toVisitIcon;
      } else
        usableIcon = pinLocationIcon;

      setState(() {
        newMarkers.add(
          Marker(
            markerId: MarkerId("$bookmarks"),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(
              title: "$bookmarks",
            ),
            icon: usableIcon,
          ),
        );
      });
    }
    return newMarkers;
  }

  void postNewMarker(
      String commentString, double latitude, double longitude, bool vis) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $tokenValue",
    };

    http.Response res = await http.post(
      "$SERVER_IP/visits",
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        "comment": "$commentString",
        "latitude": latitude,
        "longitude": longitude,
        "visited": vis
      }),
    );
  }

  bool correctAdd = false;

  dataNewMarker(LatLng newTappedPlace) async {
    commentName.clear();
    return showDialog(
        context: context,
        // ignore: missing_return
        builder: (BuildContext context) {
          return AlertDialog(

            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(

                width: 200.0,
                height: 225.0,
                child: Column(
                  children: <Widget>[
                    Text('Name your Marker'),
                    Container(height: 20.0),
                    TextField(
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        color: Colors.black87,
                        fontSize: 18.0,
                      ),
                      controller: commentName,
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.add_location),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                        title: Text('Visited this already?'),
                        value: visited,
                        onChanged: (bool val) {
                          setState(() {
                            visited = val;
                          });
                        }),
                    Container(
                      height: 20.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: Text('Add this'),
                            onPressed: () {
                              correctAdd = true;
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Container(
                          width: 20.0,
                        ),
                        Expanded(
                          child: RaisedButton(
                            child: Text('Cancel this'),
                            onPressed: () {
                              correctAdd = false;
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
          );
        });
  }
}
