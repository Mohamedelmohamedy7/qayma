import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/screens/home_screen.dart';

import 'navicationBarScreen.dart';

class ReadyScreen  extends StatelessWidget {
  const ReadyScreen ({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: Colors.white,
       body: Container(
         height: double.infinity,
         width: double.infinity,
         child: Padding(
           padding: const EdgeInsets.only(top:130.0,left: 20,),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.center,
             children:  [
               Column(
                 children: [
                   Padding(
                     padding: const EdgeInsets.only(right:40.0),
                     child: Text("اهلا بك..هل انت جاهز  ؟",
                     style: GoogleFonts.tajawal(
                       color: Colors.black,
                       fontSize: 25,
                       fontWeight: FontWeight.w700,
                       // letterSpacing: 0.5,
                     ),
                     ),
                   ),

                 ],
               ),
               Padding(
                 padding: const EdgeInsets.only(left:20.0,top: 40),
                 child: SvgPicture.asset("assets/images/welcome.svg",
                     height: 408.37, width: 320.77,
                     fit: BoxFit.scaleDown),
               ),
               SizedBox(
                 height: 40,
               ),
               Padding(
                 padding: const EdgeInsets.only(right:20.0),
                 child: Container(
                   decoration: BoxDecoration(
                       color: Theme.of(context).primaryColor,
                       border: Border.all(color:Theme.of(context).primaryColor ),
                       borderRadius: BorderRadius.circular(30)),
                    height: 56.0,
                   width: 196,
                   child: FlatButton(
                     onPressed: () {
                       Navigator.of(context,rootNavigator: true).pushReplacement(
                         MaterialPageRoute(
                           builder: (context) =>NavicationBarScreen(),
                         ),
                       );

                       // Navigator.pushNamedAndRemoveUntil(
                       //     context,
                       //     '/home',
                       //         (route) => false,
                       //   );
                     },
                     child:Text("هيا نبدء",
                       style: GoogleFonts.tajawal(
                         color: Colors.black,
                         fontSize: 25,
                         fontWeight: FontWeight.w700,
                         // letterSpacing: 0.5,
                       ),
                     ),
                         ),

                     ),
               ),
             ],
           ),
         ),
       ),
    );
  }
}
