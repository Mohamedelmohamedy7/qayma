  import 'package:flutter/material.dart';

import '../main.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key key}) : super(key: key);

  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            alignment: Alignment.center,
            // color: context.cardColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // cachedImage(NoInternet, height: 400, width: 400),
                 Text("الانترنت غير متصل", style:TextStyle()),
              ],
            ),
          ),
          // Text(language!.lblInternetWait, style: secondaryTextStyle(size: 12)).paddingBottom(8),
        ],
      ),
    );
  }
}
