import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypto_bazzar/constans.dart';
import 'package:flutter_crypto_bazzar/crypto.dart';
import 'package:flutter_crypto_bazzar/cryptopage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String title = 'loading...';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    api();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('images/logo.png')),
            SpinKitThreeBounce(
              color: greenColor,
              size: 80,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> api() async {
    var response = await Dio().get(
        'https://rest.coincap.io/v3/assets?apiKey=830e1e3f1551c5973c5ab4bae04cac91aa1e2050c92a5e40a2d368bc767c77a5');
    List<Crypto> cryptolist = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => cryptoPage(
          cryptolist: cryptolist,
        ),
      ),
    );
  }
}
