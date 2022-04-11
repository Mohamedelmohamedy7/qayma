import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/screens/cart_screen.dart';

import '../ad_help.dart';

class SuccessData extends StatefulWidget {
    SuccessData({Key key}) : super(key: key){
      adMOp();
    }
    InterstitialAd _interstitialAd;

    void adMOp() {
      InterstitialAd.load(
          adUnitId: AdHelper.interstitialAdUnitId,
          request: AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: onloadMethod, onAdFailedToLoad: (_) {}));
    }
  @override
  _SuccessDataState createState() => _SuccessDataState();

    void onloadMethod(InterstitialAd ad) {

      _interstitialAd = ad;
    }
}

class _SuccessDataState extends State<SuccessData> {
  BannerAd _ad;


  bool isLoaded = false;

  BannerAd _bottomBannerAd;


var data=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [

            Stack(
              children:[ Image.asset(
                "assets/images/Goals.png",
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
                data==true?    Padding(
                padding: EdgeInsets.symmetric(horizontal: 25,vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => CartScreen()));                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Color(0xffE5E5E5))),
                        child: Center(
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            )),
                      ),
                    ),

                    // Container(
                    //   height: 80.0,
                    //   width: 40,
                    //   decoration: BoxDecoration(
                    //     // gradient: LinearGradient(
                    //     //   colors: [
                    //     //     Colors.white,
                    //     //     Colors.white70,
                    //     //     Colors.white54,
                    //     //   ],
                    //     //   begin: Alignment.bottomCenter,
                    //     //   end: Alignment.topCenter,
                    //     // ),
                    //     borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(25.0),
                    //       topRight: Radius.circular(25.0),
                    //     ),
                    //   ),
                    //   child:   GestureDetector(
                    //     onTap: () {
                    //       FirebaseAuth.instance.currentUser == null
                    //           ? Navigator.of(context).push(
                    //           MaterialPageRoute(builder: (context) => SignInScreen()))
                    //           : Navigator.pushNamed(context, '/cart');
                    //     },
                    //     child: BlocBuilder(
                    //       cubit: cartCountBloc,
                    //       builder: (context, state) {
                    //         if (state is CartCountUpdateState) {
                    //           cartCount = state.cartCount;
                    //           return Stack(
                    //             alignment: Alignment.center,
                    //             children: <Widget>[
                    //               Icon(
                    //                 Icons.shopping_cart,
                    //                 size: 35.0,
                    //                 color: Theme.of(context).primaryColor,
                    //               ),
                    //               cartCount > 0
                    //                   ? Positioned(
                    //                 left: 20.0,
                    //                 top: 15.0,
                    //                 child: Container(
                    //                   height: 16.0,
                    //                   width: 16.0,
                    //                   alignment: Alignment.center,
                    //                   decoration: BoxDecoration(
                    //                     borderRadius: BorderRadius.circular(15.0),
                    //                     color: Colors.black,
                    //                   ),
                    //                   child: Padding(
                    //                     padding: const EdgeInsets.only(top: 2),
                    //                     child: Center(
                    //                       child: Text(
                    //                         '$cartCount',
                    //                         style: GoogleFonts.tajawal(
                    //                           color: Theme.of(context).primaryColor,
                    //                           fontSize: 10.0,
                    //                           fontWeight: FontWeight.w500,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               )
                    //                   : SizedBox(),
                    //             ],
                    //           );
                    //         }
                    //         return Icon(
                    //           Icons.shopping_cart,
                    //           size: 25.0,
                    //         );
                    //       },
                    //     ),
                    //   ),
                    //   // child: BlocBuilder(
                    //   //   cubit: cartBloc,
                    //   //   builder: (context, state) {
                    //   //     if (state is AddToCartInProgressState) {
                    //   //       return FlatButton(
                    //   //         onPressed: () {
                    //   //           //temporary
                    //   //         },
                    //   //         color: Theme.of(context).primaryColor,
                    //   //         shape: RoundedRectangleBorder(
                    //   //           borderRadius: BorderRadius.circular(15.0),
                    //   //         ),
                    //   //         child: Row(
                    //   //           mainAxisAlignment: MainAxisAlignment.center,
                    //   //           mainAxisSize: MainAxisSize.max,
                    //   //           crossAxisAlignment: CrossAxisAlignment.center,
                    //   //           children: <Widget>[
                    //   //             Container(
                    //   //               height: 25.0,
                    //   //               width: 25.0,
                    //   //               child: CircularProgressIndicator(
                    //   //                 backgroundColor: Colors.white,
                    //   //                 strokeWidth: 3.0,
                    //   //                 valueColor:
                    //   //                     AlwaysStoppedAnimation<Color>(Colors.black38),
                    //   //               ),
                    //   //             ),
                    //   //             SizedBox(
                    //   //               width: 15.0,
                    //   //             ),
                    //   //             Text(
                    //   //               'Adding to cart',
                    //   //               style: GoogleFonts.tajawal(
                    //   //                 fontSize: 15.0,
                    //   //                 fontWeight: FontWeight.w500,
                    //   //                 letterSpacing: 0.3,
                    //   //                 color: Colors.white,
                    //   //               ),
                    //   //             ),
                    //   //           ],
                    //   //         ),
                    //   //       );
                    //   //     }
                    //   //     if (state is AddToCartFailedState) {
                    //   //       //create snack
                    //   //     }
                    //   //     if (state is AddToCartCompletedState) {
                    //   //       //create snack
                    //   //       // showSnack();
                    //   //       // return FlatButton(
                    //   //       //   onPressed: () {
                    //   //       //     //temporary
                    //   //       //   },
                    //   //       //   color: Theme.of(context).primaryColor,
                    //   //       //   shape: RoundedRectangleBorder(
                    //   //       //     borderRadius: BorderRadius.circular(15.0),
                    //   //       //   ),
                    //   //       //   child: Row(
                    //   //       //     mainAxisAlignment: MainAxisAlignment.center,
                    //   //       //     mainAxisSize: MainAxisSize.max,
                    //   //       //     crossAxisAlignment: CrossAxisAlignment.center,
                    //   //       //     children: <Widget>[
                    //   //       //       Icon(
                    //   //       //         Icons.shopping_cart,
                    //   //       //         color: Colors.white,
                    //   //       //       ),
                    //   //       //       SizedBox(
                    //   //       //         width: 15.0,
                    //   //       //       ),
                    //   //       //       Text(
                    //   //       //         'Added to cart',
                    //   //       //         style: GoogleFonts.tajawal(
                    //   //       //           fontSize: 15.0,
                    //   //       //           fontWeight: FontWeight.w500,
                    //   //       //           letterSpacing: 0.3,
                    //   //       //           color: Colors.white,
                    //   //       //         ),
                    //   //       //       ),
                    //   //       //     ],
                    //   //       //   ),
                    //   //       // );
                    //
                    //   //       return FlatButton(
                    //   //         onPressed: () {
                    //   //           //add to cart
                    //   //           addToCart();
                    //   //         },
                    //   //         color: Theme.of(context).primaryColor,
                    //   //         shape: RoundedRectangleBorder(
                    //   //           borderRadius: BorderRadius.circular(15.0),
                    //   //         ),
                    //   //         child: Row(
                    //   //           mainAxisAlignment: MainAxisAlignment.center,
                    //   //           mainAxisSize: MainAxisSize.max,
                    //   //           crossAxisAlignment: CrossAxisAlignment.center,
                    //   //           children: <Widget>[
                    //   //             Icon(
                    //   //               Icons.add_shopping_cart,
                    //   //               color: Colors.white,
                    //   //             ),
                    //   //             SizedBox(
                    //   //               width: 15.0,
                    //   //             ),
                    //   //             Text(
                    //   //               'Add to cart',
                    //   //               style: GoogleFonts.tajawal(
                    //   //                 fontSize: 15.0,
                    //   //                 fontWeight: FontWeight.w500,
                    //   //                 letterSpacing: 0.3,
                    //   //                 color: Colors.white,
                    //   //               ),
                    //   //             ),
                    //   //           ],
                    //   //         ),
                    //   //       );
                    //   //     }
                    //   //     return FlatButton(
                    //   //       onPressed: () {
                    //   //         //add to cart
                    //   //         addToCart();
                    //   //       },
                    //   //       color: Theme.of(context).primaryColor,
                    //   //       shape: RoundedRectangleBorder(
                    //   //         borderRadius: BorderRadius.circular(15.0),
                    //   //       ),
                    //   //       child: Row(
                    //   //         mainAxisAlignment: MainAxisAlignment.center,
                    //   //         mainAxisSize: MainAxisSize.max,
                    //   //         crossAxisAlignment: CrossAxisAlignment.center,
                    //   //         children: <Widget>[
                    //   //           Icon(
                    //   //             Icons.add_shopping_cart,
                    //   //             color: Colors.white,
                    //   //           ),
                    //   //           SizedBox(
                    //   //             width: 15.0,
                    //   //           ),
                    //   //           Text(
                    //   //             'Add to cart',
                    //   //             style: GoogleFonts.tajawal(
                    //   //               fontSize: 15.0,
                    //   //               fontWeight: FontWeight.w500,
                    //   //               letterSpacing: 0.3,
                    //   //               color: Colors.white,
                    //   //             ),
                    //   //           ),
                    //   //         ],
                    //   //       ),
                    //   //     );
                    //   //   },
                    //   // ),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.of(context)
                    //         .pushReplacementNamed("/navicationscreen");
                    //   },
                    //   child: Container(
                    //     height: 32,
                    //     width: 32,
                    //     decoration: BoxDecoration(
                    //       color: Theme.of(context).primaryColor,
                    //       borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child: Center(
                    //       child: Text(
                    //         "+",
                    //         style: TextStyle(
                    //             fontSize: 18, fontWeight: FontWeight.bold),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ):SizedBox(),
            ]),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 70,),
                  Text(
                    "تم اضافة المنتج الي المشتريات",
                    style: TextStyle(color: Colors.white, fontSize: 22),textAlign:TextAlign.center,
                  ),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "مبروك ,تم اضافة المنتج بنجاح سيتم عرض هذة المنتج في ملف ال pdf  وسيتم اضافة قيمة سعر والكمية الي المجموع الكلي للقايمة",
                      style: TextStyle(color: Colors.white60),textAlign:TextAlign.center,
                    ),
                  ),

                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius:BorderRadius.circular(25)
                      ),
                      child: Center(
                        child: TextButton(
                          child: Text("الذهاب للمشتريات",style: TextStyle(color: Colors.white),),
                          onPressed: (){
                            setState(() {
                              data=true;
                            });
                           widget._interstitialAd.show();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => CartScreen()));

                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,)
              ],
            )
          ],
        ),
      ),
     );
  }
}
