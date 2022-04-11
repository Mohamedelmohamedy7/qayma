import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/screens/cart_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/onboardingscreen.png",width: double.infinity,height: 500,fit: BoxFit.cover,),
            // Text("Shop at ease",style: TextStyle(fontWeight: FontWeight.bold),),
            // SizedBox(height: 30,),
            // Center(child: Text("Just add the products to cart and have them delivered to you in 60 minutes",style: TextStyle(),textAlign: TextAlign.center,)),
            SizedBox(height: 130),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(25)
                ),
                child: TextButton(
                  child: Text('أبــدء الان',style: TextStyle(color: Colors.white,letterSpacing: 3),),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => MyHomePage(
                          title: 'Flutter Intro',
                          mode: Mode.defaultTheme,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 40,),

            Shimmer.fromColors(
              baseColor: Colors.grey,
              highlightColor: Colors.red,
              child: Text(
                "2022© Dokkan Agency. All rights reserved",
                // "All rights reserved قايمة العروسةm   2022 \n              Dokkan Agency©  ",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            // ElevatedButton(
            //   child: Text('Start with useAdvancedTheme'),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (BuildContext context) => MyHomePage(
            //           title: 'Flutter Intro',
            //           mode: Mode.advancedTheme,
            //         ),
            //       ),
            //     );
            //   },
            // ),
            // SizedBox(
            //   height: 16,
            // ),
            // ElevatedButton(
            //   child: Text('Start with customTheme'),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (BuildContext context) => MyHomePage(
            //           title: 'Flutter Intro',
            //           mode: Mode.customTheme,
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

enum Mode {
  defaultTheme,
  customTheme,
  advancedTheme,
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.title,
    this.mode,
  }) : super(key: key);

  final String title;

  final Mode mode;

  @override
  _MyHomePageState createState() => _MyHomePageState(
    mode: mode,
  );
}

class _MyHomePageState extends State<MyHomePage> {
  Intro intro;

  _MyHomePageState({Mode mode,}) {
    if (mode == Mode.defaultTheme) {
      /// init Intro
      intro = Intro(
        stepCount: 3,
        maskClosable: true,
        onHighlightWidgetTap: (introStatus) {
          print(introStatus);
        },
        /// use defaultTheme
        widgetBuilder: StepWidgetBuilder.useDefaultTheme(
          texts: [
             'يتم حساب المبلغ الاجمالي لجميع قيم المشتريات',
            'انشاء القايمة لجميع المشتريات و اخراج ملف pdf كامل لنموذج قائمة منقولات العروسة ',
            'يمكنك اضافة عنصر الي المشتريات او اضافة عنصر الي قايمة الاحتياجات او اضافة عنصر غير موجود الي قاعدة البيانات',
          ],
          buttonTextBuilder: (currPage, totalPage) {
            currPage == totalPage-1  ?
            Future.delayed(Duration(seconds: 2),()async{
              SharedPreferences _pref=await SharedPreferences.getInstance();
              _pref.setBool("DoneData", true);
              print("${ _pref.get("DoneData")}DoneData");
              Navigator.of(context).pop();
              return Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>CartScreen()));
            }):SizedBox();
            return currPage < totalPage - 1 ? 'Next' : 'Finish';
          },
        ),
      );
      intro.setStepConfig(
        0,
        borderRadius: BorderRadius.circular(23),
      );
    }
  }

  // Widget customThemeWidgetBuilder(StepWidgetParams stepWidgetParams) {
  //   List<String> texts = [
  //     'Hello, I\'m Flutter Intro.',
  //     'I can help you quickly implement the Step By Step guide in the Flutter project.',
  //     'My usage is also very simple, you can quickly learn and use it through example and api documentation.',
  //     'In order to quickly implement the guidance, I also provide a set of out-of-the-box themes, I wish you all a happy use, goodbye!',
  //   ];
  //   return Padding(
  //     padding: EdgeInsets.all(
  //       32,
  //     ),
  //     child: Column(
  //       children: [
  //         SizedBox(
  //           height: 40,
  //         ),
  //         Text(
  //           '${texts[stepWidgetParams.currentStepIndex]}【${stepWidgetParams.currentStepIndex + 1} / ${stepWidgetParams.stepCount}】',
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 16,
  //           ),
  //         ),
  //         Row(
  //           children: [
  //             ElevatedButton(
  //               onPressed: stepWidgetParams.onPrev,
  //               child: Text(
  //                 'Prev',
  //               ),
  //             ),
  //             SizedBox(
  //               width: 16,
  //             ),
  //             ElevatedButton(
  //               onPressed: stepWidgetParams.onNext,
  //               child: Text(
  //                 'Next',
  //               ),
  //             ),
  //             SizedBox(
  //               width: 16,
  //             ),
  //             ElevatedButton(
  //               onPressed: stepWidgetParams.onFinish,
  //               child: Text(
  //                 'Finish',
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  var date = DateTime.now();

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(
        milliseconds: 500,
      ),
          () {
        /// start the intro
        intro.start(context);
      },
    );
  } 

  Widget build(BuildContext context) {
    return Stack(
      children: [
        WillPopScope(
          child: Scaffold(
            body: Stack(
              children: [
                      SingleChildScrollView(
                child: Column(
                  children: [
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: Theme.of(context).primaryColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 70,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: (date.hour >= 0 &&
                                        date.hour < 12)
                                        ? Text(
                                      "صــبـــاح الـخـيـــــــر",
                                      style: TextStyle(
                                        color:
                                        Colors.grey.shade500,
                                        fontSize: 18,
                                        letterSpacing: 4,
                                        fontWeight:
                                        FontWeight.w200,
                                        // letterSpacing: 0.5,
                                      ),
                                    )
                                        : Text(
                                      "مساء الخير",
                                      style: TextStyle(
                                        color:
                                        Colors.grey.shade400,
                                        fontSize: 22,
                                        letterSpacing: 4,
                                        fontWeight:
                                        FontWeight.w200,
                                        // letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            FirebaseAuth.instance.currentUser != null
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    " أهلاً  ${FirebaseAuth.instance.currentUser.displayName==null?"":FirebaseAuth.instance.currentUser.displayName}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 10,
                                      top: 5),
                                  child: Icon(
                                    Icons
                                        .notification_important_sharp,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ],
                            )
                                : Row(
                              children: [
                                Padding(
                                  padding:       EdgeInsets.symmetric(
                                      horizontal: 10,vertical: 10),
                                  child: Text(
                                    " أهلاً بيكي ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(

                                    onPressed: () {
                                      intro.start(context);
                                    },
                                  child: Container(
                                    width: 180,
                                    key: intro.keys[0],
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                          "assets/images/Cost.png",
                                          width: 60,
                                          height: 60,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height: 20,),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 0),
                                              child: Text(
                                                "المبلغ الكلي",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors
                                                      .grey
                                                      .shade500,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10,),

                                            Padding(
                                              padding: const EdgeInsets.only(right: 0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "0.0",
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      24,
                                                      color: Colors
                                                          .white,
                                                      fontWeight:
                                                      FontWeight
                                                          .w500,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        bottom:
                                                        15,
                                                        right: 8),
                                                    child: Text(
                                                      "جنية",
                                                      style:
                                                      TextStyle(
                                                        fontSize:
                                                        14,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                        fontWeight:
                                                        FontWeight
                                                            .w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Container(
                                      key: intro.keys[1],
                                      width: 120,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: Colors
                                              .white
                                              .withOpacity(
                                              0.2),
                                          borderRadius:
                                          BorderRadius
                                              .circular(
                                              25)),
                                      child: TextButton(
                                          child: Center(
                                            child: Text(
                                              "انشاء القايمة",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors
                                                    .white,
                                                fontWeight:
                                                FontWeight
                                                    .w400,
                                              ),
                                            ),
                                          ))),
                                )
                              ],
                            ),

                          ],
                        ),
                      ),

                      Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Lottie.asset(
                            'assets/images/emptyCart.json',
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'لا يوجد لديك مشتريات بعد',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            'قم بأضافة أول مشترياتك الان',
                            style: TextStyle(
                              color:
                              Theme.of(context).primaryColor,
                              fontSize: 20.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),


                          ],
                        ),
                      ),

                    ],
            ),
            bottomNavigationBar: Container(
  height: 70,
  child: Stack(
        children: [
          BottomAppBar(
            color: Colors.white,
             shape: CircularNotchedRectangle(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: [
                          IconButton(
                              icon:  SvgPicture.asset(
                                  "assets/images/002-home.svg",width: 20,height: 25,fit: BoxFit.scaleDown,
                                  color:
                                  Theme.of(context).primaryColor),
                              color: Colors.grey,
                             ),

                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                              icon: SvgPicture.asset(
                                  "assets/images/003-heart.svg",width: 20,height: 23,fit: BoxFit.scaleDown,
                                  color:
                                  Colors.grey.shade400),
                              color: Colors.grey,
                              ),

                        ],
                      ),
SizedBox(width: 75,),
                      Column(
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              "assets/images/001-magnifying-glass.svg",width: 20,height: 23,fit: BoxFit.scaleDown,
                              color: Colors.grey.shade400,
                            ),
                            color: Colors.grey,
                          ),

                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                                "assets/images/004-avatar.svg",width: 20,height: 23,fit: BoxFit.scaleDown,
                                color:Colors.grey.shade400),
                            color: Colors.grey,

                          ),

                        ],
                      ),

                      // /ProfilePage
                    ],
                  ),
                ),
              ],
            ),
            // color: Utiles.primary_bg_color,
          ),

        ],
  ),
),


          ),
          onWillPop: () async {
            // sometimes you need get current status
            IntroStatus introStatus = intro.getStatus();
            if (introStatus.isOpen) {
              // destroy guide page when tap back key
              intro.dispose();
              return false;
            }
            return true;
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: SizedBox(
                    child: Container(
                      key: intro.keys[2],
                      width: 55,height: 55,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:Theme.of(context).accentColor
                      ),
                      child: Icon(Icons.add,color: Colors.white,),
                    ),

                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}