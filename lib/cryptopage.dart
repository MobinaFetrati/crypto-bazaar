import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crypto_bazzar/constans.dart';
import 'package:flutter_crypto_bazzar/crypto.dart';

class cryptoPage extends StatefulWidget {
  cryptoPage({super.key, this.cryptolist});
  List<Crypto>? cryptolist;
  @override
  State<cryptoPage> createState() => _cryptoPageState();
}

class _cryptoPageState extends State<cryptoPage> {
  List<Crypto>? cryptolist;
  bool isSearchLoadindVisible = false;
  @override
  void initState() {
    // TODO: implement initState
    cryptolist = widget.cryptolist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        title: Text('Crypto Bazzar', style: TextStyle(fontFamily: 'mr')),
        backgroundColor: blackColor,
        foregroundColor: greenColor,
        shadowColor: greenColor,
        elevation: 10,
        toolbarHeight: 45,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  onChanged: (value) {
                    _filterList(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'رمز ارز مورد نظر را جستجو کنید',
                    hintStyle: TextStyle(color: blackColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    filled: true,
                    fillColor: greenColor,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isSearchLoadindVisible,
              child: Text(
                'در حال آپدیت...',
                style: TextStyle(
                  color: greenColor,
                  fontSize: 15,
                  fontFamily: 'mr',
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: greenColor,
                color: blackColor,
                onRefresh: () async {
                  List<Crypto> freshData = await _api();
                  setState(() {
                    cryptolist = freshData;
                  });
                },
                child: ListView.builder(
                  itemCount: cryptolist!.length,
                  itemBuilder: (context, index) {
                    return _getListTile(cryptolist![index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Crypto>> _api() async {
    var response = await Dio().get('https://api.coincap.io/v3/assets');
    List<Crypto> cryptolist = response.data['data']
        .map<Crypto>((jsonMapObject) => Crypto.fromMapJson(jsonMapObject))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => cryptoPage(cryptolist: cryptolist),
      ),
    );
    return cryptolist;
  }

  Widget _getListTile(Crypto crypto) {
    return ListTile(
      title: Text(crypto.name, style: TextStyle(color: greenColor)),
      subtitle: Text(crypto.symbol, style: TextStyle(color: greyColor)),
      leading: SizedBox(
        width: 20,
        child: Center(
          child: Text(
            crypto.rank.toString(),
            style: TextStyle(color: greyColor),
          ),
        ),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  crypto.priceUsd.toStringAsFixed(2),
                  style: TextStyle(color: greyColor, fontSize: 15),
                ),
                Text(
                  crypto.changePercent24Hr.toStringAsFixed(2),
                  style: TextStyle(
                    color: _getColorChangeText(crypto.changePercent24Hr),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 30,
              child: Center(
                child: _getIconChangePercent(crypto.changePercent24Hr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getIconChangePercent(double percentChange) {
    return percentChange <= 0
        ? Icon(Icons.trending_down, size: 25, color: redColor)
        : Icon(Icons.trending_up, size: 25, color: greenColor);
  }

  Color _getColorChangeText(double percentChange) {
    return percentChange <= 0 ? redColor : greenColor;
  }

  Future<void> _filterList(String enteredKeyword) async {
    if (enteredKeyword.isEmpty) {
      setState(() {
        isSearchLoadindVisible = true;
      });
      var result = await _api();
      setState(() {
        cryptolist = result;
        isSearchLoadindVisible = false;
      });
      return;
    }
    List<Crypto> cryptoListResult = [];
    cryptoListResult = cryptolist!.where((element) {
      return element.name.toLowerCase().contains(enteredKeyword.toLowerCase());
    }).toList();
    setState(() {
      cryptolist = cryptoListResult;
    });
  }
}
