import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/pages/wishlist_page.dart';
import 'package:grocery_store/screens/account_settings_screen.dart';
import 'package:grocery_store/screens/cart_screen.dart';
import 'package:grocery_store/screens/my_orders_screen.dart';
import 'package:grocery_store/screens/navicationBarScreen.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:open_store/open_store.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  SigninBloc signinBloc;
  User currentUser;
  AccountBloc accountBloc;
  GroceryUser user;
  bool isSigningOut;

  @override
  void initState() {
    super.initState();
    signinBloc = BlocProvider.of<SigninBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);

    isSigningOut = false;

    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        print(currentUser.uid);
        accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
      }
      if (state is SignoutInProgress) {
        //show dialog
        if (isSigningOut) {
          showUpdatingDialog();
        }
      }
      if (state is SignoutFailed) {
        //show failed dialog
        if (isSigningOut) {
          showSnack('Failed to sign out!', context);
          isSigningOut = false;
        }
      }
      if (state is SignoutCompleted) {
        //take to splash screen
        if (isSigningOut) {
          isSigningOut = false;
          // Navigator.pushNamedAndRemoveUntil(
          //   context,
          //   '/sign_in',
          //   (route) => false,
          // );
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NavicationBarScreen()));
        }
      }
    });

    signinBloc.add(GetCurrentUser());
  }

  Future sendToAccountSettings() async {
    bool isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountSettingsScreen(
          currentUser: currentUser,
        ),
      ),
    );

    if (isUpdated != null) {
      if (isUpdated) {
        accountBloc.add(GetAccountDetailsEvent(currentUser.uid));
      }
    }
  }

  Future inviteAFriend() async {
    await FlutterShare.share(
      title: 'Checkout this amazing app!',
      text: 'Grocery Store',
      linkUrl: 'https://play.google.com/store/apps/details?id=com.dokkan.qayma',
      chooserTitle: 'Share to apps',
    );
  }

  Future feedback() async {
    final Email email = Email(
      body: '',
      subject: 'Grocery Store Demo Support',
      isHTML: false,
      recipients: ['support.grocery_demo@gmail.com'],
    );

    await FlutterEmailSender.send(email);
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Signing out..\nPlease wait!',
        );
      },
    );
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.red.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  showSignoutConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'هل انت متـاكد ؟',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              'هل انت متأكد من تسجيل الخروج',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: 50.0,
                  child: FlatButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'لا',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 50.0,
                  child: FlatButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {
                      Navigator.pop(context);
                      signinBloc.add(SignoutEvent());
                      isSigningOut = true;
                    },
                    child: Text(
                      'نعم',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // color: Color(0xffF2F6F9),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
            bottomRight: Radius.circular(25.0),
          ),
        ),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              // الصورة الشخصية و الاسم
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Container(
              //       width: 82,
              //       height: 82,
              //       child: Align(
              //         //alignment: Alignment.centerLeft,
              //         child: SizedBox(
              //           width: 110,
              //           height: 110,
              //           child: Container(
              //               child: ClipRRect(
              //                 borderRadius: BorderRadius.circular(100.0),
              //                 child: FadeInImage.assetNetwork(
              //                   placeholder: 'assets/icons/icon_person.png',
              //                   placeholderScale: 0.5,
              //                   imageErrorBuilder: (context, error, stackTrace) =>
              //                       Icon(
              //                         Icons.person,
              //                         size: 50.0,
              //                       ),
              //                   image: mounted ? user.profileImageUrl : '',
              //                   fit: BoxFit.cover,
              //                   fadeInDuration: Duration(milliseconds: 250),
              //                   fadeInCurve: Curves.easeInOut,
              //                   fadeOutDuration: Duration(milliseconds: 150),
              //                   fadeOutCurve: Curves.easeInOut,
              //                 ),
              //               ),),
              //         ),
              //       ),
              //     ),
              //
              //     SizedBox(
              //       width: 20,
              //     ),
              //     Text(
              //       user.name,
              //       style: TextStyle(
              //         color: Colors.black87,
              //         fontSize: 30.0,
              //         fontWeight: FontWeight.w400,
              //       ),
              //     ),
              //
              //   ],
              // ),
              Container(
                child: Stack(
                  children: [
                    ClipRRect(
// /                            // topRight: Radius.circular(25),
                            // topLeft: Radius.circular(25)),
                        child: Image.asset(
                          "assets/images/back.png",
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.fill,
                        )),
                    FirebaseAuth.instance.currentUser == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        height: 32,
                                        width: 32,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Color(0xffE5E5E5))),
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
                                    //                         style:TextStyle(
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
                                    //   //               style:TextStyle(
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
                                    //   //       //         style:TextStyle(
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
                                    //   //               style:TextStyle(
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
                                    //   //             style:TextStyle(
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
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                        "assets/icons/icon_person.png"),
                                  ),
                                  SizedBox(
                                    width: 40,
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        'أسم المستخدم',
                                        textAlign: TextAlign.center,
                                        style:TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        "البريد الالكترونى",
                                        style:TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 10),
                                  //   child: Container(
                                  //     height: 110,
                                  //     padding: const EdgeInsets.symmetric(
                                  //         horizontal: 16.0, vertical: 16.0),
                                  //     decoration: BoxDecoration(
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.black.withOpacity(0.1),
                                  //           offset: Offset(0.0, 0.0),
                                  //           blurRadius: 5.0,
                                  //           spreadRadius: 1.0,
                                  //         ),
                                  //       ],
                                  //       borderRadius: BorderRadius.circular(25.0),
                                  //       color: Colors.white,
                                  //     ),
                                  //   ),
                                  // ),
                                  Container(
                                    height: 110,
                                    // padding:
                                    //     const EdgeInsets
                                    //             .symmetric(
                                    //         horizontal:
                                    //             16.0,
                                    //         vertical:
                                    //             16.0),
                                    decoration:
                                    BoxDecoration(
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Colors
                                      //         .black
                                      //         .withOpacity(
                                      //             0.1),
                                      //     offset: Offset(
                                      //         0.0, 0.0),
                                      //     blurRadius: 5.0,
                                      //     spreadRadius:
                                      //         1.0,
                                      //   ),
                                      // ],
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          25.0),
                                      // color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: InkWell(

                                        child: Center(
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:BorderRadius.circular(25),
                                                child: SvgPicture
                                                    .asset(
                                                  "assets/images/wedatalcome.svg",
                                                  width: double
                                                      .infinity,
                                                  fit: BoxFit
                                                      .cover,
                                                  height: double
                                                      .infinity,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 10,right: 30),
                                                child: Column(
                                                  mainAxisAlignment:MainAxisAlignment.start,
                                                  crossAxisAlignment:CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 10,),
                                                    Text(
                                                      "التقييم",
                                                      style:
                                                      TextStyle(
                                                        color:Theme.of(context).primaryColor,

                                                      ),
                                                    ),
                                                    SizedBox(height: 10,),
                                                    Container(
                                                      width:200,
                                                      child: Text(
                                                        " قم بتقيم تجربتك معنا وكتابــة تعليقك الان علي المتجر",
                                                        style:
                                                        TextStyle(
                                                            color:Colors.grey,
                                                            fontWeight: FontWeight.w100
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: ()async {
                                          const appStoreId = "1617094300"; // Your app's App Store ID
                                          final packageName = (await PackageInfo.fromPlatform()).packageName;
                                          OpenStore.instance.open(
                                            androidAppBundleId: "com.dokkan.qayma",
                                            // androidAppBundleId: packageName,
                                            appStoreId: appStoreId,
                                          );
                                          // Platform.isAndroid?
                                          // launch("https://play.google.com/store/apps/details?id=com.dokkan.steng")
                                          //   launch("https://apps.apple.com/us/app/1617094300");
                                          // launch("https://play.google.com/store/apps/details?id=1614071521");
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 20.0),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            offset: Offset(0.0, 0.0),
                                            blurRadius: 5.0,
                                            spreadRadius: 1.0,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(25.0),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 25,
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Text(
                                              'المعلومات الشخصيه',
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),

                                          Container(
                                            // margin: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL),
                                            width:
                                                MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              //color: Colors.red,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(30),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 56,
                                                    //color: Colors.yellow,

                                                    child: MaterialButton(
                                                      padding: EdgeInsets.all(0),
                                                      onPressed: () {
                                                        currentUser == null
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SignInScreen(),
                                                                ),
                                                              )
                                                            : sendToAccountSettings();
                                                        //PaymentBottomSheet.paymentStatus(context);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                decoration:
                                                                    BoxDecoration(),
                                                              ),
                                                              Positioned.fill(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                "assets/images/info.svg",
                                                                width: 60,
                                                                height: 60,
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor,
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                              )),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "معلومات الحساب",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.black,
                                                            size: 17,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    thickness: .19,
                                                    color: Colors.black,
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 56,
                                                    //color: Colors.yellow,

                                                    child: MaterialButton(
                                                      padding: EdgeInsets.all(0),
                                                      onPressed: () {
                                                        currentUser == null
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SignInScreen(),
                                                                ),
                                                              )
                                                            : showMaterialModalBottomSheet(
                                                                context: context,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft: Radius
                                                                            .circular(
                                                                                25.0),
                                                                        topRight:
                                                                            Radius.circular(
                                                                                25.0))),
                                                                builder: (context) =>
                                                                    SingleChildScrollView(
                                                                        controller:
                                                                            ModalScrollController.of(
                                                                                context),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                          child: Container(
                                                                              height:
                                                                                  680,
                                                                              width:
                                                                                  400,
                                                                              decoration:
                                                                                  BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                              child: WishlistPage()),
                                                                        )),
                                                              );
                                                        //PaymentBottomSheet.paymentStatus(context);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                decoration:
                                                                    BoxDecoration(),
                                                              ),
                                                              Positioned.fill(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                "assets/images/star.svg",
                                                                width: 50,
                                                                height: 50,
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor,
                                                                fit: BoxFit
                                                                    .scaleDown,
                                                              )),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "قائمة الاحتياجات",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 14.5,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.black,
                                                            size: 17,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    thickness: .19,
                                                    color: Colors.black,
                                                  ),
                                                  // Container(
                                                  //   width: double.infinity,
                                                  //   height: 56,
                                                  //   // padding: const EdgeInsets.only(
                                                  //   //     left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                  //   child: MaterialButton(
                                                  //     padding: EdgeInsets.all(0),
                                                  //     onPressed: () {
                                                  //       // Navigator.push(
                                                  //       //     context,
                                                  //       //     MaterialPageRoute(
                                                  //       //         builder: (c) => LanguagesScreen()));
                                                  //     },
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Stack(
                                                  //           children: [
                                                  //             Container(
                                                  //               height: 50,
                                                  //               width: 50,
                                                  //               decoration: BoxDecoration(
                                                  //                 // color: Color(0xffFBF0D9),
                                                  //                 // borderRadius: BorderRadius.circular(50),
                                                  //               ),
                                                  //             ),
                                                  //             Positioned.fill(
                                                  //               child: Align(
                                                  //                 alignment: Alignment.center,
                                                  //                 child: Container(
                                                  //                     margin: EdgeInsets.all(5),
                                                  //                     width: 35,
                                                  //                     height: 35,
                                                  //                     decoration: BoxDecoration(
                                                  //                       // color: Colors.green,
                                                  //                       //   borderRadius: BorderRadius.circular(50),
                                                  //                       //   border: Border.all(color: Colors.black,width: 1.5)
                                                  //                     ),
                                                  //                     child:SvgPicture.asset("assets/icons/payments.svg",
                                                  //                       width: 60,height: 60,fit: BoxFit.scaleDown,)
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //
                                                  //           ],
                                                  //         ),
                                                  //         SizedBox(
                                                  //           width: 10,
                                                  //         ),
                                                  //         Text("العناوين",
                                                  //           // S.of(context).languages,
                                                  //           style: TextStyle(
                                                  //             color: Colors.black,
                                                  //             fontSize: 14,
                                                  //             fontWeight: FontWeight.bold,
                                                  //           ),
                                                  //         ),
                                                  //         Spacer(),
                                                  //         Icon(
                                                  //           Icons.arrow_forward_ios,
                                                  //           color: Colors.black,size: 17,
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),

                                                  Container(
                                                    // color: Colors.yellow,
                                                    width: double.infinity,
                                                    height: 56,
                                                    // padding: const EdgeInsets.only(
                                                    //     left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                    child: MaterialButton(
                                                      padding: EdgeInsets.all(0),
                                                      onPressed: () {
                                                        //PaymentBottomSheet.paymentStatus(context);

                                                        currentUser == null
                                                            ? Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SignInScreen(),
                                                                ),
                                                              )
                                                            : Navigator.of(
                                                                    context)
                                                                .pop();
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                decoration: BoxDecoration(
                                                                    // color: Color(0xffFBF0D9),
                                                                    // borderRadius: BorderRadius.circular(50),
                                                                    ),
                                                              ),
                                                              Positioned.fill(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Container(
                                                                      margin: EdgeInsets.all(5),
                                                                      width: 35,
                                                                      height: 35,
                                                                      decoration: BoxDecoration(
                                                                          // color: Colors.green,
                                                                          //   borderRadius: BorderRadius.circular(50),
                                                                          //   border: Border.all(color: Colors.black,width: 1.5)
                                                                          ),
                                                                      child: SvgPicture.asset(
                                                                        "assets/images/cart.svg",
                                                                        width: 60,
                                                                        height:
                                                                            60,
                                                                        color: Theme.of(
                                                                                context)
                                                                            .accentColor,
                                                                        fit: BoxFit
                                                                            .scaleDown,
                                                                      )),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "المشتريات",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.black,
                                                            size: 17,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Divider(
                                                    thickness: 0.19,
                                                    color: Colors.black,
                                                  ),
                                                  // Container(
                                                  //   width: double.infinity,
                                                  //   height: 37,
                                                  //   padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                  //   child: MaterialButton(
                                                  //     padding: EdgeInsets.all(0),
                                                  //     onPressed: () {
                                                  //       //PaymentBottomSheet.paymentStatus(context);
                                                  //       Navigator.push(
                                                  //           context,
                                                  //           MaterialPageRoute(
                                                  //               builder: (context) => WishlistPage()));
                                                  //     },
                                                  //     child: Row(
                                                  //       children: [
                                                  //         Icon(
                                                  //           Icons.favorite,
                                                  //           color: Theme.of(context).primaryColor,
                                                  //         ),
                                                  //         Padding(
                                                  //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                  //           child: Text(
                                                  //             S.of(context).favorite_products,
                                                  //             style: TextStyle(color: Colors.grey),
                                                  //           ),
                                                  //         )
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  // Divider(
                                                  //   thickness: 0.2,
                                                  //   color: ColorResources.COLOR_GREY,
                                                  // ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 56,
                                                    // padding: const EdgeInsets.only(
                                                    //     left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                    child: MaterialButton(
                                                      padding: EdgeInsets.all(0),
                                                      onPressed: () {
                                                        //PaymentBottomSheet.paymentStatus(context);
                                                        FirebaseAuth.instance
                                                                    .currentUser ==
                                                                null
                                                            ? Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            SignInScreen()))
                                                            : showSignoutConfimationDialog(
                                                                size);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                height: 40,
                                                                width: 40,
                                                                decoration: BoxDecoration(
                                                                    // color: Color(0xffFBF0D9),
                                                                    // borderRadius: BorderRadius.circular(30),
                                                                    ),
                                                              ),
                                                              Positioned.fill(
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Container(
                                                                      margin: EdgeInsets.all(5),
                                                                      width: 30,
                                                                      height: 30,
                                                                      decoration: BoxDecoration(
                                                                          // color: Colors.green,
                                                                          //   borderRadius: BorderRadius.circular(30),
                                                                          //   border: Border.all(color: Colors.black,width: 2.5)
                                                                          ),
                                                                      child: SvgPicture.asset(
                                                                        "assets/images/shield-check.svg",
                                                                        width: 40,
                                                                        height:
                                                                            40,
                                                                        color: Theme.of(
                                                                                context)
                                                                            .accentColor,
                                                                        fit: BoxFit
                                                                            .scaleDown,
                                                                      )),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          FirebaseAuth.instance
                                                                      .currentUser ==
                                                                  null
                                                              ? Text(
                                                                  "تسجيل الدخول",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  "تسجيل الخروج",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                          Spacer(),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.black,
                                                            size: 17,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // FlatButton(
                                          //   onPressed: () {
                                          //     if (FirebaseAuth.instance.currentUser == null) {
                                          //       Navigator.pushNamed(context, '/sign_in');
                                          //       return;
                                          //     }
                                          //     if (currentUser != null) {
                                          //       Navigator.push(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //           builder: (context) => MyOrdersScreen(
                                          //             currentUser: currentUser,
                                          //           ),
                                          //         ),
                                          //       );
                                          //     }
                                          //   },
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.circular(15.0),
                                          //   ),
                                          //   child: Padding(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(vertical: 10.0),
                                          //     child: Row(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.spaceBetween,
                                          //       mainAxisSize: MainAxisSize.max,
                                          //       crossAxisAlignment: CrossAxisAlignment.center,
                                          //       children: <Widget>[
                                          //         Row(
                                          //           children: <Widget>[
                                          //             Icon(
                                          //               Icons.fastfood,
                                          //               color: Theme.of(context).primaryColor,
                                          //             ),
                                          //             SizedBox(
                                          //               width: 15.0,
                                          //             ),
                                          //             Text(
                                          //               'My Orders',
                                          //               style: TextStyle(
                                          //                 fontSize: 15.0,
                                          //                 fontWeight: FontWeight.w500,
                                          //                 letterSpacing: 0.3,
                                          //                 color: Colors.black,
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //         Icon(
                                          //           Icons.arrow_forward_ios,
                                          //           color: Colors.black38,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: 5.0,
                                          // ),
                                          // FlatButton(
                                          //   onPressed: () {
                                          //     if (FirebaseAuth.instance.currentUser == null) {
                                          //       Navigator.pushNamed(context, '/sign_in');
                                          //       return;
                                          //     }
                                          //     if (currentUser != null) {
                                          //       sendToAccountSettings();
                                          //     }
                                          //   },
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.circular(15.0),
                                          //   ),
                                          //   child: Padding(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(vertical: 10.0),
                                          //     child: Row(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.spaceBetween,
                                          //       mainAxisSize: MainAxisSize.max,
                                          //       crossAxisAlignment: CrossAxisAlignment.center,
                                          //       children: <Widget>[
                                          //         Row(
                                          //           children: <Widget>[
                                          //             Icon(
                                          //               Icons.tune,
                                          //               color: Theme.of(context).primaryColor,
                                          //             ),
                                          //             SizedBox(
                                          //               width: 15.0,
                                          //             ),
                                          //             Text(
                                          //               'Account Settings',
                                          //               style: TextStyle(
                                          //                 fontSize: 15.0,
                                          //                 fontWeight: FontWeight.w500,
                                          //                 letterSpacing: 0.3,
                                          //                 color: Colors.black,
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //         Icon(
                                          //           Icons.arrow_forward_ios,
                                          //           color: Colors.black38,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: 5.0,
                                          // ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.symmetric(horizontal: 16.0),
                                          //   child: Divider(),
                                          // ),
                                          // SizedBox(
                                          //   height: 5.0,
                                          // ),
                                          // FlatButton(
                                          //   onPressed: () {
                                          //     inviteAFriend();
                                          //   },
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.circular(15.0),
                                          //   ),
                                          //   child: Padding(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(vertical: 10.0),
                                          //     child: Row(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.spaceBetween,
                                          //       mainAxisSize: MainAxisSize.max,
                                          //       crossAxisAlignment: CrossAxisAlignment.center,
                                          //       children: <Widget>[
                                          //         Row(
                                          //           children: <Widget>[
                                          //             Icon(
                                          //               Icons.person_add,
                                          //               color: Colors.black54,
                                          //             ),
                                          //             SizedBox(
                                          //               width: 15.0,
                                          //             ),
                                          //             Text(
                                          //               'Invite a Friend',
                                          //               style: TextStyle(
                                          //                 fontSize: 15.0,
                                          //                 fontWeight: FontWeight.w500,
                                          //                 letterSpacing: 0.3,
                                          //                 color: Colors.black54,
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //         Icon(
                                          //           Icons.arrow_forward_ios,
                                          //           color: Colors.black54,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          // // SizedBox(
                                          // //   height: 5.0,
                                          // // ),
                                          // // FlatButton(
                                          // //   onPressed: () {},
                                          // //   shape: RoundedRectangleBorder(
                                          // //     borderRadius: BorderRadius.circular(15.0),
                                          // //   ),
                                          // //   child: Padding(
                                          // //     padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          // //     child: Row(
                                          // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          // //       mainAxisSize: MainAxisSize.max,
                                          // //       crossAxisAlignment: CrossAxisAlignment.center,
                                          // //       children: <Widget>[
                                          // //         Row(
                                          // //           children: <Widget>[
                                          // //             Icon(
                                          // //               Icons.help,
                                          // //               color: Colors.black54,
                                          // //             ),
                                          // //             SizedBox(
                                          // //               width: 15.0,
                                          // //             ),
                                          // //             Text(
                                          // //               'Help',
                                          // //               style: TextStyle(
                                          // //                 fontSize: 15.0,
                                          // //                 fontWeight: FontWeight.w500,
                                          // //                 letterSpacing: 0.3,
                                          // //                 color: Colors.black54,
                                          // //               ),
                                          // //             ),
                                          // //           ],
                                          // //         ),
                                          // //         Icon(
                                          // //           Icons.arrow_forward_ios,
                                          // //           color: Colors.black54,
                                          // //         ),
                                          // //       ],
                                          // //     ),
                                          // //   ),
                                          // // ),
                                          // SizedBox(
                                          //   height: 5.0,
                                          // ),
                                          // FlatButton(
                                          //   onPressed: () {
                                          //     feedback();
                                          //   },
                                          //   shape: RoundedRectangleBorder(
                                          //     borderRadius: BorderRadius.circular(15.0),
                                          //   ),
                                          //   child: Padding(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(vertical: 10.0),
                                          //     child: Row(
                                          //       mainAxisAlignment:
                                          //           MainAxisAlignment.spaceBetween,
                                          //       mainAxisSize: MainAxisSize.max,
                                          //       crossAxisAlignment: CrossAxisAlignment.center,
                                          //       children: <Widget>[
                                          //         Row(
                                          //           children: <Widget>[
                                          //             Icon(
                                          //               Icons.email,
                                          //               color: Colors.black54,
                                          //             ),
                                          //             SizedBox(
                                          //               width: 15.0,
                                          //             ),
                                          //             Text(
                                          //               'Feedback',
                                          //               style: TextStyle(
                                          //                 fontSize: 15.0,
                                          //                 fontWeight: FontWeight.w500,
                                          //                 letterSpacing: 0.3,
                                          //                 color: Colors.black54,
                                          //               ),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //         Icon(
                                          //           Icons.arrow_forward_ios,
                                          //           color: Colors.black54,
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: 20.0,
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15,),
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: ()async{
                                        await launch("http://www.dokkan.agency/");
                                      },
                                      child: Shimmer.fromColors(
                                        baseColor: Theme.of(context).primaryColor,
                                        highlightColor: Colors.white,
                                        child: Image.asset("assets/images/dokkan.png",color: Theme.of(context).primaryColor,
                                          width: MediaQuery.of(context).size.width*.5,),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        : SizedBox(),
                    FirebaseAuth.instance.currentUser == null
                        ? SizedBox()
                        : ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Color(0xffE5E5E5))),
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
                                  //                         style:TextStyle(
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
                                  //   //               style:TextStyle(
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
                                  //   //       //         style:TextStyle(
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
                                  //   //               style:TextStyle(
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
                                  //   //             style:TextStyle(
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
                            ),
                            BlocBuilder(
                              cubit: accountBloc,
                              builder: (context, state) {
                                if (state
                                    is GetAccountDetailsInProgressState) {
                                  return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: <Widget>[
                                      // Center(
                                      //   child: Container(
                                      //     height: size.width * 0.3,
                                      //     width: size.width * 0.3,
                                      //     decoration: BoxDecoration(
                                      //       shape: BoxShape.circle,
                                      //       color: Colors.white,
                                      //       boxShadow: [
                                      //         BoxShadow(
                                      //           offset: Offset(0, 0.0),
                                      //           blurRadius: 15.0,
                                      //           spreadRadius: 2.0,
                                      //           color: Colors.black.withOpacity(0.05),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   height: 10.0,
                                      // ),
                                      // Text(
                                      //   '',
                                      //   textAlign: TextAlign.center,
                                      //   style: TextStyle(
                                      //     color: Colors.black87,
                                      //     fontSize: 17.0,
                                      //     fontWeight: FontWeight.w600,
                                      //   ),
                                      // ),
                                      // SizedBox(
                                      //   height: 25.0,
                                      // ),
                                      SizedBox(
                                        height: 300,
                                      ),
                                      Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    ],
                                  );
                                }
                                if (state
                                    is GetAccountDetailsCompletedState) {
                                  user = state.user;

                                  return ListView(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FirebaseAuth.instance.currentUser ==
                                              null
                                          ? SizedBox()
                                          : Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 20),
                                                  child: Row(
                                                    children: [
                                                      Center(
                                                        child: Container(
                                                          height: size.width *
                                                              0.25,
                                                          width: size.width *
                                                              0.25,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            color:
                                                                Colors.white,
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                offset:
                                                                    Offset(0,
                                                                        0.0),
                                                                blurRadius:
                                                                    15.0,
                                                                spreadRadius:
                                                                    2.0,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.05),
                                                              ),
                                                            ],
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100.0),
                                                            child: FadeInImage
                                                                .assetNetwork(
                                                              placeholder:
                                                                  'assets/icons/icon_person.png',
                                                              placeholderScale:
                                                                  0.5,
                                                              imageErrorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Image.asset(
                                                                      "assets/icons/icon_person.png"),
                                                              image: mounted
                                                                  ? user
                                                                      .profileImageUrl
                                                                  : '',
                                                              fit: BoxFit
                                                                  .cover,
                                                              fadeInDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          250),
                                                              fadeInCurve: Curves
                                                                  .easeInOut,
                                                              fadeOutDuration:
                                                                  Duration(
                                                                      milliseconds:
                                                                          150),
                                                              fadeOutCurve:
                                                                  Curves
                                                                      .easeInOut,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            '${user.name}',
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 17.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          user.email == null
                                                              ? Text(
                                                                  user.mobileNo !=
                                                                          null
                                                                      ? user
                                                                          .mobileNo
                                                                      : "",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor,
                                                                    fontSize:
                                                                        15.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                )
                                                              : Text(
                                                                  '${user.email}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .accentColor
                                                                        .withOpacity(
                                                                            0.7),
                                                                    fontSize:
                                                                        13.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 120,
                                                    ),
                                                    Container(
                                                      height: 110,
                                                      // padding:
                                                      //     const EdgeInsets
                                                      //             .symmetric(
                                                      //         horizontal:
                                                      //             16.0,
                                                      //         vertical:
                                                      //             16.0),
                                                      decoration:
                                                          BoxDecoration(
                                                        // boxShadow: [
                                                        //   BoxShadow(
                                                        //     color: Colors
                                                        //         .black
                                                        //         .withOpacity(
                                                        //             0.1),
                                                        //     offset: Offset(
                                                        //         0.0, 0.0),
                                                        //     blurRadius: 5.0,
                                                        //     spreadRadius:
                                                        //         1.0,
                                                        //   ),
                                                        // ],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                25.0),
                                                        // color: Colors.white,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: InkWell(

                                                          child: Center(
                                                            child: Stack(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:BorderRadius.circular(25),
                                                                  child: SvgPicture
                                                                      .asset(
                                                                    "assets/images/wedatalcome.svg",
                                                                    width: double
                                                                        .infinity,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: double
                                                                        .infinity,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 10,right: 30),
                                                                  child: Column(
                                                                    mainAxisAlignment:MainAxisAlignment.start,
                                                                    crossAxisAlignment:CrossAxisAlignment.start,
                                                                    children: [
                                                                      SizedBox(height: 10,),
                                                                      Text(
                                                                        "التقييم",
                                                                        style:
                                                                            TextStyle(
                                                                                color:Theme.of(context).primaryColor,

                                                                            ),
                                                                      ),
                                                                      SizedBox(height: 10,),
                                                                      Container(
                                                                        width:200,
                                                                        child: Text(
                                                                          " قم بتقيم تجربتك معنا وكتابــة تعليقك الان علي المتجر",
                                                                          style:
                                                                              TextStyle(
                                                                                  color:Colors.grey,
                                                                                  fontWeight: FontWeight.w100
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          onTap: ()async {
                                                            const appStoreId = "1617094300"; // Your app's App Store ID
                                                            final packageName = (await PackageInfo.fromPlatform()).packageName;
                                                            OpenStore.instance.open(
                                                            androidAppBundleId: "com.dokkan.qayma",
                                                            // androidAppBundleId: packageName,
                                                            appStoreId: appStoreId,
                                                            );
                                                             // Platform.isAndroid?
                                                             // launch("https://play.google.com/store/apps/details?id=com.dokkan.steng")
                                                             //   launch("https://apps.apple.com/us/app/1617094300");
                                                               // launch("https://play.google.com/store/apps/details?id=1614071521");
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 10),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    16.0,
                                                                vertical:
                                                                    20.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              offset: Offset(
                                                                  0.0, 0.0),
                                                              blurRadius: 5.0,
                                                              spreadRadius:
                                                                  1.0,
                                                            ),
                                                          ],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      25.0),
                                                          color: Colors.white,
                                                        ),
                                                        child: Column(
                                                          children: <Widget>[
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              child: Text(
                                                                'المعلومات الشخصيه',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),

                                                            Container(
                                                              // margin: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL, right: Dimensions.PADDING_SIZE_SMALL),
                                                              width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width,
                                                              decoration:
                                                                  BoxDecoration(
                                                                //color: Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          30),
                                                                ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          56,
                                                                      //color: Colors.yellow,

                                                                      child:
                                                                          MaterialButton(
                                                                        padding:
                                                                            EdgeInsets.all(0),
                                                                        onPressed:
                                                                            () {
                                                                          currentUser == null
                                                                              ? Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => SignInScreen(),
                                                                                  ),
                                                                                )
                                                                              : sendToAccountSettings();
                                                                          //PaymentBottomSheet.paymentStatus(context);
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Stack(
                                                                              children: [
                                                                                Container(
                                                                                  height: 50,
                                                                                  width: 50,
                                                                                  decoration: BoxDecoration(),
                                                                                ),
                                                                                Positioned.fill(
                                                                                    child: SvgPicture.asset(
                                                                                  "assets/images/info.svg",
                                                                                  width: 60,
                                                                                  color: Theme.of(context).accentColor,
                                                                                  height: 60,
                                                                                  fit: BoxFit.scaleDown,
                                                                                )),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              "معلومات الحساب",
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Spacer(),
                                                                            Icon(
                                                                              Icons.arrow_forward_ios,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: 17,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      thickness:
                                                                          .19,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          56,
                                                                      //color: Colors.yellow,

                                                                      child:
                                                                          MaterialButton(
                                                                        padding:
                                                                            EdgeInsets.all(0),
                                                                        onPressed:
                                                                            () {
                                                                          currentUser == null
                                                                              ? Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => SignInScreen(),
                                                                                  ),
                                                                                )
                                                                              : showMaterialModalBottomSheet(
                                                                                  context: context,
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                  builder: (context) => SingleChildScrollView(
                                                                                      controller: ModalScrollController.of(context),
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                        child: Container(height: 680, width: 400, decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))), child: WishlistPage()),
                                                                                      )),
                                                                                );
                                                                          //PaymentBottomSheet.paymentStatus(context);
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Stack(
                                                                              children: [
                                                                                Container(
                                                                                  height: 50,
                                                                                  width: 50,
                                                                                  decoration: BoxDecoration(),
                                                                                ),
                                                                                Positioned.fill(
                                                                                    child: SvgPicture.asset(
                                                                                  "assets/images/star.svg",
                                                                                  width: 50,
                                                                                  color: Theme.of(context).accentColor,
                                                                                  height: 50,
                                                                                  fit: BoxFit.scaleDown,
                                                                                )),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              "قائمة الاحتياجات",
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 14.5,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Spacer(),
                                                                            Icon(
                                                                              Icons.arrow_forward_ios,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: 17,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      thickness:
                                                                          .19,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    // Container(
                                                                    //   width: double.infinity,
                                                                    //   height: 56,
                                                                    //   // padding: const EdgeInsets.only(
                                                                    //   //     left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                    //   child: MaterialButton(
                                                                    //     padding: EdgeInsets.all(0),
                                                                    //     onPressed: () {
                                                                    //       // Navigator.push(
                                                                    //       //     context,
                                                                    //       //     MaterialPageRoute(
                                                                    //       //         builder: (c) => LanguagesScreen()));
                                                                    //     },
                                                                    //     child: Row(
                                                                    //       children: [
                                                                    //         Stack(
                                                                    //           children: [
                                                                    //             Container(
                                                                    //               height: 50,
                                                                    //               width: 50,
                                                                    //               decoration: BoxDecoration(
                                                                    //                 // color: Color(0xffFBF0D9),
                                                                    //                 // borderRadius: BorderRadius.circular(50),
                                                                    //               ),
                                                                    //             ),
                                                                    //             Positioned.fill(
                                                                    //               child: Align(
                                                                    //                 alignment: Alignment.center,
                                                                    //                 child: Container(
                                                                    //                     margin: EdgeInsets.all(5),
                                                                    //                     width: 35,
                                                                    //                     height: 35,
                                                                    //                     decoration: BoxDecoration(
                                                                    //                       // color: Colors.green,
                                                                    //                       //   borderRadius: BorderRadius.circular(50),
                                                                    //                       //   border: Border.all(color: Colors.black,width: 1.5)
                                                                    //                     ),
                                                                    //                     child:SvgPicture.asset("assets/icons/payments.svg",
                                                                    //                       width: 60,height: 60,fit: BoxFit.scaleDown,)
                                                                    //                 ),
                                                                    //               ),
                                                                    //             ),
                                                                    //
                                                                    //           ],
                                                                    //         ),
                                                                    //         SizedBox(
                                                                    //           width: 10,
                                                                    //         ),
                                                                    //         Text("العناوين",
                                                                    //           // S.of(context).languages,
                                                                    //           style: TextStyle(
                                                                    //             color: Colors.black,
                                                                    //             fontSize: 14,
                                                                    //             fontWeight: FontWeight.bold,
                                                                    //           ),
                                                                    //         ),
                                                                    //         Spacer(),
                                                                    //         Icon(
                                                                    //           Icons.arrow_forward_ios,
                                                                    //           color: Colors.black,size: 17,
                                                                    //         ),
                                                                    //       ],
                                                                    //     ),
                                                                    //   ),
                                                                    // ),

                                                                    Container(
                                                                      // color: Colors.yellow,
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          56,
                                                                      // padding: const EdgeInsets.only(
                                                                      //     left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                      child:
                                                                          MaterialButton(
                                                                        padding:
                                                                            EdgeInsets.all(0),
                                                                        onPressed:
                                                                            () {
                                                                          //PaymentBottomSheet.paymentStatus(context);

                                                                          currentUser == null
                                                                              ? Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => SignInScreen(),
                                                                                  ),
                                                                                )
                                                                              : Navigator.of(context).pop();
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Stack(
                                                                              children: [
                                                                                Container(
                                                                                  height: 50,
                                                                                  width: 50,
                                                                                  decoration: BoxDecoration(
                                                                                      // color: Color(0xffFBF0D9),
                                                                                      // borderRadius: BorderRadius.circular(50),
                                                                                      ),
                                                                                ),
                                                                                Positioned.fill(
                                                                                  child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: Container(
                                                                                        margin: EdgeInsets.all(5),
                                                                                        width: 35,
                                                                                        height: 35,
                                                                                        decoration: BoxDecoration(
                                                                                            // color: Colors.green,
                                                                                            //   borderRadius: BorderRadius.circular(50),
                                                                                            //   border: Border.all(color: Colors.black,width: 1.5)
                                                                                            ),
                                                                                        child: SvgPicture.asset(
                                                                                          "assets/images/cart.svg",
                                                                                          width: 60,
                                                                                          color: Theme.of(context).accentColor,
                                                                                          height: 60,
                                                                                          fit: BoxFit.scaleDown,
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Text(
                                                                              "المشتريات",
                                                                              style: TextStyle(
                                                                                color: Colors.black,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Spacer(),
                                                                            Icon(
                                                                              Icons.arrow_forward_ios,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: 17,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Divider(
                                                                      thickness:
                                                                          0.19,
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    // Container(
                                                                    //   width: double.infinity,
                                                                    //   height: 37,
                                                                    //   padding: const EdgeInsets.only(left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                    //   child: MaterialButton(
                                                                    //     padding: EdgeInsets.all(0),
                                                                    //     onPressed: () {
                                                                    //       //PaymentBottomSheet.paymentStatus(context);
                                                                    //       Navigator.push(
                                                                    //           context,
                                                                    //           MaterialPageRoute(
                                                                    //               builder: (context) => WishlistPage()));
                                                                    //     },
                                                                    //     child: Row(
                                                                    //       children: [
                                                                    //         Icon(
                                                                    //           Icons.favorite,
                                                                    //           color: Theme.of(context).primaryColor,
                                                                    //         ),
                                                                    //         Padding(
                                                                    //           padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                                    //           child: Text(
                                                                    //             S.of(context).favorite_products,
                                                                    //             style: TextStyle(color: Colors.grey),
                                                                    //           ),
                                                                    //         )
                                                                    //       ],
                                                                    //     ),
                                                                    //   ),
                                                                    // ),
                                                                    // Divider(
                                                                    //   thickness: 0.2,
                                                                    //   color: ColorResources.COLOR_GREY,
                                                                    // ),
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height:
                                                                          56,
                                                                      // padding: const EdgeInsets.only(
                                                                      //     left: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                      child:
                                                                          MaterialButton(
                                                                        padding:
                                                                            EdgeInsets.all(0),
                                                                        onPressed:
                                                                            () {
                                                                          //PaymentBottomSheet.paymentStatus(context);
                                                                          FirebaseAuth.instance.currentUser == null
                                                                              ? Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignInScreen()))
                                                                              : showSignoutConfimationDialog(size);
                                                                        },
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Stack(
                                                                              children: [
                                                                                Container(
                                                                                  height: 40,
                                                                                  width: 40,
                                                                                  decoration: BoxDecoration(
                                                                                      // color: Color(0xffFBF0D9),
                                                                                      // borderRadius: BorderRadius.circular(30),
                                                                                      ),
                                                                                ),
                                                                                Positioned.fill(
                                                                                  child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: Container(
                                                                                        margin: EdgeInsets.all(5),
                                                                                        width: 30,
                                                                                        height: 30,
                                                                                        decoration: BoxDecoration(
                                                                                            // color: Colors.green,
                                                                                            //   borderRadius: BorderRadius.circular(30),
                                                                                            //   border: Border.all(color: Colors.black,width: 2.5)
                                                                                            ),
                                                                                        child: SvgPicture.asset(
                                                                                          "assets/images/shield-check.svg",
                                                                                          width: 40,
                                                                                          color: Theme.of(context).accentColor,
                                                                                          height: 40,
                                                                                          fit: BoxFit.scaleDown,
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            FirebaseAuth.instance.currentUser == null
                                                                                ? Text(
                                                                                    "تسجيل الدخول",
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  )
                                                                                : Text(
                                                                                    "تسجيل الخروج",
                                                                                    style: TextStyle(
                                                                                      color: Colors.black,
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                            Spacer(),
                                                                            Icon(
                                                                              Icons.arrow_forward_ios,
                                                                              color: Theme.of(context).primaryColor,
                                                                              size: 17,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),

                                                            // FlatButton(
                                                            //   onPressed: () {
                                                            //     if (FirebaseAuth.instance.currentUser == null) {
                                                            //       Navigator.pushNamed(context, '/sign_in');
                                                            //       return;
                                                            //     }
                                                            //     if (currentUser != null) {
                                                            //       Navigator.push(
                                                            //         context,
                                                            //         MaterialPageRoute(
                                                            //           builder: (context) => MyOrdersScreen(
                                                            //             currentUser: currentUser,
                                                            //           ),
                                                            //         ),
                                                            //       );
                                                            //     }
                                                            //   },
                                                            //   shape: RoundedRectangleBorder(
                                                            //     borderRadius: BorderRadius.circular(15.0),
                                                            //   ),
                                                            //   child: Padding(
                                                            //     padding:
                                                            //         const EdgeInsets.symmetric(vertical: 10.0),
                                                            //     child: Row(
                                                            //       mainAxisAlignment:
                                                            //           MainAxisAlignment.spaceBetween,
                                                            //       mainAxisSize: MainAxisSize.max,
                                                            //       crossAxisAlignment: CrossAxisAlignment.center,
                                                            //       children: <Widget>[
                                                            //         Row(
                                                            //           children: <Widget>[
                                                            //             Icon(
                                                            //               Icons.fastfood,
                                                            //               color: Theme.of(context).primaryColor,
                                                            //             ),
                                                            //             SizedBox(
                                                            //               width: 15.0,
                                                            //             ),
                                                            //             Text(
                                                            //               'My Orders',
                                                            //               style: TextStyle(
                                                            //                 fontSize: 15.0,
                                                            //                 fontWeight: FontWeight.w500,
                                                            //                 letterSpacing: 0.3,
                                                            //                 color: Colors.black,
                                                            //               ),
                                                            //             ),
                                                            //           ],
                                                            //         ),
                                                            //         Icon(
                                                            //           Icons.arrow_forward_ios,
                                                            //           color: Colors.black38,
                                                            //         ),
                                                            //       ],
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // SizedBox(
                                                            //   height: 5.0,
                                                            // ),
                                                            // FlatButton(
                                                            //   onPressed: () {
                                                            //     if (FirebaseAuth.instance.currentUser == null) {
                                                            //       Navigator.pushNamed(context, '/sign_in');
                                                            //       return;
                                                            //     }
                                                            //     if (currentUser != null) {
                                                            //       sendToAccountSettings();
                                                            //     }
                                                            //   },
                                                            //   shape: RoundedRectangleBorder(
                                                            //     borderRadius: BorderRadius.circular(15.0),
                                                            //   ),
                                                            //   child: Padding(
                                                            //     padding:
                                                            //         const EdgeInsets.symmetric(vertical: 10.0),
                                                            //     child: Row(
                                                            //       mainAxisAlignment:
                                                            //           MainAxisAlignment.spaceBetween,
                                                            //       mainAxisSize: MainAxisSize.max,
                                                            //       crossAxisAlignment: CrossAxisAlignment.center,
                                                            //       children: <Widget>[
                                                            //         Row(
                                                            //           children: <Widget>[
                                                            //             Icon(
                                                            //               Icons.tune,
                                                            //               color: Theme.of(context).primaryColor,
                                                            //             ),
                                                            //             SizedBox(
                                                            //               width: 15.0,
                                                            //             ),
                                                            //             Text(
                                                            //               'Account Settings',
                                                            //               style: TextStyle(
                                                            //                 fontSize: 15.0,
                                                            //                 fontWeight: FontWeight.w500,
                                                            //                 letterSpacing: 0.3,
                                                            //                 color: Colors.black,
                                                            //               ),
                                                            //             ),
                                                            //           ],
                                                            //         ),
                                                            //         Icon(
                                                            //           Icons.arrow_forward_ios,
                                                            //           color: Colors.black38,
                                                            //         ),
                                                            //       ],
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // SizedBox(
                                                            //   height: 5.0,
                                                            // ),
                                                            // Padding(
                                                            //   padding:
                                                            //       const EdgeInsets.symmetric(horizontal: 16.0),
                                                            //   child: Divider(),
                                                            // ),
                                                            // SizedBox(
                                                            //   height: 5.0,
                                                            // ),
                                                            // FlatButton(
                                                            //   onPressed: () {
                                                            //     inviteAFriend();
                                                            //   },
                                                            //   shape: RoundedRectangleBorder(
                                                            //     borderRadius: BorderRadius.circular(15.0),
                                                            //   ),
                                                            //   child: Padding(
                                                            //     padding:
                                                            //         const EdgeInsets.symmetric(vertical: 10.0),
                                                            //     child: Row(
                                                            //       mainAxisAlignment:
                                                            //           MainAxisAlignment.spaceBetween,
                                                            //       mainAxisSize: MainAxisSize.max,
                                                            //       crossAxisAlignment: CrossAxisAlignment.center,
                                                            //       children: <Widget>[
                                                            //         Row(
                                                            //           children: <Widget>[
                                                            //             Icon(
                                                            //               Icons.person_add,
                                                            //               color: Colors.black54,
                                                            //             ),
                                                            //             SizedBox(
                                                            //               width: 15.0,
                                                            //             ),
                                                            //             Text(
                                                            //               'Invite a Friend',
                                                            //               style: TextStyle(
                                                            //                 fontSize: 15.0,
                                                            //                 fontWeight: FontWeight.w500,
                                                            //                 letterSpacing: 0.3,
                                                            //                 color: Colors.black54,
                                                            //               ),
                                                            //             ),
                                                            //           ],
                                                            //         ),
                                                            //         Icon(
                                                            //           Icons.arrow_forward_ios,
                                                            //           color: Colors.black54,
                                                            //         ),
                                                            //       ],
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // // SizedBox(
                                                            // //   height: 5.0,
                                                            // // ),
                                                            // // FlatButton(
                                                            // //   onPressed: () {},
                                                            // //   shape: RoundedRectangleBorder(
                                                            // //     borderRadius: BorderRadius.circular(15.0),
                                                            // //   ),
                                                            // //   child: Padding(
                                                            // //     padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                            // //     child: Row(
                                                            // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            // //       mainAxisSize: MainAxisSize.max,
                                                            // //       crossAxisAlignment: CrossAxisAlignment.center,
                                                            // //       children: <Widget>[
                                                            // //         Row(
                                                            // //           children: <Widget>[
                                                            // //             Icon(
                                                            // //               Icons.help,
                                                            // //               color: Colors.black54,
                                                            // //             ),
                                                            // //             SizedBox(
                                                            // //               width: 15.0,
                                                            // //             ),
                                                            // //             Text(
                                                            // //               'Help',
                                                            // //               style: TextStyle(
                                                            // //                 fontSize: 15.0,
                                                            // //                 fontWeight: FontWeight.w500,
                                                            // //                 letterSpacing: 0.3,
                                                            // //                 color: Colors.black54,
                                                            // //               ),
                                                            // //             ),
                                                            // //           ],
                                                            // //         ),
                                                            // //         Icon(
                                                            // //           Icons.arrow_forward_ios,
                                                            // //           color: Colors.black54,
                                                            // //         ),
                                                            // //       ],
                                                            // //     ),
                                                            // //   ),
                                                            // // ),
                                                            // SizedBox(
                                                            //   height: 5.0,
                                                            // ),
                                                            // FlatButton(
                                                            //   onPressed: () {
                                                            //     feedback();
                                                            //   },
                                                            //   shape: RoundedRectangleBorder(
                                                            //     borderRadius: BorderRadius.circular(15.0),
                                                            //   ),
                                                            //   child: Padding(
                                                            //     padding:
                                                            //         const EdgeInsets.symmetric(vertical: 10.0),
                                                            //     child: Row(
                                                            //       mainAxisAlignment:
                                                            //           MainAxisAlignment.spaceBetween,
                                                            //       mainAxisSize: MainAxisSize.max,
                                                            //       crossAxisAlignment: CrossAxisAlignment.center,
                                                            //       children: <Widget>[
                                                            //         Row(
                                                            //           children: <Widget>[
                                                            //             Icon(
                                                            //               Icons.email,
                                                            //               color: Colors.black54,
                                                            //             ),
                                                            //             SizedBox(
                                                            //               width: 15.0,
                                                            //             ),
                                                            //             Text(
                                                            //               'Feedback',
                                                            //               style: TextStyle(
                                                            //                 fontSize: 15.0,
                                                            //                 fontWeight: FontWeight.w500,
                                                            //                 letterSpacing: 0.3,
                                                            //                 color: Colors.black54,
                                                            //               ),
                                                            //             ),
                                                            //           ],
                                                            //         ),
                                                            //         Icon(
                                                            //           Icons.arrow_forward_ios,
                                                            //           color: Colors.black54,
                                                            //         ),
                                                            //       ],
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                            // SizedBox(
                                                            //   height: 20.0,
                                                            // ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                    ],
                                  );
                                }
                                return SizedBox();
                              },
                            ),
                            SizedBox(height:15),
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: ()async{
                                      await launch("http://www.dokkan.agency/");
                                    },
                                    child: Shimmer.fromColors(
                                      baseColor: Theme.of(context).primaryColor,
                                      highlightColor: Colors.white,
                                      child: Image.asset("assets/images/dokkan.png",color: Theme.of(context).primaryColor,
                                        width: MediaQuery.of(context).size.width*.5,),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // bottomSheet: Container(
      //   margin: EdgeInsets.only(bottom: 10),
      //   color: Colors.white,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       InkWell(
      //         onTap: ()async{
      //           await launch("http://www.dokkan.agency/");
      //         },
      //         child: Shimmer.fromColors(
      //           baseColor: Theme.of(context).primaryColor,
      //           highlightColor: Colors.white,
      //           child: Image.asset("assets/images/dokkan.png",color: Theme.of(context).primaryColor,
      //             width: MediaQuery.of(context).size.width*.4,),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
// ClipRRect(
//   borderRadius: BorderRadius.circular(50.0),
//   child: Material(
//     color: Colors.transparent,
//     child: InkWell(
//       splashColor: Colors.white.withOpacity(0.5),
//       onTap: () {
//         print('Logout');
//         //show confirmation dialog
//         if (FirebaseAuth.instance.currentUser == null) {
//           Navigator.pushNamed(context, '/sign_in');
//           return;
//         }
//         showSignoutConfimationDialog(size);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//         ),
//         width: 40.0,
//         height: 37.0,
//         alignment: Alignment.center,
//         child: FaIcon(
//           FontAwesomeIcons.signOutAlt,
//           color: Colors.white,
//           size: 20.0,
//         ),
//       ),
//     ),
//   ),
// ),
