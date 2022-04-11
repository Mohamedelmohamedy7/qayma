import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carousel_widget/flutter_carousel_indicators.dart';
import 'package:flutter_carousel_widget/flutter_carousel_options.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/cart_screen.dart';
import 'package:intl/intl.dart';

import '../ad_help.dart';
import 'navicationBarScreen.dart';

class ProductDetailsScreenAdded extends StatefulWidget {
  Product product;
  int index;
  String payImageForUpload;
  String productImageForUpload;
  String priceDate;
  String skuName;
  var dateOfProduct;
  Sku skuData;
  var orgImage;

  ProductDetailsScreenAdded(
      {this.product,
      this.index,
      this.payImageForUpload,
      this.productImageForUpload,
      this.priceDate,
      this.skuName,
      this.dateOfProduct,
      this.skuData,
      this.orgImage});

  @override
  _ProductDetailsScreenAddedState createState() =>
      _ProductDetailsScreenAddedState();
}

class _ProductDetailsScreenAddedState extends State<ProductDetailsScreenAdded> {
  CartBloc cartBloc;
  String proProduct;
  String quantityProduct;
  var patDate;
  var patDateValue;
  SigninBloc signinBloc;
  User _currentUser;
  bool currentDate = false;

  addToCart(String proProduct, String quantityProduct, var patDateValue) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/sign_in');
      return;
    }
    print('adding to cart');
    if (FirebaseAuth.instance.currentUser.uid != null) {
      cartBloc.add(
        AddToCartEvent(
          {
            'productId': widget.product.id,
            'sku': widget.skuData,
            'skuId': widget.skuData.skuId,
            'quantity': "1",
            'skuName': quantityProduct,
            "payImageForUpload": widget.payImageForUpload,
            "productImageForUpload": widget.productImageForUpload,
            "priceDate": proProduct,
            "DateOfProduct": patDateValue
          },
        ),
      );
      // Navigator.pop(context);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CartScreen()));
      Flushbar(
        margin: const EdgeInsets.all(8.0),
        borderRadius: 8.0,
        backgroundColor: Colors.green.shade500,
        animationDuration: Duration(milliseconds: 300),
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
          'تم تعديل المنتج ',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      )..show(context);
    } else {
      //not logged in

    }
  }

  @override
  void initState() {
    cartBloc = BlocProvider.of<CartBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);

    signinBloc.listen((state) {
      print('Current User :: $state');
      if (state is GetCurrentUserCompleted) {
        _currentUser = state.firebaseUser;
      }
      if (state is GetCurrentUserFailed) {
        //failed to get current user
      }
      if (state is GetCurrentUserInProgress) {
        //getting current user
      }
    });
    cartBloc.add(InitializeCartEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> lastData = [

      ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        child:      widget.productImageForUpload==null && widget.orgImage==""?Image.asset("assets/images/sympgoney.jpg") :
        widget.productImageForUpload!=null?
        Image.network("${widget.productImageForUpload}",fit: BoxFit.contain,errorBuilder: (context,x,ss,)=>Image.asset("assets/images/sympgoney.jpg")):Image.network("${widget.orgImage}",errorBuilder: (context,x,ss,)=>Image.asset("assets/images/sympgoney.jpg"))
      ),
      ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          child:widget.payImageForUpload==null&&widget.orgImage==""?Image.asset("assets/images/sympgoney.jpg") :
          widget.payImageForUpload!=null?Image.network("${widget.payImageForUpload}",errorBuilder: (context,x,ss,)=>Image.asset("assets/images/sympgoney.jpg")):Image.network("${widget.orgImage}",errorBuilder: (context,x,ss,)=>Image.asset("assets/images/sympgoney.jpg"))
      ),
    ];
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0))),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 0,
                    ),
                    Column(
                      children: [
                        Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: 350,
                          child: PageView(
                            children: lastData,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "أسم المنتج : ${widget.product.name}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Text(
                                "سعر المنتج : ${widget.priceDate} ج.م ",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Text(
                                "فئة المنتج : ${widget.product.subCategory is String ? widget.product.subCategory : widget.product.subCategory["subCategoryName"]}",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    " الكمية : ${widget.skuName} قطعة ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.dateOfProduct==null?   Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "تاريخ شراء المنتج : لا يوجد ",
                                    style:
                                    TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ): Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "تاريخ شراء المنتج : ${widget.dateOfProduct}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [],
                )
              ],
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).accentColor),
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(25)),
                child: TextButton(
                  child: Text(
                    "تعديل المنتج",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 40,
                              ),
                              Text(
                                "تعديل المنتج",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "سعر المنتج :",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  initialValue: widget.priceDate,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.shade100,
                                    filled: true,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(20.0),
                                      borderSide: new BorderSide(),
                                    ),
                                    hintText: 'سعر المنتج',
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.9),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      proProduct = val;
                                    });
                                    setState(() {});
                                  },
                                  onSaved: (String value) {
                                    setState(() {
                                      proProduct = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "كمية المنتج :",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  initialValue: widget.skuName,
                                  decoration: InputDecoration(
                                    fillColor: Colors.grey.shade100,
                                    filled: true,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(20.0),
                                      borderSide: new BorderSide(),
                                    ),
                                    hintText: 'كمية المنتج',
                                    hintStyle: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.9),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      quantityProduct = val;
                                    });
                                  },
                                  onSaved: (String value) {
                                    setState(() {
                                      quantityProduct = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              StatefulBuilder(
                                builder:(context,state)=> TextButton(
                                    onPressed: () {
                                      DatePicker.showDatePicker(context,
                                              showTitleActions: true,
                                              minTime: DateTime(2000, 1, 1),
                                              maxTime: DateTime.now(),
                                              theme: DatePickerTheme(
                                                  headerColor:
                                                      Colors.grey.shade200,
                                                  cancelStyle:
                                                      GoogleFonts.tajawal(
                                                          color: Colors.black),
                                                  itemStyle: TextStyle(
                                                      color: Colors.white),
                                                  doneStyle: TextStyle(
                                                      color: Colors.black),
                                                  backgroundColor: Colors.black),
                                              onChanged: (date) {
                                                state(() {
                                          DateFormat formatter =
                                              DateFormat('yyyy-MM-dd');
                                          patDate = formatter.format(date);
                                        });
                                      }, onConfirm: (date) {
                                            state(() {
                                          patDateValue = patDate;
                                        });
                                      },
                                              currentTime: DateTime.now()
                                                  .subtract(Duration(days: 11110)),
                                              locale: LocaleType.ar)
                                          .then((value) {
                                        state(() {
                                          currentDate = true;
                                        });
                                        Flushbar(
                                          margin: const EdgeInsets.all(8.0),
                                          borderRadius: 8.0,
                                          backgroundColor: Colors.green.shade500,
                                          animationDuration:
                                              Duration(milliseconds: 300),
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
                                            'تم تعديل وقت الشراء',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )..show(context);
                                      });
                                    },
                                    child: widget.dateOfProduct == null
                                        ? Text(
                                            'تعديل وقت الشراء',
                                            style: TextStyle(color: Colors.black),
                                          )
                                        : Text(
                                            "وقت الشراء : ${patDateValue == null ? widget.dateOfProduct : patDateValue}",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 20),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(25)),
                                  child: TextButton(
                                    child: Text(
                                      "تعديل",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      addToCart(
                                          proProduct == null
                                              ? widget.priceDate
                                              : proProduct,
                                          quantityProduct == null
                                              ? widget.skuName
                                              : quantityProduct,
                                          patDateValue == null
                                              ? widget.dateOfProduct
                                              : patDateValue);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
