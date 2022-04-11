import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'my_orders_screen.dart';
import 'navicationBarScreen.dart';

class SuccessOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
            ),
            Center(child: Text("تم الطلب بنجاح جاري \nتوصيل الطلب ",style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,fontSize: 20,
            ),textAlign: TextAlign.center,)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SvgPicture.asset("assets/icons/2.svg"),
            ),
            SizedBox(height: 40,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                height: 50,width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black,
                ),
                child: InkWell(
                  onTap: (){
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>NavicationBarScreen()));
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => MyOrdersScreen( currentUser: FirebaseAuth.instance.currentUser),
                      ),
                          (route) => false,
                    );
                  },
                  child: Center(
                    child: Text("تتبع الطلب",style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w600,fontSize: 20,color: Colors.white
                    ),textAlign: TextAlign.center,),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20,),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                height: 50,width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xffF2A500),
                ),
                child: InkWell(
                  onTap: (){
                     // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>NavicationBarScreen()));
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => NavicationBarScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  child: Center(
                    child: Text("متابعة التسوق",style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,fontSize: 20,color: Colors.white
                    ),textAlign: TextAlign.center,),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
