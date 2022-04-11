import 'dart:ui';

import 'package:flushbar/flushbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/wishlist_product_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/widget/product_sku_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

class ProductListItem extends StatefulWidget {
  final Product product;
  final CartBloc cartBloc;
  final User currentUser;
  int screenId;
  int data;
  ProductListItem({
    @required this.product,
    this.cartBloc,
    @required this.currentUser,
    this.data=0,
    this.screenId
  });

  @override
  _ProductListItemState createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  Sku selectedSku;
  double rating;
  WishlistProductBloc wishlistProductBloc;

  @override
  void initState() {
    super.initState();
    wishlistProductBloc = BlocProvider.of<WishlistProductBloc>(context);
    wishlistProductBloc.add(InitializeWishlistEvent());

      wishlistProductBloc.listen((state) {
        //TODO: add to wishlist and remove from wishlist
        // if (state is AddToWishlistCompletedState) {
        //   showSnack('Added to wishlist');
        //   // wishlistProductBloc.close();
        // }
        if (state is AddToWishlistFailedState) {
         }
        if(state is RemoveFromWishlistInProgressState){
          showWishlistSnack('تم الحذف من قائمة الاحتياجات', context);

        }
        if (state is AddToWishlistInProgressState) {
          showWishlistSnack('تم الاضافة الي قائمة الاحتياجات', context);
        }
      });
    print(widget.product.skus[0].skuName);
    print(widget.product.skus[0].skuPrice);
    selectedSku = widget.product.skus[0];
    rating = 0;
    if (widget.product.reviews.length == 0) {
    } else {
      if (widget.product.reviews.length > 0) {
        for (var review in widget.product.reviews) {
          rating = rating + double.parse(review.rating);
        }
        rating = rating / widget.product.reviews.length;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),topRight: Radius.circular(25)
        )
      ),
      child: GestureDetector(
          onTap: () {
            // print('Open Product');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => ProductScreen(
            //       productId: widget.product.id,
            //       screenId:widget.screenId,
            //     ),
            //   ),
            // );
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,height: 70,
                        //padding: EdgeInsets.all(10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).accentColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // color: Colors.blue,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/sympgoney.jpg',
                            image: widget.product.productImages[0],
                            fit: BoxFit.fitHeight,
                            // fadeInDuration: Duration(milliseconds: 1),
                            // fadeInCurve: Curves.easeInOut,
                            // fadeOutDuration: Duration(milliseconds: 1),
                            // fadeOutCurve: Curves.easeInOut,
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                              Container(
                                 width: 140,
                                child: Text(
                                  widget.product.name,
                                    style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),textAlign:TextAlign.start ,overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                               Container(
                                 width: 140,
                                 child: Text(
                                   widget.product.subCategory,
                                   style: TextStyle(
                                     color: Colors.grey,
                                     fontSize: 16,
                                     fontWeight: FontWeight.w300,
                                   ),textAlign:TextAlign.start ,overflow: TextOverflow.ellipsis,
                                   maxLines: 1,
                                 ),
                               ),
                              // Container(
                              //   width: 140,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         widget.product.subCategory,
                              //         textAlign: TextAlign.start,
                              //         maxLines: 1,
                              //          style: TextStyle(
                              //           color: Colors.grey,
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w400,
                              //         ),
                              //         overflow: TextOverflow.ellipsis,
                              //        ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      width: 100,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(14),
                       ),
                      child: Center(
                          child: TextButton(
                            onPressed: () {
                              return showMaterialModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(
                                    topLeft: Radius.circular(25.0),
                                    topRight: Radius.circular(25.0))),
                                builder: (context) => BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX:2, sigmaY: 2,tileMode:TileMode.mirror),
                                  child: SingleChildScrollView(
                                      controller: ModalScrollController.of(context),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(25.0),
                                                topRight: Radius.circular(25.0))),
                                        child: Container(
                                          height: 650,
                                          width: 400,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0))),
                                          child:ProductScreen(
                                            productId: widget.product.id,
                                            screenId:widget.screenId,
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
                              "أضـف",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                    ),
                  ),
                  // widget.data!=1? SizedBox(): Positioned(
                  //   top: 25,
                  //   right: 10,
                  //   child:  ClipRRect(
                  //     borderRadius: BorderRadius.circular(8.0),
                  //     child: InkWell(
                  //       splashColor: Colors.blue.withOpacity(0.5),
                  //       onTap: () {
                  //         print('Wishlist');
                  //         FirebaseAuth.instance.currentUser == null
                  //             ? Navigator.of(context).push(
                  //             MaterialPageRoute(builder: (context) => SignInScreen())):
                  //         wishlistProductBloc.add(RemoveFromWishlistEvent(
                  //           widget.product.id,
                  //           FirebaseAuth.instance.currentUser.uid,
                  //         ));
                  //       },
                  //       child: Container(
                  //         width: 38.0,
                  //         height: 35.0,
                  //         decoration: BoxDecoration(
                  //           // color:
                  //           // Colors.black.withOpacity(0.04),
                  //           borderRadius: BorderRadius.circular(8.0),
                  //         ),
                  //         child: Icon(
                  //           Icons.favorite,
                  //           color: Colors.red.withOpacity(0.4),
                  //           size: 26.0,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                ],
              ),
              SizedBox(height: 10,),
              Divider()
            ],
          ),
          // Container(
          //   padding: EdgeInsets.only(top:20),
          //   height: 180,color: Colors.transparent,
          //   child: Stack(
          //     children: [
          //        Container(
          //          child: Stack(
          //           children: [
          //             Container(
          //               height: 130,
          //               decoration: BoxDecoration(
          //                 color: Theme.of(context).primaryColor,
          //                 borderRadius: BorderRadius.circular(15.0),
          //               ),
          //               child: Padding(
          //                 padding: const EdgeInsets.only(right:100.0),
          //                 child: Row(
          //                 mainAxisAlignment: MainAxisAlignment.start,
          //                 children: <Widget>[
          //                   SizedBox(
          //                     width: 20.0,
          //                   ),
          //                   Expanded(
          //                     child: Padding(
          //                       padding: const EdgeInsets.only(top:8.0),
          //                       child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           Padding(
          //                             padding: const EdgeInsets.only(top: 0.0,right: 20),
          //                             child: Text(
          //                               '${widget.product.name}',
          //                               maxLines: 1,
          //                               overflow: TextOverflow.ellipsis,
          //                               style: GoogleFonts.poppins(
          //                                 color: Colors.white,
          //                                 fontSize: 22.0,letterSpacing: 2,
          //                                 fontWeight: FontWeight.w600,
          //                               ),
          //                             ),
          //                           ),
          //
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                   // Padding(
          //                   //   padding: const EdgeInsets.only(bottom: 17.0,),
          //                   //   child: Align(
          //                   //     alignment: Alignment.centerLeft,
          //                   //     child: Container(
          //                   //       height: 40,
          //                   //       width: 125,
          //                   //       decoration: BoxDecoration(
          //                   //         borderRadius: BorderRadius.circular(10),
          //                   //         border: Border.all(color: Colors.black),
          //                   //       ),
          //                   //       child: Center(
          //                   //         child: Text(
          //                   //           " +  اضف الى السله",
          //                   //           style: TextStyle(
          //                   //               fontSize: 14, fontWeight: FontWeight.w400),
          //                   //         ),
          //                   //       ),
          //                   //     ),
          //                   //   ),
          //                   // ),
          //
          //                 ]),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Positioned(
          //         bottom: 50,
          //         child: Container(
          //           width: 120,
          //           height: 120,padding: EdgeInsets.all(12),
          //           decoration: BoxDecoration(
          //             color: Colors.white,shape: BoxShape.circle,
          //           ),
          //           child: ClipRRect(
          //             borderRadius: BorderRadius.circular(45.0),
          //             child: Center(
          //               child: FadeInImage.assetNetwork(
          //                 placeholder:
          //                 'assets/icons/category_placeholder.png',
          //                 image: widget.product.productImages[0],
          //                 fadeInDuration: Duration(milliseconds: 250),
          //                 fadeInCurve: Curves.easeInOut,
          //                 fit: BoxFit.cover,
          //                 fadeOutDuration: Duration(milliseconds: 150),
          //                 fadeOutCurve: Curves.easeInOut,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
      ),
    );

  }
  void showWishlistSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: Colors.green,
      animationDuration: Duration(milliseconds: 350),
      isDismissible: true,
      duration: Duration(milliseconds: 2500),
      icon: Icon(
        Icons.favorite_border,
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

}

