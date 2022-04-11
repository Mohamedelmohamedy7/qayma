import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/cart.dart';
import 'package:grocery_store/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/Product_details_ScreenAdded.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../ad_help.dart';

class CartItem extends StatefulWidget {

  final Size size;
  final Product product;
  final String quantity;
  final User currentUser;
  final CartBloc cartBloc;
  final List<Cart> cartProducts;
  final int index;
  String payImageForUpload;
  String productImageForUpload;
  String priceDate;
  String skuName;
  var dateOfProduct;
  var  selectedSku;
  CartItem(
      {@required this.size,
      @required this.product,
      @required this.quantity,
      @required this.cartBloc,
      @required this.currentUser,
      @required this.cartProducts,
      @required this.index,
      this.payImageForUpload,
      this.productImageForUpload,
      this.priceDate,
      this.skuName,
        this.selectedSku,
      this.dateOfProduct});

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  // BannerAd _bottomBannerAd;
  //
  // bool _isBottomBannerAdLoaded = false;
  //
  // void _createBottomBannerAd() {
  //   _bottomBannerAd = BannerAd(
  //     adUnitId: AdHelper.bannerAdUnitId,
  //     size: AdSize.banner,
  //     request: AdRequest(),
  //     listener: BannerAdListener(
  //       onAdLoaded: (_) {
  //         setState(() {
  //           _isBottomBannerAdLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //       },
  //     ),
  //   );
  //   _bottomBannerAd.load();
  // }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 122.0,
          width: widget.size.width,
          padding: EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    widget.cartProducts[widget.index].product.productImages==null?SizedBox():      Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11.0),
                          border: Border.all(color: Theme.of(context).accentColor)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Center(
                            child: FadeInImage.assetNetwork(
                              placeholder:
                                  'assets/icons/category_placeholder.png',
                              image: widget.productImageForUpload == null
                                  ? widget.cartProducts[widget.index].product.productImages[0]
                                  : widget.productImageForUpload,
                              fit: BoxFit.fill,
                              width: 60,
                              height: double.infinity,
                              fadeInDuration: Duration(milliseconds: 250),
                              fadeInCurve: Curves.easeInOut,
                              fadeOutDuration: Duration(milliseconds: 150),
                              fadeOutCurve: Curves.easeInOut,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 180,
                                child: Text(
                                  '${widget.skuName}  x   ${widget.cartProducts[widget.index].product.name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.8),
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          // Row(
                          //   children: [
                          //     SvgPicture.asset("assets/images/SizeIcon.svg"),
                          //     SizedBox(
                          //       width: 10.0,
                          //     ),
                          //     Text(
                          //       '${cartProducts[index].sku.skuName}',
                          //       style: TextStyle(
                          //         color: Colors.black54,
                          //         fontSize: 13.0,
                          //         fontWeight: FontWeight.w500,
                          //         letterSpacing: 0.3,
                          //       ),
                          //     ),
                          //     SizedBox(
                          //       width: 10.0,
                          //     ),
                          //     Icon(Icons.access_alarm_rounded,
                          //         color: Colors.black, size: 17),
                          //     SizedBox(
                          //       width: 5,
                          //     ),
                          //     Text(
                          //       "30 دقيقة ",
                          //       style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 12,
                          //         fontWeight: FontWeight.w600,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // Text(
                          //   product.subCategory,
                          //   overflow: TextOverflow.ellipsis,
                          //   textAlign: TextAlign.left,
                          //   style: TextStyle(
                          //     color: Colors.black,
                          //     fontSize: 16.0,
                          //     fontWeight: FontWeight.w600,
                          //     letterSpacing: 0.3,
                          //   ),
                          // ),
                        if(widget.product.subCategory is String)
                          Text(
                           widget.product.subCategory,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if(widget.product.subCategory is Map<dynamic,dynamic>)
                            Text(
                              widget.product.subCategory["subCategoryName"],
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                          SizedBox(
                            height: 7,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.dateOfProduct!=null?  Text(
                                widget.dateOfProduct,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ):SizedBox(),
                              Container(
                                width: 100,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Theme.of(context).accentColor)),
                                child: Center(
                                    child: TextButton(
                                  onPressed: () {
                                    return showMaterialModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                      builder: (context) => SingleChildScrollView(
                                          controller: ModalScrollController.of(context),
                                          child: Container(
                                            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                            child: Container(
                                                height: 600,
                                                width: 400,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
                                                child:    ProductDetailsScreenAdded(
                                                  product: widget.product,
                                                  payImageForUpload:
                                                  widget.payImageForUpload,
                                                  priceDate: widget.priceDate,
                                                  productImageForUpload:
                                                  widget.productImageForUpload,
                                                  skuName: widget.skuName,
                                                  index: widget.index,
                                                  dateOfProduct: widget.dateOfProduct,
                                                  skuData: widget.selectedSku,
                                                  orgImage:widget.cartProducts[widget.index].product.productImages != null?widget.cartProducts[widget.index].product.productImages[0]:"",
                                                ),),
                                          )),
                                    );

                                  },
                                  child:Text("تفاصيل",style: TextStyle(fontSize: 14,color: Theme.of(context).accentColor.withOpacity(0.8)),)
                                )),
                              ),

                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),


                          // Padding(
                          //   padding:
                          //       const EdgeInsets.only(bottom: 0.0, right: 3.0),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.max,
                          //     crossAxisAlignment: CrossAxisAlignment.end,
                          //     children: <Widget>[
                          //       // Text(
                          //       //   cartProducts[index].product.isDiscounted
                          //       //       ? '${Config().currency}${((1 - (cartProducts[index].product.discount / 100)) * double.parse(cartProducts[index].sku.skuPrice)).toStringAsFixed(2)}'
                          //       //       : '${Config().currency}${double.parse(cartProducts[index].sku.skuPrice).toStringAsFixed(2)}',
                          //       //   style: GoogleFonts.poppins(
                          //       //     color: Colors.green.shade700,
                          //       //     fontSize: 16.5,
                          //       //     fontWeight: FontWeight.w600,
                          //       //     letterSpacing: 0.3,
                          //       //   ),
                          //       // ),
                          //       // Row(
                          //       //   children: <Widget>[
                          //       //     // ClipRRect(
                          //       //     //   borderRadius: BorderRadius.circular(8.0),
                          //       //     //   child: Material(
                          //       //     //     child: InkWell(
                          //       //     //       splashColor:
                          //       //     //           Theme.of(context).primaryColor,
                          //       //     //       onTap: () {
                          //       //     //         print('decrease');
                          //       //     //         int tempQuan = int.parse(quantity);
                          //       //     //         if (tempQuan > 1) {
                          //       //     //           tempQuan--;
                          //       //     //           cartBloc.add(
                          //       //     //             IncreaseQuantityEvent(
                          //       //     //               productId: cartProducts[index]
                          //       //     //                   .product
                          //       //     //                   .id,
                          //       //     //               quantity: '$tempQuan',
                          //       //     //               uid: currentUser.uid,
                          //       //     //               id: cartProducts[index]
                          //       //     //                   .sku
                          //       //     //                   .skuId,
                          //       //     //             ),
                          //       //     //           );
                          //       //     //         }
                          //       //     //         cartProducts[index].quantity =
                          //       //     //             '$tempQuan';
                          //       //     //         print(cartProducts[index].quantity);
                          //       //     //       },
                          //       //     //       child: Container(
                          //       //     //         width: 25,
                          //       //     //         height: 25,
                          //       //     //         decoration: BoxDecoration(
                          //       //     //             color: Colors.white,
                          //       //     //             borderRadius: BorderRadius.all(
                          //       //     //                 Radius.circular(100)),
                          //       //     //             border: Border.all(
                          //       //     //               width: 1,
                          //       //     //               color: Colors.black,
                          //       //     //             )),
                          //       //     //         child: Icon(
                          //       //     //           Icons.remove,
                          //       //     //           color: Colors.black,
                          //       //     //           size: 18.0,
                          //       //     //         ),
                          //       //     //       ),
                          //       //     //     ),
                          //       //     //   ),
                          //       //     // ),
                          //       //     // SizedBox(
                          //       //     //   width: 10,
                          //       //     // ),
                          //       //     // Container(
                          //       //     //   width: 30.0,
                          //       //     //   height: 25.0,
                          //       //     //   padding: EdgeInsets.only(
                          //       //     //     bottom:
                          //       //     //         2, // Space between underline and text
                          //       //     //   ),
                          //       //     //   decoration: BoxDecoration(
                          //       //     //       border: Border(
                          //       //     //           bottom: BorderSide(
                          //       //     //               color: Colors.black,
                          //       //     //               width:
                          //       //     //                   0.6 // Underline thickness
                          //       //     //               ))),
                          //       //     //   child: Text(
                          //       //     //     '$quantity',
                          //       //     //     textAlign: TextAlign.center,
                          //       //     //     style: GoogleFonts.poppins(
                          //       //     //       color: Colors.black54,
                          //       //     //       fontSize: 15.0,
                          //       //     //       fontWeight: FontWeight.w500,
                          //       //     //       letterSpacing: 0.3,
                          //       //     //     ),
                          //       //     //   ),
                          //       //     // ),
                          //       //     // SizedBox(
                          //       //     //   width: 10,
                          //       //     // ),
                          //       //     // ClipRRect(
                          //       //     //   borderRadius: BorderRadius.circular(8.0),
                          //       //     //   child: Material(
                          //       //     //     child: InkWell(
                          //       //     //       splashColor:
                          //       //     //           Theme.of(context).primaryColor,
                          //       //     //       onTap: () {
                          //       //     //         print('increase');
                          //       //     //
                          //       //     //         int tempQuan = int.parse(quantity);
                          //       //     //
                          //       //     //         tempQuan++;
                          //       //     //
                          //       //     //         //check if available
                          //       //     //         if (cartProducts[index].sku.quantity <
                          //       //     //             tempQuan) {
                          //       //     //           return;
                          //       //     //         }
                          //       //     //
                          //       //     //         cartBloc.add(
                          //       //     //           IncreaseQuantityEvent(
                          //       //     //             productId: cartProducts[index]
                          //       //     //                 .product
                          //       //     //                 .id,
                          //       //     //             quantity: '$tempQuan',
                          //       //     //             uid: currentUser.uid,
                          //       //     //             id: cartProducts[index].sku.skuId,
                          //       //     //           ),
                          //       //     //         );
                          //       //     //
                          //       //     //         cartProducts[index].quantity =
                          //       //     //             '$tempQuan';
                          //       //     //         print(cartProducts[index].quantity);
                          //       //     //       },
                          //       //     //       child: Container(
                          //       //     //         width: 25,
                          //       //     //         height: 25,
                          //       //     //         decoration: BoxDecoration(
                          //       //     //             color: Colors.black,
                          //       //     //             borderRadius: BorderRadius.all(
                          //       //     //                 Radius.circular(100)),
                          //       //     //             border: Border.all(
                          //       //     //               width: 1,
                          //       //     //               color: Colors.black,
                          //       //     //             )),
                          //       //     //         child: Icon(
                          //       //     //           Icons.add,
                          //       //     //           color: Colors.white,
                          //       //     //           size: 18.0,
                          //       //     //         ),
                          //       //     //       ),
                          //       //     //     ),
                          //       //     //   ),
                          //       //     // ),
                          //       //   ],
                          //       // ),
                          //       // SizedBox(
                          //       //   width: 50,
                          //       // ),
                          //
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
               // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 8,
              //   ),
              // )
            ],
          ),
        ),
        Positioned(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.blue.withOpacity(0.5),
                onTap: () {
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
                            'هل انت متأكد من مسح هذة المنتج ؟',
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
                                    print('remove from cart');

                                    widget.cartBloc.add(
                                      RemoveFromCartEvent(
                                        widget.cartProducts[widget.index].product.id,
                                        widget.cartProducts[widget.index].sku.skuId,
                                      ),
                                    );
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

                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  width: 38.0,
                  height: 35.0,
                  child: Icon(
                    Icons.delete,
                    color:Theme.of(context).primaryColor,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
          top:10,
          left: 15,
        ),

      ],
    );
  }
}
