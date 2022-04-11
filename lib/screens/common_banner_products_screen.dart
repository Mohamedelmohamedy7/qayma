import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_product_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:grocery_store/widget/product_list_item.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CommonBannerProductsScreen extends StatefulWidget {
  final String category;
  final User currentUser;
  final CartBloc cartBloc;

  CommonBannerProductsScreen({
    this.category,
    this.currentUser,
    this.cartBloc,
  });

  @override
  _CommonBannerProductsScreenState createState() =>
      _CommonBannerProductsScreenState();
}

class _CommonBannerProductsScreenState
    extends State<CommonBannerProductsScreen> {
  BannerProductBloc bannerProductBloc;
  List<Product> productList;

  @override
  void initState() {
    super.initState();

    productList = [];
    bannerProductBloc = BlocProvider.of<BannerProductBloc>(context);
    bannerProductBloc.add(LoadBannerAllProductsEvent(widget.category));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Container(
              height: 35,
              width: 35,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).primaryColor,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "${widget.category}",
            style: GoogleFonts.tajawal(
              fontSize: 20,
            ),
          ),
        ),
        body: Column(
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
            //             '${widget.category}',
            //             style: GoogleFonts.poppins(
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
              child: BlocBuilder(
                cubit: bannerProductBloc,
                buildWhen: (previous, current) {
                  if (current is LoadBannerAllProductsCompletedState ||
                      current is LoadBannerAllProductsFailedState ||
                      current is LoadBannerAllProductsInProgressState) {
                    return true;
                  }
                  return false;
                },
                builder: (context, state) {
                  if (state is LoadBannerAllProductsInProgressState) {
                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1 / 1.6,
                        crossAxisSpacing: 16.0,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: 8,
                      itemBuilder: (context, index) {
                         return Shimmer.fromColors(
                          period: Duration(milliseconds: 800),
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.black.withOpacity(0.5),
                          child: ShimmerProductListItem(),
                        );
                      },
                    );
                  } else if (state is LoadBannerAllProductsFailedState) {
                    return Center(
                      child: Text(
                        'Failed to load products!',
                        style: GoogleFonts.poppins(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    );
                  }
                  if (state is LoadBannerAllProductsCompletedState) {
                    if (state.products.length == 0) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 140,
                          ),
                          Stack(
                            children: [
                              Opacity(
                                opacity: 0.15,
                                child: Image.asset(
                                  'assets/images/sympgoney.jpg',
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  // width: 700,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Text(
                          //   'عفوأ لا يوجد منتجات في هذة الفئة !',
                          //   textAlign: TextAlign.center,
                          //   overflow: TextOverflow.clip,
                          //   style: GoogleFonts.tajawal(
                          //     color: Colors.black.withOpacity(0.5),
                          //     fontSize: 16.5,
                          //     fontWeight: FontWeight.w600,
                          //     letterSpacing: 0.3,
                          //   ),
                          // )
                        ],
                      );
                      // return Column(
                      //   // crossAxisAlignment: CrossAxisAlignment.center,
                      //   // mainAxisAlignment: MainAxisAlignment.center,
                      //   // mainAxisSize: MainAxisSize.max,
                      //   children: <Widget>[
                      //     SvgPicture.asset(
                      //       'assets/images/empty_prod.svg',
                      //       width: size.width * 0.4,
                      //     ),
                      //     SizedBox(
                      //       height: 15.0,
                      //     ),
                      //     Text(
                      //       'لا يوجد منتجات في هذة الفئة !',
                      //       textAlign: TextAlign.center,
                      //       overflow: TextOverflow.clip,
                      //       style: GoogleFonts.poppins(
                      //         color: Colors.black.withOpacity(0.7),
                      //         fontSize: 14.5,
                      //         fontWeight: FontWeight.w500,
                      //         letterSpacing: 0.3,
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       height: 15.0,
                      //     ),
                      //   ],
                      // );
                    }
                    productList = state.products;
                    return ListView.separated(
                      // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisCount: 2,
                      //   mainAxisSpacing: 16.0,
                      //   childAspectRatio: 1 / 1.6,
                      //   crossAxisSpacing: 16.0,
                      // ),
                      separatorBuilder: (context, index) => SizedBox(
                        height: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      itemCount: productList.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            print('Open Product');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductScreen(
                                  productId: productList[index].id,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 175,
                                decoration: BoxDecoration(
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey,
                                  //     offset: Offset(0.0, 1.0), //(x,y)
                                  //     blurRadius: 6.0,
                                  //   ),
                                  // ],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                                //color: Colors.yellow,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    // color: Colors.lightGreenAccent,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Colors.grey.withOpacity(0.5),
                                      //     spreadRadius: 3,
                                      //     blurRadius:2 ,
                                      //     offset: Offset(0, 1), // changes position of shadow
                                      //   ),
                                      // ],
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        // 10% of the width, so there are ten blinds.
                                        colors: <Color>[
                                          Theme.of(context).primaryColor,
                                          Theme.of(context).primaryColor,
                                        ],
                                        // red to yellow
                                        tileMode: TileMode
                                            .repeated, // repeats the gradient over the canvas
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom: 20, right: 20, top: 25),
                                        //color: Colors.white,
                                        height: 150,
                                        width: 150,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 10, left: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  productList[index].name,
                                                  textAlign: TextAlign.right,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.tajawal(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                "assets/images/ratings.svg",
                                                height: 15,
                                                width: 40,
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "تكفي ل",
                                                        style:
                                                            GoogleFonts.tajawal(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Icon(
                                                            Icons.person,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            "1x ",
                                                            style: GoogleFonts
                                                                .tajawal(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                    width: 1,
                                                    height: 30,
                                                    color: Colors.grey,
                                                  ),
                                                  // VerticalDivider(
                                                  //   color: Colors.red,
                                                  //   thickness: 2,
                                                  // ),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "سوف تستغرق",
                                                        style:
                                                            GoogleFonts.tajawal(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Icon(Icons.access_time,
                                                              color: Colors.white,
                                                              size: 17),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            "30 دقيقة ",
                                                            style: GoogleFonts
                                                                .tajawal(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 10,
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  padding: EdgeInsets.all(15),
                                  width: 155,
                                  height: 155,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 2,
                                        offset: Offset(
                                            0, 1), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    //padding: EdgeInsets.all(10),
                                    clipBehavior: Clip.antiAlias,

                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    // color: Colors.blue,
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/icons/usericon.png',
                                      image: productList[index].productImages[0],
                                      fit: BoxFit.cover,
                                      // fadeInDuration: Duration(milliseconds: 1),
                                      // fadeInCurve: Curves.easeInOut,
                                      // fadeOutDuration: Duration(milliseconds: 1),
                                      // fadeOutCurve: Curves.easeInOut,
                                    ),
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   left: 40,
                              //   bottom: 20,
                              //   child: Container(
                              //     width: 150,لا
                              //     height: 100,
                              //     // color: Colors.white,
                              //     child: Align(
                              //       alignment: Alignment.centerLeft,
                              //       child: Text(
                              //         product[index].description,
                              //         maxLines: 2,
                              //         overflow: TextOverflow.ellipsis,
                              //         style: GoogleFonts.tajawal(
                              //           color: Colors.black,
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.w500,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
                          //                   //           style: GoogleFonts.tajawal(
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
                        );
                      },
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
