import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceOrderDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          // // Image.asset(
          //   'assets/images/shop_at_ease.png',
          //   width: size.width * 0.4,
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(
                height: 10.0,
              ),
              Text(
                'جاري تنفيذ طلبك..برجاء الانتظار !',
                style: GoogleFonts.tajawal(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15.0,
          ),
        ],
      ),
    );
  }
}
