import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/search_bloc/search_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/navicationBarScreen.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:grocery_store/widget/product_list_item.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

import '../ad_help.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  SearchBloc searchBloc;
  String previousLetter, currentLetter;
  List<Product> productsList;
  List<Product> filteredList;
  CartBloc cartBloc;
  User currentUser;
  SigninBloc signinBloc;
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
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );
    _ad.load();
    searchBloc = BlocProvider.of<SearchBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    // searchBloc.add(FirstSearchEvent());

    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        print(currentUser.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return   Stack(
      children: [
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 100,right: 10),
                child: Row(
                  children: [
                    IconButton(
                        icon: Container(
                          height: 35,
                          width: 35,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                          decoration: BoxDecoration(
                            border:Border.all(color:  Colors.black.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(5),
                            color: Color(0xffF2F6F9),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
              ),
              Container(
                width: size.width,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 10.0, bottom: 16.0),
                  child: Container(
                    height: 56,
                    width: size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 0.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      enableInteractiveSelection: false,
                      onChanged: (value) {
                        if (value.length > 0) {
                          if (productsList != null) {
                            searchBloc.add(NewSearchEvent(
                                value.toLowerCase(), productsList));
                          }
                        }
                      },
                      onSubmitted: (value) {
                        if (value.trim().length > 0) {
                          if (productsList != null) {
                          } else {
                            searchBloc.add(FirstSearchEvent(value.toLowerCase()));
                          }
                        }
                      },
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.all(18),

                        isDense: true,
                        //contentPadding: EdgeInsets.all(30),
                        prefixIcon: Container(
                          padding: EdgeInsets.only(right: 10),
                          //color: Colors.yellow,
                          // margin: EdgeInsets.only(left: 15),
                          height: 10,
                          width: 10,
                          child: SvgPicture.asset(
                              'assets/images/searchScreenIcon.svg',
                              width: 25,
                              height: 25,
                              color:  Theme.of(context).primaryColor,
                              fit: BoxFit.scaleDown),
                        ),
                        border: InputBorder.none,
                        hintText: '    ابحث عن المنتجات    ',
                        //hintText: '${S.of(context).search}',
                        hintStyle: TextStyle(
                          fontSize: 17,                          color:  Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder(
                  cubit: searchBloc,
                  buildWhen: (previous, current) {
                    if (current is FirstSearchCompletedState ||
                        current is FirstSearchFailedState ||
                        current is FirstSearchInProgressState ||
                        current is NewSearchCompletedState ||
                        current is NewSearchFailedState ||
                        current is NewSearchInProgressState) {
                      return true;
                    }
                    return false;
                  },
                  builder: (context, state) {
                    if (state is FirstSearchInProgressState ||
                        state is NewSearchInProgressState) {
                      return ListView.separated(
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 5,
                          );
                        },
                        physics: NeverScrollableScrollPhysics(),
                        // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //   crossAxisCount: 2,
                        //   mainAxisSpacing: 16.0,
                        //   childAspectRatio: 1 / 1.6,
                        //   crossAxisSpacing: 16.0,
                        // ),
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 35.0, top: 16.0),
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
                    }
                    if (state is FirstSearchFailedState ||
                        state is NewSearchFailedState) {
                      return Center(
                        child: Text(
                          'فشل التحميل!',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    }
                    if (state is NewSearchCompletedState ||
                        state is FirstSearchCompletedState) {
                      if (state.filteredList.length == 0) {
                        return ListView(
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            // Image.asset(
                            //   'assets/images/Empty-rafiki.png',
                            //   width: size.width * 0.6,
                            // ),
                            Lottie.asset("assets/images/searww.json",
                                width: size.width * 0.3,reverse: false,),
                            SizedBox(
                              height: 0.0,
                            ),
                            Center(
                              child: Text(
                                "لا يوجد منتجات بهذة الاسم ",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),  Center(
                              child: Text(
                                'برجاء كتابة الاسم صحيح..!',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      if (state is FirstSearchCompletedState) {
                        productsList = state.searchList;
                        filteredList = state.filteredList;
                      }
                      if (state is NewSearchCompletedState) {
                        filteredList = state.filteredList;
                      }

                      return ListView.separated(
                        // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        //   crossAxisCount: 2,
                        //   mainAxisSpacing: 16.0,
                        //   childAspectRatio: 3/ 1.6,
                        //   crossAxisSpacing: 16.0,
                        // ),
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: 10,
                          );
                        },
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 35.0, top: 16.0),
                        itemCount: filteredList.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              index==0?Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Text("نتائج البحث : ",style:         TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .w500),),
                                ),
                              ):SizedBox(),
                              InkWell(
                                onTap: () {
                                  return showMaterialModalBottomSheet(
                                    context: context,
                                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0))),
                                    builder: (context) => SingleChildScrollView(
                                        controller: ModalScrollController.of(context),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25.0),
                                                  topRight: Radius.circular(25.0))),
                                          child: Container(
                                              height: 680,
                                              width: 400,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(25.0),
                                                      topRight: Radius.circular(25.0))),
                                              child: ProductScreen(
                                                productId: filteredList[index].id,
                                              ),),
                                        )
                                    ),
                                  );
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ProductScreen(
                                  //       productId: filteredList[index].id,
                                  //     ),
                                  //   ),
                                  // );
                                },
                                child: Container(
                                  padding: EdgeInsets.only(top: 10),
                                  height: 110,
                                  color: Colors.transparent,
                                  child: Stack(
                                    children: [
                                      Container(
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 130,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(15.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.only(right: 50.0),
                                                child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 0.0,
                                                      ),

                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                          bottom: 15.0,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                          Alignment.centerLeft,
                                                          child: Container(
                                                            height: 40,
                                                            width: 150,
                                                            decoration: BoxDecoration(

                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  10),
                                                              border: Border.all(
                                                                color:  Theme.of(context).accentColor,
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Text(
                                                                " +  اضف الى المشتريات",
                                                                style:
                                                                TextStyle(
                                                                    color:  Theme.of(context).primaryColor,
                                                                    fontSize: 14,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      filteredList[index].productImages==null?
                                      SizedBox():
                                      Row(
                                        children: [
                                          Container(
                                            // width: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:BorderRadius.circular(10),
                                              border: Border.all(
                                                color:  Theme.of(context).accentColor,
                                              ),
                                            ),
                                            height: 80,
                                            width:70,
                                            // padding: EdgeInsets.all(12),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10.0),
                                              child: Center(
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                  'assets/icons/category_placeholder.png',
                                                  image:
                                                  filteredList[index].productImages[0],
                                                  fadeInDuration:
                                                  Duration(milliseconds: 250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fit: BoxFit.cover,
                                                  fadeOutDuration:
                                                  Duration(milliseconds: 150),
                                                  fadeOutCurve: Curves.easeInOut,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Padding(
                                            padding:   EdgeInsets.only(
                                              top: 8.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width:120,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 0.0,
                                                        right: 0),
                                                    child: Text(
                                                      '${filteredList[index].name}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style:
                                                      TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 25,),

                                                Container(
                                                  width:140,
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        top: 0.0,
                                                        right: 0),
                                                    child: Text(
                                                      '${filteredList[index].subCategory}',
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style:
                                                      TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Padding(
                                                //   padding:
                                                //   const EdgeInsets.only(
                                                //       top: 0.0,
                                                //       right: 0),
                                                //   child: Text(
                                                //     '${filteredList[index].subCategory.replaceRange(4, filteredList[index].description.length, "...")}',
                                                //     maxLines: 1,
                                                //     overflow: TextOverflow
                                                //         .ellipsis,
                                                //     style:
                                                //     TextStyle(
                                                //       color: Colors.black38,
                                                //       fontSize: 14.0,
                                                //       fontWeight:
                                                //       FontWeight.w400,
                                                //     ),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                          //   ProductListItem(
                          //   product: filteredList[index],
                          //   cartBloc: cartBloc,
                          //   currentUser: currentUser,
                          // );
                        },
                      );
                    } else {
                      return Center(
                        child: ListView(
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            // Image.asset(
                            //   'assets/images/Search-rafiki.png',
                            //   width: size.width * 0.6,
                            // ),
                            Lottie.asset("assets/images/searchqayma.json",
                               width: size.width * 0.3,fit: BoxFit.scaleDown,height: 300),
                            SizedBox(
                              height: 30.0,
                            ),
                            Center(
                              child: Text(
                                "لم يتم اجراء عمليات بحث بعد ",
                                style: TextStyle(
                                  color:  Theme.of(context).accentColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Center(
                              child: Text(
                                "اختر من الاقتراحات او ابحث عن العنصر الذي تريدة بسهولة ",
                                style: TextStyle(
                                  color:  Theme.of(context).primaryColor,
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        Positioned(
          top: 10,left: 20,
          child: Center(
            child: Container(
              child: AdWidget(ad: _ad),
              width: _ad.size.width.toDouble(),
              height: 72.0,
              alignment: Alignment.center,
            ),
          ),
        )
        ],
    );

  }

  @override
  bool get wantKeepAlive => true;
}
