import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
import 'package:grocery_store/blocs/manage_coupons_bloc/manage_coupons_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/cart.dart';
import 'package:grocery_store/models/cart_values.dart';
import 'package:grocery_store/models/coupon.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/pages/profile_page.dart';
import 'package:grocery_store/pages/search_page.dart';
import 'package:grocery_store/pages/wishlist_page.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/services/firebase_service.dart';
import 'package:grocery_store/widget/cart_item.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:grocery_store/widget/shimmer_cart_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../ad_help.dart';
import '../generate.dart';
import 'PaymentsData.dart';
import 'checkout_screen.dart';
import 'commanText.dart';
import 'common_banner_products_screen.dart';
import 'navicationBarScreen.dart';
import '../models/banner.dart' as prefix;
import 'notification_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with WidgetsBindingObserver {
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

  AppLifecycleState _lastLifecycleState;

  CartBloc cartBloc;
  SigninBloc signinBloc;
  User currentUser;
  CartValues cartValues;
  List<Cart> cartProducts = [];
  double totalOrderAmt,
      totalAmt,
      discountAmt,
      shippingAmt,
      taxAmt,
      couponDiscountAmt;
  int val;
  bool isUserLoaded;
  bool isPriceLoaded;
  bool isFirst;
  bool isApplying;
  String popUpImage;
  BannerBloc bannerBloc;
  prefix.Banner banner;

  //coupon
  Coupon coupon;
  bool appliedCoupon;
  ManageCouponsBloc manageCouponsBloc;
  NotificationBloc notificationBloc;
  TextEditingController couponController;
  bool first;
  CartCountBloc cartCountBloc;
  UserNotification userNotification;

  // var _ModelForBanner = [];
  //
  // Future getSideBanner() async {
  //   CollectionReference _reference =
  //   await FirebaseFirestore.instance.collection("SideBanner");
  //   try {
  //     await _reference.get().then((value) {
  //       _ModelForBanner.clear();
  //       for (int i = 0; i < 1; i++) {
  //         setState(() {
  //           _ModelForBanner.add(SideBannerData.fromjson(value.docs[i].data()));
  //         });
  //         print("${_ModelForBanner[i].name}::::::::::<");
  //       }
  //     });
  //   } catch (e) {
  //     print("the error $e");
  //   }
  // }
  // showDialogIfFirstLoaded(BuildContext context) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool isFirstLoaded = prefs.getBool('is_first_loaded');
  //   print("${isFirstLoaded}::::::><<<<<<");
  //    // Future.delayed(Duration(seconds: 0),() {
  //      if (_ModelForBanner[0].image != null &&
  //          isFirstLoaded == true || isFirstLoaded==null&&
  //          Navigator.canPop(context) == false
  //      )
  //    // });
  //   showGeneralDialog(
  //         barrierColor: Colors.black.withOpacity(0.5),
  //         transitionBuilder: (context, a1, a2, widgget) {
  //           return Transform.scale(
  //             scale: a1.value,
  //             child: Opacity(
  //               opacity: a1.value,
  //               child: AlertDialog(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.all(
  //                     Radius.circular(15.0),
  //                   ),
  //                 ),
  //                 elevation: 5.0,
  //                 contentPadding: const EdgeInsets.only(
  //                     left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
  //                 content: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: <Widget>[
  //                     ClipRRect(
  //                       borderRadius: BorderRadius.circular(50.0),
  //                       child: Material(
  //                         color: Colors.red,
  //                         child: InkWell(
  //                           splashColor: Colors.white.withOpacity(0.5),
  //                           onTap: () {
  //                             //TODO: take user to edit
  //                             prefs.setBool('is_first_loaded', false);
  //                             Navigator.pop(context);
  //                           },
  //                           child: Container(
  //                             // margin: EdgeInsets.only(right: 60.0),
  //                             decoration: BoxDecoration(
  //                               color:Theme.of(context).primaryColor,
  //                             ),
  //                             width: 30.0,
  //                             height: 30.0,
  //                             child: Icon(
  //                               Icons.close,
  //                               color: Colors.white,
  //                               size: 16.0,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 15.0,
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                         // Navigator.of(context).push(PageRouteBuilder(
  //                         //     pageBuilder: (context, anmation, _) {
  //                         //       return ScaleTransition(
  //                         //           scale: anmation,
  //                         //           alignment: Alignment.centerRight,
  //                         //           child: CommonBannerProductsScreen(
  //                         //             cartBloc: cartBloc,
  //                         //             category: banner.popUpBanner['category'],
  //                         //             currentUser: currentUser,
  //                         //           ));
  //                         //     }));
  //                       },
  //                       child: ClipRRect(
  //                         borderRadius: BorderRadius.circular(15.0),
  //                         child: AspectRatio(
  //                           aspectRatio: 10 / 17,
  //                           child: FadeInImage.assetNetwork(
  //                             placeholder:
  //                             'assets/icons/category_placeholder.png',
  //                             image: _ModelForBanner[0].image,
  //                             fadeInDuration: Duration(milliseconds: 250),
  //                             fadeInCurve: Curves.easeInOut,
  //                             fit: BoxFit.cover,
  //                             fadeOutDuration: Duration(milliseconds: 150),
  //                             fadeOutCurve: Curves.easeInOut,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(
  //                       height: 30.0,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //         transitionDuration: Duration(milliseconds: 200),
  //         barrierDismissible: true,
  //         barrierLabel: '',
  //         context: context,
  //         pageBuilder: (context, animation1, animation2) {});
  // }
  @override
  void dispose() {
    _ad.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    WidgetsBinding.instance.addObserver(this);
    signinBloc = BlocProvider.of<SigninBloc>(context);

    totalAmt = 0;
    totalOrderAmt = 0;
    discountAmt = 0;
    shippingAmt = 0;
    taxAmt = 0;
    isFirst = true;
    isUserLoaded = false;
    first = true;
    cartCountBloc = BlocProvider.of<CartCountBloc>(context);
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
    isPriceLoaded = false;
    cartBloc = BlocProvider.of<CartBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    manageCouponsBloc = BlocProvider.of<ManageCouponsBloc>(context);
    couponDiscountAmt = 0;
    appliedCoupon = false;
    isApplying = false;
    couponController = TextEditingController();

    currentUser = FirebaseAuth.instance.currentUser;
    currentUser == null
        ? SizedBox()
        : cartBloc.add(GetCartProductsEvent(currentUser.uid));

    // signinBloc.listen((state) {
    //   print('SIGN IN BLOC :: $state');

    //   if (state is GetCurrentUserCompleted) {
    //     currentUser = state.firebaseUser;
    //     cartBloc.add(GetCartProductsEvent(currentUser.uid));
    //     // cartBloc.add(GetCartValuesEvent());
    //   }
    // });
    cartBloc.listen((state) {
      print(state);
      if (state is GetCartProductsCompletedState) {
        setState(() {
          val = state.cartProductsList.length;
        });
      }
      if (state is RemoveFromCartInProgressState) {
        showRemovingProductDialog();
        isPriceLoaded = false;
      }
      if (state is RemoveFromCartCompletedState) {
        Navigator.of(context).pop();
      }
    });
    manageCouponsBloc.listen((state) {
      print(state);
      if (state is ApplyCouponFailedState) {
        //failed
        if (isApplying) {
          isApplying = false;
          Navigator.of(context).pop();
          showSnack('Failed to apply coupon!', context);
        }
      }
      if (state is ApplyCouponInProgressState) {
        showUpdatingDialog();
      }
      if (state is ApplyCouponCompletedState) {
        if (isApplying) {
          isApplying = true;
          Navigator.of(context).pop();

          if (state.res.couponCode != null) {
            //found
            coupon = state.res;
            applyCoupon();
          } else {
            //not found
            showSnack('كوبون غير صالح !', context);
          }
        }
      }
    });

    cartBloc.listen((state) {
      print(state);
      if (state is GetCartProductsCompletedState) {
        print(state.cartProductsList.length);
        if (state.cartProductsList.length > 0) {
          if (isFirst) {
            cartBloc.add(GetCartValuesEvent());
            isFirst = false;
          }
        }
      }
      if (state is RemoveFromCartInProgressState) {
        showRemovingProductDialog();
        isPriceLoaded = false;
      }
      if (state is RemoveFromCartCompletedState) {
        cartBloc.add(GetCartValuesEvent());

        Navigator.of(context).pop();
      }
    });

    signinBloc.add(GetCurrentUser());

    // if (!isUserLoaded) {
    //   signinBloc.add(GetCurrentUser());
    //   isUserLoaded = true;
    // }
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
  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'جاري تطبيق الكوبون..\nمن فضلك انتظر !',
        );
      },
    );
  }
  void showRemovingProductDialog() {
    showDialog(
      builder: (context) => AlertDialog(
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'حذف المنتج',
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                color: Colors.black.withOpacity(0.9),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      context: context,
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
      duration: Duration(milliseconds: 2500),
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
  applyCoupon() {
    print(coupon.type);
    totalAmt = 0;
    totalOrderAmt = 0;
    discountAmt = 0;
    taxAmt = 0;
    shippingAmt = double.parse(cartValues.cartInfo.shippingAmt);
    for (var product in cartProducts) {
      var price;

      if (product.product.isDiscounted) {
        price = (1 - (product.product.discount / 100)) *
            double.parse(product.sku.skuPrice);
      } else {
        price = double.parse(product.sku.skuPrice);
      }
      totalOrderAmt = totalOrderAmt + (price * int.parse(product.quantity));
    }

    if (totalOrderAmt > double.parse(cartValues.cartInfo.discountAmt)) {
      discountAmt =
          (double.parse(cartValues.cartInfo.discountPer) / 100) * totalOrderAmt;
    }

    taxAmt = (double.parse(cartValues.cartInfo.taxPer) / 100) * totalOrderAmt;

    totalAmt = totalOrderAmt + taxAmt + shippingAmt - discountAmt;

    setState(() {
      if (coupon.type == 'LIMITED_USE_COUPON') {
        //limited no of use
        if (coupon.usedNoOfTimes < int.parse(coupon.noOfUses)) {
          //allow it
          double couponDiscountPer = double.parse(coupon.discount);
          couponDiscountAmt =
              (totalOrderAmt + taxAmt + shippingAmt - discountAmt) *
                  couponDiscountPer /
                  100;

          totalAmt = totalAmt - couponDiscountAmt;
          appliedCoupon = true;

          print(totalAmt);
        } else {
          //dont allow
          showSnack('Coupon is expired!', context);
        }
      } else {
        //limited time
        DateTime now = DateTime.now();

        if (now.isAfter(coupon.fromDate.toDate()) &&
            now.isBefore(coupon.toDate.toDate())) {
          //yes
          print('YES');
          double couponDiscountPer = double.parse(coupon.discount);
          couponDiscountAmt =
              (totalOrderAmt + taxAmt + shippingAmt - discountAmt) *
                  couponDiscountPer /
                  100;

          totalAmt = totalAmt - couponDiscountAmt;
          appliedCoupon = true;

          print(totalAmt);
        } else {
          print('NO');
          showSnack('Coupon is invalid!', context);
        }
      }
    });
  }
  removeCoupon() {
    setState(() {
      totalAmt = 0;
      totalOrderAmt = 0;
      discountAmt = 0;
      taxAmt = 0;
      shippingAmt = double.parse(cartValues.cartInfo.shippingAmt);
      for (var product in cartProducts) {
        var price;

        if (product.product.isDiscounted) {
          price = (1 - (product.product.discount / 100)) *
              double.parse(product.sku.skuPrice);
        } else {
          price = double.parse(product.sku.skuPrice);
        }
        totalOrderAmt = totalOrderAmt + (price * int.parse(product.quantity));
      }

      if (totalOrderAmt > double.parse(cartValues.cartInfo.discountAmt)) {
        discountAmt = (double.parse(cartValues.cartInfo.discountPer) / 100) *
            totalOrderAmt;
      }

      taxAmt = (double.parse(cartValues.cartInfo.taxPer) / 100) * totalOrderAmt;

      totalAmt = totalOrderAmt + taxAmt + shippingAmt - discountAmt;

      appliedCoupon = false;
    });
  }

  var date = DateTime.now();
  var clear = false;
  var data1;

  @override
  Widget build(BuildContext context) {
    //
    // _ModelForBanner.length == 0 ? getSideBanner():SizedBox();
    //
    // _ModelForBanner.length == 1 ? Future.delayed(Duration(seconds: 2), () async {
    //   print("مرة");
    //   switch(_ModelForBanner[0].image !=null){
    //     case true :
    //       showDialogIfFirstLoaded(context);
    //        break;
    //     case false: print("*/*/*/*1");
    //   }
    //   // setState(() {
    //   //   popUpImage = banner.popUpBanner['sideBanner'];
    //   //   // popUpImage = banner.popUpBanner['popUpBanner'];
    //   // });
    //   // print(popUpImage);
    // }):SizedBox();
    double allCost = 0.0;
    AppUpdateInfo _updateInfo;

    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

    bool _flexibleUpdateAvailable = false;

    // Platform messages are asynchronous, so we initialize in an async method.
    Future<void> checkForUpdate() async {
      InAppUpdate.checkForUpdate().then((info) {
        setState(() {
          _updateInfo = info;
        });
      }).catchError((e) {
        // showSnack(e.toString());
      });
    }
    Size size = MediaQuery.of(context).size;
    print(NavicationBarScreen.colorData);
    return WillPopScope(
      onWillPop: () async {
        SharedPreferences _pref = await SharedPreferences.getInstance();
        _pref.setBool('is_first_loaded', true);
        print(
            "${_pref.getBool("is_first_loaded")}:::::::::::::::::>>>>>>>>>>>>>>>>>>>>>>>>");
      },
      child: ConnectivityWidget(
          builder: (context, isOnline) => Center(
                child: isOnline == true
                    ? Scaffold(
                        backgroundColor: Color(0xffF2F6F9),
                        appBar: AppBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          toolbarHeight:0,
                          elevation: 0,
                        ),
                        // appBar: AppBar(
                        //   leading: IconButton(
                        //       icon: Container(
                        //         height: 35,
                        //         width: 35,
                        //         child: Icon(
                        //           Icons.arrow_back,
                        //           color: Colors.black,
                        //           size: 20,
                        //         ),
                        //         decoration: BoxDecoration(
                        //           border: Border.all(color: Colors.grey),
                        //           borderRadius: BorderRadius.circular(5),
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //       onPressed: () => Navigator.of(context, rootNavigator: true)
                        //               .pushReplacement(MaterialPageRoute(
                        //             builder: (context) => NavicationBarScreen(),
                        //           ))),
                        //   centerTitle: true,
                        //   backgroundColor: Colors.white,
                        //   elevation: 0,
                        //   title: Text(
                        //     "ائمة المشتريات",
                        //     style: TextStyle(
                        //       fontSize: 20,
                        //     ),
                        //   ),
                        // ),
                        body: SafeArea(
                          top: false,
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      // width: double.infinity,
                                      // height: double.infinity,
                                      // clear==true?Colors.red:
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    height: 250,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 40,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              child: Align(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: (date.hour >=
                                                                            0 &&
                                                                        date.hour <
                                                                            12)
                                                                    ? Text(
                                                                        "صــبـــاح الـخـيـــــــر",
                                                                        style:
                                                                            TextStyle(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade500,
                                                                          fontSize:
                                                                              18,
                                                                          letterSpacing:
                                                                              4,
                                                                          fontWeight:
                                                                              FontWeight.w200,
                                                                          // letterSpacing: 0.5,
                                                                        ),
                                                                      )
                                                                    : Text(
                                                                        "مساء الخير",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Theme.of(context).accentColor,
                                                                          fontSize:
                                                                              22,
                                                                          letterSpacing:
                                                                              4,
                                                                          fontWeight:
                                                                              FontWeight.w200,
                                                                          // letterSpacing: 0.5,
                                                                        ),
                                                                      ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        FirebaseAuth.instance
                                                                    .currentUser !=
                                                                null
                                                            ? Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        " أهلاً  ${FirebaseAuth.instance.currentUser.displayName == null ? "بيكي" : FirebaseAuth.instance.currentUser.displayName}",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    BlocBuilder(
                                                                      cubit:
                                                                          notificationBloc,
                                                                      buildWhen:
                                                                          (previous,
                                                                              current) {
                                                                        if (current is GetAllNotificationsInProgressState ||
                                                                            current
                                                                                is GetAllNotificationsFailedState ||
                                                                            current
                                                                                is GetAllNotificationsCompletedState ||
                                                                            current
                                                                                is GetNotificationsUpdateState) {
                                                                          return true;
                                                                        }
                                                                        return false;
                                                                      },
                                                                      builder:
                                                                          (context,
                                                                              state) {
                                                                        if (state
                                                                            is GetAllNotificationsInProgressState) {
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 5),
                                                                            child:
                                                                                ClipRRect(
                                                                              child: Material(
                                                                                color: Colors.transparent,
                                                                                child: InkWell(
                                                                                  splashColor: Colors.white.withOpacity(0.5),
                                                                                  onTap: () {
                                                                                    print('Notification');
                                                                                    // showNoNotifSnack('لا توجد إشعارات');
                                                                                  },
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Theme.of(context).accentColor.withOpacity(0.7)), borderRadius: BorderRadius.circular(10)),
                                                                                    width: 40.0,
                                                                                    height: 40.0,
                                                                                    child: Icon(
                                                                                      Icons.notifications_active_outlined,
                                                                                      color: Colors.white.withOpacity(0.7),
                                                                                      size: 26.0,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }
                                                                        if (state
                                                                            is GetNotificationsUpdateState) {
                                                                          if (state.userNotification !=
                                                                              null) {
                                                                            if (state.userNotification.notifications.length ==
                                                                                0) {
                                                                              return Padding(
                                                                                padding: const EdgeInsets.only(left: 10),
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(50.0),
                                                                                  child: Material(
                                                                                    color: Colors.transparent,
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.white.withOpacity(0.5),
                                                                                      onTap: () {
                                                                                        print('Notification');
                                                                                        //show snackbar with no notifications
                                                                                        // showNoNotifSnack('لا توجد إشعارات');
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Theme.of(context).accentColor.withOpacity(0.7)), borderRadius: BorderRadius.circular(10)),
                                                                                        width: 40.0,
                                                                                        height: 40.0,
                                                                                        child: Icon(
                                                                                          Icons.notifications_active_outlined,
                                                                                          color: Colors.white.withOpacity(0.7),
                                                                                          size: 26.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }
                                                                            userNotification =
                                                                                state.userNotification;
                                                                            return Stack(
                                                                              alignment: Alignment.center,
                                                                              children: <Widget>[
                                                                                Positioned(
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(left: 10),
                                                                                    child: ClipRRect(
                                                                                      child: Material(
                                                                                        color: Colors.transparent,
                                                                                        child: InkWell(
                                                                                          splashColor: Colors.white.withOpacity(0.5),
                                                                                          onTap: () {
                                                                                            print('Notification');
                                                                                            if (userNotification.unread) {
                                                                                              notificationBloc.add(
                                                                                                NotificationMarkReadEvent(currentUser.uid),
                                                                                              );
                                                                                            }
                                                                                            Navigator.push(
                                                                                              context,
                                                                                              MaterialPageRoute(
                                                                                                builder: (context) => NotificationScreen(
                                                                                                  userNotification,
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          },
                                                                                          child: Container(
                                                                                            decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Theme.of(context).accentColor.withOpacity(0.7)), borderRadius: BorderRadius.circular(10)),
                                                                                            width: 40.0,
                                                                                            height: 40.0,
                                                                                            child: Icon(
                                                                                              Icons.notifications_active_outlined,
                                                                                              color: Colors.white.withOpacity(0.7),
                                                                                              size: 26.0,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                userNotification.unread
                                                                                    ? Positioned(
                                                                                        right: 4.0,
                                                                                        top: 4.0,
                                                                                        child: Container(
                                                                                          height: 7.5,
                                                                                          width: 7.5,
                                                                                          alignment: Alignment.center,
                                                                                          decoration: BoxDecoration(
                                                                                            shape: BoxShape.circle,
                                                                                            color: Theme.of(context).primaryColor,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : SizedBox(),
                                                                              ],
                                                                            );
                                                                          }
                                                                          return Stack(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            children: <Widget>[
                                                                              Positioned(
                                                                                child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(50.0),
                                                                                  child: Material(
                                                                                    color: Colors.transparent,
                                                                                    child: InkWell(
                                                                                      splashColor: Colors.white.withOpacity(0.5),
                                                                                      onTap: () {
                                                                                        print('Notification');
                                                                                        if (userNotification.unread) {
                                                                                          notificationBloc.add(
                                                                                            NotificationMarkReadEvent(currentUser.uid),
                                                                                          );
                                                                                        }
                                                                                        Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (context) => NotificationScreen(
                                                                                              userNotification,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(color: Colors.transparent, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                                                                                        width: 40.0,
                                                                                        height: 40.0,
                                                                                        child: Icon(
                                                                                          Icons.notifications_active_outlined,
                                                                                          color: Theme.of(context).accentColor.withOpacity(0.5),
                                                                                          size: 26.0,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              userNotification.unread
                                                                                  ? Positioned(
                                                                                      right: 4.0,
                                                                                      top: 4.0,
                                                                                      child: Container(
                                                                                        height: 7.5,
                                                                                        width: 7.5,
                                                                                        alignment: Alignment.center,
                                                                                        decoration: BoxDecoration(
                                                                                          shape: BoxShape.circle,
                                                                                          color: Theme.of(context).primaryColor,
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  : SizedBox(),
                                                                            ],
                                                                          );
                                                                        }
                                                                        if (state
                                                                                is GetAllNotificationsCompletedState ||
                                                                            state
                                                                                is GetAllNotificationsFailedState) {}
                                                                        return Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(),
                                                                          child:
                                                                              Container(
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.transparent,
                                                                                border: Border.all(color: Theme.of(context).accentColor),
                                                                                borderRadius: BorderRadius.circular(10)),
                                                                            width:
                                                                                40.0,
                                                                            height:
                                                                                40.0,
                                                                            child:
                                                                                Icon(
                                                                              Icons.notifications_active_outlined,
                                                                              color: Colors.white,
                                                                              size: 26.0,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            10),
                                                                    child: Text(
                                                                      " أهلاً بيكي ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        right:
                                                                            10,
                                                                        bottom:
                                                                            15),
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .transparent,
                                                                          border:
                                                                              Border.all(color: Theme.of(context).accentColor.withOpacity(0.7)),
                                                                          borderRadius: BorderRadius.circular(10)),
                                                                      width:
                                                                          40.0,
                                                                      height:
                                                                          40.0,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .notifications_active_outlined,
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(0.7),
                                                                        size:
                                                                            26.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height -
                                                            320,
                                                    color: Color(0xffF2F6F9),
                                                  ),
                                                ],
                                              ),
                                              FirebaseAuth.instance
                                                          .currentUser ==
                                                      null
                                                  ? Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 120,
                                                        ),
                                                        Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                              child:
                                                                  SingleChildScrollView(
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            "assets/images/Cost.png",
                                                                            width:
                                                                                60,
                                                                            height:
                                                                                60,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "المبلغ الكلي للقايمة",
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  color: Theme.of(context).accentColor,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "${allCost}",
                                                                                    style: TextStyle(
                                                                                      fontSize: 24,
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(bottom: 15, right: 8),
                                                                                    child: Text(
                                                                                      "جنية",
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        color: Colors.grey.shade500,
                                                                                        fontWeight: FontWeight.w500,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    allCost == 0
                                                                        ? Container(
                                                                            width:
                                                                                120,
                                                                            height:
                                                                                40,
                                                                            decoration:
                                                                                BoxDecoration(color: Theme.of(context).accentColor.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                                                                            child: TextButton(
                                                                                child: Center(
                                                                              child: Text(
                                                                                "انشاء القايمة",
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.w400,
                                                                                ),
                                                                              ),
                                                                            )))
                                                                        : Container(
                                                                            width:
                                                                                120,
                                                                            height:
                                                                                40,
                                                                            decoration:
                                                                                BoxDecoration(color: Theme.of(context).accentColor.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                                                                            child:
                                                                                TextButton(
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "انشاء القايمة",
                                                                                  style: TextStyle(
                                                                                    fontSize: 15,
                                                                                    color: Colors.white,
                                                                                    fontWeight: FontWeight.w400,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              onPressed: () {
                                                                                return showMaterialModalBottomSheet(
                                                                                  context: context,
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                  builder: (context) => SingleChildScrollView(
                                                                                      controller: ModalScrollController.of(context),
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                        child: Container(
                                                                                            height: 680,
                                                                                            width: 400,
                                                                                            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                            child: PatmentData(
                                                                                              category: cartProducts,
                                                                                            )),
                                                                                      )),
                                                                                );
                                                                              },
                                                                            ),
                                                                          )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                        ),
                                                        Lottie.asset(
                                                          'assets/images/emptyCart.json',
                                                        ),
                                                        SizedBox(
                                                          height: 30.0,
                                                        ),
                                                        // Text(
                                                        //   'لا يوجد لديك مشتريات بعد',
                                                        //   style: TextStyle(
                                                        //     color: Color(0xff00B6E6),
                                                        //     fontSize: 18.5,
                                                        //     fontWeight: FontWeight.w600,
                                                        //     letterSpacing: 0.3,
                                                        //   ),
                                                        // ),
                                                        SizedBox(
                                                          height: 0.0,
                                                        ),
                                                        Text(
                                                          'قومى بتسجيل الدخول واحفظى\n بياناتك من الفقدان',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 20.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing: 0.3,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(
                                                          height: 100,
                                                        ),
                                                      ],
                                                    )
                                                  : BlocBuilder(
                                                      cubit: cartBloc,
                                                      buildWhen:
                                                          (previous, current) {
                                                        if (current is GetCartProductsInProgressState ||
                                                            current
                                                                is GetCartProductsFailedState ||
                                                            current
                                                                is GetCartProductsCompletedState ||
                                                            current
                                                                is IncreaseQuantityInProgressState ||
                                                            current
                                                                is IncreaseQuantityCompletedState) {
                                                          return true;
                                                        }
                                                        return false;
                                                      },
                                                      builder:
                                                          (context, state) {
                                                        if (state
                                                            is GetCartProductsInProgressState) {
                                                          return Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 250,
                                                              ),
                                                              ListView
                                                                  .separated(
                                                                itemCount: 5,
                                                                physics:
                                                                    NeverScrollableScrollPhysics(),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(0),
                                                                shrinkWrap:
                                                                    true,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Shimmer
                                                                      .fromColors(
                                                                    period: Duration(
                                                                        milliseconds:
                                                                            800),
                                                                    baseColor: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.5),
                                                                    highlightColor: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.5),
                                                                    child: ShimmerCartItem(
                                                                        size:
                                                                            size),
                                                                  );
                                                                },
                                                                separatorBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return SizedBox(
                                                                      height:
                                                                          20.0);
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                        if (state
                                                            is GetCartProductsFailedState) {
                                                          return Center(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .max,
                                                              children: <Widget>[
                                                                SvgPicture.asset(
                                                                  'assets/banners/retry.svg',
                                                                  width:
                                                                      size.width *
                                                                          0.6,
                                                                ),
                                                                SizedBox(
                                                                  height: 15.0,
                                                                ),
                                                                Text(
                                                                  'فشل في تحميل المنتجات!',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.9),
                                                                    fontSize:
                                                                        14.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    letterSpacing:
                                                                        0.3,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15.0,
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                        if (state is GetCartProductsCompletedState ||
                                                            state
                                                                is IncreaseQuantityInProgressState ||
                                                            state
                                                                is IncreaseQuantityCompletedState ||
                                                            state
                                                                is RemoveFromCartCompletedState) {
                                                          if (state
                                                              is GetCartProductsCompletedState) {
                                                            cartProducts = state
                                                                .cartProductsList;
                                                            if (cartProducts
                                                                    .length ==
                                                                0) {
                                                              return Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                children: <
                                                                    Widget>[
                                                                  SizedBox(
                                                                    height: 140,
                                                                  ),
                                                                  Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            0,
                                                                      ),
                                                                      SingleChildScrollView(
                                                                        physics:
                                                                            NeverScrollableScrollPhysics(),
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(left: 10),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                child: Row(
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
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          "المبلغ الكلي للقايمة",
                                                                                          style: TextStyle(
                                                                                            fontSize: 18,
                                                                                            color: Theme.of(context).accentColor,
                                                                                            fontWeight: FontWeight.w500,
                                                                                          ),
                                                                                        ),
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Text(
                                                                                              "${allCost}",
                                                                                              style: TextStyle(
                                                                                                fontSize: 24,
                                                                                                color: Colors.white,
                                                                                                fontWeight: FontWeight.w500,
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(bottom: 15, right: 8),
                                                                                              child: Text(
                                                                                                "جنية مصري",
                                                                                                style: TextStyle(
                                                                                                  fontSize: 14,
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              allCost == 0
                                                                                  ? Shimmer.fromColors(
                                                                                      baseColor: Theme.of(context).accentColor,
                                                                                      highlightColor: Colors.white,
                                                                                      child: Container(
                                                                                          width: 120,
                                                                                          height: 40,
                                                                                          decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                                                                                          child: TextButton(
                                                                                              child: Center(
                                                                                            child: Text(
                                                                                              "انشاء القايمة",
                                                                                              style: TextStyle(
                                                                                                fontSize: 15,
                                                                                                color: Colors.white,
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                              onPressed:(){
                                                                                                Flushbar(
                                                                                                  margin: const EdgeInsets.all(8.0),
                                                                                                  borderRadius: 8.0,
                                                                                                  backgroundColor:Theme.of(context).accentColor,
                                                                                                  // backgroundColor: Colors.green.shade500,
                                                                                                  animationDuration: Duration(milliseconds: 200),
                                                                                                  flushbarPosition: FlushbarPosition.TOP,
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
                                                                                                    Icons.cloud_done,
                                                                                                    color: Colors.white,
                                                                                                  ),
                                                                                                  messageText: Text(
                                                                                                    'لا يوجد مشتريات بعد لأنشاء القائمة ',
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 14.0,
                                                                                                      fontWeight: FontWeight.w500,
                                                                                                      letterSpacing: 0.3,
                                                                                                      color: Colors.white,
                                                                                                    ),
                                                                                                  ),
                                                                                                )..show(context);
                                                                                              }

                                                                                          )),
                                                                                    )
                                                                                  : Shimmer.fromColors(
                                                                                      baseColor: Theme.of(context).accentColor,
                                                                                      highlightColor: Colors.white70,
                                                                                      child: Container(
                                                                                        width: 120,
                                                                                        height: 40,
                                                                                        decoration: BoxDecoration(color: Theme.of(context).accentColor.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                                                                                        child: TextButton(
                                                                                          child: Center(
                                                                                            child: Text(
                                                                                              "انشاء القايمة",
                                                                                              style: TextStyle(
                                                                                                fontSize: 15,
                                                                                                color: Colors.white,
                                                                                                fontWeight: FontWeight.w400,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          onPressed: () {
                                                                                            return showMaterialModalBottomSheet(
                                                                                              context: context,
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                              builder: (context) => SingleChildScrollView(
                                                                                                  controller: ModalScrollController.of(context),
                                                                                                  child: Container(
                                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                                    child: Container(
                                                                                                        height: 680,
                                                                                                        width: 400,
                                                                                                        decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                                        child: PatmentData(
                                                                                                          category: cartProducts,
                                                                                                        )),
                                                                                                  )),
                                                                                            );
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height *
                                                                        0.08,
                                                                  ),
                                                                  Lottie.asset(
                                                                    'assets/images/emptyCart.json',
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10.0,
                                                                  ),
                                                                  Text(
                                                                    'لا يوجد لديك مشتريات بعد',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .accentColor,
                                                                      fontSize:
                                                                          18.5,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      letterSpacing:
                                                                          0.3,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10.0,
                                                                  ),
                                                                  Text(
                                                                    'قم بأضافة أول مشترياتك الان',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      fontSize:
                                                                          20.5,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      letterSpacing:
                                                                          0.3,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 100,
                                                                  ),
                                                                ],
                                                              );
                                                            }
                                                            allCost = 0;
                                                            for (int i = 0;
                                                                i <
                                                                    cartProducts
                                                                        .length;
                                                                i++) {
                                                              print(
                                                                  "${cartProducts[i].priceDate}::::::::: $i");
                                                              var data = cartProducts[
                                                                              i]
                                                                          .priceDate !=
                                                                      null
                                                                  ? double.parse(
                                                                          cartProducts[i]
                                                                              .priceDate) *
                                                                      double.parse(
                                                                          cartProducts[i]
                                                                              .skuName)
                                                                  : 0;
                                                              allCost =
                                                                  allCost +
                                                                      data;
                                                            }
                                                            return Column(
                                                              children: [
                                                                SizedBox(
                                                                  height: 65,
                                                                ),
                                                                AnimationLimiter(
                                                                  child: ListView
                                                                      .separated(
                                                                    physics:
                                                                        BouncingScrollPhysics(),
                                                                    itemCount:
                                                                        cartProducts
                                                                            .length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return AnimationConfiguration
                                                                          .staggeredList(
                                                                        position:
                                                                            index,
                                                                        duration:
                                                                            const Duration(milliseconds: 2000),
                                                                        child:
                                                                            SlideAnimation(
                                                                          verticalOffset:
                                                                              100.0,
                                                                          child:
                                                                              FadeInAnimation(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                SizedBox(
                                                                                  height: index == 0 ? 30 : 0,
                                                                                ),
                                                                                index == 0
                                                                                    ? Column(
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            height: 40,
                                                                                          ),
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.only(left: 10),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                                  child: Row(
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
                                                                                                          Text(
                                                                                                            "المبلغ الكلي",
                                                                                                            style: TextStyle(
                                                                                                              fontSize: 20,
                                                                                                              color: Colors.grey.shade500,
                                                                                                              fontWeight: FontWeight.w500,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Text(
                                                                                                                "${allCost}",
                                                                                                                style: TextStyle(
                                                                                                                  fontSize: 24,
                                                                                                                  color: Colors.white,
                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                ),
                                                                                                              ),
                                                                                                              Padding(
                                                                                                                padding: const EdgeInsets.only(bottom: 15, right: 8),
                                                                                                                child: Text(
                                                                                                                  "جنية",
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 14,
                                                                                                                    color: Colors.grey.shade500,
                                                                                                                    fontWeight: FontWeight.w500,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ],
                                                                                                      )
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                Container(
                                                                                                  width: 120,
                                                                                                  height: 40,
                                                                                                  decoration: BoxDecoration(color: Theme.of(context).accentColor.withOpacity(0.7), borderRadius: BorderRadius.circular(25)),
                                                                                                  child: TextButton(
                                                                                                    child: Center(
                                                                                                      child: Text(
                                                                                                        "انشاء القايمة",
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 15,
                                                                                                          color: Colors.white,
                                                                                                          fontWeight: FontWeight.w400,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      return showMaterialModalBottomSheet(
                                                                                                        context: context,
                                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                                        builder: (context) => SingleChildScrollView(
                                                                                                            controller: ModalScrollController.of(context),
                                                                                                            child: Container(
                                                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                                              child: Container(
                                                                                                                  height: 720,
                                                                                                                  width: 400,
                                                                                                                  decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                                                  child: PatmentData(
                                                                                                                    category: cartProducts,
                                                                                                                  )),
                                                                                                            )),
                                                                                                      );
                                                                                                    },
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : SizedBox(),
                                                                                SizedBox(
                                                                                  height: index == 0 ? 20 : 0,
                                                                                ),
                                                                                CartItem(
                                                                                  cartProducts: cartProducts,
                                                                                  index: index,
                                                                                  selectedSku: cartProducts[index].sku,
                                                                                  size: size,
                                                                                  product: cartProducts[index].product,
                                                                                  quantity: cartProducts[index].quantity,
                                                                                  cartBloc: cartBloc,
                                                                                  currentUser: currentUser,
                                                                                  payImageForUpload: cartProducts[index].payImageForUpload,
                                                                                  productImageForUpload: cartProducts[index].productImageForUpload,
                                                                                  priceDate: cartProducts[index].priceDate,
                                                                                  skuName: cartProducts[index].skuName,
                                                                                  dateOfProduct: cartProducts[index].dateOfProduct,
                                                                                ),
                                                                                index == 0
                                                                                    ? checkForAdd()
                                                                                    : SizedBox(),
                                                                                index==cartProducts.length-1?  SizedBox(height: 40,):SizedBox()
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    separatorBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return SizedBox(
                                                                          height:
                                                                              20.0);
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        }
                                                        return SizedBox();
                                                      },
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              clear == true
                                  ? Positioned.fill(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 7.0,
                                          sigmaY: 7.0,
                                        ),
                                        child: Center(),
                                      ),
                                    )
                                  : SizedBox()
                              // Container(
                              //   width: double.infinity,
                              //   height: double.infinity,
                              //   padding: EdgeInsets.all(12),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white.withOpacity(0.7),
                              //    ),
                              //   clipBehavior: Clip.antiAlias,
                              //   child: BackdropFilter(
                              //       filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              //
                              //   ) ),
                            ],
                          ),
                        ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation.centerDocked,
                        floatingActionButton: Padding(
                          padding: const EdgeInsets.only(bottom: 130),
                          child: FloatingActionButton(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        bottomNavigationBar: Container(
                          color: Colors.transparent,
                          height: clear == true ? 600 : 70,
                          child: Stack(
                            children: [
                              clear == true
                                  ? BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 7.0,
                                        sigmaY: 7.0,
                                      ),
                                      child:
                                          Container(color: Colors.transparent),
                                    )
                                  : BottomAppBar(
                                      color: Colors.white,
                                      notchMargin: 28,
                                      shape: CircularNotchedRectangle(),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3),
                                            child: new Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Column(
                                                  children: [
                                                    IconButton(
                                                        icon: SvgPicture.asset(
                                                            "assets/images/002-home.svg",
                                                            width: 20,
                                                            height: 25,
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                        color: Colors.grey,
                                                        onPressed: () => Navigator
                                                                .of(context)
                                                            .pushReplacement(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CartScreen()))),
                                                    // Text(
                                                    //   "الرئيسية",
                                                    //   style: TextStyle(
                                                    //     fontSize: 12,
                                                    //     fontWeight: FontWeight.w800,
                                                    //     color:Theme.of(context).primaryColor,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                        icon: SvgPicture.asset(
                                                            "assets/images/003-heart.svg",
                                                            width: 20,
                                                            height: 23,
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            color: Colors
                                                                .grey.shade400),
                                                        color: Colors.grey,
                                                        onPressed: () {
                                                          return FirebaseAuth
                                                                      .instance
                                                                      .currentUser ==
                                                                  null
                                                              ? Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              SignInScreen()))
                                                              : showMaterialModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              25.0),
                                                                          topRight:
                                                                              Radius.circular(25.0))),
                                                                  builder: (context) =>
                                                                      SingleChildScrollView(
                                                                          controller: ModalScrollController.of(
                                                                              context),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                            child: Container(
                                                                                height: 680,
                                                                                width: 400,
                                                                                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                                                child: WishlistPage()),
                                                                          )),
                                                                );
                                                        }),
                                                    // Text(
                                                    //   "الاحتياجات",
                                                    //   style: TextStyle(
                                                    //       fontSize: 12,
                                                    //       fontWeight: FontWeight.w800,
                                                    //       color: Colors.grey),
                                                    // ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 75,
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      icon: SvgPicture.asset(
                                                        "assets/images/001-magnifying-glass.svg",
                                                        width: 20,
                                                        height: 23,
                                                        fit: BoxFit.scaleDown,
                                                        color: Colors
                                                            .grey.shade400,
                                                      ),
                                                      color: Colors.grey,
                                                      onPressed: () {
                                                        return showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          25.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          25.0))),
                                                          builder: (context) =>
                                                              BackdropFilter(
                                                            filter: ImageFilter
                                                                .blur(
                                                                    sigmaX: 2,
                                                                    sigmaY: 2,
                                                                    tileMode:
                                                                        TileMode
                                                                            .mirror),
                                                            child:
                                                                SingleChildScrollView(
                                                                    controller:
                                                                        ModalScrollController.of(
                                                                            context),
                                                                    child:
                                                                        Container(
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .white,
                                                                          borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(15.0),
                                                                              topRight: Radius.circular(15.0))),
                                                                      child: Container(
                                                                          height:
                                                                              680,
                                                                          width:
                                                                              400,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
                                                                          child: SearchPage()),
                                                                    )),
                                                          ),
                                                        );
                                                        // showModalBottomSheet(
                                                        //      context: context,
                                                        //     // isScrollControlled: true,
                                                        //      shape: RoundedRectangleBorder(
                                                        //       borderRadius: BorderRadius.only(
                                                        //           topLeft: Radius.circular(25.0),
                                                        //           topRight: Radius.circular(25.0)),
                                                        //     ),
                                                        //     builder: (context) {
                                                        //       return
                                                        //     });
                                                      },
                                                    ),
                                                    // Text(
                                                    //   "البحث",
                                                    //   style: TextStyle(
                                                    //       fontSize: 12,
                                                    //       fontWeight: FontWeight.w800,
                                                    //       color: Colors.grey),
                                                    // ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    IconButton(
                                                      icon: SvgPicture.asset(
                                                          "assets/images/004-avatar.svg",
                                                          width: 20,
                                                          height: 23,
                                                          fit: BoxFit.scaleDown,
                                                          color: Colors
                                                              .grey.shade400),
                                                      color: Colors.grey,
                                                      onPressed: () {
                                                        return showMaterialModalBottomSheet(
                                                          context: context,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          25.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          25.0))),
                                                          builder: (context) =>
                                                              SingleChildScrollView(
                                                                  controller:
                                                                      ModalScrollController.of(
                                                                          context),
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(25.0),
                                                                            topRight: Radius.circular(25.0))),
                                                                    child: Container(
                                                                        height:
                                                                            1000,
                                                                        width:
                                                                            400,
                                                                        decoration:
                                                                            BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
                                                                        child: ProfilePage()),
                                                                  )),
                                                        );
                                                      },
                                                    ),
                                                    // Text(
                                                    //   "الحساب",
                                                    //   style: TextStyle(
                                                    //       fontSize: 12,
                                                    //       fontWeight: FontWeight.w800,
                                                    //       color: Colors.grey),
                                                    // ),
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
                              AnimatedPadding(
                                duration:
                                    Duration(seconds: clear == true ? 1 : 1),
                                curve: Curves.easeInBack,
                                padding: clear == true
                                    ? EdgeInsets.only(left: 15, bottom: 100)
                                    : EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.425,
                                        bottom: 42),
                                child: SpeedDial(
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  overlayColor: Colors.red,
                                  icon: Icons.add,
                                  overlayOpacity: 0,
                                  activeIcon: Icons.close,
                                  closeManually: false,
                                  elevation: 8.0,
                                  onOpen: () async {
                                    SharedPreferences _prefs =
                                        await SharedPreferences.getInstance();
                                    if (clear == false) {
                                      setState(() {
                                        clear = true;
                                        _prefs.setBool(
                                            'is_first_loaded', false);
                                      });
                                    }
                                  },
                                  onClose: () async {
                                    SharedPreferences _prefs =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      clear = false;
                                      _prefs.setBool('is_first_loaded', false);
                                    });
                                    // Navigator.canPop(context)?   Navigator.of(context).pop():Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>CartScreen()));
                                  },
                                  animationSpeed: 200,
                                  children: [
                                    // SpeedDialChild(
                                    //     child: const Icon(Icons.share),
                                    //     backgroundColor: Theme.of(context).primaryColor,
                                    //     foregroundColor: Colors.white,
                                    //     onTap: () {
                                    //       br.inviteFriendShareMessage(callId: 0);
                                    //     }),
                                    SpeedDialChild(
                                        labelBackgroundColor: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.9),
                                        label: "أضف منتج جديد لقائمة المشتريات",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        onTap: () {
                                          return FirebaseAuth
                                                      .instance.currentUser ==
                                                  null
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignInScreen()))
                                              : showMaterialModalBottomSheet(
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      25.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      25.0))),
                                                  builder: (context) =>
                                                      BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 2,
                                                        sigmaY: 2,
                                                        tileMode:
                                                            TileMode.mirror),
                                                    child:
                                                        SingleChildScrollView(
                                                            controller:
                                                                ModalScrollController
                                                                    .of(context),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xffF2F6F9),
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15.0))),
                                                              child: Container(
                                                                  height: 680,
                                                                  width: 400,
                                                                  decoration: BoxDecoration(
                                                                      color: Color(
                                                                          0xffF2F6F9),
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              15.0),
                                                                          topRight: Radius.circular(
                                                                              15.0))),
                                                                  child:
                                                                      HomePage()),
                                                            )),
                                                  ),
                                                );
                                        }),
                                    SpeedDialChild(
                                        labelBackgroundColor: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.9),
                                        label: "أضافة منتج غير موجود",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                        child: const Icon(
                                          Icons.near_me,
                                          color: Colors.white,
                                        ),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        onTap: () {
                                          return FirebaseAuth
                                                      .instance.currentUser ==
                                                  null
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignInScreen()))
                                              : showMaterialModalBottomSheet(
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      25.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      25.0))),
                                                  builder: (context) =>
                                                      SingleChildScrollView(
                                                          controller:
                                                              ModalScrollController
                                                                  .of(context),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            25.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            25.0))),
                                                            child: Container(
                                                                height: 680,
                                                                width: 400,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                25.0),
                                                                        topRight:
                                                                            Radius.circular(
                                                                                25.0))),
                                                                child:
                                                                    ProductScreen(
                                                                  initScreenId:
                                                                      4,
                                                                )),
                                                          )),
                                                );
                                        }),
                                    SpeedDialChild(
                                        labelBackgroundColor: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.9),
                                        label:
                                            "اضافة منتج الي قائمة الاحتياجات",
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400),
                                        child: const Icon(
                                          Icons.favorite_border,
                                          color: Colors.white,
                                        ),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        onTap: () {
                                          return FirebaseAuth
                                                      .instance.currentUser ==
                                                  null
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignInScreen()))
                                              : showMaterialModalBottomSheet(
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      25.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      25.0))),
                                                  builder: (context) =>
                                                      BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 2,
                                                        sigmaY: 2,
                                                        tileMode:
                                                            TileMode.mirror),
                                                    child:
                                                        SingleChildScrollView(
                                                            controller:
                                                                ModalScrollController
                                                                    .of(context),
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xffF2F6F9),
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15.0),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15.0))),
                                                              child: Container(
                                                                  height: 680,
                                                                  width: 400,
                                                                  decoration: BoxDecoration(
                                                                      color: Color(
                                                                          0xffF2F6F9),
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              15.0),
                                                                          topRight: Radius.circular(
                                                                              15.0))),
                                                                  child:
                                                                      HomePage()),
                                                            )),
                                                  ),
                                                );
                                        }),
                                    SpeedDialChild(
                                        labelBackgroundColor: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.9),
                                        label: "الانتقال الي قائمة الاحتياجات",
                                        elevation: 5,
                                        labelStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400),
                                        child: const Icon(
                                          Icons.add_shopping_cart_sharp,
                                          color: Colors.white,
                                        ),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        foregroundColor: Colors.white,
                                        onTap: () {
                                          return FirebaseAuth
                                                      .instance.currentUser ==
                                                  null
                                              ? Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SignInScreen()))
                                              : showMaterialModalBottomSheet(
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      25.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      25.0))),
                                                  builder: (context) =>
                                                      SingleChildScrollView(
                                                          controller:
                                                              ModalScrollController
                                                                  .of(context),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            25.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            25.0))),
                                                            child: Container(
                                                                height: 680,
                                                                width: 400,
                                                                decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                25.0),
                                                                        topRight:
                                                                            Radius.circular(
                                                                                25.0))),
                                                                child:
                                                                    WishlistPage()),
                                                          )),
                                                );
                                        }),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                        // floatingActionButton:SpeedDial(
                        //   renderOverlay: false,
                        //   icon: Icons.add,
                        //   activeIcon: Icons.close,
                        //   overlayOpacity: 0.4,
                        //   closeManually: false,
                        //   elevation: 8.0,
                        //   backgroundColor: Color(0xff00B6E6),
                        //   animationSpeed: 200,
                        //   children: [
                        //     SpeedDialChild(
                        //         label: "ww",
                        //         child: const Icon(Icons.share),
                        //         backgroundColor: Theme.of(context).primaryColor,
                        //         foregroundColor: Colors.white,
                        //         onTap: () {
                        //         }),
                        //     SpeedDialChild(
                        //         label: "ww",
                        //         child: const Icon(Icons.notification_important_sharp),
                        //         backgroundColor: Theme.of(context).primaryColor,
                        //         foregroundColor: Colors.white,
                        //         onTap: () {
                        //         }),
                        //   ],
                        // ),
                      )
                    : Scaffold(
                        body: Stack(
                          children: [
                            Container(
                              color: Color(0xfff7cb5a).withOpacity(0.7),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Lottie.asset(
                                      "assets/images/connectionFailed.json"),
                                  SizedBox(
                                    height: 150,
                                  ),
                                  Text(
                                    'تم فقد الاتصال برجاء اعادة المحاولة ٠٠٠!',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                            builder: (context) =>
                                                CartScreen())),
                                    child: Container(
                                      width: double.infinity,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: Color(0xffe12d64)),
                                      child: Center(
                                        child: Text(
                                          ' أعادة الاتصال',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
              )),
    );
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

/*
*   Positioned(
                              bottom:0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // SizedBox(
                                  //   height: MediaQuery.of(context)
                                  //           .size
                                  //           .height *
                                  //       0.65,
                                  // ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) =>
                                                PatmentData(
                                                  category: cartProducts,
                                                ))),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Container(
                                        width: double.infinity,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    25)),
                                        child: Center(
                                          child: Text(
                                            "انشاء قائمة المشتريات",
                                            style: TextStyle(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
* */
