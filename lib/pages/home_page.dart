import 'dart:convert';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
import 'package:grocery_store/blocs/category_bloc/category_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/recommended_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/trending_product_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/models/category.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/pages/search_page.dart';
import 'package:grocery_store/screens/all_categories_screen.dart';
import 'package:grocery_store/screens/common_all_products_screen.dart';
import 'package:grocery_store/screens/common_banner_products_screen.dart';
import 'package:grocery_store/screens/notification_screen.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:grocery_store/screens/sub_categories_screen.dart';
import 'package:grocery_store/services/firebase_service.dart';
import 'package:grocery_store/widget/all_category_item.dart';
import 'package:grocery_store/widget/cart_item.dart';
import 'package:grocery_store/widget/category_item.dart';
import 'package:grocery_store/widget/shimmer_all_category_item.dart';
import 'package:grocery_store/widget/shimmer_banner_item.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import '../ad_help.dart';
import '../widget/product_list_item.dart';
import '../models/banner.dart' as prefix;
import 'package:elastic_drawer/elastic_drawer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {

  // TODO: Add _kAdIndex
  static final _kAdIndex = 4;

  // TODO: Add a BannerAd instance
  BannerAd _ad;

  // TODO: Add _isAdLoaded
  bool _isAdLoaded = false;
  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _isAdLoaded) {
      return rawIndex - 1;
    }
    return rawIndex;
  }
  CategoryBloc categoryBloc;
  BannerBloc bannerBloc;
  ProductBloc productBloc;
  TrendingProductBloc trendingProductBloc;
  FeaturedProductBloc featuredProductBloc;
  CartCountBloc cartCountBloc;
  SigninBloc signinBloc;
  User currentUser;
  CartBloc cartBloc;
  NotificationBloc notificationBloc;
  UserNotification userNotification;

  bool first=true;
  prefix.Banner banner;
  List<Category> categoryList;

  List<Product> trendingProducts;
  List<Product> featuredProducts;

  //
  var _Model = [];
  var _ModelForBanner = [];

  Future getSideBanner() async {
    CollectionReference _reference =
        await FirebaseFirestore.instance.collection("SideBanner");
    try {
      await _reference.get().then((value) {
        _ModelForBanner.clear();
        for (int i = 0; i < value.docs.length; i++) {
          setState(() {
            _ModelForBanner.add(SideBannerData.fromjson(value.docs[i].data()));
          });
          print("${_ModelForBanner[i].name}::::::::::<");
        }
      });
    } catch (e) {
      print("the error $e");
    }
  }

  Future getProduct() async {
    CollectionReference _reference =
        await FirebaseFirestore.instance.collection("Products");
    try {
      await _reference.get().then((value) {
        _Model.clear();
        for (int i = 0; i < value.docs.length; i++) {
          setState(() {
            _Model.add(ProductHome.fromjson(value.docs[i].data()));
          });

        }
        print(_Model[0].name);
      });
    } catch (e) {
      print("the error $e");
    }
  }

  int data = 0;

  @override
  void initState() {
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.largeBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          // ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );

    // TODO: Load an ad
    _ad.load();

    super.initState();
    getProduct();
    getSideBanner();
    first = true;
    categoryBloc = BlocProvider.of<CategoryBloc>(context);
    bannerBloc = BlocProvider.of<BannerBloc>(context);
    productBloc = BlocProvider.of<ProductBloc>(context);
    trendingProductBloc = BlocProvider.of<TrendingProductBloc>(context);
    featuredProductBloc = BlocProvider.of<FeaturedProductBloc>(context);
    // cartCountBloc = BlocProvider.of<CartCountBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);

    // categoryBloc.listen((state) {
    //   if (state is CategoryInitialState) {}
    // });

    // bannerBloc.listen((state) {
    //   print(state);
    //   if (first) {}
    // });

    // productBloc.listen((state) {
    //   print('PRODUCT STATE: $state');
    //   if (state is ProductInitial) {}
    // });

    // trendingProductBloc.listen((state) {
    //   if (state is InitialTrendingProductState) {}
    // });

    // featuredProductBloc.listen((state) {
    //   if (state is InitialFeaturedProductState) {}
    // });
    cartCountBloc=BlocProvider.of<CartCountBloc>(context);
    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        print(currentUser.uid);

        if (first) {
          FirebaseService.init(context, currentUser.uid, currentUser);
          cartCountBloc.add(GetCartCountEvent(currentUser.uid));
          notificationBloc.add(GetAllNotificationsEvent(currentUser.uid));
          first = false;
        }
      }
    });

    notificationBloc.listen((state) {
      print('NOTIFICATION STATE :::: $state');
    });

    signinBloc.add(GetCurrentUser());
    bannerBloc.add(LoadBannersEvent());
    categoryBloc.add(LoadCategories());
    productBloc.add(LoadTrendingProductsEvent());
    trendingProductBloc.add(LoadTrendingProductsEvent());
    featuredProductBloc.add(LoadFeaturedProductsEvent());
  }
  checkForAdd(){

    return _isAdLoaded==true? Container(
      child: AdWidget(ad: _ad),
      width: _ad.size.width.toDouble(),
      height: 72.0,
      alignment: Alignment.center,
    )
        :Container();
  }
  @override
  void dispose() {
    _ad.dispose();
    notificationBloc.close();
    first = true;
    super.dispose();
  }

  void showNoNotifSnack(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.green.shade500,
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
      duration: Duration(milliseconds: 1500),
      icon: Icon(
        Icons.notification_important,
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

  var date = DateTime.now();

  Widget buildBanners(int whichBanner) {
    return BlocBuilder(
      cubit: bannerBloc,
      buildWhen: (previous, current) {
        if (current is LoadBannersInProgressState ||
            current is LoadBannersFailedState ||
            current is LoadBannersCompletedState) {
          return true;
        }
        return false;
      },
      builder: (context, state) {
        print('BANNER STATE :: $state');
        if (state is LoadBannersInProgressState) {
          return Container(
            height: 160.0,
            child: Shimmer.fromColors(
              period: Duration(milliseconds: 800),
              baseColor: Colors.grey.withOpacity(0.5),
              highlightColor: Colors.black.withOpacity(0.5),
              child: ShimmerBannerItem(),
            ),
          );
        } else if (state is LoadBannersFailedState) {
          return Container(
            height: 160.0,
            decoration: BoxDecoration(
              color: Colors.cyanAccent,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                'Failed to load image!',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else if (state is LoadBannersCompletedState) {
          banner = state.banner;
          return Container(
            height: 180.0,
            decoration: BoxDecoration(
              color:
                  whichBanner == 1 ? Colors.cyanAccent : Colors.green.shade100,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: whichBanner == 1
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommonBannerProductsScreen(
                              cartBloc: cartBloc,
                              category: banner.middleBanner['category'],
                              currentUser: currentUser,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        banner.middleBanner['middleBanner'],
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            child: child,
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      // child: SvgPicture.network(
                      //   banner.middleBanner['middleBanner'],
                      //   fit: BoxFit.cover,
                      //   placeholderBuilder: (context) => Shimmer.fromColors(
                      //     period: Duration(milliseconds: 800),
                      //     baseColor: Colors.grey.withOpacity(0.5),
                      //     highlightColor: Colors.black.withOpacity(0.5),
                      //     child: ShimmerBannerItem(),
                      //   ),
                      // ),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommonBannerProductsScreen(
                              cartBloc: cartBloc,
                              category: banner.bottomBanner['category'],
                              currentUser: currentUser,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        banner.bottomBanner['bottomBanner'],
                        fit: BoxFit.cover,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            child: child,
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        },
                      ),
                      // child: SvgPicture.network(
                      //   banner.bottomBanner['bottomBanner'],
                      //   fit: BoxFit.cover,
                      //   placeholderBuilder: (context) => Shimmer.fromColors(
                      //     period: Duration(milliseconds: 800),
                      //     baseColor: Colors.grey.withOpacity(0.5),
                      //     highlightColor: Colors.black.withOpacity(0.5),
                      //     child: ShimmerBannerItem(),
                      //   ),
                      // ),
                    ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _ModelForBanner.length == 0 ? getSideBanner() : SizedBox();

    super.build(context);
    // getProduct();

    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        notificationBloc.close();
        return true;
      },
      child: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                   borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0))),
              child: Column(
                children: <Widget>[
                  // Container(
                  //   width: size.width,
                  //   decoration: BoxDecoration(
                  //     color: Theme.of(context).primaryColor,
                  //     borderRadius: BorderRadius.only(
                  //       bottomLeft: Radius.circular(20.0),
                  //       bottomRight: Radius.circular(20.0),
                  //     ),
                  //   ),
                  //   child: SafeArea(
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(
                  //           left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         crossAxisAlignment: CrossAxisAlignment.center,
                  //         mainAxisSize: MainAxisSize.max,
                  //         children: <Widget>[
                  //           Text(
                  //             'Grocery Store',
                  //             style: TextStyle(
                  //               color: Colors.white,
                  //               fontSize: 19.0,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //           ),
                  //           BlocBuilder(
                  //             cubit: notificationBloc,
                  //             buildWhen: (previous, current) {
                  //               if (current is GetAllNotificationsInProgressState ||
                  //                   current is GetAllNotificationsFailedState ||
                  //                   current is GetAllNotificationsCompletedState ||
                  //                   current is GetNotificationsUpdateState) {
                  //                 return true;
                  //               }
                  //               return false;
                  //             },
                  //             builder: (context, state) {
                  //               if (state is GetAllNotificationsInProgressState) {
                  //                 return ClipRRect(
                  //                   borderRadius: BorderRadius.circular(50.0),
                  //                   child: Material(
                  //                     color: Colors.transparent,
                  //                     child: InkWell(
                  //                       splashColor: Colors.white.withOpacity(0.5),
                  //                       onTap: () {
                  //                         print('Notification');
                  //                       },
                  //                       child: Container(
                  //                         decoration: BoxDecoration(
                  //                           color: Colors.transparent,
                  //                         ),
                  //                         width: 38.0,
                  //                         height: 35.0,
                  //                         child: Icon(
                  //                           Icons.notifications,
                  //                           color: Colors.white,
                  //                           size: 26.0,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 );
                  //               }
                  //               if (state is GetNotificationsUpdateState) {
                  //                 if (state.userNotification != null) {
                  //                   if (state.userNotification.notifications.length ==
                  //                       0) {
                  //                     return ClipRRect(
                  //                       borderRadius: BorderRadius.circular(50.0),
                  //                       child: Material(
                  //                         color: Colors.transparent,
                  //                         child: InkWell(
                  //                           splashColor:
                  //                               Colors.white.withOpacity(0.5),
                  //                           onTap: () {
                  //                             print('Notification');
                  //                             //show snackbar with no notifications
                  //                             showNoNotifSnack(
                  //                                 'No notifications found!');
                  //                           },
                  //                           child: Container(
                  //                             decoration: BoxDecoration(
                  //                               color: Colors.transparent,
                  //                             ),
                  //                             width: 38.0,
                  //                             height: 35.0,
                  //                             child: Icon(
                  //                               Icons.notifications,
                  //                               color: Colors.white,
                  //                               size: 26.0,
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     );
                  //                   }
                  //                   userNotification = state.userNotification;
                  //                   return Stack(
                  //                     alignment: Alignment.center,
                  //                     children: <Widget>[
                  //                       Positioned(
                  //                         child: ClipRRect(
                  //                           borderRadius: BorderRadius.circular(50.0),
                  //                           child: Material(
                  //                             color: Colors.transparent,
                  //                             child: InkWell(
                  //                               splashColor:
                  //                                   Colors.white.withOpacity(0.5),
                  //                               onTap: () {
                  //                                 print('Notification');
                  //                                 if (userNotification.unread) {
                  //                                   notificationBloc.add(
                  //                                     NotificationMarkReadEvent(
                  //                                         currentUser.uid),
                  //                                   );
                  //                                 }
                  //                                 Navigator.push(
                  //                                   context,
                  //                                   MaterialPageRoute(
                  //                                     builder: (context) =>
                  //                                         NotificationScreen(
                  //                                       userNotification,
                  //                                     ),
                  //                                   ),
                  //                                 );
                  //                               },
                  //                               child: Container(
                  //                                 decoration: BoxDecoration(
                  //                                   color: Colors.transparent,
                  //                                 ),
                  //                                 width: 38.0,
                  //                                 height: 35.0,
                  //                                 child: Icon(
                  //                                   Icons.notifications,
                  //                                   color: Colors.white,
                  //                                   size: 26.0,
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       userNotification.unread
                  //                           ? Positioned(
                  //                               right: 4.0,
                  //                               top: 4.0,
                  //                               child: Container(
                  //                                 height: 7.5,
                  //                                 width: 7.5,
                  //                                 alignment: Alignment.center,
                  //                                 decoration: BoxDecoration(
                  //                                   shape: BoxShape.circle,
                  //                                   color: Colors.amber,
                  //                                 ),
                  //                               ),
                  //                             )
                  //                           : SizedBox(),
                  //                     ],
                  //                   );
                  //                 }
                  //                 return SizedBox();
                  //               }
                  //               return SizedBox();
                  //             },
                  //           )
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  // // IconButton(icon: Icon(Icons.eighteen_mp), onPressed: (){}),
                  // // Center(
                  // //   child:,
                  // // ),
                  // // SizedBox(
                  // //   height: 30,
                  // // ),
                  // Row(
                  //   children: [
                  //     Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 15),
                  //       child: Align(
                  //         alignment: Alignment.centerRight,
                  //         child: (date.hour >= 0 && date.hour < 12)
                  //             ? Text(
                  //           "صباح الخير",
                  //           style: TextStyle(
                  //             color: Color(0xffB8B8B8),
                  //             fontSize: 17,
                  //             fontWeight: FontWeight.w400,
                  //             // letterSpacing: 0.5,
                  //           ),
                  //         )
                  //             : Text(
                  //           "مساء الخير",
                  //           style: TextStyle(
                  //             color: Colors.black,
                  //             fontSize: 16,
                  //             fontWeight: FontWeight.w400,
                  //             // letterSpacing: 0.5,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     FirebaseAuth.instance.currentUser != null
                  //         ? Text(
                  //         "${FirebaseAuth.instance.currentUser.displayName}",
                  //         style: TextStyle(
                  //             fontSize: 20, color: Color(0xffB8B8B8)))
                  //         : Text(""),
                  //   ],
                  // ),
                  // SizedBox(height: 10),
                  //
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 15),
                  //   child: Align(
                  //     alignment: Alignment.centerRight,
                  //     child: Text(
                  //       "يوم سعيد!",
                  //       style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 28,
                  //         fontWeight: FontWeight.w700,
                  //         // letterSpacing: 0.5,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 80
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Color(0xffE5E5E5))),
                            child: Center(
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
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
                  ),
                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 15),
                  //   child: Row(
                  //     //mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Expanded(
                  //         flex: 6,
                  //         child: InkWell(
                  //           onTap: () {
                  //             Navigator.of(context, rootNavigator: true)
                  //                 .pushReplacement(MaterialPageRoute(
                  //                 builder: (context) => SearchPage()));
                  //             // Navigator.of(context,rootNavigator:true).push(MaterialPageRoute(
                  //             //     builder: (BuildContext context) =>
                  //             //         )));
                  //           },
                  //           child: Container(
                  //               padding: EdgeInsets.symmetric(horizontal: 15),
                  //               margin: EdgeInsets.only(left: 15),
                  //               height: 55,
                  //               decoration: BoxDecoration(
                  //                 // color: Colors.green,
                  //                 border: Border.all(
                  //                   color: Color(0xffB8B8B8),
                  //                 ),
                  //                 borderRadius: BorderRadius.circular(15),
                  //               ),
                  //               clipBehavior: Clip.antiAlias,
                  //               child: Row(
                  //                 children: [
                  //                   Text(
                  //                     "ابحث هنا",
                  //                     style: TextStyle(
                  //                         color: Color(0xff3F2D20),
                  //                         fontSize: 14,
                  //                         fontWeight: FontWeight.w500),
                  //                   ),
                  //                   Spacer(),
                  //                   Container(
                  //                     height: 30,
                  //                     width: 30,
                  //                     //color: Colors.red,
                  //                     child: SvgPicture.asset(
                  //                       'assets/images/icon Search.svg',
                  //                       fit: BoxFit.cover,
                  //                       color: Colors.black,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               )
                  //             // width: MediaQuery.of(context).size.width * .7,
                  //             //  child: TextFormField(
                  //             //
                  //             //    readOnly: true,
                  //             //    maxLines: 1,
                  //             //    textAlign: TextAlign.left,
                  //             //    onTap: () {
                  //             //      Navigator.of(context).push(MaterialPageRoute(
                  //             //          builder: (BuildContext context) => SearchPage()));
                  //             //    },
                  //             //    decoration: InputDecoration(
                  //             //      contentPadding: EdgeInsets.all(30),
                  //             //      hintText: "ابحث هنا      ",
                  //             //      prefixIcon: Icon(
                  //             //        Icons.search,
                  //             //        color: Colors.black,
                  //             //        size: 22,
                  //             //      ),
                  //             //      hintStyle: TextStyle(
                  //             //        color: Colors.black,
                  //             //        fontSize: 13,
                  //             //      ),
                  //             //    ),
                  //             //  ),
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         flex: 1,
                  //         child: InkWell(
                  //           onTap: () {
                  //             Navigator.of(context, rootNavigator: true)
                  //                 .pushReplacement(MaterialPageRoute(
                  //                 builder: (context) => SearchPage()));
                  //             // Navigator.of(context,rootNavigator:true).push(MaterialPageRoute(
                  //             //     builder: (BuildContext context) =>
                  //             //         )));
                  //           },
                  //           child: Container(
                  //             padding: EdgeInsets.all(10),
                  //             width: 50,
                  //             height: 55,
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(13),
                  //               border: Border.all(
                  //                 color: Color(0xffB8B8B8),
                  //               ),
                  //             ),
                  //             child: SvgPicture.asset(
                  //               'assets/images/icon filter.svg',
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 15,
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(right: 17, top: 10),
                    child: Row(
                      children: [
                        Text(
                          "اضافة بعض المشتريات الجديدة",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            // letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 22),
                    child: Row(
                      children: [
                        Text(
                          "اختر الفئة لأضافة المنتج",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            // letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

  Container(
    width: 400,height: 500,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      padding: const EdgeInsets.only(top: 5.0),
                      shrinkWrap: false,
                      children: <Widget>[
                         buildCategories(size),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 16.0, vertical: 15.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisSize: MainAxisSize.max,
                        //     children: <Widget>[
                        //       Text(
                        //         'CATEGORIES',
                        //         style: TextStyle(
                        //           fontSize: 16.0,
                        //           fontWeight: FontWeight.w600,
                        //           letterSpacing: 0.3,
                        //         ),
                        //       ),
                        //       FlatButton(
                        //         onPressed: () {
                        //           print('go to category');
                        //           Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //               builder: (context) => AllCategoriesScreen(
                        //                 categoryList: categoryList,
                        //                 cartBloc: cartBloc,
                        //                 firebaseUser: currentUser,
                        //               ),
                        //             ),
                        //           );
                        //         },
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: 10.0,
                        //         ),
                        //         color: Theme.of(context).primaryColor,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10.0),
                        //         ),
                        //         child: Text(
                        //           'View All',
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 14.0,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 8.0,
                        // ),
                        // buildCategories(size),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 16.0, vertical: 8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisSize: MainAxisSize.max,
                        //     children: <Widget>[
                        //       Text(
                        //         'TRENDING',
                        //         style: TextStyle(
                        //           fontSize: 16.0,
                        //           fontWeight: FontWeight.w600,
                        //           letterSpacing: 0.3,
                        //         ),
                        //       ),
                        //       FlatButton(
                        //         onPressed: () {
                        //           if (trendingProducts != null &&
                        //               trendingProducts.length > 0) {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) => CommonAllProductsScreen(
                        //                   productList: trendingProducts,
                        //                   productType: 'Trending',
                        //                   cartBloc: cartBloc,
                        //                   currentUser: currentUser,
                        //                 ),
                        //               ),
                        //             );
                        //           }
                        //         },
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: 10.0,
                        //         ),
                        //         color: Theme.of(context).primaryColor,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10.0),
                        //         ),
                        //         child: Text(
                        //           'View All',
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 14.0,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Container(
                        //   height: 300.0,
                        //   child: BlocBuilder(
                        //     cubit: trendingProductBloc,
                        //     builder: (context, state) {
                        //       if (state is LoadTrendingProductsInProgressState) {
                        //         return ListView.separated(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 16.0),
                        //           shrinkWrap: true,
                        //           scrollDirection: Axis.horizontal,
                        //           itemCount: 5,
                        //           itemBuilder: (context, index) {
                        //             return Shimmer.fromColors(
                        //               period: Duration(milliseconds: 800),
                        //               baseColor: Colors.grey.withOpacity(0.5),
                        //               highlightColor: Colors.black.withOpacity(0.5),
                        //               child: Container(
                        //                 width: 150.0,
                        //                 child: ShimmerProductListItem(),
                        //               ),
                        //             );
                        //           },
                        //           separatorBuilder: (context, index) {
                        //             return SizedBox(
                        //               width: 20.0,
                        //             );
                        //           },
                        //         );
                        //       } else if (state is LoadTrendingProductsFailedState) {
                        //         return Center(
                        //           child: Text(
                        //             'Failed to load trending products!',
                        //             style: TextStyle(
                        //               fontSize: 15.0,
                        //               fontWeight: FontWeight.w600,
                        //               letterSpacing: 0.3,
                        //             ),
                        //           ),
                        //         );
                        //       } else if (state
                        //           is LoadTrendingProductsCompletedState) {
                        //         trendingProducts = state.productList;
                        //         return ListView.separated(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 16.0),
                        //           shrinkWrap: true,
                        //           scrollDirection: Axis.horizontal,
                        //           itemCount: trendingProducts.length > 5
                        //               ? 5
                        //               : trendingProducts.length,
                        //           itemBuilder: (context, index) {
                        //             return ProductListItem(
                        //               product: trendingProducts[index],
                        //               cartBloc: cartBloc,
                        //               currentUser: currentUser,
                        //             );
                        //           },
                        //           separatorBuilder: (context, index) {
                        //             return SizedBox(
                        //               width: 20.0,
                        //             );
                        //           },
                        //         );
                        //       } else {
                        //         return SizedBox();
                        //       }
                        //     },
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        // buildBanner(1),
                        // SizedBox(
                        //   height: 15.0,
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       horizontal: 16.0, vertical: 8.0),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //     crossAxisAlignment: CrossAxisAlignment.center,
                        //     mainAxisSize: MainAxisSize.max,
                        //     children: <Widget>[
                        //       Text(
                        //         'FEATURED',
                        //         style: TextStyle(
                        //           fontSize: 16.0,
                        //           fontWeight: FontWeight.w600,
                        //           letterSpacing: 0.3,
                        //         ),
                        //       ),
                        //       FlatButton(
                        //         onPressed: () {
                        //           if (featuredProducts != null &&
                        //               featuredProducts.length > 0) {
                        //             Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) => CommonAllProductsScreen(
                        //                   productList: featuredProducts,
                        //                   productType: 'Featured',
                        //                   cartBloc: cartBloc,
                        //                   currentUser: currentUser,
                        //                 ),
                        //               ),
                        //             );
                        //           }
                        //         },
                        //         padding: const EdgeInsets.symmetric(
                        //           vertical: 10.0,
                        //         ),
                        //         color: Theme.of(context).primaryColor,
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(10.0),
                        //         ),
                        //         child: Text(
                        //           'View All',
                        //           style: TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 14.0,
                        //             fontWeight: FontWeight.w500,
                        //           ),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 10.0,
                        // ),
                        // Container(
                        //   height: 300.0,
                        //   child: BlocBuilder(
                        //     cubit: featuredProductBloc,
                        //     builder: (context, state) {
                        //       if (state is LoadFeaturedProductsInProgressState) {
                        //         return ListView.separated(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 16.0),
                        //           shrinkWrap: true,
                        //           scrollDirection: Axis.horizontal,
                        //           itemCount: 5,
                        //           itemBuilder: (context, index) {
                        //             return Shimmer.fromColors(
                        //               period: Duration(milliseconds: 800),
                        //               baseColor: Colors.grey.withOpacity(0.5),
                        //               highlightColor: Colors.black.withOpacity(0.5),
                        //               child: Container(
                        //                 width: 150.0,
                        //                 child: ShimmerProductListItem(),
                        //               ),
                        //             );
                        //           },
                        //           separatorBuilder: (context, index) {
                        //             return SizedBox(
                        //               width: 20.0,
                        //             );
                        //           },
                        //         );
                        //       } else if (state is LoadFeaturedProductsFailedState) {
                        //         return Center(
                        //           child: Text(
                        //             'Failed to load featured products!',
                        //             style: TextStyle(
                        //               fontSize: 15.0,
                        //               fontWeight: FontWeight.w600,
                        //               letterSpacing: 0.3,
                        //             ),
                        //           ),
                        //         );
                        //       } else if (state
                        //           is LoadFeaturedProductsCompletedState) {
                        //         featuredProducts = state.productList;
                        //         return ListView.separated(
                        //           padding:
                        //               const EdgeInsets.symmetric(horizontal: 16.0),
                        //           shrinkWrap: true,
                        //           scrollDirection: Axis.horizontal,
                        //           itemCount: featuredProducts.length > 5
                        //               ? 5
                        //               : featuredProducts.length,
                        //           itemBuilder: (context, index) {
                        //             return ProductListItem(
                        //               product: featuredProducts[index],
                        //               cartBloc: cartBloc,
                        //               currentUser: currentUser,
                        //             );
                        //           },
                        //           separatorBuilder: (context, index) {
                        //             return SizedBox(
                        //               width: 20.0,
                        //             );
                        //           },
                        //         );
                        //       } else {
                        //         return SizedBox();
                        //       }
                        //     },
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        // buildBanner(2),
                        // SizedBox(
                        //   height: 40.0,
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
                // Positioned(child:checkForAdd(),top: 5,left: 15,)
         // _isAdLoaded?  checkForAdd():SizedBox(),
        ],
      ),
    );
  }

  Widget buildTopImageSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: BlocBuilder(
        cubit: bannerBloc,
        buildWhen: (previous, current) {
          if (current is LoadBannersInProgressState ||
              current is LoadBannersFailedState ||
              current is LoadBannersCompletedState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          if (state is LoadBannersInProgressState) {
            return Container(
              height: 220.0,
              child: Shimmer.fromColors(
                period: Duration(milliseconds: 800),
                baseColor: Colors.grey.withOpacity(0.5),
                highlightColor: Colors.black.withOpacity(0.5),
                child: ShimmerBannerItem(),
              ),
            );
          } else if (state is LoadBannersFailedState) {
            return Container(
              height: 220.0,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Text(
                  'Failed to load image!',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          } else if (state is LoadBannersCompletedState) {
            banner = state.banner;
            List<Widget> imageWidgets = [
              buildBanners(2),
            ];
            for (var banner in banner.topBanner) {
              imageWidgets.add(
                Container(
                  height: 180.0,
                  width: double.infinity,
                  child: Image.network(
                    banner,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) {
                        return child;
                      }
                      return AnimatedOpacity(
                        child: child,
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                    },
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0.0, 0.0),
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                  ),
                ],
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlayCurve: Curves.easeInOut,
                    autoPlay: true,
                    autoPlayAnimationDuration: Duration(milliseconds: 500),
                    autoPlayInterval: Duration(milliseconds: 3000),
                    height: 160.0,
                    initialPage: 0,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                    pauseAutoPlayOnTouch: true,
                    viewportFraction: 1.0,
                  ),
                  items: imageWidgets,
                ),
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  Widget buildBanner(int whichBanner) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: BlocBuilder(
        cubit: bannerBloc,
        buildWhen: (previous, current) {
          if (current is LoadBannersInProgressState ||
              current is LoadBannersFailedState ||
              current is LoadBannersCompletedState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          print('BANNER STATE :: $state');
          if (state is LoadBannersInProgressState) {
            return Container(
              height: 160.0,
              child: Shimmer.fromColors(
                period: Duration(milliseconds: 800),
                baseColor: Colors.grey.withOpacity(0.5),
                highlightColor: Colors.black.withOpacity(0.5),
                child: ShimmerBannerItem(),
              ),
            );
          } else if (state is LoadBannersFailedState) {
            return Container(
              height: 160.0,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Text(
                  'Failed to load image!',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          } else if (state is LoadBannersCompletedState) {
            banner = state.banner;
            return Container(
              height: 160.0,
              decoration: BoxDecoration(
                color: whichBanner == 1
                    ? Colors.cyanAccent
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: whichBanner == 1
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommonBannerProductsScreen(
                                cartBloc: cartBloc,
                                category: banner.middleBanner['category'],
                                currentUser: currentUser,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          banner.middleBanner['middleBanner'],
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedOpacity(
                              child: child,
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                        // child: SvgPicture.network(
                        //   banner.middleBanner['middleBanner'],
                        //   fit: BoxFit.cover,
                        //   placeholderBuilder: (context) => Shimmer.fromColors(
                        //     period: Duration(milliseconds: 800),
                        //     baseColor: Colors.grey.withOpacity(0.5),
                        //     highlightColor: Colors.black.withOpacity(0.5),
                        //     child: ShimmerBannerItem(),
                        //   ),
                        // ),
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommonBannerProductsScreen(
                                cartBloc: cartBloc,
                                category: banner.bottomBanner['category'],
                                currentUser: currentUser,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          banner.bottomBanner['bottomBanner'],
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedOpacity(
                              child: child,
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                        // child: SvgPicture.network(
                        //   banner.bottomBanner['bottomBanner'],
                        //   fit: BoxFit.cover,
                        //   placeholderBuilder: (context) => Shimmer.fromColors(
                        //     period: Duration(milliseconds: 800),
                        //     baseColor: Colors.grey.withOpacity(0.5),
                        //     highlightColor: Colors.black.withOpacity(0.5),
                        //     child: ShimmerBannerItem(),
                        //   ),
                        // ),
                      ),
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }

  List number = [];
  var Model = [];

  Widget buildCategories(Size size) {
    return BlocBuilder(
      cubit: categoryBloc,
      buildWhen: (previous, current) {
        if (current is LoadCategoriesInProgressState ||
            current is LoadCategoriesCompletedState ||
            current is LoadCategoriesInFailedState) {
          return true;
        } else {
          return false;
        }
      },
      builder: (BuildContext context, state) {
        if (state is LoadCategoriesInProgressState ||
            state is CategoryInitialState) {
          //getting categories
          print('getting the categories');
          return Container(
            width: size.width,
            height: size.width - size.width * 0.2 - 32.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            // child: ListView.builder(
            //   itemCount: 6,
            //   itemBuilder: (context, index) {
            //     return Shimmer.fromColors(
            //       period: Duration(milliseconds: 800),
            //       baseColor: Colors.grey.withOpacity(0.5),
            //       highlightColor: Colors.black.withOpacity(0.5),
            //       child: ShimmerAllCategoryItem(),
            //     );
            //   },
            // ),
          );
        } else if (state is LoadCategoriesInFailedState) {
          //failed getting categories
          print('failed to get the categories');
          return Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Faild to fetch!',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        } else if (state is LoadCategoriesCompletedState) {
          //getting categories completed
          print(state.categories);
          categoryList = state.categories;
          List model = [];
          for (int i = 0; i < categoryList.length; i++) {
            model.add(categoryList[i].subCategories);

            for (var i in model) {
              return Column(
                children: [
                  // AnimationLimiter(
                  //   child:
                    ListView.builder(
                      itemCount: categoryList[0].subCategories.length,
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        data = 0;
                        for (var i in _Model) {
                          if (i.subCategoryName ==
                              categoryList[0].subCategories[index]
                                  ["subCategoryName"]) {
                            data++;
                          } else {}
                        }
                       return Column(
                         children: [

                           // AnimationConfiguration
                           //      .staggeredList(
                           //    position: index,
                           //    duration: const Duration(
                           //        milliseconds: 2000),
                           //    child: SlideAnimation(
                           //      verticalOffset: 100.0,
                           //      child: FadeInAnimation(
                           //      child:
                                Column(
                              children: [
                                Container(
                                    // height: 38.0,
                                    child: TextButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            decoration:BoxDecoration(
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(color: Theme.of(context).accentColor,width: 1)
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(18),
                                              child: new FadeInImage.assetNetwork(
                                                placeholder: 'assets/images/sympgoney.jpg',
                                                image: categoryList[0]
                                                    .subCategories[index]["imageData"]
                                                    .toString(),
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 15),
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    categoryList[0].subCategories[index]
                                                    ["subCategoryName"],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  child: Text(
                                                    "  عدد المنتجات :  ${data.toString()}",
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 0,),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                             color: Theme.of(context).primaryColor,
                                            // border: Border.all(color: Theme.of(context).accentColor)
                                          ),
                                          child: Center(
                                              child: TextButton(
                                            onPressed: () {
                                              return showMaterialModalBottomSheet(
                                                context: context,
                                                barrierColor: Colors.black.withAlpha(1),
                                                shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(
                                                    topLeft: Radius.circular(25.0),
                                                    topRight: Radius.circular(25.0))),
                                                builder: (context) => BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX:2, sigmaY: 2,tileMode:TileMode.mirror),
                                                  child: SingleChildScrollView(
                                                      controller: ModalScrollController.of(context),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color:Color(0xffF2F6F9),
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(15.0),
                                                                topRight: Radius.circular(15.0))),
                                                        child: Container(
                                                            height: 680,
                                                            width: 400,
                                                            decoration: BoxDecoration(
                                                                // color:Theme.of(context).primaryColor,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(15.0),
                                                                    topRight: Radius.circular(15.0))),
                                                            child: SubCategoriesScreen(
                                                              category: categoryList[0].categoryName,
                                                              subCategories: categoryList[0].subCategories,
                                                              selectedCategory: index,
                                                              cartBloc: cartBloc,
                                                              firebaseUser: currentUser,
                                                            ),),
                                                      )
                                                  ),
                                                ),
                                              );
                                            //   return Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) => SubCategoriesScreen(
                                            //       category: categoryList[0].categoryName,
                                            //       subCategories: categoryList[0].subCategories,
                                            //       selectedCategory: index,
                                            //       cartBloc: cartBloc,
                                            //       firebaseUser: currentUser,
                                            //     ),
                                            //   ),
                                            // );
                                            },
                                            child: Text(
                                              "اختر",
                                              style: TextStyle(color:Colors.white,fontWeight: FontWeight.w500),
                                            ),
                                          )),
                                        ),
                                      ),

                                    ],
                                  ),
                                )),


                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Divider(),
                                ),


                              ],
                                )
                            // )
                            // )
                            // ),

                         ],
                       );

                      },
                    // ),
                  ),
                ],
              );
            }
          }
          //  return GridView.builder(
          //   itemCount: categoryList.length,
          //   scrollDirection: Axis.vertical,
          //   physics: NeverScrollableScrollPhysics(),
          //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 2,
          //     childAspectRatio: 4 / 5,
          //     crossAxisSpacing: 15,
          //     mainAxisSpacing: 15,
          //   ),
          //   shrinkWrap: true,
          //   itemBuilder: (context, index) {
          //       return ClipRRect(
          //         borderRadius: BorderRadius.circular(10.0),
          //         child: GestureDetector(
          //           onTap: () {
          //             print('go to category');
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => SubCategoriesScreen(
          //                   category: categoryList[index].categoryName,
          //                   subCategories: categoryList[index].subCategories,
          //                   selectedCategory: index,
          //                   cartBloc: cartBloc,
          //                   firebaseUser: currentUser,
          //                 ),
          //               ),
          //             );
          //           },
          //           child: Container(
          //             child: Stack(
          //               children: <Widget>[
          //                 Container(
          //                   padding: EdgeInsets.all(5.0),
          //                   child: ClipRRect(
          //                     borderRadius: BorderRadius.circular(25),
          //                     child: FadeInImage.assetNetwork(
          //                       placeholder: 'assets/icons/category_placeholder.png',
          //                       image: categoryList[index].imageLink,
          //                       fadeInCurve: Curves.easeInOut,
          //                       fadeInDuration: Duration(milliseconds: 250),
          //                       fadeOutCurve: Curves.easeInOut,
          //                       fadeOutDuration: Duration(milliseconds: 150),
          //                     ),
          //                   ),
          //                 ),
          //                 Column(
          //                   children: [
          //                     Padding(
          //                       padding: const EdgeInsets.only(top:20.0,right: 20),
          //                       child: Text(
          //                         categoryList[index].categoryName,
          //                         overflow: TextOverflow.ellipsis,
          //                         maxLines: 2,
          //                         style: TextStyle(
          //                           fontSize: 20,
          //                           color: Colors.white,
          //                           fontWeight: FontWeight.w500,
          //                           letterSpacing: 0.3,
          //                         ),
          //                       ),
          //
          //                     )],
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //       //   AllCategoryItem(
          //       //   category: categoryList[index],
          //       //   index: index,
          //       //   cartBloc: cartBloc,
          //       //   firebaseUser: currentUser,
          //       //   num:number,
          //       // );
          //     }
          //
          // );
        }
        return SizedBox();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ProductHome {
  var subCategoryName;
  var name;
  var id;

  ProductHome(this.subCategoryName, this.name);

  ProductHome.fromjson(Map<String, dynamic> data) {
    subCategoryName = data["subCategory"];
    name = data["name"];
    id = data["id"];
  }
}

class SideBannerData {
  String name;
  String image;

  SideBannerData.fromjson(Map<String, dynamic> map) {
    name = map["Product"];
    image = map["sideBanner"];
  }
}
