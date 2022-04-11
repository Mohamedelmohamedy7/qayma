import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/wishlist_product_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/navicationBarScreen.dart';
import 'package:grocery_store/widget/product_list_item.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../ad_help.dart';

class WishlistPage extends StatefulWidget {
  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage>
    with AutomaticKeepAliveClientMixin<WishlistPage> {
  WishlistProductBloc wishlistProductBloc;
  List<Product> wishlistProducts;
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

    // TODO: Load an ad
    _ad.load();
    wishlistProductBloc = BlocProvider.of<WishlistProductBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);

    signinBloc.listen((state) {
      if (state is GetCurrentUserCompleted) {
        currentUser = state.firebaseUser;
        print(currentUser.uid);

        wishlistProductBloc.add(LoadWishlistProductEvent(currentUser.uid));
      }
    });

    wishlistProductBloc.listen((state) {
      if (state is AddToWishlistCompletedState ||
          state is RemoveFromWishlistCompletedState) {
        wishlistProductBloc.add(LoadWishlistProductEvent(currentUser.uid));
      }
    });
    signinBloc.add(GetCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25.0),
                  topLeft: Radius.circular(25.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 80.0, bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
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
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop()
                      // Navigator.of(context, rootNavigator: true)
                      //     .pushReplacement(MaterialPageRoute(
                      //   builder: (context) => NavicationBarScreen(),
                      // ),
                    ),

                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(50.0),
                    //   child: Material(
                    //     color: Colors.transparent,
                    //     child: InkWell(
                    //       splashColor: Colors.white.withOpacity(0.5),
                    //       onTap: () {
                    //         Navigator.pop(context);
                    //       },
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //           color: Colors.transparent,
                    //         ),
                    //         width: 38.0,
                    //         height: 35.0,
                    //         child: Icon(
                    //           Icons.arrow_back,
                    //           color: Colors.white,
                    //           size: 24.0,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder(
                cubit: wishlistProductBloc,
                buildWhen: (previous, current) {
                  if (current is LoadWishlistProductCompletedState ||
                      current is LoadWishlistProductFailedState ||
                      current is LoadWishlistProductInProgressState) {
                    return true;
                  }
                  return false;
                },
                builder: (context, state) {
                  if (state is LoadWishlistProductInProgressState) {
                    return ListView.separated(
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
                      separatorBuilder: (ctx, index) => SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          period: Duration(milliseconds: 800),
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.black.withOpacity(0.5),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is LoadWishlistProductFailedState) {
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
                  if (state is LoadWishlistProductCompletedState) {
                    if (state.productList.length == 0) {
                      return Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Lottie.asset(
                                "assets/images/needs.json",width: 380,height: 380
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              'لم يتم أضافة اي من العناصر حتى الأن..!',
                              style: TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              NavicationBarScreen()));
                                    },
                                    child: Text(
                                      "الذهاب للعناصر",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
                                    )),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    wishlistProducts = state.productList;

                    return AnimationLimiter(
                      child: ListView.separated(
                        separatorBuilder: (ctx, index) => SizedBox(
                          height: 10,
                        ),
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 35.0, top: 16.0),
                        itemCount: wishlistProducts.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 2000),
                              child: SlideAnimation(
                                  verticalOffset: 100.0,
                                  child: FadeInAnimation(
                                      child: ProductListItem(
                                        product: wishlistProducts[index],
                                        cartBloc: cartBloc,
                                        currentUser: currentUser,
                                        data: 1,
                                        screenId: 5,
                                      ))));
                        },
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
        // Positioned(
        //   top: 10,left: 20,
        //   child: Center(
        //     child: Container(
        //       child: AdWidget(ad: _ad),
        //       width: _ad.size.width.toDouble(),
        //       // height: 72.0,
        //       alignment: Alignment.center,
        //     ),
        //   ),
        // )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
