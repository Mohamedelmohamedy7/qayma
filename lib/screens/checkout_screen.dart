import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/checkout_bloc/checkout_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/cart.dart';
import 'package:grocery_store/models/cart_values.dart';
import 'package:grocery_store/models/coupon.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/account_settings_screen.dart';
import 'package:grocery_store/screens/card_payment_screen.dart';
import 'package:grocery_store/screens/successOrder.dart';
import 'package:grocery_store/widget/order_placed_dialog.dart';
import 'package:grocery_store/widget/place_order_dialog.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:grocery_store/widget/shimmer_checkout_address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

import '../areaModel.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Cart> cartProducts;
  final double totalOrderAmt,
      totalAmt,
      discountAmt,
      shippingAmt,
      taxAmt,
      couponDiscountAmt;
  final User currentUser;
  final CartValues cartValues;
  final Coupon coupon;
  final bool appliedCoupon;

  const CheckoutScreen({
    this.cartProducts,
    this.totalOrderAmt,
    this.totalAmt,
    this.discountAmt,
    this.shippingAmt,
    this.taxAmt,
    this.currentUser,
    this.cartValues,
    this.couponDiscountAmt,
    this.coupon,
    this.appliedCoupon,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutBloc checkoutBloc;
  bool proceed;
  bool placeOrder;
  int selectedPayment = 0;
  AccountBloc accountBloc;
  GroceryUser user;
  Razorpay _razorpay;
 var deliveryprice=0.0;
 var i;
  String elGalaa = "شارع الجلاء أمام بوابه الجامعة";
  String elgmohria = " شارع الجمهورية برج السوسن";
  String tanta = "فرع طنطا -سيمفونى ";
  @override
  void initState() {
    i=0;
    super.initState();
    _changeval="";
    getArea();
    checkoutBloc = BlocProvider.of<CheckoutBloc>(context);
    accountBloc = BlocProvider.of<AccountBloc>(context);

    proceed = false;
    initRazorpay();

    accountBloc.add(GetAccountDetailsEvent(widget.currentUser.uid));

    checkoutBloc.listen((state) {
      print('CHECKOUT STATE ::: $state');
      if (state is ProceedOrderCompletedState) {
        if (state.res == 'CARD') {
          //move to card payment screen
          if (proceed) {
            proceed = false;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CardPaymentScreen(
                  cartProducts: widget.cartProducts,
                  discountAmt: widget.discountAmt,
                  // shippingAmt: widget.shippingAmt,
                   shippingAmt: deliveryprice,
                  totalAmt: allCost,
                  // totalAmt: widget.totalAmt,
                  totalOrderAmt: widget.totalOrderAmt,
                  currentUser: widget.currentUser,
                  cartValues: widget.cartValues,
                  taxAmt: widget.taxAmt,
                  appliedCoupon: widget.appliedCoupon,
                  coupon: widget.coupon,
                  couponDiscountAmt: widget.couponDiscountAmt,
                ),
              ),
            );
          }
        } else {
          if (proceed) {
            checkoutBloc.add(PlaceOrderEvent(
              cartList: widget.cartProducts,
              discountAmt: widget.discountAmt.toStringAsFixed(2),
              orderAmt: widget.totalOrderAmt.toStringAsFixed(2),
              taxAmt: widget.taxAmt.toStringAsFixed(2),
              paymentMethod: 1,
              shippingAmt: deliveryprice.toStringAsFixed(2),
              // shippingAmt: widget.shippingAmt.toStringAsFixed(2),
              // totalAmt: widget.totalAmt.toStringAsFixed(2),
               totalAmt: allCost.toStringAsFixed(2),
              uid: widget.currentUser.uid,
              appliedCoupon: widget.appliedCoupon,
              coupon: widget.coupon,
              couponDiscountAmt: widget.couponDiscountAmt.toStringAsFixed(2),
            ));
          }
        }
      }
      if (state is PlaceOrderInProgressState) {
        showPlacingOrderDialog();
      }
      if (state is PlaceOrderCompletedState) {
        if (proceed) {
          Navigator.pop(context);
          showOrderPlaceDialog();
          proceed = false;
        }
      }
      if (state is PlaceOrderFailedState) {
        if (proceed) {
          Navigator.pop(context);
          showSnack('Failed to place order!', context);
          proceed = false;
        }
      }
    });
  }

  showPlacingOrderDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PlaceOrderDialog();
      },
    );
  }

  showOrderPlaceDialog() async {
    var res = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SuccessOrder();
      },
    );

    if (res == 'PLACED') {
      //placed
      //TODO: take user to my orders
      Navigator.popUntil(context, ModalRoute.withName('/home'));
    }
  }

  void proceedOrder(int paymentMode) {
    print(paymentMode);
    print(proceed);

    switch (paymentMode) {
      case 1:
        //COD
        if (proceed) {
          checkoutBloc.add(PlaceOrderEvent(
            cartList: widget.cartProducts,
            discountAmt: widget.discountAmt.toStringAsFixed(2),
            orderAmt: widget.totalOrderAmt.toStringAsFixed(2),
            taxAmt: widget.taxAmt.toStringAsFixed(2),
            paymentMethod: 1,
            shippingAmt: deliveryprice.toStringAsFixed(2),
            // shippingAmt: widget.shippingAmt.toStringAsFixed(2),
            // totalAmt: widget.totalAmt.toStringAsFixed(2),
             totalAmt: allCost.toStringAsFixed(2),
            uid: widget.currentUser.uid,
            appliedCoupon: widget.appliedCoupon,
            coupon: widget.coupon,
            couponDiscountAmt: widget.couponDiscountAmt.toStringAsFixed(2),
          ));
        }
        break;
      case 2:
        //Stripe
        if (proceed) {
          if (proceed) {
             checkoutBloc.add(PlaceOrderEvent(
              cartList: widget.cartProducts,
              discountAmt: widget.discountAmt.toStringAsFixed(2),
              orderAmt: widget.totalOrderAmt.toStringAsFixed(2),
              taxAmt: widget.taxAmt.toStringAsFixed(2),
              paymentMethod: 1,
              shippingAmt: deliveryprice.toStringAsFixed(2),
              // shippingAmt: widget.shippingAmt.toStringAsFixed(2),
              // totalAmt: widget.totalAmt.toStringAsFixed(2),
              totalAmt: allCost.toStringAsFixed(2),
              uid: widget.currentUser.uid,
              appliedCoupon: widget.appliedCoupon,
              coupon: widget.coupon,
              couponDiscountAmt: widget.couponDiscountAmt.toStringAsFixed(2),
            ));
          }
        }
        break;
      case 3:
        //Razorpay
        print('pay via razorpay');
        payViaRazorpay();
        break;
      default:
    }
  }

  showProcessingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Please wait!\nWe are processing order...',
        );
      },
    );
  }

  initRazorpay() {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
String add;
  //RAZORPAY
  void payViaRazorpay() async {
    showProcessingDialog();
     print("Done=============");
    var createOrderIdResp = await http.post(
      Uri.parse(Config().razorpayCreateOrderIdUrl),
      body: json.encode({
        // 'amount': widget.totalAmt.toInt() * 100,
         'amount':allCost.toInt() * 100,
      }),
    );

    var razorpayOrderId = jsonDecode(createOrderIdResp.body);

    var options = {
      'key': Config().razorpayKey,
      // 'amount':
      //     widget.totalAmt.toInt() * 100,
       'amount':
          allCost.toInt() * 100, //in the smallest currency sub-unit.
      'name': Config().companyName,
      'order_id': razorpayOrderId['data']['id'],
      'description': 'New order payment',
      'timeout': 60, // in seconds
      'prefill': {
        'contact': user.mobileNo,
        'email': user.email,
      }
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print(response.paymentId);
    print(response.orderId);
    print(response.signature);
    Navigator.pop(context);
    // showSnack('Payment successful!', context);

    checkoutBloc.add(PlaceOrderEvent(
      cartList: widget.cartProducts,
      discountAmt: widget.discountAmt.toStringAsFixed(2),
      orderAmt: widget.totalOrderAmt.toStringAsFixed(2),
      taxAmt: widget.taxAmt.toStringAsFixed(2),
      paymentMethod: 3,
      shippingAmt: deliveryprice.toStringAsFixed(2),
      // shippingAmt: widget.shippingAmt.toStringAsFixed(2),
      totalAmt: allCost.toStringAsFixed(2),
      // totalAmt: widget.totalAmt.toStringAsFixed(2),
      uid: widget.currentUser.uid,
      razorpayTxnId: response.paymentId,
      appliedCoupon: widget.appliedCoupon,
      coupon: widget.coupon,
      couponDiscountAmt: widget.couponDiscountAmt.toStringAsFixed(2),
    ));
  }

  List<AreaModel> _Model = [];
  Future getArea() async {
    CollectionReference _reference =
    await FirebaseFirestore.instance.collection("DeliveryArea");
    try {
      await _reference.get().then((value) {
        _Model.clear();
        for (int i = 0; i < value.docs.length; i++) {
          setState(() {
            _Model.add(AreaModel.fromMap(value.docs[i].data()));
          });
          print(_Model[i].areaName);
        }
      });
    } catch (e) {
      print("the error $e");
    }
  }
 String _changeval="البحر";
  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print(response);
    Navigator.pop(context);
    showSnack('Payment failed!', context);
    proceed = false;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    print(response);
    Navigator.pop(context);
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
        style: GoogleFonts.tajawal(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  // Future callFunction() async {
  //   print('calling function');

  // }
 var allCost=0.0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "الدفـــع",
          style: GoogleFonts.tajawal(
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Column(
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
              //     bottom: false,
              //     child: Padding(
              //       padding: const EdgeInsets.only(
              //           left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.start,
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisSize: MainAxisSize.max,
              //         children: <Widget>[
              //           ClipRRect(
              //             borderRadius: BorderRadius.circular(50.0),
              //             child: Material(
              //               color: Colors.transparent,
              //               child: InkWell(
              //                 splashColor: Colors.white.withOpacity(0.5),
              //                 onTap: () {
              //                   Navigator.pop(context);
              //                 },
              //                 child: Container(
              //                   decoration: BoxDecoration(
              //                     color: Colors.transparent,
              //                   ),
              //                   width: 38.0,
              //                   height: 35.0,
              //                   child: Icon(
              //                     Icons.arrow_back,
              //                     color: Colors.white,
              //                     size: 24.0,
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           SizedBox(
              //             width: 8.0,
              //           ),
              //           Text(
              //             'Checkout',
              //             style: GoogleFonts.tajawal()(
              //               color: Colors.white,
              //               fontSize: 18.0,
              //               fontWeight: FontWeight.w600,
              //               letterSpacing: 0.3,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  children: <Widget>[
                    BlocBuilder(
                      cubit: accountBloc,
                      buildWhen: (previous, current) {
                        if (current is GetAccountDetailsCompletedState ||
                            current is GetAccountDetailsInProgressState ||
                            current is GetAccountDetailsFailedState) {
                          return true;
                        }
                        return false;
                      },
                      builder: (context, state) {
                        if (state is GetAccountDetailsInProgressState) {
                          return Shimmer.fromColors(
                            period: Duration(milliseconds: 1000),
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.black.withOpacity(0.5),
                            child: ShimmerCheckoutAddress(
                              size: size,
                            ),
                          );
                        }
                        if (state is GetAccountDetailsFailedState) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0.0),
                                  blurRadius: 15.0,
                                  spreadRadius: 2.0,
                                  color: Colors.black.withOpacity(0.05),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                SvgPicture.asset(
                                  'assets/banners/retry.svg',
                                  width: size.width * 0.6,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Text(
                                  "فشل التحميل",
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.tajawal(
                                    color: Colors.black.withOpacity(0.9),
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                Container(
                                  height: 38.0,
                                  width: size.width * 0.5,
                                  child: FlatButton(
                                    onPressed: () {
                                      accountBloc.add(GetAccountDetailsEvent(
                                          widget.currentUser.uid));
                                    },
                                    color: Colors.red.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      'Retry',
                                      style: GoogleFonts.tajawal(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is GetAccountDetailsCompletedState) {
                          user = state.user;

                          if (state.user.address.length == 0) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0.0),
                                    blurRadius: 15.0,
                                    spreadRadius: 2.0,
                                    color: Colors.black.withOpacity(0.05),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "تفاصيل العنوان",
                                    style: GoogleFonts.tajawal(
                                      color: Colors.black87,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Center(
                                    child: Text(
                                      "لا يوجد عنوان",
                                      style: GoogleFonts.tajawal(
                                        color: Colors.black.withOpacity(0.8),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                  Container(
                                    height: 42.0,
                                    width: double.infinity,
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AccountSettingsScreen(
                                                  currentUser: widget.currentUser,
                                                ),
                                          ),
                                        );
                                      },
                                      color: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7.0),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'أضافة عنوان',
                                            style: GoogleFonts.tajawal(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10.0, right: 15, bottom: 10),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    'اختـــــر العنــــوان : ',
                                    style: GoogleFonts.tajawal(
                                      color: Colors.black87,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              widget.cartValues.paymentMethods.cod
                                  ? InkWell(
                                onTap: () {
                                  setState(() {
                                    // if(press1==true)
                                    //   press1=false;
                                    // press2=true;
                                    selectedPayment = 1;
                                    deliveryprice=0;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: selectedPayment == 1
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 0.0),
                                          blurRadius: 14.0,
                                          spreadRadius: 2.0,
                                          color:
                                          Colors.grey.withOpacity(0.158),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                       width:double.infinity,
                                              child: SingleChildScrollView(
                                                scrollDirection:Axis.horizontal,
                                                physics:BouncingScrollPhysics(),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                   children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 8),
                                                      child: Column(
                                                        crossAxisAlignment:CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(height: 10,),
                                                          Align(
                                                            alignment:
                                                            Alignment.topLeft,
                                                            child: Text(
                                                              ' الاسم : ${user.name}',
                                                              style: GoogleFonts
                                                                  .tajawal(
                                                                color: Colors.black
                                                                    .withOpacity(
                                                                    0.8),
                                                                fontSize: 14.5,
                                                                fontWeight:
                                                                FontWeight.w700,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 8.0,
                                                          ),
                                                          // Text(
                                                          //   user.mobileNo.isEmpty
                                                          //       ? 'Mobile No. : NA'
                                                          //       : '${user.mobileNo}',
                                                          //   style: GoogleFonts.tajawal(
                                                          //     color: Colors.black.withOpacity(0.7),
                                                          //     fontSize: 14.0,
                                                          //     fontWeight: FontWeight.w500,
                                                          //     letterSpacing: 0.3,
                                                          //   ),
                                                          // ),
                                                          user.address[0].city
                                                              .toString() ==
                                                              null
                                                              ? Text(""
                                                              "من فضلك ادخل العنوان")
                                                              : Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 0.0,
                                                                right: 5,
                                                                bottom: 5),
                                                            child: Column(
                                                              crossAxisAlignment:CrossAxisAlignment.start,

                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                  Alignment
                                                                      .topRight,
                                                                  child: Text(
                                                                    "أسم المحافظة : ${user.address[0].city.toString()}",
                                                                    style: GoogleFonts.tajawal(
                                                                        fontSize:
                                                                        15.0,
                                                                        fontWeight: FontWeight
                                                                            .w400,
                                                                        letterSpacing:
                                                                        0.3,
                                                                        color:
                                                                        Colors.black),
                                                                    overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                    maxLines:
                                                                    1,
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width:300,
                                                                  child: Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                        8.0),
                                                                    child: Text(
                                                                      "${user.address[0].addressLine1.toString()}",
                                                                      style: GoogleFonts.tajawal(
                                                                          fontSize:
                                                                          13.0,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          letterSpacing:
                                                                          0.3,
                                                                          color:
                                                                          Colors.black),
                                                                      // overflow: TextOverflow.ellipsis,
                                                                      maxLines:
                                                                      1,overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                     SizedBox(width: 20,),

                                                    // Text(
                                                    //   selectedPayment==1?
                                                    //   '${user.address[0].houseNo.toString()}, ${user.address[0].addressLine1.toString()}, ${user.address[0].addressLine2.toString()}, ${user.address[0].landmark.toString()}, ${user.address[0].city.toString()}, ${user.address[0].state.toString()}, ${user.address[0].country.toString()} ':selectedbra==1?elGalaa:elgmohria,
                                                    //   style: GoogleFonts.tajawal(
                                                    //     color: Colors.black.withOpacity(0.7),
                                                    //     fontSize: 14.0,
                                                    //     fontWeight: FontWeight.w500,
                                                    //     letterSpacing: 0.3,
                                                    //   ),
                                                    // ),
                                                    // // SizedBox(
                                                    // //   height: 15.0,
                                                    // // ),
                                                    // // Container(
                                                    // //   height: 42.0,
                                                    // //   width: double.infinity,
                                                    // //   child: FlatButton(
                                                    // //     onPressed: () {
                                                    // //       Navigator.push(
                                                    // //         context,
                                                    // //         MaterialPageRoute(
                                                    // //           builder: (context) =>
                                                    // //               AccountSettingsScreen(
                                                    // //                 currentUser: widget.currentUser,
                                                    // //               ),
                                                    // //         ),
                                                    // //       );
                                                    // //     },
                                                    // //     color: Theme.of(context).primaryColor,
                                                    // //     shape: RoundedRectangleBorder(
                                                    // //       borderRadius: BorderRadius.circular(7.0),
                                                    // //     ),
                                                    // //     child: Text(
                                                    // //       "${S.of(context).edit_address}",
                                                    // //       style: GoogleFonts.tajawal(
                                                    // //         color: Colors.white,
                                                    // //         fontSize: 14.0,
                                                    // //         fontWeight: FontWeight.w500,
                                                    // //         letterSpacing: 0.3,
                                                    // //       ),
                                                    // //     ),
                                                    // //   ),
                                                    // // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top:0,
                                              left:4,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 10.0),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width: 70,
                                                          height: 40,
                                                          decoration:
                                                          BoxDecoration(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        user.address[0].houseNo
                                                            .toString() ==
                                                            null
                                                            ? Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 14.0,
                                                              right: 5),
                                                          child: Text(
                                                            "ادخل العنوان ",
                                                            style: GoogleFonts.tajawal(
                                                                fontSize:
                                                                14.0,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                                letterSpacing:
                                                                0.3,
                                                                color: Colors
                                                                    .white),
                                                            // overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        )
                                                            : Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              top: 12.0,
                                                              right: 5),
                                                          child: Text(
                                                            "عنــوان رئيـــسي ",
                                                            style: GoogleFonts.tajawal(
                                                                fontSize:
                                                                10.0,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                                letterSpacing:
                                                                0.3,
                                                                color: Colors
                                                                    .white),
                                                            // overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 5.0),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.more_vert,
                                                      ),
                                                      onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AccountSettingsScreen(currentUser: widget.currentUser,))),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  : SizedBox(),
                              Padding(
                                padding: const EdgeInsets.only(left: 15,right: 15,top: 15,bottom: 5),
                                child: Row(
                                  children: [
                                  Expanded(child: Divider(color: Colors.grey,)),
                                    Text("       أو        ",style: GoogleFonts.tajawal(color: Colors.black,fontWeight: FontWeight.w600)),
                                    Expanded(child: Divider(color: Colors.grey,)),

                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              widget.cartValues.paymentMethods.razorpay
                                  ? InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedPayment = 2;
                                    add = tanta;
                                    allCost=widget.totalAmt-widget.discountAmt;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                        boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 14.0,
                                        spreadRadius: 2.0,
                                        color:
                                        Colors.grey.withOpacity(0.15),
                                      ),
                                      ],
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      color: selectedPayment == 2
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,

                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: <Widget>[
                                        // Text(
                                        //   '${S.of(context).delivery_details} :',
                                        //   style: GoogleFonts.tajawal(
                                        //     color: Colors.black87,
                                        //     fontSize: 15.5,
                                        //     fontWeight: FontWeight.w600,
                                        //     letterSpacing: 0.3,
                                        //   ),
                                        // ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: 30,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 70.0),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: Text(
                                                  'الاستلام من الفرع ',
                                                  style: GoogleFonts.tajawal(
                                                      color: Colors.black
                                                          .withOpacity(0.8),
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      letterSpacing: 2),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, right: 15),
                                              child: Container(
                                                width: 200,
                                                child: Column(
                                                  children: [
                                                    // Align(
                                                    //   alignment:Alignment.topRight,
                                                    //   child: Text(
                                                    //     "رقم البنية : ${user.address[0].houseNo.toString()}",
                                                    //     style: GoogleFonts.tajawal(
                                                    //         fontSize: 15.0,
                                                    //         fontWeight: FontWeight.w600,
                                                    //         letterSpacing: 0.3,
                                                    //         color: Colors.grey
                                                    //     ),
                                                    //     overflow: TextOverflow.ellipsis,
                                                    //     maxLines: 1,
                                                    //   ),
                                                    //
                                                    // ),
                                                    Align(
                                                      alignment:
                                                      Alignment.topRight,
                                                      child: Text(
                                                        "فرع طنطا -سيمفونى",
                                                        style: GoogleFonts
                                                            .tajawal(
                                                            fontSize:
                                                            13.0,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                            letterSpacing:
                                                            0.3,
                                                            color: Colors
                                                                .black.withOpacity(0.6)),
                                                        // overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // SizedBox(
                                            //   height: 2.0,
                                            // ),
                                            // Text(
                                            //   user.mobileNo.isEmpty
                                            //       ? 'Mobile No. : NA'
                                            //       : '${user.mobileNo}',
                                            //   style: GoogleFonts.tajawal(
                                            //     color: Colors.black.withOpacity(0.7),
                                            //     fontSize: 14.0,
                                            //     fontWeight: FontWeight.w500,
                                            //     letterSpacing: 0.3,
                                            //   ),
                                            // ),
                                          ],
                                        ),

                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 0, bottom: 0, top: 20),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: 90,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        5),
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      top: 12.0,
                                                      right: 9),
                                                  child: Text(
                                                    "فرع طنطــا ",
                                                    style:
                                                    GoogleFonts.tajawal(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                        letterSpacing:
                                                        0.3,
                                                        color:
                                                        Colors.white),
                                                    // overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20.0),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.more_vert,
                                            ),
                                            onPressed: () {},
                                          ),
                                        )
                                        // Text(
                                        //   selectedPayment==1?
                                        //   '${user.address[0].houseNo.toString()}, ${user.address[0].addressLine1.toString()}, ${user.address[0].addressLine2.toString()}, ${user.address[0].landmark.toString()}, ${user.address[0].city.toString()}, ${user.address[0].state.toString()}, ${user.address[0].country.toString()} ':selectedbra==1?elGalaa:elgmohria,
                                        //   style: GoogleFonts.tajawal(
                                        //     color: Colors.black.withOpacity(0.7),
                                        //     fontSize: 14.0,
                                        //     fontWeight: FontWeight.w500,
                                        //     letterSpacing: 0.3,
                                        //   ),
                                        // ),
                                        // // SizedBox(
                                        // //   height: 15.0,
                                        // // ),
                                        // // Container(
                                        // //   height: 42.0,
                                        // //   width: double.infinity,
                                        // //   child: FlatButton(
                                        // //     onPressed: () {
                                        // //       Navigator.push(
                                        // //         context,
                                        // //         MaterialPageRoute(
                                        // //           builder: (context) =>
                                        // //               AccountSettingsScreen(
                                        // //                 currentUser: widget.currentUser,
                                        // //               ),
                                        // //         ),
                                        // //       );
                                        // //     },
                                        // //     color: Theme.of(context).primaryColor,
                                        // //     shape: RoundedRectangleBorder(
                                        // //       borderRadius: BorderRadius.circular(7.0),
                                        // //     ),
                                        // //     child: Text(
                                        // //       "${S.of(context).edit_address}",
                                        // //       style: GoogleFonts.tajawal(
                                        // //         color: Colors.white,
                                        // //         fontSize: 14.0,
                                        // //         fontWeight: FontWeight.w500,
                                        // //         letterSpacing: 0.3,
                                        // //       ),
                                        // //     ),
                                        // //   ),
                                        // // ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                                  : SizedBox(),
                            ],
                          );
                        }
                        return SizedBox();
                      },
                    ),
                    // Container(
                    //   margin: const EdgeInsets.symmetric(
                    //     horizontal: 16.0,
                    //   ),
                    //   padding: const EdgeInsets.all(8.0),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(20.0),
                    //     color: Colors.white,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         offset: Offset(0, 0.0),
                    //         blurRadius: 15.0,
                    //         spreadRadius: 2.0,
                    //         color: Colors.black.withOpacity(0.05),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: <Widget>[
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(
                    //           horizontal: 10.0,
                    //           vertical: 10.0,
                    //         ),
                    //         child: Text(
                    //           'Select a payment method',
                    //           style: GoogleFonts.tajawal()(
                    //             color: Colors.black87,
                    //             fontSize: 15.5,
                    //             fontWeight: FontWeight.w600,
                    //             letterSpacing: 0.3,
                    //           ),
                    //         ),
                    //       ),
                    //       widget.cartValues.paymentMethods.cod
                    //           ? RadioListTile(
                    //               activeColor: Theme.of(context).primaryColor,
                    //               dense: true,
                    //               value: 1,
                    //               groupValue: selectedPayment,
                    //               title: Text(
                    //                 'Cash on delivery',
                    //                 style: GoogleFonts.tajawal()(
                    //                   color: Colors.black87,
                    //                   fontSize: 14.0,
                    //                   fontWeight: FontWeight.w500,
                    //                   letterSpacing: 0.3,
                    //                 ),
                    //               ),
                    //               onChanged: (val) {
                    //                 setState(() {
                    //                   selectedPayment = val;
                    //                 });
                    //               },
                    //             )
                    //           : SizedBox(),
                    //       widget.cartValues.paymentMethods.stripe
                    //           ? RadioListTile(
                    //               activeColor: Theme.of(context).primaryColor,
                    //               dense: true,
                    //               value: 2,
                    //               groupValue: selectedPayment,
                    //               title: Text(
                    //                 'Pay via Credit/Debit card',
                    //                 style: GoogleFonts.tajawal()(
                    //                   color: Colors.black87,
                    //                   fontSize: 14.0,
                    //                   fontWeight: FontWeight.w500,
                    //                   letterSpacing: 0.3,
                    //                 ),
                    //               ),
                    //               onChanged: (val) {
                    //                 setState(() {
                    //                   selectedPayment = val;
                    //                 });
                    //               },
                    //             )
                    //           : SizedBox(),
                    //       widget.cartValues.paymentMethods.razorpay
                    //           ? RadioListTile(
                    //               activeColor: Theme.of(context).primaryColor,
                    //               dense: true,
                    //               value: 3,
                    //               groupValue: selectedPayment,
                    //               title: Text(
                    //                 'Pay via Razorpay',
                    //                 style: GoogleFonts.tajawal()(
                    //                   color: Colors.black87,
                    //                   fontSize: 14.0,
                    //                   fontWeight: FontWeight.w500,
                    //                   letterSpacing: 0.3,
                    //                 ),
                    //               ),
                    //               onChanged: (val) {
                    //                 setState(() {
                    //                   selectedPayment = val;
                    //                 });
                    //               },
                    //             )
                    //           : SizedBox(),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 20.0,
                    ),
                    // BlocBuilder(
                    //   cubit: accountBloc,
                    //   buildWhen: (previous, current) {
                    //     if (current is GetAccountDetailsCompletedState ||
                    //         current is GetAccountDetailsInProgressState ||
                    //         current is GetAccountDetailsFailedState) {
                    //       return true;
                    //     }
                    //     return false;
                    //   },
                    //   builder: (context, state) {
                    //     if (state is GetAccountDetailsInProgressState) {
                    //       return Shimmer.fromColors(
                    //         period: Duration(milliseconds: 1000),
                    //         baseColor: Colors.grey.withOpacity(0.5),
                    //         highlightColor: Colors.black.withOpacity(0.5),
                    //         child: ShimmerCheckoutAddress(
                    //           size: size,
                    //         ),
                    //       );
                    //     }
                    //     if (state is GetAccountDetailsFailedState) {
                    //       return Container(
                    //         margin: const EdgeInsets.symmetric(
                    //           horizontal: 16.0,
                    //         ),
                    //         padding: const EdgeInsets.all(20.0),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(20.0),
                    //           color: Colors.white,
                    //           boxShadow: [
                    //             BoxShadow(
                    //               offset: Offset(0, 0.0),
                    //               blurRadius: 15.0,
                    //               spreadRadius: 2.0,
                    //               color: Colors.black.withOpacity(0.05),
                    //             ),
                    //           ],
                    //         ),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           mainAxisSize: MainAxisSize.max,
                    //           children: <Widget>[
                    //             SvgPicture.asset(
                    //               'assets/banners/retry.svg',
                    //               width: size.width * 0.6,
                    //             ),
                    //             SizedBox(
                    //               height: 15.0,
                    //             ),
                    //             Text(
                    //               'Failed to get shipping details!',
                    //               textAlign: TextAlign.center,
                    //               overflow: TextOverflow.clip,
                    //               style: GoogleFonts.tajawal()(
                    //                 color: Colors.black.withOpacity(0.9),
                    //                 fontSize: 14.5,
                    //                 fontWeight: FontWeight.w500,
                    //                 letterSpacing: 0.3,
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               height: 15.0,
                    //             ),
                    //             Container(
                    //               height: 38.0,
                    //               width: size.width * 0.5,
                    //               child: FlatButton(
                    //                 onPressed: () {
                    //                   accountBloc.add(GetAccountDetailsEvent(
                    //                       widget.currentUser.uid));
                    //                 },
                    //                 color: Colors.red.shade400,
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(12.0),
                    //                 ),
                    //                 child: Text(
                    //                   'Retry',
                    //                   style: GoogleFonts.tajawal()(
                    //                     color: Colors.white,
                    //                     fontSize: 13.5,
                    //                     fontWeight: FontWeight.w500,
                    //                     letterSpacing: 0.3,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     }
                    //     if (state is GetAccountDetailsCompletedState) {
                    //       user = state.user;
                    //
                    //       if (state.user.address.length == 0) {
                    //         return Container(
                    //           margin: const EdgeInsets.symmetric(
                    //             horizontal: 16.0,
                    //           ),
                    //           padding: const EdgeInsets.all(20.0),
                    //           decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(20.0),
                    //             color: Colors.white,
                    //             boxShadow: [
                    //               BoxShadow(
                    //                 offset: Offset(0, 0.0),
                    //                 blurRadius: 15.0,
                    //                 spreadRadius: 2.0,
                    //                 color: Colors.black.withOpacity(0.05),
                    //               ),
                    //             ],
                    //           ),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             mainAxisAlignment: MainAxisAlignment.start,
                    //             children: <Widget>[
                    //               Text(
                    //                 'Shipping details :',
                    //                 style: GoogleFonts.tajawal()(
                    //                   color: Colors.black87,
                    //                   fontSize: 15.5,
                    //                   fontWeight: FontWeight.w600,
                    //                   letterSpacing: 0.3,
                    //                 ),
                    //               ),
                    //               SizedBox(
                    //                 height: 15.0,
                    //               ),
                    //               Center(
                    //                 child: Text(
                    //                   'No address found!',
                    //                   style: GoogleFonts.tajawal()(
                    //                     color: Colors.black.withOpacity(0.8),
                    //                     fontSize: 14.5,
                    //                     fontWeight: FontWeight.w500,
                    //                     letterSpacing: 0.3,
                    //                   ),
                    //                 ),
                    //               ),
                    //               SizedBox(
                    //                 height: 15.0,
                    //               ),
                    //               Container(
                    //                 height: 42.0,
                    //                 width: double.infinity,
                    //                 child: FlatButton(
                    //                   onPressed: () {
                    //                     Navigator.push(
                    //                       context,
                    //                       MaterialPageRoute(
                    //                         builder: (context) =>
                    //                             AccountSettingsScreen(
                    //                           currentUser: widget.currentUser,
                    //                         ),
                    //                       ),
                    //                     );
                    //                   },
                    //                   color: Colors.green.shade400,
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(12.0),
                    //                   ),
                    //                   child: Text(
                    //                     'Add address',
                    //                     style: GoogleFonts.tajawal()(
                    //                       color: Colors.white,
                    //                       fontSize: 14.0,
                    //                       fontWeight: FontWeight.w500,
                    //                       letterSpacing: 0.3,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         );
                    //       }
                    //
                    //       return Container(
                    //         margin: const EdgeInsets.symmetric(
                    //           horizontal: 16.0,
                    //         ),
                    //         padding: const EdgeInsets.all(20.0),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(20.0),
                    //           color: Colors.white,
                    //           boxShadow: [
                    //             BoxShadow(
                    //               offset: Offset(0, 0.0),
                    //               blurRadius: 15.0,
                    //               spreadRadius: 2.0,
                    //               color: Colors.black.withOpacity(0.05),
                    //             ),
                    //           ],
                    //         ),
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           children: <Widget>[
                    //             Text(
                    //               'Shipping details :',
                    //               style: GoogleFonts.tajawal()(
                    //                 color: Colors.black87,
                    //                 fontSize: 15.5,
                    //                 fontWeight: FontWeight.w600,
                    //                 letterSpacing: 0.3,
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               height: 10.0,
                    //             ),
                    //             Text(
                    //               '${user.name}',
                    //               style: GoogleFonts.tajawal()(
                    //                 color: Colors.black.withOpacity(0.8),
                    //                 fontSize: 14.5,
                    //                 fontWeight: FontWeight.w500,
                    //                 letterSpacing: 0.3,
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               height: 2.0,
                    //             ),
                    //             Text(
                    //               user.mobileNo.isEmpty
                    //                   ? 'Mobile No. : NA'
                    //                   : '${user.mobileNo}',
                    //               style: GoogleFonts.tajawal()(
                    //                 color: Colors.black.withOpacity(0.7),
                    //                 fontSize: 14.0,
                    //                 fontWeight: FontWeight.w500,
                    //                 letterSpacing: 0.3,
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               height: 2.0,
                    //             ),
                    //             Text(
                    //               '${user.address[int.parse(user.defaultAddress)].houseNo}, ${user.address[int.parse(user.defaultAddress)].addressLine1}, ${user.address[int.parse(user.defaultAddress)].addressLine2}, ${user.address[int.parse(user.defaultAddress)].landmark}, ${user.address[int.parse(user.defaultAddress)].city}, ${user.address[int.parse(user.defaultAddress)].state}, ${user.address[int.parse(user.defaultAddress)].country} - ${user.address[int.parse(user.defaultAddress)].pincode}',
                    //               style: GoogleFonts.tajawal()(
                    //                 color: Colors.black.withOpacity(0.7),
                    //                 fontSize: 14.0,
                    //                 fontWeight: FontWeight.w500,
                    //                 letterSpacing: 0.3,
                    //               ),
                    //             ),
                    //             SizedBox(
                    //               height: 15.0,
                    //             ),
                    //             Container(
                    //               height: 42.0,
                    //               width: double.infinity,
                    //               child: FlatButton(
                    //                 onPressed: () {
                    //                   Navigator.push(
                    //                     context,
                    //                     MaterialPageRoute(
                    //                       builder: (context) =>
                    //                           AccountSettingsScreen(
                    //                         currentUser: widget.currentUser,
                    //                       ),
                    //                     ),
                    //                   );
                    //                 },
                    //                 color: Colors.green.shade400,
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(12.0),
                    //                 ),
                    //                 child: Text(
                    //                   'Change address',
                    //                   style: GoogleFonts.tajawal()(
                    //                     color: Colors.white,
                    //                     fontSize: 14.0,
                    //                     fontWeight: FontWeight.w500,
                    //                     letterSpacing: 0.3,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       );
                    //     }
                    //     return SizedBox();
                    //   },
                    // ),
                    selectedPayment==1?  Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0.0),
              blurRadius: 15.0,
              spreadRadius: 2.0,
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'اختر منطقة التوصيل ',
              style: GoogleFonts.tajawal(
                color: Colors.black87,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
        DropdownButton(
          isExpanded: true,
          iconSize: 30.0,hint: Text("اختر منطقة التوصيل "),
            style: TextStyle(color: Colors.black),
          value:deliveryprice!=0? _Model[i]:_Model.last,
           items: _Model.map(
                (val) {
                  print("${val.areaprice}:::::::::::");
              return DropdownMenuItem(
                value: val,
                child:val.areaName=="اختر منطقة التوصيل"?Visibility(child: SizedBox(),  visible: false,
                ):Text(val.areaName,style: GoogleFonts.tajawal(),),
              );
            },
          ).toList(),
          onChanged: (val) {
            if(val.areaName=="اختر منطقة التوصيل"){
            return TextButton(
              child: Container(),
              onPressed: (){},

            );
            }
             setState(() {
               i=_Model.indexOf(val);
            });
            setState(
                  () {
                    setState(() {
                      deliveryprice=0;
                       deliveryprice=deliveryprice+num.parse(val.areaprice);
                      print(deliveryprice);
                    });
                    allCost =widget.totalAmt+deliveryprice-widget.discountAmt;

                  },
            );
          },
        )

          ],
        ),
      ):SizedBox(),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 15.0,
                            spreadRadius: 2.0,
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   mainAxisSize: MainAxisSize.max,
                          //   children: <Widget>[
                          //     Icon(
                          //       Icons.local_offer,
                          //       color: Theme.of(context).primaryColor,
                          //       size: 25.0,
                          //     ),
                          //     SizedBox(
                          //       width: 10.0,
                          //     ),
                          //     Expanded(
                          //       child: Text(
                          //         'Get ${widget.cartValues.cartInfo.discountPer}% discount on orders above ${Config().currency}${widget.cartValues.cartInfo.discountAmt}',
                          //         style: GoogleFonts.tajawal()(
                          //           color: Colors.black87,
                          //           fontSize: 15.5,
                          //           fontWeight: FontWeight.w600,
                          //           letterSpacing: 0.3,
                          //         ),
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 10.0,
                          //     ),
                          //     // Icon(
                          //     //   Icons.check_circle,
                          //     //   size: 22.0,
                          //     //   color: Theme.of(context).primaryColor,
                          //     // ),
                          //   ],
                          // ),
                          // SizedBox(
                          //   height: 10.0,
                          // ),
                          // Divider(),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'الثمن :',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${widget.totalOrderAmt.toStringAsFixed(2)} ${Config().currency}',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'التوصيل :',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${deliveryprice.toStringAsFixed(2)} ${Config().currency}',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'الضريبة (${widget.cartValues.cartInfo.taxPer}%) :',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${widget.taxAmt.toStringAsFixed(2)} ${Config().currency}',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'الخصم :',
                                style: GoogleFonts.tajawal(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '- ${widget.discountAmt.toStringAsFixed(2)} ${Config().currency}',
                                style: GoogleFonts.tajawal(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          widget.appliedCoupon
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        Text(
                                          'Coupon (${widget.coupon.couponCode}):',
                                          style: GoogleFonts.tajawal(
                                            color:
                                                Colors.green.withOpacity(0.85),
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        Text(
                                          '- ${Config().currency}${widget.couponDiscountAmt.toStringAsFixed(2)}',
                                          style: GoogleFonts.tajawal(
                                            color:
                                                Colors.green.withOpacity(0.85),
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 10.0,
                          ),
                          Divider(),
                          SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Text(
                                'المبلغ الاجمالي :',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.85),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                // '${Config().currency}${(widget.totalAmt.toStringAsFixed(2)) } ',
                                '${(allCost) } ${Config().currency}',
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.85),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 90.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 80.0,
              width: size.width,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white70,
                    Colors.white54,
                    Colors.white10,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: FlatButton(
                onPressed: () {
                  if (selectedPayment != 0) {
                    if (user.address.length > 0) {
                      if (user.mobileNo.isNotEmpty) {
                        if(deliveryprice==0&&selectedPayment==1){
                          showSnack(
                              'ادخل منطقة التوصيل', context);
                        }else {
                          proceed = true;
                          proceedOrder(selectedPayment);
                        }
                      } else {
                        showSnack(
                            'ادخل رقم الهاتف', context);
                      }
                    } else {
                      showSnack('ادخل العنوان الخاص بكم', context);
                    }
                  } else {
                    showSnack('اختر وسيلة الاستلام ', context);
                  }
                },
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Text(
                  ' تــأكيـد الطلــــب',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
