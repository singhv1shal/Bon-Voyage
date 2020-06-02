import 'dart:ui';

import 'package:bon_voyage/screens/readUser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;

import '../main.dart';
import 'MapPage.dart';
final SERVER_IP = 'https://e0a328310508.ngrok.io';

// ignore: must_be_immutable
class LoggedInPage extends StatefulWidget {
  var value;
  var json;

  LoggedInPage(this.value, this.json);

  @override
  State<StatefulWidget> createState() {
    return NewLoginPage(value, json);
  }
}

class NewLoginPage extends State<LoggedInPage> {
  var val;
  var jsonn;

  NewLoginPage(this.val, this.jsonn);

  @override
  Widget build(BuildContext context) {
//    debugPrint('inside logged in page');
//    debugPrint(jsonn);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.blueGrey,
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
              Column(
                children: <Widget>[
                  Container(height: 80.0,),
                  Container(
                    child: Text(
                      'Welcome to Bon-Voyage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40.0,
                        fontFamily: 'Amatic',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),


                  Container(
                    height: 200.0,
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                        child: Text('Social'),
                        onPressed: () {
                          debugPrint('Social tapped  $jsonn');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return readUser(jsonn);
                              }));

                        }),
                  ),
                  Container(
                    height: 20.0,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RaisedButton(
                        child: Text('Journey'),
                        onPressed: () async {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return MapPage(jsonn);
                              }));
                        }),
                  ),

                  Container(height: 140.0),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(

                      children: <Widget>[
                        Container(width: 20.0),
                        Expanded(

                          child: RaisedButton(
                              child: Text('Log Out'),
                              onPressed: () {
//                            debugPrint('LOGOUT TAPPED');
                                logoutHere('$jsonn');
//                            debugPrint('Logout done');
                              }
                          ),
                        ),
                        Container(width: 20.0),
                        Expanded(

                          child: RaisedButton(
                              child: Text('Log Out ALL'),
                              onPressed: () {
                                logoutAllDev('$jsonn');
                              }
                          ),
                        ),
                        Container(width: 20.0),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }



  Future logoutHere(String _token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $_token"
    };


    http.Response res = await http.post(
      "$SERVER_IP/users/logout",
      headers: headers,
    );

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp()
        ),
        ModalRoute.withName("../main")
    );
  }

  Future logoutAllDev(String _token) async {
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $_token"
    };


    http.Response res = await http.post(
      "$SERVER_IP/users/logoutAll",
      headers: headers,
    );

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp()
        ),
        ModalRoute.withName("../main")
    );
  }


}

