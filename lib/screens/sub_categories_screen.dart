// import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
// import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
// import 'package:grocery_store/blocs/category_bloc/category_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/category_products_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
// import 'package:grocery_store/models/category.dart';
// import 'package:grocery_store/models/product.dart';
// import 'package:grocery_store/screens/common_banner_products_screen.dart';
// import 'package:grocery_store/widget/product_list_item.dart';
// import 'package:grocery_store/widget/shimmer_all_category_item.dart';
// import 'package:grocery_store/widget/shimmer_banner_item.dart';
// import 'package:grocery_store/widget/shimmer_product_list_item.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shimmer/shimmer.dart';
// import '../models/banner.dart' as prefix;
//
// class SubCategoriesScreen extends StatefulWidget {
//   final List subCategories;
//   final int selectedCategory;
//   final String category;
//   final CartBloc cartBloc;
//   final User firebaseUser;
//
//   const SubCategoriesScreen({
//     this.subCategories,
//     this.selectedCategory,
//     this.category,
//     this.cartBloc,
//     this.firebaseUser,
//   });
//
//   @override
//   _SubCategoriesScreenState createState() => _SubCategoriesScreenState();
// }
//
// class _SubCategoriesScreenState extends State<SubCategoriesScreen>
//     with SingleTickerProviderStateMixin {
//   TabController _tabController;
//   List<Widget> tabs;
//   CategoryBloc categoryBloc;
//   List<Widget> tabViews;
//   CategoryProductsBloc categoryProductsBloc;
//   List<Product> productList;
//   BannerBloc bannerBloc;
//   prefix.Banner banner;
//   ProductBloc productBloc;
//   User currentUser;
//   CartBloc cartBloc;
//
//   bool first;
//   List<Category> categoryList;
//
//   List<Product> trendingProducts;
//   List<Product> featuredProducts;
//
//   @override
//   void initState() {
//     super.initState();
//     bannerBloc = BlocProvider.of<BannerBloc>(context);
//     bannerBloc.add(LoadBannersEvent());
//
//     categoryProductsBloc = BlocProvider.of<CategoryProductsBloc>(context);
//
//     print(widget.subCategories);
//
//     tabs = [];
//     tabViews = [];
//
//     _tabController =
//         TabController(length: widget.subCategories.length, vsync: this);
//
//     //TODO: 1) get all this category products
//     //TODO: 2) then categorize them into subcategories and add to specific tab views
//
//     categoryProductsBloc
//         .add(LoadCategoryProductsEvent(category: widget.category));
//
//     for (var subCategory in widget.subCategories) {
//       tabs.add(
//         Tab(
//           text: subCategory['subCategoryName'],
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('AGAIN BUILT');
//     Size size = MediaQuery.of(context).size;
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: <Widget>[
//             // Container(
//             //   padding: const EdgeInsets.only(bottom: 12.0),
//             //   decoration: BoxDecoration(
//             //     color: Colors.blue.withOpacity(0.06),
//             //     borderRadius: BorderRadius.only(
//             //       bottomLeft: Radius.circular(20.0),
//             //       bottomRight: Radius.circular(20.0),
//             //     ),
//             //   ),
//             //   child: Column(
//             //     children: <Widget>[
//             //       Container(
//             //         width: size.width,
//             //         decoration: BoxDecoration(
//             //           color: Theme.of(context).primaryColor,
//             //           borderRadius: BorderRadius.only(
//             //             bottomLeft: Radius.circular(20.0),
//             //             bottomRight: Radius.circular(20.0),
//             //           ),
//             //         ),
//             //         child: SafeArea(
//             //           bottom: false,
//             //           child: Padding(
//             //             padding: const EdgeInsets.only(
//             //                 left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
//             //             child: Row(
//             //               mainAxisAlignment: MainAxisAlignment.start,
//             //               crossAxisAlignment: CrossAxisAlignment.center,
//             //               mainAxisSize: MainAxisSize.max,
//             //               children: <Widget>[
//             //                 ClipRRect(
//             //                   borderRadius: BorderRadius.circular(50.0),
//             //                   child: Material(
//             //                     color: Colors.transparent,
//             //                     child: InkWell(
//             //                       splashColor: Colors.white.withOpacity(0.5),
//             //                       onTap: () {
//             //                         Navigator.pop(context);
//             //                       },
//             //                       child: Container(
//             //                         decoration: BoxDecoration(
//             //                           color: Colors.transparent,
//             //                         ),
//             //                         width: 38.0,
//             //                         height: 35.0,
//             //                         child: Icon(
//             //                           Icons.arrow_back,
//             //                           color: Colors.white,
//             //                           size: 24.0,
//             //                         ),
//             //                       ),
//             //                     ),
//             //                   ),
//             //                 ),
//             //                 SizedBox(
//             //                   width: 8.0,
//             //                 ),
//             //                 Text(
//             //                   widget.category,
//             //                   style: GoogleFonts.poppins(
//             //                     color: Colors.white,
//             //                     fontSize: 18.0,
//             //                     fontWeight: FontWeight.w600,
//             //                     letterSpacing: 0.3,
//             //                   ),
//             //                 ),
//             //               ],
//             //             ),
//             //           ),
//             //         ),
//             //       ),
//             //       SizedBox(
//             //         height: 12.0,
//             //       ),
//             //       Container(
//             //         height: 38.0,
//             //         padding: EdgeInsets.symmetric(horizontal: 16.0),
//             //         child: TabBar(
//             //           tabs: tabs,
//             //           controller: _tabController,
//             //           isScrollable: true,
//             //           indicatorSize: TabBarIndicatorSize.tab,
//             //           labelPadding: EdgeInsets.symmetric(horizontal: 25.0),
//             //           indicatorPadding: EdgeInsets.symmetric(horizontal: 10.0),
//             //           indicator: BoxDecoration(
//             //             color: Theme.of(context).primaryColor,
//             //             borderRadius: BorderRadius.circular(20.0),
//             //           ),
//             //           unselectedLabelStyle: GoogleFonts.poppins(
//             //             color: Colors.black87,
//             //             fontSize: 15.0,
//             //             fontWeight: FontWeight.w600,
//             //             letterSpacing: 0.3,
//             //           ),
//             //           unselectedLabelColor: Colors.black45,
//             //           labelColor: Colors.white,
//             //           labelStyle: GoogleFonts.poppins(
//             //             color: Colors.black87,
//             //             fontSize: 15.0,
//             //             fontWeight: FontWeight.w600,
//             //             letterSpacing: 0.3,
//             //           ),
//             //         ),
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             SizedBox(
//               height: 15,
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 15),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: Container(
//                       height: 32,
//                       width: 32,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(5),
//                           border: Border.all(color: Color(0xffE5E5E5))),
//                       child: Center(
//                           child: Icon(
//                         Icons.arrow_back,
//                         color: Colors.black,
//                       )),
//                     ),
//                   ),
//                   Text(
//                     'الاصناف',
//                     style: GoogleFonts.tajawal(
//                       color: Colors.black,
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.of(context)
//                           .pushReplacementNamed("/navicationscreen");
//                     },
//                     child: Container(
//                       height: 32,
//                       width: 32,
//                       decoration: BoxDecoration(
//                         color: Theme.of(context).primaryColor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       child: Center(
//                         child: Text(
//                           "+",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             buildBanner(1),
//             buildCategories(size),
//             Expanded(
//               child: BlocBuilder(
//                 cubit: categoryProductsBloc,
//                 builder: (context, state) {
//                   print('Category Products :: $state');
//                   if (state is LoadCategoryProductsInProgressState ||
//                       state is InitialCategoryProductsState) {
//                     return GridView.builder(
//                       physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         mainAxisSpacing: 16.0,
//                         childAspectRatio: 1 / 1.6,
//                         crossAxisSpacing: 16.0,
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       shrinkWrap: true,
//                       scrollDirection: Axis.vertical,
//                       itemCount: 8,
//                       itemBuilder: (context, index) {
//                         return Shimmer.fromColors(
//                           period: Duration(milliseconds: 800),
//                           baseColor: Colors.grey.withOpacity(0.5),
//                           highlightColor: Colors.black.withOpacity(0.5),
//                           child: ShimmerProductListItem(),
//                         );
//                       },
//                     );
//                   } else if (state is LoadCategoryProductsFailedState) {
//                     return Center(
//                       child: Text(
//                         'Failed to load products!',
//                         style: GoogleFonts.poppins(
//                           fontSize: 15.0,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     );
//                   } else if (state is LoadCategoryProductsCompletedState) {
//                     print('BUILD');
//                     print(state.productList.length);
//                     if (state.productList.length == 0) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.max,
//                         children: <Widget>[
//                           SvgPicture.asset(
//                             'assets/images/empty_prod.svg',
//                             width: size.width * 0.6,
//                           ),
//                           SizedBox(
//                             height: 15.0,
//                           ),
//                           Text(
//                             'No products in this category!',
//                             textAlign: TextAlign.center,
//                             overflow: TextOverflow.clip,
//                             style: GoogleFonts.poppins(
//                               color: Colors.black.withOpacity(0.7),
//                               fontSize: 14.5,
//                               fontWeight: FontWeight.w500,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                           SizedBox(
//                             height: 15.0,
//                           ),
//                         ],
//                       );
//                     }
//                     productList = state.productList;
//                     //categorize them
//
//                     int i = 0;
//                     tabViews = [];
//
//                     for (var subCategory in widget.subCategories) {
//                       List<Product> tempList = [];
//
//                       for (var item in productList) {
//                         if (item.subCategory.toLowerCase() ==
//                             subCategory['subCategoryName']
//                                 .toString()
//                                 .toLowerCase()) {
//                           tempList.add(item);
//                         }
//                       }
//
//                       if (tempList.length == 0) {
//                         tabViews.add(
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.max,
//                             children: <Widget>[
//                               SvgPicture.asset(
//                                 'assets/images/empty_prod.svg',
//                                 width: size.width * 0.6,
//                               ),
//                               SizedBox(
//                                 height: 15.0,
//                               ),
//                               Text(
//                                 'No products in this category!',
//                                 textAlign: TextAlign.center,
//                                 overflow: TextOverflow.clip,
//                                 style: GoogleFonts.poppins(
//                                   color: Colors.black.withOpacity(0.7),
//                                   fontSize: 14.5,
//                                   fontWeight: FontWeight.w500,
//                                   letterSpacing: 0.3,
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 15.0,
//                               ),
//                             ],
//                           ),
//                         );
//                       } else {
//
//                         tabViews.add(
//                           ListView.builder(
//                             padding:
//                                 const EdgeInsets.symmetric(horizontal: 16.0),
//                             itemCount: tempList.length,
//                             shrinkWrap: true,
//                             scrollDirection: Axis.vertical,
//                             itemBuilder: (context, index) {
//                               return Column(
//                                 children: [
//                                   index==0 ?Align(
//                                     alignment:Alignment.topRight,
//                                     child: Padding(
//                                       padding: const EdgeInsets.only(top:15.0,bottom: 0),
//                                       child: Text(" عدد الاطباق : ${tempList.length} ",style: GoogleFonts.tajawal(
//                                         fontSize: 20,
//                                       ),),
//                                     ),
//                                   ):SizedBox(),
//                                   ProductListItem(
//                                     product: tempList[index],
//                                     cartBloc: widget.cartBloc,
//                                     currentUser: widget.firebaseUser,
//                                   ),
//
//                                 ],
//                               );
//                             },
//                           ),
//                         );
//                       }
//                       i++;
//                     }
//
//                     return TabBarView(
//                       children: tabViews,
//                       controller: _tabController,
//                     );
//                   } else {
//                     return SizedBox();
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildBanner(int whichBanner) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: BlocBuilder(
//         cubit: bannerBloc,
//         buildWhen: (previous, current) {
//           if (current is LoadBannersInProgressState ||
//               current is LoadBannersFailedState ||
//               current is LoadBannersCompletedState) {
//             return true;
//           }
//           return false;
//         },
//         builder: (context, state) {
//           print('BANNER STATE :: $state');
//           if (state is LoadBannersInProgressState) {
//             return Container(
//               height: 160.0,
//               child: Shimmer.fromColors(
//                 period: Duration(milliseconds: 800),
//                 baseColor: Colors.grey.withOpacity(0.5),
//                 highlightColor: Colors.black.withOpacity(0.5),
//                 child: ShimmerBannerItem(),
//               ),
//             );
//           } else if (state is LoadBannersFailedState) {
//             return Container(
//               height: 160.0,
//               decoration: BoxDecoration(
//                 color: Colors.cyanAccent,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               child: Center(
//                 child: Text(
//                   'Failed to load image!',
//                   style: GoogleFonts.poppins(
//                     color: Colors.black87,
//                     fontSize: 14.0,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             );
//           } else if (state is LoadBannersCompletedState) {
//             banner = state.banner;
//             return Container(
//               height: 160.0,
//               decoration: BoxDecoration(
//                 color: whichBanner == 1
//                     ? Colors.cyanAccent
//                     : Colors.green.shade100,
//                 borderRadius: BorderRadius.circular(15.0),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15.0),
//                 child: whichBanner == 1
//                     ? GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CommonBannerProductsScreen(
//                                 cartBloc: cartBloc,
//                                 category: banner.middleBanner['category'],
//                                 currentUser: currentUser,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Image.network(
//                           banner.middleBanner['middleBanner'],
//                           fit: BoxFit.cover,
//                           frameBuilder:
//                               (context, child, frame, wasSynchronouslyLoaded) {
//                             if (wasSynchronouslyLoaded) {
//                               return child;
//                             }
//                             return AnimatedOpacity(
//                               child: child,
//                               opacity: frame == null ? 0 : 1,
//                               duration: const Duration(milliseconds: 500),
//                               curve: Curves.easeOut,
//                             );
//                           },
//                         ),
//                         // child: SvgPicture.network(
//                         //   banner.middleBanner['middleBanner'],
//                         //   fit: BoxFit.cover,
//                         //   placeholderBuilder: (context) => Shimmer.fromColors(
//                         //     period: Duration(milliseconds: 800),
//                         //     baseColor: Colors.grey.withOpacity(0.5),
//                         //     highlightColor: Colors.black.withOpacity(0.5),
//                         //     child: ShimmerBannerItem(),
//                         //   ),
//                         // ),
//                       )
//                     : GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => CommonBannerProductsScreen(
//                                 cartBloc: cartBloc,
//                                 category: banner.bottomBanner['category'],
//                                 currentUser: currentUser,
//                               ),
//                             ),
//                           );
//                         },
//                         child: Image.network(
//                           banner.bottomBanner['bottomBanner'],
//                           fit: BoxFit.cover,
//                           frameBuilder:
//                               (context, child, frame, wasSynchronouslyLoaded) {
//                             if (wasSynchronouslyLoaded) {
//                               return child;
//                             }
//                             return AnimatedOpacity(
//                               child: child,
//                               opacity: frame == null ? 0 : 1,
//                               duration: const Duration(milliseconds: 500),
//                               curve: Curves.easeOut,
//                             );
//                           },
//                         ),
//                         // child: SvgPicture.network(
//                         //   banner.bottomBanner['bottomBanner'],
//                         //   fit: BoxFit.cover,
//                         //   placeholderBuilder: (context) => Shimmer.fromColors(
//                         //     period: Duration(milliseconds: 800),
//                         //     baseColor: Colors.grey.withOpacity(0.5),
//                         //     highlightColor: Colors.black.withOpacity(0.5),
//                         //     child: ShimmerBannerItem(),
//                         //   ),
//                         // ),
//                       ),
//               ),
//             );
//           }
//           return SizedBox();
//         },
//       ),
//     );
//   }
//   var val=1;
//   Widget buildCategories(Size size) {
//     return BlocBuilder(
//       cubit: categoryBloc,
//       buildWhen: (previous, current) {
//         if (current is LoadCategoriesInProgressState ||
//             current is LoadCategoriesCompletedState ||
//             current is LoadCategoriesInFailedState) {
//           return true;
//         } else {
//           return false;
//         }
//       },
//       builder: (BuildContext context, state) {
//         if (state is LoadCategoriesInProgressState ||
//             state is CategoryInitialState) {
//           //getting categories
//           print('getting the categories');
//           return Container(
//             width: size.width,
//             height: size.width - size.width * 0.2 - 32.0,
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//             ),
//             child: ListView.builder(
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: 6,
//               itemBuilder: (context, index) {
//                 return Shimmer.fromColors(
//                   period: Duration(milliseconds: 800),
//                   baseColor: Colors.grey.withOpacity(0.5),
//                   highlightColor: Colors.black.withOpacity(0.5),
//                   child: ShimmerAllCategoryItem(),
//                 );
//               },
//             ),
//           );
//         } else if (state is LoadCategoriesInFailedState) {
//           //failed getting categories
//           print('failed to get the categories');
//           return Container(
//             width: size.width,
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: Center(
//               child: Text(
//                 'Faild to fetch!',
//                 style: GoogleFonts.poppins(
//                   color: Colors.black87,
//                   fontSize: 14.0,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         } else if (state is LoadCategoriesCompletedState) {
//           //getting categories completed
//           print(state.categories);
//           categoryList = state.categories;
//           return Container(
//             height: 60,
//             child: Align(
//               alignment: Alignment.topRight,
//               child: ListView.builder(
//                   itemCount: categoryList.length,
//                   scrollDirection: Axis.horizontal,
//                   shrinkWrap: true,
//                   itemBuilder: (context, index) {
//                     return GestureDetector(
//                       onTap: () {
//                         print('go to category');
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => Container(
//                               child: SubCategoriesScreen(
//                                 category: categoryList[index].categoryName,
//                                 subCategories:
//                                     categoryList[index].subCategories,
//                                 selectedCategory: index,
//                                 cartBloc: cartBloc,
//                                 firebaseUser: currentUser,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                       child: Row(
//                         children: [
//                           Padding(
//                             padding:
//                                 const EdgeInsets.only(top: 20.0, right: 10),
//                             child:Container(
//                               height: 60,
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 2),
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(25),
//                                 shape: BoxShape.rectangle,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(25),
//                                       child:
//                                           Image.asset("assets/icons/icon.jpg"),
//                                     ),
//                                   ),
//                                   SizedBox(width: 2,),
//                                   Text(
//                                     categoryList[index].categoryName,
//                                     overflow: TextOverflow.ellipsis,
//                                     maxLines: 2,
//                                     style: GoogleFonts.tajawal(
//                                       fontSize: 16,
//                                       color: Colors.black,
//                                       fontWeight: FontWeight.w500,
//                                       letterSpacing: 0.3,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           ),
//                         ],
//                       ),
//                     );
//                     //   AllCategoryItem(
//                     //   category: categoryList[index],
//                     //   index: index,
//                     //   cartBloc: cartBloc,
//                     //   firebaseUser: currentUser,
//                     //   num:number,
//                     // );
//                   }),
//             ),
//           );
//         }
//         return SizedBox();
//       },
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/category_bloc/category_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/category_products_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/models/category.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/screens/common_banner_products_screen.dart';
import 'package:grocery_store/widget/product_list_item.dart';
import 'package:grocery_store/widget/shimmer_all_category_item.dart';
import 'package:grocery_store/widget/shimmer_banner_item.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../ad_help.dart';
import '../models/banner.dart' as prefix;

class SubCategoriesScreen extends StatefulWidget {
  final List subCategories;
  final int selectedCategory;
  final String category;
  final CartBloc cartBloc;
  final User firebaseUser;

  const SubCategoriesScreen({
    this.subCategories,
    this.selectedCategory,
    this.category,
    this.cartBloc,
    this.firebaseUser,
  });

  @override
  _SubCategoriesScreenState createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Widget> tabs;
  CategoryBloc categoryBloc;
  List<Widget> tabViews;
  CategoryProductsBloc categoryProductsBloc;
  List<Product> productList;
  BannerBloc bannerBloc;
  prefix.Banner banner;
  ProductBloc productBloc;
  User currentUser;
  CartBloc cartBloc;

  bool first;
  List<Category> categoryList;

  List<Product> trendingProducts;
  List<Product> featuredProducts;
  int data;
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
  // Future getData() async {
  //   CollectionReference _reference =
  //   await FirebaseFirestore.instance.collection("Products");
  //   try {
  //     await _reference.get().then((value) {
  //       Model.clear();
  //       for (int i = 0; i < value.docs.length; i++) {
  //         setState(() {
  //           Model.add(ProductList.fromMap(value.docs[i].data()).uid);
  //         });
  //         print(Model.length);
  //       }
  //     });
  //   } catch (e) {
  //     print("the error $e");
  //   }
  // }
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
          ad.dispose();

          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    );
    _ad.load();
    // data = widget.selectedCategory;
    super.initState();
    bannerBloc = BlocProvider.of<BannerBloc>(context);
    bannerBloc.add(LoadBannersEvent());

    categoryProductsBloc = BlocProvider.of<CategoryProductsBloc>(context);

    print(widget.subCategories);

    tabs = [];
    tabViews = [];

    _tabController = TabController(
        length: widget.subCategories.length,
        vsync: this,
        initialIndex: widget.selectedCategory);

    //TODO: 1) get all this category products
    //TODO: 2) then categorize them into subcategories and add to specific tab views

    categoryProductsBloc
        .add(LoadCategoryProductsEvent(category: widget.category));

    for (var subCategory in widget.subCategories) {
      tabs.add(
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/sympgoney.jpg",
                    width: 23,
                    height: 23,
                    fit: BoxFit.cover,
                  )),
              SizedBox(
                width: 10,
              ),
              Tab(
                text: subCategory['subCategoryName'],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AGAIN BUILT');
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25), topRight: Radius.circular(25))),
            child: Column(
              children: <Widget>[
                // Container(
                //   padding: const EdgeInsets.only(bottom: 12.0),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.only(
                //       bottomLeft: Radius.circular(20.0),
                //       bottomRight: Radius.circular(20.0),
                //     ),
                //   ),
                //   child: Column(
                //     children: <Widget>[
                //       Container(
                //         width: size.width,
                //         decoration: BoxDecoration(
                //           color: Theme.of(context).primaryColor,
                //           borderRadius: BorderRadius.only(
                //             bottomLeft: Radius.circular(20.0),
                //             bottomRight: Radius.circular(20.0),
                //           ),
                //         ),
                //         child: SafeArea(
                //           bottom: false,
                //           child: Padding(
                //             padding: const EdgeInsets.only(
                //                 left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               crossAxisAlignment: CrossAxisAlignment.center,
                //               mainAxisSize: MainAxisSize.max,
                //               children: <Widget>[
                //                 ClipRRect(
                //                   borderRadius: BorderRadius.circular(50.0),
                //                   child: Material(
                //                     color: Colors.transparent,
                //                     child: InkWell(
                //                       splashColor: Colors.white.withOpacity(0.5),
                //                       onTap: () {
                //                         Navigator.pop(context);
                //                       },
                //                       child: Container(
                //                         decoration: BoxDecoration(
                //                           color: Colors.transparent,
                //                         ),
                //                         width: 38.0,
                //                         height: 35.0,
                //                         child: Icon(
                //                           Icons.arrow_back,
                //                           color: Colors.white,
                //                           size: 24.0,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                 ),
                //                 SizedBox(
                //                   width: 8.0,
                //                 ),
                //                 Text(
                //                   widget.category,
                //                   style: GoogleFonts.tajawal(
                //                     color: Colors.white,
                //                     fontSize: 18.0,
                //                     fontWeight: FontWeight.w600,
                //                     letterSpacing: 0.3,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       ),
                //       SizedBox(
                //         height: 12.0,
                //       ),
                //
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 80,
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
                // SizedBox(
                //   height: 20,
                // ),
                // buildBanner(1),
                // buildCategories(size),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 38.0,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: TabBar(
                    tabs: tabs,

                    controller: _tabController,
                    isScrollable: true,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.symmetric(horizontal: 25.0),
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 0.0),
                    indicator: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    unselectedLabelStyle: GoogleFonts.tajawal(
                      color: Colors.black87,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    unselectedLabelColor: Colors.black45,
                    labelColor: Colors.white,

                    labelStyle: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      // letterSpacing: 0.3,
                    ),
                    onTap: (val) {
                      setState(() {
                        data=val;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: BlocBuilder(
                    cubit: categoryProductsBloc,
                    builder: (context, state) {
                      print('Category Products :: $state');
                      if (state is LoadCategoryProductsInProgressState ||
                          state is InitialCategoryProductsState) {
                        return ListView.separated(
                          separatorBuilder: (ctx, index) => SizedBox(
                            height: 10,
                          ),
                          physics: NeverScrollableScrollPhysics(),
                          // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //   crossAxisCount: 1,
                          //   mainAxisSpacing: 16.0,
                          //   childAspectRatio: 1 / 1.6,
                          //   crossAxisSpacing: 16.0,
                          // ),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              period: Duration(milliseconds: 800),
                              baseColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.black.withOpacity(0.5),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, left: 5, right: 5),
                                child: Column(
                                  children: [
                                    index == 0
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 108,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(25)),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    index == 0
                                        ? SizedBox(
                                            height: 30,
                                          )
                                        : SizedBox(),
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(20),

                                      ),

                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is LoadCategoryProductsFailedState) {
                        return Center(
                          child: Text(
                            'Failed to load products!',
                            style: GoogleFonts.tajawal(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        );
                      } else if (state is LoadCategoryProductsCompletedState) {
                        print('BUILD');
                        print(state.productList.length);
                        if (state.productList.length == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              SvgPicture.asset(
                                'assets/images/empty_prod.svg',
                                width: size.width * 0.6,
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(
                                'No products in this category!',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.tajawal(
                                  color: Colors.black.withOpacity(0.7),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                            ],
                          );
                        }
                        productList = state.productList;
                        //categorize them
                        int i = 0;
                        tabViews = [];
                        for (var subCategory in widget.subCategories) {
                          List<Product> tempList = [];
                          for (var item in productList) {
                            if (item.subCategory.toLowerCase() ==
                                subCategory['subCategoryName']
                                    .toString()
                                    .toLowerCase()) {
                              tempList.add(item);
                            }
                          }
                          if (tempList.length == 0) {
                            tabViews.add(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Stack(
                                    children: [
                                      Opacity(
                                        opacity: 0.15,
                                        child: Image.asset(
                                          'assets/images/sympgoney.jpg',
                                          height: MediaQuery.of(context).size.height *
                                              0.5,
                                        ),
                                      ),
                                      // Positioned(
                                      //     bottom: 10,
                                      //     right: MediaQuery.of(context).size.width*0.18,
                                      //     child: Text(
                                      //       'عفوأ لا يوجد منتجات في هذة الفئة !',
                                      //       textAlign: TextAlign.center,
                                      //       overflow: TextOverflow.clip,
                                      //       style: GoogleFonts.tajawal(
                                      //         color: Colors.black.withOpacity(0.5),
                                      //         fontSize: 16.5,
                                      //         fontWeight: FontWeight.w600,
                                      //         letterSpacing: 0.3,
                                      //       ),
                                      //     ))
                                    ],
                                  ),
                                ],
                              ),
                            );
                          } else {
                            tabViews.add(
                              // AnimationLimiter(
                              //   child:
                                ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  itemCount: tempList.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return  Column(
                                    children: [
                                    index == 0
                                        ? Row(
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
                                          )
                                        : SizedBox(),
                                    index == 0
                                        ? SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(),
                                    index == 0
                                        ? Row(
                                            children: [
                                              Text("اختر المنتج للأضافة"),
                                            ],
                                          )
                                        : SizedBox(),
                                    index == 0
                                        ? SizedBox(
                                            height: 20,
                                          )
                                        : SizedBox(),
                                     SingleChildScrollView(
                                      child: ProductListItem(
                                        product: tempList[index],
                                        cartBloc: widget.cartBloc,
                                        currentUser: widget.firebaseUser,
                                        data: 5,
                                      ),
                                      // Column(
                                      //   children: [
                                      //     AnimationConfiguration
                                      //         .staggeredList(
                                      //     position: index,
                                      //     duration: const Duration(
                                      //     milliseconds: 2000),
                                      //     child: SlideAnimation(
                                      //     verticalOffset: 100.0,
                                      //     child: FadeInAnimation(
                                      //     child:
                                      //     ),
                                      //     ),
                                      //     ),
                                      //   ],
                                      // ),
                                    )],
                                    );
                                  },
                                ),
                              // ),
                            );
                          }
                          i++;
                        }
                        return TabBarView(
                          children: tabViews,
                          controller: _tabController,
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
         // Container(
        //   child: AdWidget(ad: _ad),
        //   width: _ad.size.width.toDouble(),
        //   // height: 72.0,
        //   alignment: Alignment.center,
        // ),
        // _isAdLoaded?  Column(
        //   children: [
        //     SizedBox(height: 10,),
        //     Center(
        //       child: Container(
        //         child: AdWidget(ad: _ad),
        //         width: _ad.size.width.toDouble(),
        //         height: 72.0,
        //         alignment: Alignment.center,
        //       ),
        //     ),
        //   ],
        // ):SizedBox(),
      ],
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
                  style: GoogleFonts.tajawal(
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

  var val = 1;

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
            height: size.width - size.width * 0.1 - 80.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.2),
                  highlightColor: Colors.black.withOpacity(0.2),
                  child: ShimmerAllCategoryItem(),
                );
              },
            ),
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
                style: GoogleFonts.tajawal(
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
          return Container(
            height: 60,
            child: Align(
              alignment: Alignment.topRight,
              child: ListView.builder(
                  itemCount: categoryList.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        print('go to category');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Container(
                              child: SubCategoriesScreen(
                                category: categoryList[index].categoryName,
                                subCategories:
                                    categoryList[index].subCategories,
                                selectedCategory: index,
                                cartBloc: cartBloc,
                                firebaseUser: currentUser,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                              padding:
                                  const EdgeInsets.only(top: 20.0, right: 10),
                              child: Container(
                                height: 60,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  shape: BoxShape.rectangle,
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.asset(
                                            "assets/icons/icon.jpg"),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    Text(
                                      categoryList[index].categoryName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    );
                    //   AllCategoryItem(
                    //   category: categoryList[index],
                    //   index: index,
                    //   cartBloc: cartBloc,
                    //   firebaseUser: currentUser,
                    //   num:number,
                    // );
                  }),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
// Widget buildCategories(Size size) {
//   return BlocBuilder(
//     cubit: categoryBloc,
//     buildWhen: (previous, current) {
//       if (current is LoadCategoriesInProgressState ||
//           current is LoadCategoriesCompletedState ||
//           current is LoadCategoriesInFailedState) {
//         return true;
//       } else {
//         return false;
//       }
//     },
//     builder: (BuildContext context, state) {
//       if (state is LoadCategoriesInProgressState ||
//           state is CategoryInitialState) {
//         //getting categories
//         print('getting the categories');
//         return Container(
//           width: size.width,
//           height: size.width - size.width * 0.2 - 32.0,
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ),
//           child: ListView.builder(
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: 6,
//             itemBuilder: (context, index) {
//               return Shimmer.fromColors(
//                 period: Duration(milliseconds: 800),
//                 baseColor: Colors.grey.withOpacity(0.5),
//                 highlightColor: Colors.black.withOpacity(0.5),
//                 child: ShimmerAllCategoryItem(),
//               );
//             },
//           ),
//         );
//       } else if (state is LoadCategoriesInFailedState) {
//         //failed getting categories
//         print('failed to get the categories');
//         return Container(
//           width: size.width,
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Center(
//             child: Text(
//               'Faild to fetch!',
//               style: GoogleFonts.tajawal(
//                 color: Colors.black87,
//                 fontSize: 14.0,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         );
//       } else if (state is LoadCategoriesCompletedState) {
//         //getting categories completed
//         print(state.categories);
//         categoryList = state.categories;
//     // return Column(
//     //   children: [
//     //     DefaultTabController(
//     //       length:categoryList.length ,
//     //       child: Container(
//     //         child: TabBar(
//     //           isScrollable: true,
//     //           tabs:categoryList.map((e) => Text("${e.categoryName}")).toList() ,
//     //         ),
//     //       ),
//     //     ),
//     //     TabBarView(children: [
//     //
//     //     ]);
//     //   ],
//     // );
//
//       }
//       return SizedBox();
//     },
//   );
// }
// child: Align(
// alignment: Alignment.topRight,
// child: ListView.builder(
// itemCount: categoryList.length,
// scrollDirection: Axis.horizontal,
// shrinkWrap: true,
// itemBuilder: (context, index) {
// return GestureDetector(
// onTap: () {
// print('go to category');
// Navigator.pushReplacement(
// context,
// MaterialPageRoute(
// builder: (context) => Container(
// child: SubCategoriesScreen(
// category: categoryList[index].categoryName,
// subCategories:
// categoryList[index].subCategories,
// selectedCategory: index,
// cartBloc: cartBloc,
// firebaseUser: currentUser,
// ),
// ),
// ),
// );
// },
// child: Row(
// children: [
// Padding(
// padding:
// const EdgeInsets.only(top: 20.0, right: 10),
// child:Container(
// height: 60,
// padding: EdgeInsets.symmetric(
// horizontal: 10, vertical: 2),
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(25),
// shape: BoxShape.rectangle,
// color: Theme.of(context).primaryColor,
// ),
// child: Row(
// children: [
// Container(
// child: ClipRRect(
// borderRadius: BorderRadius.circular(25),
// child:
// Image.asset("assets/icons/icon.jpg"),
// ),
// ),
// SizedBox(width: 2,),
// Text(
// categoryList[index].categoryName,
// overflow: TextOverflow.ellipsis,
// maxLines: 2,
// style: GoogleFonts.tajawal(
// fontSize: 16,
// color: Colors.black,
// fontWeight: FontWeight.w500,
// letterSpacing: 0.3,
// ),
// ),
// ],
// ),
// )
// ),
// ],
// ),
// );
// //   AllCategoryItem(
// //   category: categoryList[index],
// //   index: index,
// //   cartBloc: cartBloc,
// //   firebaseUser: currentUser,
// //   num:number,
// // );
// }),
// ),
// class
