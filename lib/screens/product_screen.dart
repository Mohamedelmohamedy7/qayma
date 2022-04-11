import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
import 'package:grocery_store/blocs/category_bloc/category_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/increment_view_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/post_question_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/rate_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/report_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/similar_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/wishlist_product_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/models/category.dart';
import 'package:grocery_store/models/product.dart';
import 'package:grocery_store/pages/successData.dart';
import 'package:grocery_store/screens/cart_screen.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/widget/post_question_dialog.dart';
import 'package:grocery_store/widget/processing_dialog.dart';

import 'package:grocery_store/widget/product_list_item.dart';
import 'package:grocery_store/widget/product_sku_dialog.dart';
import 'package:grocery_store/widget/question_answer_item.dart';
import 'package:grocery_store/widget/rate_product_dialog.dart';
import 'package:grocery_store/widget/report_product_dialog.dart';
import 'package:grocery_store/widget/review_item.dart';
import 'package:grocery_store/widget/shimmer_product_detail.dart';
import 'package:grocery_store/widget/shimmer_product_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';

import '../ad_help.dart';
import 'fullscreen_image_screen.dart';

class ProductScreen extends StatefulWidget {
  final String productId;
  var screenId;
  var initScreenId;

  ProductScreen({this.productId, this.screenId, this.initScreenId}) {
    adMOp();
  }

  BannerAd _ad;
  InterstitialAd _interstitialAd;
  bool isLoaded = false;
  BannerAd _bottomBannerAd;

  void adMOp() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: onloadMethod, onAdFailedToLoad: (_) {}));
  }

  @override
  _ProductScreenState createState() => _ProductScreenState();

  void onloadMethod(InterstitialAd ad) {
    _interstitialAd = ad;
  }
}

class _ProductScreenState extends State<ProductScreen> {
  ProductBloc productBloc;
  SimilarProductBloc similarProductBloc;
  CartBloc cartBloc;
  SigninBloc signinBloc;
  CartCountBloc cartCountBloc;
  User _currentUser;
  WishlistProductBloc wishlistProductBloc;
  IncrementViewBloc incrementViewBloc;
  ReportProductBloc reportProductBloc;
  String dataPrice;
  Product _product;
  List<Product> _similarProducts;
  int cartCount;
  List<Category> categoryList;
  var productIdSpecial;
  var addName;
  var addPrice;
  var addQuantity;
  var addDate;
  var subCategoryNameData;
  var addDate2;

  // var

  bool isReporting;

  double rating;
  String discount;

  PostQuestionBloc postQuestionBloc;
  RateProductBloc rateProductBloc;
  Sku _selectedSku;

  bool isPostingQuestion;
  bool isRatingProduct;
  bool checkRatingProduct;

  //////////////////////////////////////////
  var productImage;
  var payImage;

  //////////////////////////////////////////
  var productImageForUpload;
  var payImageForUpload;

  //////////////////////////////////////////
  var addProductImage;
  var addProductImageUpload;

  //////////////////////////////////////////
  var addPayImage;
  var addPayImageUpload;

  //////////////////////////////////////////

  var proPrice;
  var patDate;
  var patDateValue;
  List productImages = [];
  CategoryBloc categoryBloc;

  List<Product> wishlistProducts;

  @override
  void initState() {
    categoryBloc = BlocProvider.of<CategoryBloc>(context);

    categoryBloc.add(LoadCategories());
     super.initState();

    print('PRODUCT ID :: ${widget.productId}');

    isReporting = false;

    productBloc = BlocProvider.of<ProductBloc>(context);
    similarProductBloc = BlocProvider.of<SimilarProductBloc>(context);
    cartBloc = BlocProvider.of<CartBloc>(context);
    signinBloc = BlocProvider.of<SigninBloc>(context);
    cartCountBloc = BlocProvider.of<CartCountBloc>(context);
    wishlistProductBloc = BlocProvider.of<WishlistProductBloc>(context);
    incrementViewBloc = BlocProvider.of<IncrementViewBloc>(context);
    reportProductBloc = BlocProvider.of<ReportProductBloc>(context);

    productBloc.add(LoadProductEvent(widget.productId));
    signinBloc.add(GetCurrentUser());
    incrementViewBloc.add(IncrementViewEvent(widget.productId));
    discount = '0';

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
    wishlistProductBloc.add(InitializeWishlistEvent());

    wishlistProductBloc.listen((state) {
      if (state is LoadWishlistProductCompletedState) {
        wishlistProducts = state.productList;
        checkWishListProduct(wishlistProducts);
        print(wishListProduct);
        print(wishlistProducts.length);
      }
      if (state is AddToWishlistCompletedState) {
        // showWishlistSnack('تم الاضافة الي المفضلة', context);

      }
      if (state is RemoveFromWishlistCompletedState) {
        // showWishlistSnack('تم الحذف من المفضلة', context);

      }
    });
    // wishlistProductBloc.listen((state) {
    //   //TODO: add to wishlist and remove from wishlist
    //   // if (state is AddToWishlistCompletedState) {
    //   //   showSnack('Added to wishlist');
    //   //   // wishlistProductBloc.close();
    //   // }
    //   if (state is AddToWishlistFailedState) {
    //     showSnack('Failed adding to wishlist', context);
    //   }
    //   if(state is RemoveFromWishlistInProgressState){
    //     showWishlistSnack('تم الحذف من المفضلة', context);
    //
    //   }
    //   if (state is AddToWishlistInProgressState) {
    //     showWishlistSnack('تم الاضافة الي المفضلة', context);
    //   }
    // });

    reportProductBloc.listen((state) {
      print('REPORT BLOC: $state');

      if (state is ReportProductInProgressState) {
        //show updating dialog
        isReporting = true;
        Navigator.pop(context);
        showReportingProductDialog();
      }
      if (state is ReportProductFailedState) {
        //show failed dialog
        if (isReporting = false) {
          isReporting = false;
          Navigator.pop(context);
          showReportSnack('Failed to report the product!', 'FAILED', context);
        }
      }
      if (state is ReportProductCompletedState) {
        //show reported dialog
        if (isReporting) {
          isReporting = false;
          Navigator.pop(context);
          showReportSnack(
              'Reported the product successfully', 'REPORTED', context);
        }
      }
    });

    isPostingQuestion = false;
    checkRatingProduct = false;
    isRatingProduct = false;

    wishlistProductBloc = BlocProvider.of<WishlistProductBloc>(context);
    productBloc = BlocProvider.of<ProductBloc>(context);
    postQuestionBloc = BlocProvider.of<PostQuestionBloc>(context);
    rateProductBloc = BlocProvider.of<RateProductBloc>(context);

    wishlistProductBloc.listen((state) {
      if (state is AddToWishlistCompletedState) {
        print('Added to wishlist');
      }
      if (state is RemoveFromWishlistCompletedState) {
        print('remove to wishlist');
      }
    });

    postQuestionBloc.listen((state) {
      print('$state');

      if (state is PostQuestionInProgressState) {
        //show popup
        isPostingQuestion = true;
        Navigator.pop(context);
        showUpdatingDialog('Posting your question..\nPlease wait!');
      }
      if (state is PostQuestionFailedState) {
        //show failed popup
        if (isPostingQuestion) {
          Navigator.pop(context);
          showSnack('Failed to post question!', context);
          isPostingQuestion = false;
        }
      }
      if (state is PostQuestionCompletedState) {
        //show popup
        if (isPostingQuestion) {
          Navigator.pop(context);
          showPostedSnack('Posted your question!', context);
          isPostingQuestion = false;

          _product = null;

          productBloc.add(LoadProductEvent(widget.productId));
        }
      }
    });

    rateProductBloc.listen((state) {
      print('RATE PRODUCT BLOC :: $state');

      if (state is CheckRateProductInProgressState) {
        //show popup
        checkRatingProduct = true;
      }
      if (state is CheckRateProductFailedState) {
        //show failed popup
        if (checkRatingProduct) {
          showSnack('Failed to check!', context);
          checkRatingProduct = false;
        }
      }
      if (state is CheckRateProductCompletedState) {
        //show popup
        if (checkRatingProduct) {
          checkRatingProduct = false;

          if (state.result != null) {
            if (state.result == 'RATED') {
              //already rated
              showRateProductPopup(state.review, 'RATED');
            }
            if (state.result == 'NOT_RATED') {
              //not rated
              showRateProductPopup(state.review, 'NOT_RATED');
            }
            if (state.result == 'NOT_ORDERED') {
              //not ordered
              showSnack('You can\'t rate this product!', context);
            }
          } else {
            showSnack('You can\'t rate this product!', context);
          }
        }
      }

      if (state is RateProductInProgressState) {
        //show popup
        isRatingProduct = true;
        Navigator.pop(context);
        showUpdatingDialog('Posting your rating..\nPlease wait!');
      }
      if (state is RateProductFailedState) {
        //show failed popup
        if (isRatingProduct) {
          Navigator.pop(context);
          showSnack('Failed to post rating!', context);
          isRatingProduct = false;
        }
      }
      if (state is RateProductCompletedState) {
        //show popup
        if (isRatingProduct) {
          Navigator.pop(context);
          showPostedSnack('Posted your rating!', context);
          isRatingProduct = false;
          _product = null;

          productBloc.add(LoadProductEvent(widget.productId));
        }
      }
    });
  }

  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future cropProductImage(context) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery, maxWidth: double.infinity, maxHeight: 700);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 19.5, ratioY: 28),
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        maxHeight: 581,
        maxWidth: 1125,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());

      setState(() {
        productImage = croppedFile;
       });
      Flushbar(
        margin: const EdgeInsets.all(8.0),
        borderRadius: 8.0,
        backgroundColor: Colors.green.shade500,
        animationDuration: Duration(milliseconds: 300),
        flushbarPosition: FlushbarPosition.BOTTOM,
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
          'تم أضافة الصورة بنجاح ',
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

  futureProductScreen() async {
    cropProductImage(context).then((value) async {
      var uuid = Uuid().v4();
      Reference storageReference = firebaseStorage.ref().child('banners/$uuid');
      await storageReference.putFile(productImage);
      var url = await storageReference.getDownloadURL();
      setState(() {
        productImageForUpload = url;
      });

      //add to list
      // setState(() {
      //   subCategories
      //       .add({'subCategoryName': subCategoryName, 'imageData': url});
      // });
      // FirebaseFirestore db = await FirebaseFirestore.instance;
      // await db
      //     .collection("SideBanner")
      //     .doc('${FirebaseAuth.instance.currentUser.uid}')
      //     .set({
      //   'sideBanner': url,
      //   'Product': productName,
      // });
    });
  }

  Future addCropProductImage(context) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery, maxWidth: double.infinity, maxHeight: 700);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 19.5, ratioY: 28),
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        maxHeight: 581,
        maxWidth: 1125,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());

      setState(() {
        addProductImage = croppedFile;
       });

      Flushbar(
        margin: const EdgeInsets.all(8.0),
        borderRadius: 8.0,
        backgroundColor: Colors.green.shade500,
        animationDuration: Duration(milliseconds: 300),
        flushbarPosition: FlushbarPosition.BOTTOM,
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
          'تم أضافة الصورة بنجاح ',
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

  addFutureProductScreen() async {
    addCropProductImage(context).then((value) async {
      var uuid = Uuid().v4();
      Reference storageReference = firebaseStorage.ref().child('banners/$uuid');
      await storageReference.putFile(addProductImage);
      var url = await storageReference.getDownloadURL();
      setState(() {
        addProductImageUpload = url;
      });
      //add to list
      // setState(() {
      //   subCategories
      //       .add({'subCategoryName': subCategoryName, 'imageData': url});
      // });
      // FirebaseFirestore db = await FirebaseFirestore.instance;
      // await db
      //     .collection("SideBanner")
      //     .doc('${FirebaseAuth.instance.currentUser.uid}')
      //     .set({
      //   'sideBanner': url,
      //   'Product': productName,
      // });
    });
  }

  bool done = false;

  Future cropPayImage(context) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery, maxWidth: double.infinity, maxHeight: 700);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 19.5, ratioY: 28),
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        maxHeight: 581,
        maxWidth: 1125,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        payImage = croppedFile;
      });
      Flushbar(
        margin: const EdgeInsets.all(8.0),
        borderRadius: 8.0,
        backgroundColor: Colors.green.shade500,
        animationDuration: Duration(milliseconds: 300),
        flushbarPosition: FlushbarPosition.BOTTOM,
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
          'تم أضافة صورة الفاتورة بنجاح ',
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

  futurePayImage() async {
    cropPayImage(context).then((value) async {
      var uuid = Uuid().v4();
      Reference storageReference =
          firebaseStorage.ref().child('Products/$uuid');
      await storageReference.putFile(payImage);
      var url = await storageReference.getDownloadURL();
      setState(() {
        payImageForUpload = url;
      });

      //add to list
      // setState(() {
      //   subCategories
      //       .add({'subCategoryName': subCategoryName, 'imageData': url});
      // });
      // FirebaseFirestore db = await FirebaseFirestore.instance;
      // await db
      //     .collection("SideBanner")
      //     .doc('${FirebaseAuth.instance.currentUser.uid}')
      //     .set({
      //   'sideBanner': url,
      //   'Product': productName,
      // });
    });
  }

  Future addCropPayImage(context) async {
    var image = await ImagePicker().getImage(
        source: ImageSource.gallery, maxWidth: double.infinity, maxHeight: 700);
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 19.5, ratioY: 28),
        cropStyle: CropStyle.rectangle,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        maxHeight: 581,
        maxWidth: 1125,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          showCropGrid: false,
          lockAspectRatio: true,
          statusBarColor: Theme.of(context).primaryColor,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ));

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        addPayImage = croppedFile;
      });
      Flushbar(
        margin: const EdgeInsets.all(8.0),
        borderRadius: 8.0,
        backgroundColor: Colors.green.shade500,
        animationDuration: Duration(milliseconds: 300),
        flushbarPosition: FlushbarPosition.BOTTOM,
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
          'تم أضافة صورة الفاتورة بنجاح ',
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

  addfuturePayImage() async {
    addCropPayImage(context).then((value) async {
      var uuiddata = Uuid().v4();
      Reference storageReference =
          firebaseStorage.ref().child('Products/$uuiddata');
      await storageReference.putFile(addPayImage);
      var url = await storageReference.getDownloadURL();
      setState(() {
        addPayImageUpload = url;
      });
      //add to list
      // setState(() {
      //   subCategories
      //       .add({'subCategoryName': subCategoryName, 'imageData': url});
      // });
      // FirebaseFirestore db = await FirebaseFirestore.instance;
      // await db
      //     .collection("SideBanner")
      //     .doc('${FirebaseAuth.instance.currentUser.uid}')
      //     .set({
      //   'sideBanner': url,
      //   'Product': productName,
      // });
    });
  }

  checkWishListProduct(List<Product> list) {
    for (var product in list) {
      if (product.id == _product.id) {
        setState(() {
          wishListProduct = true;
        });
        print(wishListProduct);
      }
    }
  }

  void addToCart() {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/sign_in');
      return;
    }

    print('adding to cart');
    if (_currentUser.uid != null) {
      if (_selectedSku.quantity > 0) {
        // if(dataName!=null ||_selectedSku!=null) {
          if(proPrice !=null) {
            // if (_selectedSku.quantity != 1) {
            //   showReportSnack('Only 1 quantity left', 'FAILED', context);
            // }
            cartBloc.add(
              AddToCartEvent(
                {
                  'productId': widget.productId,
                  'sku': _selectedSku,
                  'skuId': _selectedSku.skuId,
                  'quantity': _selectedSku.quantity,
                  'skuName': dataName == null ? _selectedSku.skuName : dataName,
                  "payImageForUpload": payImageForUpload,
                  "productImageForUpload": productImageForUpload,
                  "priceDate": proPrice,
                  "DateOfProduct": patDate
                },
              ),
            );
            setState(() {
              if (widget.screenId == 5) {
                print('Wishlist');
                FirebaseAuth.instance.currentUser == null
                    ? Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignInScreen()))
                    : wishlistProductBloc.add(RemoveFromWishlistEvent(
                  _product.id,
                  FirebaseAuth.instance.currentUser.uid,
                ));
                setState(() {
                  wishListProduct = false;
                });
              }
            });
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
                'تم أضافة المنتج الي المشتريات',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: Colors.white,
                ),
              ),
            )
              ..show(context);
            // widget._interstitialAd.show();

            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => SuccessData()));

          }
          else{
            showReportSnack('برجاء ادخال السعر', 'FAILED', context);
          }
        //   showReportSnack('برجاء ادخال الكمية', 'FAILED', context);
        //
        // }
      } else {
        showReportSnack('Product is Out of stock!', 'FAILED', context);
      }
    } else {
      //not logged in

    }
  }

    addToCartSpecial() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/sign_in');
      return;
    }
    final FirebaseFirestore db = FirebaseFirestore.instance;

    print('adding to cart');
    if (_currentUser.uid != null) {
      // if (_selectedSku.quantity > 0) {
      // if (_selectedSku.quantity != 1) {
      //   showReportSnack('Only 1 quantity left', 'FAILED', context);
      // }

      cartBloc.add(
        AddToCartEvent(
          {
            'productId': productIdSpecial,
            'sku': _selectedSku,
            'skuId': productIdSpecial.toString() +
                addName.toString() +
                addDate2.toString() +
                addPrice.toString(),
            'quantity': "1",
            'skuName': addQuantity,
            "payImageForUpload": addPayImageUpload,
            "productImageForUpload": addProductImageUpload,
            "priceDate": addPrice,
            "DateOfProduct": addDate2
          },
        ),
      );

      // widget._interstitialAd.show();
      Flushbar(
        margin: const EdgeInsets.all(8.0),
        borderRadius: 8.0,
        backgroundColor:
        Colors.green.shade500,
        animationDuration:
        Duration(milliseconds: 300),
        flushbarPosition:
        FlushbarPosition.TOP,
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
        duration:
        Duration(milliseconds: 2000),
        icon: Icon(
          Icons.cloud_done,
          color: Colors.white,
        ),
        messageText: Text(
          'تم أضافة المنتج الي المشتريات',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
      )..show(context);
      // setState(() {});
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  SuccessData()));
      // } else {
      //   showReportSnack('Product is Out of stock!', 'FAILED', context);
      // }
    } else {
      //not logged in

    }
  }

  addProductSpecial() async {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.pushNamed(context, '/sign_in');
      return;
    }
    final FirebaseFirestore db = FirebaseFirestore.instance;

    print('adding to cart');
    if (_currentUser.uid != null) {
      // if (_selectedSku.quantity != 1) {
      //   showReportSnack('Only 1 quantity left', 'FAILED', context);
      // }
      DocumentSnapshot productCounterDoc =
          await db.doc("AdminInfo/productIdCounter").get();

      String productPrefix = productCounterDoc.data()['prefix'];
      String productIdCounter = productCounterDoc.data()['productIdCounter'];
      productIdCounter = (int.parse(productIdCounter) +
              150 +
              int.parse(addPrice) +
              int.parse(addQuantity))
          .toString()
          .padLeft(productIdCounter.length, '0');
      String productId = productPrefix + productIdCounter;
      setState(() {
        productIdSpecial = productId;
      });
      db.collection(Paths.productsPath).doc(productId).set({
        'additionalInfo': {
          'bestBefore': "",
          'brand': "",
          'manufactureDate': "",
          'shelfLife': "",
        },
        'category': "جميع الفئات",
        'description': "",
        'featured': "",
        'id': productId,
        'inStock': "",
        'isListed': "",
        'name': addName,
        // 'ogPrice': product['ogPrice'],
        // 'price': product['price'],
        'productImages': addProductImageUpload,
        // 'quantity': product['quantity'],
        'queAndAns': {},
        'reviews': {},
        'skus': {
          "${productId + addName.toString() + addDate2.toString() + addPrice.toString()}":
              {
            "quantity": "78787878787",
            "skuId":
                "${productId + addName.toString() + addDate2.toString() + addPrice.toString()}",
            "skuName": "1",
            "skuPrice": "1"
          }
        },
        'isDiscounted': "",
        'discount': "",
        'subCategory': subCategoryNameData,
        'timestamp': Timestamp.now(),
        'trending': "false",
        // 'unitQuantity': product['unitQuantity'],
        'views': 0,
      }).then((value) {
        Flushbar(
          margin: const EdgeInsets.all(8.0),
          borderRadius: 8.0,
          backgroundColor: Colors.green.shade500,
          animationDuration:
          Duration(milliseconds: 300),
          flushbarPosition:
          FlushbarPosition.BOTTOM,
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
            'تم أضافة المنتج بنجاح\n يمكنك الاضافة الان الي المشتريات',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
        )..show(context);
        setState(() {
          done = true;
        });
      });
    } else {
      //not logged in

    }
  }

  void showReportingProductDialog() {
    showDialog(
      builder: (context) => AlertDialog(
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Reporting the product',
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

  Future showReportProductPopup() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ReportProductDialog(
          productId: widget.productId,
          reportProductBloc: reportProductBloc,
          uid: _currentUser.uid,
        );
      },
    );
  }

  showUpdatingDialog(String s) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: s,
        );
      },
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
      duration: Duration(milliseconds: 2000),
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

  void showPostedSnack(String text, BuildContext context) {
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
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.done,
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

  Future showPostQuestionPopup() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PostQuestionDialog(
          postQuestionBloc,
          FirebaseAuth.instance.currentUser.uid,
          widget.productId,
        );
      },
    );
  }

  Future showRateProductPopup(Review review, String result) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return RateProductDialog(
          rateProductBloc,
          FirebaseAuth.instance.currentUser.uid,
          widget.productId,
          review,
          result,
          _product,
        );
      },
    );
  }

  var dataName;

  Future<void> _createDynamicLink(bool short) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: Config().urlPrefix,
      link: Uri.parse('${Config().urlPrefix}/${widget.productId}'),
      androidParameters: AndroidParameters(
        packageName: Config().packageName,
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.google.FirebaseCppDynamicLinksTestApp.dev',
        minimumVersion: '0',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: _product.name,
        imageUrl: Uri.parse(_product.productImages[0]),
        description: 'Check out this amazing product',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
    } else {
      url = await parameters.buildUrl();
    }

    await FlutterShare.share(
      title: 'Checkout this product',
      text: '${_product.name}',
      linkUrl: url.toString(),
      chooserTitle: 'Share to apps',
    );
  }

  bool wishListProduct = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // appBar: AppBar(
    //   backgroundColor: Colors.white,
    //   elevation: 0,
    //   actions: <Widget>[
    //     // GestureDetector(
    //     //   onTap: () {
    //     //     Navigator.push(
    //     //         context,
    //     //         MaterialPageRoute(
    //     //           builder: (context) => SearchPage(),
    //     //         ));
    //     //   },
    //     //   child: Icon(
    //     //     Icons.search,
    //     //     size: 25.0,
    //     //   ),
    //     // ),
    //     // SizedBox(
    //     //   width: 5,
    //     // ),
    //     // ClipRRect(
    //     //   borderRadius: BorderRadius.circular(8.0),
    //     //   child: InkWell(
    //     //     splashColor: Colors.blue.withOpacity(0.5),
    //     //     onTap: () {
    //     //       print('Wishlist');
    //     //       FirebaseAuth.instance.currentUser == null
    //     //           ? Navigator.of(context).push(
    //     //           MaterialPageRoute(builder: (context) => SignInScreen())):
    //     //             wishlistProductBloc.add(AddToWishlistEvent(
    //     //         _product.id,
    //     //         FirebaseAuth.instance.currentUser.uid,
    //     //       ));
    //     //     },
    //     //     child: Container(
    //     //       width: 38.0,
    //     //       height: 35.0,
    //     //       decoration: BoxDecoration(
    //     //         // color:
    //     //         // Colors.black.withOpacity(0.04),
    //     //         borderRadius: BorderRadius.circular(8.0),
    //     //       ),
    //     //       child: Icon(
    //     //         Icons.favorite_border,
    //     //         color: Colors.black.withOpacity(0.5),
    //     //         size: 26.0,
    //     //       ),
    //     //     ),
    //     //   ),
    //     // ),
    //     SizedBox(
    //       width: 16.0,
    //     ),
    //
    //     // Padding(
    //     //   padding: const EdgeInsets.only(left: 10.0),
    //     //   child: PopupMenuButton(
    //     //     offset: Offset(0, 50.0),
    //     //     shape: RoundedRectangleBorder(
    //     //       borderRadius: BorderRadius.circular(8.0),
    //     //     ),
    //     //     child: Icon(Icons.more_vert),
    //     //     onSelected: (value) {
    //     //       if (value == 1) {
    //     //         showReportProductPopup();
    //     //       }
    //     //     },
    //     //     itemBuilder: (context) => [
    //     //       PopupMenuItem(
    //     //         value: 1,
    //     //         child: Row(
    //     //           children: <Widget>[
    //     //             Icon(
    //     //               Icons.report,
    //     //               color: Colors.red,
    //     //             ),
    //     //             SizedBox(
    //     //               width: 8.0,
    //     //             ),
    //     //             Text(
    //     //               'Report product',
    //     //               style: TextStyle(
    //     //                 color: Colors.black87,
    //     //                 fontSize: 14.0,
    //     //                 fontWeight: FontWeight.w500,
    //     //               ),
    //     //             ),
    //     //           ],
    //     //         ),
    //     //       ),
    //     //     ],
    //     //   ),
    //     // ),
    //
    //   ],
    // ),
    return widget.initScreenId == 4
        ? Container(
            color: Colors.transparent,
            //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(25.0),
                        topRight: const Radius.circular(25.0))),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "أضافة منتج جديد",
                              style: TextStyle(
                                fontSize: 18.0,
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
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              "قم باختيار الفئة",
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 0.3,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      BlocBuilder(
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
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 4 / 5,
                                  mainAxisSpacing: 15.0,
                                  crossAxisSpacing: 15.0,
                                ),
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  return Shimmer.fromColors(
                                    period: Duration(milliseconds: 800),
                                    baseColor: Colors.grey.withOpacity(0.5),
                                    highlightColor:
                                        Colors.black.withOpacity(0.5),
                                  );
                                },
                              ),
                            );
                          } else if (state is LoadCategoriesInFailedState) {
                            //failed getting categories
                            print('failed to get the categories');
                            return Container(
                              width: size.width,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                            var s = 0;
                            for (int i = 0; i < categoryList.length; i++) {
                              model.add(categoryList[i].subCategories);
                              return AnimationLimiter(
                                child: Container(
                                  height: 120,
                                  child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return AnimationConfiguration
                                            .staggeredList(
                                                position: index,
                                                duration: const Duration(
                                                    milliseconds: 1800),
                                                child: SlideAnimation(
                                                    horizontalOffset: 80.0,
                                                    // verticalOffset: ,
                                                    child: FadeInAnimation(
                                                        child: TextButton(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            35),
                                                                child: FadeInImage
                                                                    .assetNetwork(
                                                                  width: 70,
                                                                  height: 70,
                                                                  placeholder:
                                                                      'assets/images/sympgoney.jpg',
                                                                  image: categoryList[0]
                                                                              .subCategories[
                                                                          index]
                                                                      [
                                                                      "imageData"],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  // fadeInDuration: Duration(milliseconds: 1),
                                                                  // fadeInCurve: Curves.easeInOut,
                                                                  // fadeOutDuration: Duration(milliseconds: 1),
                                                                  // fadeOutCurve: Curves.easeInOut,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                  "${categoryList[0].subCategories[index]["subCategoryName"]}",
                                                                  style: TextStyle(
                                                                      color: subCategoryNameData ==
                                                                              categoryList[0].subCategories[index][
                                                                                  "subCategoryName"]
                                                                          ? Theme.of(context)
                                                                              .primaryColor
                                                                          : Colors
                                                                              .black,
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          subCategoryNameData =
                                                              categoryList[0]
                                                                          .subCategories[
                                                                      index][
                                                                  "subCategoryName"];
                                                        });
                                                      },
                                                    ))));
                                      },
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            width: 12,
                                          ),
                                      itemCount:
                                          categoryList[0].subCategories.length),
                                ),
                              );
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
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            addProductImage == null
                                ? Container(
                                    width: 150,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: TextButton(
                                      child: Text(
                                        "اضافة صورة",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w100),
                                      ),
                                      onPressed: () {
                                        addFutureProductScreen();
                                        setState(() {});
                                      },
                                    ),
                                  )
                                : Image.file(
                                    addProductImage,
                                    width: 160,
                                    height: 180,
                                  ),
                            addPayImage == null
                                ? Container(
                                    width: 150,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: TextButton(
                                      child: Text(
                                        "صورة الفاتورة",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w100),
                                      ),
                                      onPressed: () {
                                        // futureProductScreen();
                                        addfuturePayImage();
                                        setState(() {});
                                      },
                                    ),
                                  )
                                : Image.file(
                                    addPayImage,
                                    width: 160,
                                    height: 180,
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 14, top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "اسم المنتج :",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  disabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  hintText: 'ادخل أسم المنتج',
                                  hintStyle: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    addName = val;
                                  });
                                },
                                onSaved: (String value) {
                                  setState(() {
                                    addName = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      /////////////////////////
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 14, top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "سعر المنتج :",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  disabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  hintText: 'ادخل سعر المنتج',
                                  hintStyle: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    addPrice = val;
                                  });
                                },
                                onSaved: (String value) {
                                  setState(() {
                                    addPrice = value;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      /////////////////////////
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 14, top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "كمية المنتج :",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  focusedBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Theme.of(context).accentColor,
                                    ),
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  disabledBorder: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                    borderSide: new BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  hintText: 'ادخل كمية المنتج',
                                  hintStyle: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    addQuantity = val;
                                  });
                                },
                                onSaved: (String value) {
                                  setState(() {
                                    addQuantity = value;
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),

                      /////////////////////////

                      TextButton(
                        onPressed: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(2000, 1, 1),
                              maxTime: DateTime.now(),
                              theme: DatePickerTheme(
                                  headerColor: Colors.grey.shade200,
                                  cancelStyle: TextStyle(color: Colors.black),
                                  itemStyle: TextStyle(color: Colors.white),
                                  doneStyle: TextStyle(color: Colors.black),
                                  backgroundColor: Colors.black),
                              onChanged: (date) {
                            setState(() {
                              DateFormat formatter = DateFormat('yyyy-MM-dd');
                              addDate = formatter.format(date);
                            });
                          }, onConfirm: (date) {
                            setState(() {
                              addDate2 = addDate;
                            });
                          },
                              currentTime:
                                  DateTime.now().subtract(Duration(days: 720)),
                              locale: LocaleType.ar);
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              addDate2 == null
                                  ? Text(
                                      'ادخل توقيت شراء هذة المنتج',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500),
                                    )
                                  : Text(
                                      'وقت الشراء',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                    ),
                              addDate2 == null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, left: 20),
                                      child: Text(
                                        'تغيير',
                                        style: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            letterSpacing: 0.8),
                                      ),
                                    )
                                  : Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, left: 15),                                    child: Text(
                                        "${addDate2}",
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  )
                            ]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Center(
                                    child: TextButton(
                                  onPressed: () {
                                    if (
                                        // addProductImageUpload == null ||
                                        addName == null ||
                                        addPrice == null ||
                                        addQuantity == null ||
                                        subCategoryNameData == null ||
                                        addDate2 == null) {
                                      Flushbar(
                                        margin: const EdgeInsets.all(8.0),
                                        borderRadius: 8.0,
                                        backgroundColor: Colors.red.shade500,
                                        animationDuration:
                                            Duration(milliseconds: 300),
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
                                          'برجاء اكمال جميع البيانات',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )..show(context);
                                    } else {
                                      if (addDate == null) {
                                        Flushbar(
                                          margin: const EdgeInsets.all(8.0),
                                          borderRadius: 8.0,
                                          backgroundColor: Colors.red.shade500,
                                          animationDuration:
                                          Duration(milliseconds: 300),
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
                                            'من فضلك قم بأضافة تاريخ الشراء',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )..show(context);
                                      } else {
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
                                                  'تنبية !',
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
                                                  'لن يتم اضافة المنتج الي قاعدة البيانات اذا لم يتم اضافتة الي قائمة مشترياتك ...!',
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
                                                Padding(padding: EdgeInsets.symmetric(horizontal: 15),child: Divider(),),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'هل انت متأكد من الاضافة ؟ ',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 0.3,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
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
                                                          addProductSpecial();
                                                          setState(() {});
                                                          Navigator.of(context).pop();
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
                                      }
                                    }
                                  },
                                  child: Text(
                                    "اضافة المنتج",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                )),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                padding: EdgeInsets.all(6),
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Center(
                                    child: TextButton(
                                  onPressed: () {
                                    if (
                                    // addPayImageUpload == null ||
                                    //     addProductImageUpload == null ||
                                        addName == null ||
                                        addPrice == null ||
                                        addQuantity == null ||
                                        addDate == null ||
                                        subCategoryNameData == null ||
                                        addDate2 == null) {
                                      Flushbar(
                                        margin: const EdgeInsets.all(8.0),
                                        borderRadius: 8.0,
                                        backgroundColor: Colors.red.shade500,
                                        animationDuration:
                                            Duration(milliseconds: 300),
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
                                          'برجاء اكمال جميع البيانات',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )..show(context);
                                    } else {
                                      if (done == false) {
                                        Flushbar(
                                          margin: const EdgeInsets.all(8.0),
                                          borderRadius: 8.0,
                                          backgroundColor: Colors.red.shade500,
                                          animationDuration:
                                              Duration(milliseconds: 300),
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
                                          duration:
                                              Duration(milliseconds: 2000),
                                          icon: Icon(
                                            Icons.error,
                                            color: Colors.white,
                                          ),
                                          messageText: Text(
                                            'من فضلك قم بأضافة المنتج أولاً',
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )..show(context);
                                      }
                                      else {
                                        addToCartSpecial();
setState(() {

});
                                      }
                                    }
                                  },
                                  child: Text(
                                    "الأضافة الي المشتريات",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      WidgetsBinding
                          .instance
                          .window
                          .viewInsets
                          .bottom >
                          0.0?SizedBox(height: 300,):SizedBox()
                    ],
                  ),
                )),
          )
        : Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25))),
            child: Stack(
              children: <Widget>[
                ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    BlocBuilder(
                      cubit: productBloc,
                      buildWhen: (previous, current) {
                        if (current is LoadProductCompletedState ||
                            current is LoadProductFailedState ||
                            current is LoadProductInProgressState) {
                          return true;
                        } else {
                          return false;
                        }
                      },
                      builder: (context, state) {
                        print('ProductEvent State: $state');
                        if (state is ProductInitial) {
                          return SizedBox();
                        } else if (state is LoadProductInProgressState) {
                          print("///////////////////////");
                          return Shimmer.fromColors(
                            period: Duration(milliseconds: 1000),
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.black.withOpacity(0.5),
                            child: ShimmerProductDetail(),
                          );
                        } else if (state is LoadProductFailedState) {
                          return Column(
                            children: <Widget>[
                              SizedBox(
                                height: 15.0,
                              ),
                              SvgPicture.asset(
                                'assets/banners/retry.svg',
                                height: 150.0,
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                              Container(
                                height: 75.0,
                                width: size.width * 0.7,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                child: FlatButton(
                                  onPressed: () {
                                    //TODO: fix this
                                    // productBloc.add(LoadSimilarProductsEvent(
                                    //     category: 'Fruits & Vegetables',
                                    //     subCategory: 'Fruits'));
                                    // productBloc
                                    //     .add(LoadProductEvent(widget.productId));
                                  },
                                  color: Colors.lightGreen,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.rotate_right,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 15.0,
                                      ),
                                      Text(
                                        'Retry loading',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (state is LoadProductCompletedState) {
                          if (state.product.id != widget.productId) {
                            return SizedBox();
                          }
                          if (_product == null) {
                            _product = state.product;

                            _selectedSku = _product.skus[0];
                            // discount = ((1 -
                            //             (int.parse(_selectedSku.skuPrice) /
                            //                 (int.parse(_selectedSku.skuMrp)))) *
                            //         100)
                            //     .round()
                            //     .toString();
                            rating = 0;

                            if (_product.reviews.length == 0) {
                            } else {
                              if (_product.reviews.length > 0) {
                                for (var review in _product.reviews) {
                                  rating = rating + double.parse(review.rating);
                                }
                                rating = rating / _product.reviews.length;
                              }
                            }

                            if (_product.productImages.length == 0) {
                              productImages.add(
                                Center(
                                  child: Text(
                                    'No product image available',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              for (var item in _product.productImages) {
                                productImages.add(
                                  Center(
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                          'assets/icons/category_placeholder.png',
                                      image: item,
                                      fadeInDuration:
                                          Duration(milliseconds: 250),
                                      fadeInCurve: Curves.easeInOut,
                                      fit: BoxFit.fill,
                                      fadeOutDuration:
                                          Duration(milliseconds: 150),
                                      fadeOutCurve: Curves.easeInOut,
                                    ),
                                  ),
                                );
                              }
                            }
                            similarProductBloc.add(
                              LoadSimilarProductsEvent(
                                category: _product.category,
                                subCategory: _product.subCategory,
                                productId: _product.id,
                              ),
                            );
                          }
                          return Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Container(
                              //   height: MediaQuery.of(context).size.height * 0.5,
                              //   // color: Colors.red,
                              //   width: MediaQuery.of(context).size.width,
                              //   child: Stack(
                              //     children: <Widget>[
                              //       // Positioned(
                              //       //   top: 0,
                              //       //   child: Container(
                              //       //     height: 180.0,
                              //       //     padding: const EdgeInsets.only(
                              //       //         bottom: 20.0,
                              //       //         left: 16.0,
                              //       //         right: 16.0,
                              //       //         top: 10.0),
                              //       //     width: size.width,
                              //       //     decoration: BoxDecoration(
                              //       //       color: Theme.of(context).primaryColor,
                              //       //       borderRadius: BorderRadius.only(
                              //       //         bottomLeft: Radius.circular(25.0),
                              //       //         bottomRight: Radius.circular(25.0),
                              //       //       ),
                              //       //     ),
                              //       //   ),
                              //       // ),
                              //       ClipRRect(
                              //         borderRadius: BorderRadius.circular(15.0),
                              //         child: Carousel(
                              //           images: productImages,
                              //           dotSize: 4.0,
                              //           dotSpacing: 15.0,
                              //           dotColor: Colors.lightGreenAccent,
                              //           dotIncreasedColor: Colors.amber,
                              //           autoplayDuration:
                              //               Duration(milliseconds: 3000),
                              //           autoplay: false,
                              //           showIndicator: true,
                              //           indicatorBgPadding: 5.0,
                              //           dotBgColor: Colors.transparent,
                              //           borderRadius: false,
                              //           animationDuration:
                              //               Duration(milliseconds: 450),
                              //           animationCurve: Curves.easeInOut,
                              //           boxFit: BoxFit.contain,
                              //           dotVerticalPadding: 5.0,
                              //           dotPosition: DotPosition.bottomCenter,
                              //           noRadiusForIndicator: true,
                              //           onImageTap: (index) {
                              //             print('Tapped: $index');
                              //             Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                 builder: (context) =>
                              //                     FullScreenImageScreen(
                              //                   images: _product.productImages,
                              //                 ),
                              //               ),
                              //             );
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 20.0,
                              // ),

                              Padding(
                                padding: EdgeInsets.only(right: 20, left: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width:160,
                                      child: Text(
                                        "${_product.name}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    wishListProduct == false
                                        ? wishListIcon()
                                        : removewishListIcon(),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            //padding: EdgeInsets.all(10),
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            // color: Colors.blue,
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/images/sympgoney.jpg',
                                              image: _product.productImages[0],
                                              fit: BoxFit.cover,
                                              // fadeInDuration: Duration(milliseconds: 1),
                                              // fadeInCurve: Curves.easeInOut,
                                              // fadeOutDuration: Duration(milliseconds: 1),
                                              // fadeOutCurve: Curves.easeInOut,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              width:160,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: Text(
                                                  _product.name,
                                                  overflow: TextOverflow.clip,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black
                                                        .withOpacity(0.75),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: Text(
                                                _product.subCategory,
                                                overflow: TextOverflow.clip,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey
                                                      .withOpacity(0.75),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: TextButton(
                                        child: Text(
                                          "تغيير",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    )
                                    // Text(
                                    //   _product.isDiscounted
                                    //       ? '${((1 - (_product.discount / 100)) * double.parse(_selectedSku.skuPrice)).toStringAsFixed(2)}${Config().currency}'
                                    //       : '${double.parse(_selectedSku.skuPrice).toStringAsFixed(2)}${Config().currency}',
                                    //   overflow: TextOverflow.clip,
                                    //   style: TextStyle(
                                    //     fontSize: 18.5,
                                    //     fontWeight: FontWeight.w600,
                                    //     color: Colors.black.withOpacity(0.9),
                                    //   ),
                                    // ),
                                    // Row(
                                    //   children: <Widget>[
                                    //     SizedBox(
                                    //       width: 10.0,
                                    //     ),
                                    //
                                    //     SizedBox(
                                    //       width: 15.0,
                                    //     ),
                                    //     // ClipRRect(
                                    //     //   borderRadius: BorderRadius.circular(8.0),
                                    //     //   child: Material(
                                    //     //     child: InkWell(
                                    //     //       splashColor:
                                    //     //           Colors.blue.withOpacity(0.5),
                                    //     //       onTap: () {
                                    //     //         print('Share');
                                    //     //         _createDynamicLink(true);
                                    //     //       },
                                    //     //       child: Container(
                                    //     //         width: 38.0,
                                    //     //         height: 35.0,
                                    //     //         decoration: BoxDecoration(
                                    //     //           color:
                                    //     //               Colors.black.withOpacity(0.04),
                                    //     //           borderRadius:
                                    //     //               BorderRadius.circular(8.0),
                                    //     //         ),
                                    //     //         child: Icon(
                                    //     //           Icons.share,
                                    //     //           color:
                                    //     //               Colors.black.withOpacity(0.5),
                                    //     //           size: 20.0,
                                    //     //         ),
                                    //     //       ),
                                    //     //     ),
                                    //     //   ),
                                    //     // ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ListTileTheme(
                                    contentPadding: EdgeInsets.all(0),
                                    dense: true,
                                    horizontalTitleGap: 0.0,
                                    minLeadingWidth: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 0, right: 10),
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        title: Text(
                                          "الكمية ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                        subtitle: _selectedSku ==
                                                _product.skus[0]
                                            ? Text("قطعة واحدة ",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey))
                                            : SizedBox(),
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            child: Stack(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 0),
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          // crossAxisAlignment: CrossAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              "كمية المنتج :",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                            Stack(
                                                              children: [
                                                                Container(
                                                                  // width:300,
                                                                  height: 50,
                                                                  child: ListView
                                                                      .separated(
                                                                    itemCount:
                                                                        _product
                                                                            .skus
                                                                            .length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    physics:
                                                                        NeverScrollableScrollPhysics(),
                                                                    itemBuilder:
                                                                        (context,
                                                                            index) {
                                                                      return InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            _selectedSku =
                                                                                _product.skus[index];
                                                                          });
                                                                        },
                                                                        child: Container(
                                                                            width: 50,
                                                                            height: 20,
                                                                            decoration: BoxDecoration(color: _product.skus[index] == _selectedSku ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey.shade300, borderRadius: BorderRadius.circular(14), border: _product.skus[index] == _selectedSku ? Border.all(color: Theme.of(context).accentColor, width: 1) : Border.all(color: Colors.grey)),
                                                                            child: Center(
                                                                              child: Text(
                                                                                "${_product.skus[index].skuName}",
                                                                                style: TextStyle(
                                                                                  color: _product.skus[index] == _selectedSku ? Colors.white : Colors.grey,
                                                                                  fontSize: 14.0,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                            )),
                                                                      );

                                                                      //   GestureDetector(
                                                                      //   onTap: () {
                                                                      //
                                                                      //     // Navigator.pop(context, _selectedSku);
                                                                      //   },
                                                                      //   child: Container(
                                                                      //     width: 40,height: 70,
                                                                      //     decoration: BoxDecoration(
                                                                      //       color: _product.skus[index] == _selectedSku
                                                                      //           ? Theme.of(context).primaryColor
                                                                      //           : Colors.transparent,
                                                                      //       borderRadius: BorderRadius.circular(4.0),
                                                                      //     ),
                                                                      //     margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                      //     padding: const EdgeInsets.symmetric(
                                                                      //         horizontal: 10, vertical: 7),
                                                                      //     child: Column(
                                                                      //       children: [
                                                                      //         Row(
                                                                      //           mainAxisAlignment: MainAxisAlignment.center,
                                                                      //           children: [
                                                                      //             Text(
                                                                      //               _product.isDiscounted
                                                                      //                   ? '${_product.skus[index].skuName}'
                                                                      //                   : '${_product.skus[index].skuName}',
                                                                      //               style: TextStyle(
                                                                      //                 color:
                                                                      //                 _product.skus[index] == _selectedSku
                                                                      //                     ? Colors.white.withOpacity(0.9)
                                                                      //                     : Colors.black.withOpacity(0.7),
                                                                      //                 fontSize: 13.0,
                                                                      //                 fontWeight: FontWeight.w500,
                                                                      //               ),
                                                                      //             ),
                                                                      //             // SizedBox(
                                                                      //             //   width: 10,
                                                                      //             // ),
                                                                      //             Text(
                                                                      //               _product.isDiscounted
                                                                      //                   ? '  -  ${Config().currency}${((1 - (_product.discount / 100)) * double.parse(_product.skus[index].skuPrice)).toStringAsFixed(2)}  '
                                                                      //                   : '  -  ${Config().currency}${double.parse(_product.skus[index].skuPrice).toStringAsFixed(2)}  ',
                                                                      //               style: TextStyle(
                                                                      //                 color:
                                                                      //                 _product.skus[index] == _selectedSku
                                                                      //                     ? Colors.white
                                                                      //                     : Colors.black.withOpacity(0.75),
                                                                      //                 fontSize: 13.0,
                                                                      //                 fontWeight: FontWeight.w600,
                                                                      //               ),
                                                                      //             ),
                                                                      //             _product.isDiscounted
                                                                      //                 ? Text(
                                                                      //               '${Config().currency}${double.parse(_product.skus[index].skuPrice).toStringAsFixed(2)}',
                                                                      //               style: TextStyle(
                                                                      //                 color: _product.skus[index] ==
                                                                      //                     _selectedSku
                                                                      //                     ? Colors.white.withOpacity(0.75)
                                                                      //                     : Colors.black.withOpacity(0.55),
                                                                      //                 decoration: TextDecoration.lineThrough,
                                                                      //                 fontSize: 13.0,
                                                                      //                 fontWeight: FontWeight.w400,
                                                                      //               ),
                                                                      //             )
                                                                      //                 : SizedBox(),
                                                                      //           ],
                                                                      //         ),
                                                                      //         _product.skus[index].quantity == 0
                                                                      //             ? Padding(
                                                                      //           padding: const EdgeInsets.only(top: 5),
                                                                      //           child: Text(
                                                                      //             'غير متاح',
                                                                      //             style: TextStyle(
                                                                      //               color: _product.skus[index] ==
                                                                      //                   _selectedSku
                                                                      //                   ? Colors.red.shade200
                                                                      //                   : Colors.red.withOpacity(0.75),
                                                                      //               fontSize: 12.0,
                                                                      //               fontWeight: FontWeight.w500,
                                                                      //             ),
                                                                      //           ),
                                                                      //         )
                                                                      //             : SizedBox(),
                                                                      //       ],
                                                                      //     ),
                                                                      //   ),
                                                                      // );
                                                                    },
                                                                    separatorBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index) {
                                                                      return Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 5));
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Center(
                                                          child: TextButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder:
                                                                    (context) =>
                                                                        Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25)),
                                                                  child:
                                                                      new AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                25)),
                                                                    title:
                                                                        new Text(
                                                                      'أضافة الكمية',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16.5,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                                0.9),
                                                                      ),
                                                                    ),
                                                                    content:
                                                                        Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        TextFormField(
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          decoration:
                                                                              InputDecoration(
                                                                            fillColor: Colors
                                                                                .grey
                                                                                .shade100,
                                                                            filled:
                                                                                true,
                                                                            border:
                                                                                new OutlineInputBorder(
                                                                              borderRadius:
                                                                                  new BorderRadius.circular(20.0),
                                                                              borderSide:
                                                                                  new BorderSide(),
                                                                            ),
                                                                            hintText:
                                                                                'الكمية',
                                                                            hintStyle:
                                                                                TextStyle(
                                                                              fontSize:
                                                                                  13.5,
                                                                              fontWeight:
                                                                                  FontWeight.w600,
                                                                              color:
                                                                                  Colors.black.withOpacity(0.5),
                                                                            ),
                                                                          ),
                                                                          onChanged:
                                                                              (val) {
                                                                            setState(
                                                                                () {
                                                                              // dataPrice = val;
                                                                              dataName =
                                                                                  val;
                                                                            });
                                                                          },
                                                                          onSaved:
                                                                              (String
                                                                                  value) {
                                                                            setState(
                                                                                () {
                                                                              dataName =
                                                                                  value;
                                                                            });
                                                                          },
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Column(
                                                                          children: [
                                                                            Container(
                                                                              width:
                                                                                  130,
                                                                              height:
                                                                                  40,
                                                                              decoration:
                                                                                  BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(25)),
                                                                              child:
                                                                                  Center(
                                                                                child: new FlatButton(
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      // _selectedSku.skuId = _product.skus[0].Id;
                                                                                      _selectedSku.skuName = dataName;
                                                                                      // _selectedSku.quantity=_product.skus[0].quantity;
                                                                                      // _selectedSku.skuPrice=_product.skus[0].skuPrice;
                                                                                    });
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text(
                                                                                    'أضافة',
                                                                                    style: TextStyle(
                                                                                      fontSize: 16.5,
                                                                                      fontWeight: FontWeight.w400,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            new FlatButton(
                                                                              onPressed:
                                                                                  () {
                                                                                Navigator.of(context, rootNavigator: true).pop(); // dismisses only the dialog and returns nothing
                                                                              },
                                                                              child:
                                                                                  Text(
                                                                                'الغاء',
                                                                                style: TextStyle(
                                                                                  fontSize: 13.5,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.black.withOpacity(0.9),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(right: 5),
                                                              child: Text(
                                                                dataName == null
                                                                    ? "رقم أخر "
                                                                    : dataName,
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors.white,
                                                                  fontSize: 14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w100,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                        // trailing: Padding(
                                        //   padding: const EdgeInsets.only(left: 18),
                                        //   child: Text(
                                        //     "تغيير",
                                        //     style: TextStyle(
                                        //         fontSize: 18,
                                        //         fontWeight: FontWeight.w500,
                                        //         color: Theme.of(context)
                                        //             .primaryColor),
                                        //   ),
                                        // ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent),
                                  child: ListTileTheme(
                                    contentPadding: EdgeInsets.all(0),
                                    dense: true,
                                    horizontalTitleGap: 0.0,
                                    minLeadingWidth: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 10),
                                      child: ExpansionTile(
                                        onExpansionChanged: (val) {
                                          return DatePicker.showDatePicker(context,
                                                showTitleActions: true,
                                                minTime: DateTime(2000, 1, 1),
                                                maxTime: DateTime.now(),

                                                theme: DatePickerTheme(
                                                    headerColor:
                                                        Colors.grey.shade200,
                                                    cancelStyle: TextStyle(
                                                        color: Colors.black),
                                                    itemStyle: TextStyle(
                                                        color: Colors.white),
                                                    doneStyle: TextStyle(
                                                        color: Colors.black),
                                                    backgroundColor:
                                                        Colors.black),
                                                onChanged: (date) {
                                          setState(() {
                                            DateFormat formatter =
                                                DateFormat('yyyy-MM-dd');
                                            patDate = formatter.format(date);
                                          });
                                        }, onConfirm: (date) {
                                                DateFormat formatter =
                                                DateFormat('yyyy-MM-dd');
                                                patDate = formatter.format(date);
                                                setState(() {
                                            patDateValue = patDate;
                                          });
                                        },
                                                currentTime: DateTime.now()
                                                    .subtract(Duration(days: 720)),
                                                locale: LocaleType.ar);
                                        },
                                        title: Text(
                                          "التاريخ ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                        subtitle: patDateValue!=null
                                            ? Text(
                                                "تاريخ الشراء ${patDateValue != null ? patDateValue : ""}",
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey))
                                            : SizedBox(),
                                        trailing: Text(
                                          "تغيير",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Divider(),
                              SizedBox(
                                height: 10,
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "سعر الشراء ",
                                      style: TextStyle(),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        // color: Colors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: TextButton(
                                          child: Text(
                                            proPrice == null
                                                ? "اضافة السعر"
                                                : "${proPrice}   ج.م  ",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize:
                                                    proPrice == null ? 12 : 17),
                                          ),
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) => Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25)),
                                                child: new AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25)),
                                                  title: new Text(
                                                    'أضافة السعر',
                                                    style: TextStyle(
                                                      fontSize: 16.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        // inputFormatters: <TextInputFormatter>[
                                                        //   WhitelistingTextInputFormatter.digitsOnly,
                                                        // ],
                                                        decoration:
                                                            InputDecoration(
                                                          fillColor: Colors
                                                              .grey.shade100,
                                                          filled: true,

                                                          border:
                                                              new OutlineInputBorder(

                                                            borderRadius:
                                                                new BorderRadius
                                                                        .circular(
                                                                    20.0),
                                                            borderSide:
                                                                new BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                            ),
                                                          ),
                                                          hintText:
                                                              'قيمة السعر',
                                                          hintStyle: TextStyle(
                                                            fontSize: 13.5,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.4),
                                                          ),
                                                        ),
                                                        onChanged: (val) {
                                                          setState(() {
                                                            dataPrice = val;
                                                          });
                                                        },
                                                        onSaved:
                                                            (String value) {
                                                          setState(() {
                                                            dataPrice = value;
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            width: 170,
                                                            height: 40,
                                                            decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25)),
                                                            child: Center(
                                                              child:
                                                                  new FlatButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    proPrice =
                                                                        dataPrice;
                                                                  });
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                                child: Text(
                                                                  'أضافة',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          new FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context,
                                                                      rootNavigator:
                                                                          true)
                                                                  .pop(); // dismisses only the dialog and returns nothing
                                                            },
                                                            child: Text(
                                                              'الغاء',
                                                              style: TextStyle(
                                                                fontSize: 13.5,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.9),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
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
                              ),
                              Divider(),
                              SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  // mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    productImage == null
                                        ? Container(
                                            width: 150,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              // border:Border.all(color:Theme.of(context).accentColor,width: 1.5),

                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: TextButton(
                                              child: Text(
                                                "اضافة صورة",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                futureProductScreen();
                                              },
                                            ),
                                          )
                                        : Image.file(
                                            productImage,
                                            width: 160,
                                            height: 180,
                                          ),
                                    payImage == null
                                        ? Container(
                                            width: 150,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              // border:Border.all(color:Theme.of(context).accentColor,width: 1.5),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: TextButton(
                                              child: Text(
                                                "صورة الفاتورة",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w100,
                                                    color: Colors.white),
                                              ),
                                              onPressed: () {
                                                // futureProductScreen();
                                                futurePayImage();
                                              },
                                            ),
                                          )
                                        : Image.file(
                                            payImage,
                                            width: 160,
                                            height: 180,
                                          ),
                                  ],
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: _product.isDiscounted
                              //       ? Row(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.spaceBetween,
                              //           children: [
                              //             Text(
                              //               '%${_product.discount.toInt()} خصم ',
                              //               maxLines: 1,
                              //               style: TextStyle(
                              //                 fontSize: 16.0,
                              //                 color: Colors.green.shade700,
                              //                 fontWeight: FontWeight.w500,
                              //                 letterSpacing: 0.5,
                              //               ),
                              //             ),
                              //             Text(
                              //               '${double.parse(_selectedSku.skuPrice).toStringAsFixed(2)}${Config().currency}',
                              //               maxLines: 1,
                              //               overflow: TextOverflow.ellipsis,
                              //               style: TextStyle(
                              //                 decoration: TextDecoration.lineThrough,
                              //                 color: Colors.grey,
                              //                 fontSize: 14.0,
                              //                 fontWeight: FontWeight.w500,
                              //               ),
                              //             ),
                              //           ],
                              //         )
                              //       : SizedBox(),
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.only(right: 14.0, left: 10),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Row(
                              //         children: [
                              //           SvgPicture.asset(
                              //               "assets/images/SizeIcon.svg"),
                              //           Text(
                              //             " الفئة : ${_product.subCategory}",
                              //             style: TextStyle(
                              //               fontSize: 16.0,
                              //               fontWeight: FontWeight.w600,
                              //               letterSpacing: 0.3,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SvgPicture.asset(
                              //         "assets/images/ratings.svg",
                              //         height: 15,
                              //         width: 40,
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.only(right: 10, left: 10),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Row(
                              //         crossAxisAlignment: CrossAxisAlignment.end,
                              //         children: [
                              //           Icon(Icons.access_time,
                              //               color: Colors.grey, size: 19),
                              //           SizedBox(
                              //             width: 5,
                              //           ),
                              //           Text(
                              //             "30 دقيقة ",
                              //             style: TextStyle(
                              //               color: Colors.grey,
                              //               fontSize: 12,
                              //               fontWeight: FontWeight.w600,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       Row(
                              //         crossAxisAlignment: CrossAxisAlignment.end,
                              //         children: [
                              //           SizedBox(
                              //             width: 5,
                              //           ),
                              //           Text(
                              //             "5.0 ⭐️",
                              //             style: TextStyle(
                              //               color: Colors.grey,
                              //               fontSize: 17,
                              //               fontWeight: FontWeight.w600,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     // mainAxisAlignment: MainAxisAlignment.start,
                              //     // mainAxisSize: MainAxisSize.min,
                              //     children: <Widget>[
                              //       Row(
                              //         mainAxisAlignment: MainAxisAlignment.start,
                              //         children: [
                              //           Text(
                              //             'وصف المنتج :',
                              //             style: TextStyle(
                              //               fontSize: 16.0,
                              //               fontWeight: FontWeight.w600,
                              //               letterSpacing: 0.3,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(
                              //         height: 10.0,
                              //       ),
                              //       Text(
                              //         _product.description,
                              //         style: TextStyle(
                              //           fontSize: 13.5,
                              //           fontWeight: FontWeight.w400,
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              // GestureDetector(
                              //   onTap: () async {
                              //     //show sku dialog
                              //     var res = await showDialog(
                              //       barrierDismissible: true,
                              //       context: context,
                              //       builder: (context) {
                              //         return ProductSkuDialog(
                              //           product: _product,
                              //           selectedSku: _selectedSku,
                              //         );
                              //       },
                              //     );
                              //
                              //     if (res != null) {
                              //       setState(() {
                              //         _selectedSku = res;
                              //       });
                              //     }
                              //   },
                              //   child: Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20),
                              //     child: Container(
                              //       width: double.infinity,
                              //       height: 50,
                              //       decoration: BoxDecoration(
                              //           color: Colors.green,
                              //           borderRadius: BorderRadius.circular(20)),
                              //       margin:
                              //           const EdgeInsets.symmetric(horizontal: 16),
                              //       child: Center(
                              //         child: Text(
                              //           'تحديد وزن المنتج',
                              //           maxLines: 1,
                              //           overflow: TextOverflow.ellipsis,
                              //           style: TextStyle(
                              //             color: Colors.white,
                              //             fontSize: 14.0,
                              //             fontWeight: FontWeight.w500,
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     mainAxisSize: MainAxisSize.max,
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: <Widget>[
                              //       Text(
                              //         _selectedSku.quantity > 0
                              //             ? 'In stock'
                              //             : 'Out of stock',
                              //         maxLines: 1,
                              //         style: TextStyle(
                              //           fontSize: 15.0,
                              //           color: _selectedSku.quantity > 0
                              //               ? Colors.green.shade700
                              //               : Colors.red.shade700,
                              //           fontWeight: FontWeight.w500,
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     mainAxisSize: MainAxisSize.max,
                              //     crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: <Widget>[
                              //       Container(
                              //         padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
                              //         decoration: BoxDecoration(
                              //           color: Colors.green.shade300,
                              //           borderRadius: BorderRadius.circular(7.0),
                              //         ),
                              //         child: Row(
                              //           children: <Widget>[
                              //             Text(
                              //               'Unit:',
                              //               maxLines: 1,
                              //               style: TextStyle(
                              //                 fontSize: 14.0,
                              //                 color: Colors.white,
                              //                 fontWeight: FontWeight.w500,
                              //                 letterSpacing: 0.5,
                              //               ),
                              //             ),
                              //             SizedBox(
                              //               width: 10.0,
                              //             ),
                              //             // Text(
                              //             //   _product.unitQuantity,
                              //             //   maxLines: 1,
                              //             //   style: TextStyle(
                              //             //     fontSize: 14.0,
                              //             //     color: Colors.white,
                              //             //     fontWeight: FontWeight.w500,
                              //             //     letterSpacing: 0.5,
                              //             //   ),
                              //             // ),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Divider(),
                              // ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              // // Padding(
                              // //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              // //   child: Row(
                              // //     crossAxisAlignment: CrossAxisAlignment.center,
                              // //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // //     mainAxisSize: MainAxisSize.max,
                              // //     children: <Widget>[
                              // //       Expanded(
                              // //         child: Container(
                              // //           padding: EdgeInsets.symmetric(
                              // //               horizontal: 12.0, vertical: 8.0),
                              // //           decoration: BoxDecoration(
                              // //             color: Colors.black.withOpacity(0.05),
                              // //             borderRadius: BorderRadius.circular(15.0),
                              // //           ),
                              // //           child: Text(
                              // //             'Fast Delivery',
                              // //             maxLines: 1,
                              // //             textAlign: TextAlign.center,
                              // //             overflow: TextOverflow.ellipsis,
                              // //             style: TextStyle(
                              // //               fontSize: 13.0,
                              // //               color: Colors.brown,
                              // //               fontWeight: FontWeight.w500,
                              // //               letterSpacing: 0.3,
                              // //             ),
                              // //           ),
                              // //         ),
                              // //       ),
                              // //       SizedBox(
                              // //         width: 16.0,
                              // //       ),
                              // //       Expanded(
                              // //         child: Container(
                              // //           padding: EdgeInsets.symmetric(
                              // //               horizontal: 12.0, vertical: 8.0),
                              // //           decoration: BoxDecoration(
                              // //             color: Colors.black.withOpacity(0.05),
                              // //             borderRadius: BorderRadius.circular(15.0),
                              // //           ),
                              // //           child: Text(
                              // //             'Easy cancellation',
                              // //             maxLines: 1,
                              // //             textAlign: TextAlign.center,
                              // //             overflow: TextOverflow.ellipsis,
                              // //             style: TextStyle(
                              // //               fontSize: 13.0,
                              // //               color: Colors.brown,
                              // //               fontWeight: FontWeight.w500,
                              // //               letterSpacing: 0.3,
                              // //             ),
                              // //           ),
                              // //         ),
                              // //       ),
                              // //     ],
                              // //   ),
                              // // ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Divider(),
                              // ),

                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Divider(),
                              // ),
                              // SizedBox(
                              //   height: 5.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: <Widget>[
                              //       Text(
                              //         'Additional Information',
                              //         style: TextStyle(
                              //           fontSize: 16.0,
                              //           fontWeight: FontWeight.w600,
                              //           letterSpacing: 0.3,
                              //         ),
                              //       ),
                              //       SizedBox(
                              //         height: 10.0,
                              //       ),
                              //       Text(
                              //         _product.additionalInfo.bestBefore.length == 0
                              //             ? '\u2022 Best before: NA'
                              //             : '\u2022 Best before: ${_product.additionalInfo.bestBefore}',
                              //         style: TextStyle(
                              //           fontSize: 13.5,
                              //           fontWeight: FontWeight.w400,
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //       Text(
                              //         _product.additionalInfo.manufactureDate
                              //                     .length ==
                              //                 0
                              //             ? '\u2022 Manufacture date: NA'
                              //             : '\u2022 Manufacture date: ${_product.additionalInfo.manufactureDate}',
                              //         style: TextStyle(
                              //           fontSize: 13.5,
                              //           fontWeight: FontWeight.w400,
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //       Text(
                              //         _product.additionalInfo.shelfLife.length == 0
                              //             ? '\u2022 Shelf life: NA'
                              //             : '\u2022 Shelf life: ${_product.additionalInfo.shelfLife}',
                              //         style: TextStyle(
                              //           fontSize: 13.5,
                              //           fontWeight: FontWeight.w400,
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //       Text(
                              //         _product.additionalInfo.brand.length == 0
                              //             ? '\u2022 Brand: NA'
                              //             : '\u2022 Brand: ${_product.additionalInfo.brand}',
                              //         style: TextStyle(
                              //           fontSize: 13.5,
                              //           fontWeight: FontWeight.w400,
                              //           letterSpacing: 0.5,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 10.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Divider(),
                              // ),
                              // SizedBox(
                              //   height: 5.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: <Widget>[
                              //       Row(
                              //         mainAxisSize: MainAxisSize.min,
                              //         children: <Widget>[
                              //           Expanded(
                              //             child: Text(
                              //               'Questions & Answers',
                              //               style: TextStyle(
                              //                 fontSize: 16.0,
                              //                 fontWeight: FontWeight.w600,
                              //                 letterSpacing: 0.3,
                              //               ),
                              //             ),
                              //           ),
                              //           Container(
                              //             height: 33.0,
                              //             child: FlatButton(
                              //               onPressed: () {
                              //                 //post question
                              //                 showPostQuestionPopup();
                              //               },
                              //               color: Theme.of(context).primaryColor,
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10.0),
                              //               ),
                              //               child: Text(
                              //                 'Post Question',
                              //                 style: TextStyle(
                              //                   color: Colors.white,
                              //                   fontSize: 13.5,
                              //                   fontWeight: FontWeight.w500,
                              //                   letterSpacing: 0.3,
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(
                              //         height: 12.0,
                              //       ),
                              //       _product.queAndAns.length == 0
                              //           ? Padding(
                              //               padding: const EdgeInsets.all(8.0),
                              //               child: Center(
                              //                 child: Text(
                              //                   'No questions found!',
                              //                   textAlign: TextAlign.center,
                              //                   overflow: TextOverflow.clip,
                              //                   style: TextStyle(
                              //                     color:
                              //                         Colors.black.withOpacity(0.7),
                              //                     fontSize: 14.5,
                              //                     fontWeight: FontWeight.w500,
                              //                     letterSpacing: 0.3,
                              //                   ),
                              //                 ),
                              //               ),
                              //             )
                              //           : Column(
                              //               children: <Widget>[
                              //                 ListView.separated(
                              //                   shrinkWrap: true,
                              //                   physics:
                              //                       NeverScrollableScrollPhysics(),
                              //                   padding: const EdgeInsets.only(
                              //                       bottom: 10.0),
                              //                   itemBuilder: (context, index) {
                              //                     return QuestionAnswerItem(
                              //                         _product.queAndAns[index]);
                              //                   },
                              //                   separatorBuilder: (context, index) {
                              //                     return Divider();
                              //                   },
                              //                   itemCount:
                              //                       _product.queAndAns.length > 3
                              //                           ? 3
                              //                           : _product.queAndAns.length,
                              //                 ),
                              //                 _product.queAndAns.length > 3
                              //                     ? Column(
                              //                         mainAxisSize: MainAxisSize.min,
                              //                         crossAxisAlignment:
                              //                             CrossAxisAlignment.start,
                              //                         mainAxisAlignment:
                              //                             MainAxisAlignment.start,
                              //                         children: <Widget>[
                              //                           Divider(),
                              //                           Container(
                              //                             height: 36.0,
                              //                             width: double.infinity,
                              //                             child: FlatButton(
                              //                               onPressed: () {
                              //                                 //TODO: take to all questions screen
                              //                                 Navigator.push(
                              //                                   context,
                              //                                   MaterialPageRoute(
                              //                                     builder: (context) =>
                              //                                         AllQuestionsScreen(
                              //                                             _product
                              //                                                 .queAndAns),
                              //                                   ),
                              //                                 );
                              //                               },
                              //                               color: Colors.transparent,
                              //                               padding:
                              //                                   const EdgeInsets.all(
                              //                                       0),
                              //                               shape:
                              //                                   RoundedRectangleBorder(
                              //                                 borderRadius:
                              //                                     BorderRadius
                              //                                         .circular(10.0),
                              //                               ),
                              //                               child: Container(
                              //                                 alignment: Alignment
                              //                                     .centerLeft,
                              //                                 child: Text(
                              //                                   'View All Questions',
                              //                                   style: GoogleFonts
                              //                                       .tajawal(
                              //                                     color:
                              //                                         Colors.black87,
                              //                                     fontSize: 14.0,
                              //                                     fontWeight:
                              //                                         FontWeight.w500,
                              //                                     letterSpacing: 0.3,
                              //                                   ),
                              //                                 ),
                              //                               ),
                              //                             ),
                              //                           ),
                              //                         ],
                              //                       )
                              //                     : SizedBox(),
                              //               ],
                              //             ),
                              //     ],
                              //   ),
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Divider(),
                              // ),
                              // SizedBox(
                              //   height: 5.0,
                              // ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: <Widget>[
                              //       Row(
                              //         children: <Widget>[
                              //           Expanded(
                              //             child: Text(
                              //               // 'Reviews & Ratings',
                              //               'Ratings',
                              //               style: TextStyle(
                              //                 fontSize: 16.0,
                              //                 fontWeight: FontWeight.w600,
                              //                 letterSpacing: 0.3,
                              //               ),
                              //             ),
                              //           ),
                              //           Container(
                              //             height: 33.0,
                              //             child: FlatButton(
                              //               onPressed: () {
                              //                 //rate
                              //                 rateProductBloc
                              //                     .add(CheckRateProductEvent(
                              //                   FirebaseAuth.instance.currentUser.uid,
                              //                   _product.id,
                              //                   _product,
                              //                 ));
                              //               },
                              //               color: Theme.of(context).primaryColor,
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius:
                              //                     BorderRadius.circular(10.0),
                              //               ),
                              //               child: Text(
                              //                 'Rate Product',
                              //                 style: TextStyle(
                              //                   color: Colors.white,
                              //                   fontSize: 13.5,
                              //                   fontWeight: FontWeight.w500,
                              //                   letterSpacing: 0.3,
                              //                 ),
                              //               ),
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(
                              //         height: 20.0,
                              //       ),
                              //       Row(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.spaceEvenly,
                              //         crossAxisAlignment: CrossAxisAlignment.center,
                              //         mainAxisSize: MainAxisSize.max,
                              //         children: <Widget>[
                              //           Expanded(
                              //             child: Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.center,
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.center,
                              //               mainAxisSize: MainAxisSize.max,
                              //               children: <Widget>[
                              //                 Text(
                              //                   '${_product.reviews.length}',
                              //                   textAlign: TextAlign.center,
                              //                   overflow: TextOverflow.clip,
                              //                   style: TextStyle(
                              //                     color: Colors.green.shade700,
                              //                     fontSize: 20.0,
                              //                     fontWeight: FontWeight.w600,
                              //                     letterSpacing: 0.3,
                              //                   ),
                              //                 ),
                              //                 SizedBox(
                              //                   width: 5.0,
                              //                 ),
                              //                 Text(
                              //                   'reviews',
                              //                   textAlign: TextAlign.center,
                              //                   overflow: TextOverflow.clip,
                              //                   style: TextStyle(
                              //                     fontSize: 15.0,
                              //                     fontWeight: FontWeight.w500,
                              //                     letterSpacing: 0.3,
                              //                   ),
                              //                 )
                              //               ],
                              //             ),
                              //           ),
                              //           Expanded(
                              //             child: Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.center,
                              //               crossAxisAlignment:
                              //                   CrossAxisAlignment.center,
                              //               mainAxisSize: MainAxisSize.max,
                              //               children: <Widget>[
                              //                 Text(
                              //                   _product.reviews.length == 0
                              //                       ? '0'
                              //                       : '${rating.toStringAsFixed(1)}',
                              //                   textAlign: TextAlign.center,
                              //                   overflow: TextOverflow.clip,
                              //                   style: TextStyle(
                              //                     color: Colors.green.shade700,
                              //                     fontSize: 20.0,
                              //                     fontWeight: FontWeight.w600,
                              //                     letterSpacing: 0.3,
                              //                   ),
                              //                 ),
                              //                 SizedBox(
                              //                   width: 5.0,
                              //                 ),
                              //                 Padding(
                              //                   padding: const EdgeInsets.only(
                              //                       bottom: 1.5),
                              //                   child: Text(
                              //                     '\u2605',
                              //                     textAlign: TextAlign.center,
                              //                     overflow: TextOverflow.clip,
                              //                     style: TextStyle(
                              //                       color:
                              //                           Colors.black.withOpacity(0.7),
                              //                       fontSize: 17.0,
                              //                       fontWeight: FontWeight.w600,
                              //                       letterSpacing: 0.3,
                              //                     ),
                              //                   ),
                              //                 )
                              //               ],
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       SizedBox(
                              //         height: 20.0,
                              //       ),
                              //       _product.reviews.length == 0
                              //           ? Padding(
                              //               padding:
                              //                   const EdgeInsets.only(bottom: 8.0),
                              //               child: Center(
                              //                 child: Text(
                              //                   'No reviews found!',
                              //                   textAlign: TextAlign.center,
                              //                   overflow: TextOverflow.clip,
                              //                   style: TextStyle(
                              //                     color:
                              //                         Colors.black.withOpacity(0.7),
                              //                     fontSize: 14.5,
                              //                     fontWeight: FontWeight.w500,
                              //                     letterSpacing: 0.3,
                              //                   ),
                              //                 ),
                              //               ),
                              //             )
                              //           : Column(
                              //               children: <Widget>[
                              //                 ListView.separated(
                              //                   shrinkWrap: true,
                              //                   physics:
                              //                       NeverScrollableScrollPhysics(),
                              //                   padding: const EdgeInsets.only(
                              //                       bottom: 10.0),
                              //                   itemBuilder: (context, index) {
                              //                     return ReviewItem(
                              //                       review: _product.reviews[index],
                              //                     );
                              //                   },
                              //                   separatorBuilder: (context, index) {
                              //                     return Divider();
                              //                   },
                              //                   itemCount: _product.reviews.length > 3
                              //                       ? 3
                              //                       : _product.reviews.length,
                              //                 ),
                              //                 _product.reviews.length > 3
                              //                     ? Column(
                              //                         mainAxisSize: MainAxisSize.min,
                              //                         crossAxisAlignment:
                              //                             CrossAxisAlignment.start,
                              //                         mainAxisAlignment:
                              //                             MainAxisAlignment.start,
                              //                         children: <Widget>[
                              //                           Divider(),
                              //                           Container(
                              //                             height: 36.0,
                              //                             width: double.infinity,
                              //                             child: FlatButton(
                              //                               onPressed: () {
                              //                                 //TODO: take to all reviews screen
                              //                                 Navigator.push(
                              //                                   context,
                              //                                   MaterialPageRoute(
                              //                                     builder: (context) =>
                              //                                         AllReviewsScreen(
                              //                                       _product.reviews,
                              //                                       rating,
                              //                                     ),
                              //                                   ),
                              //                                 );
                              //                               },
                              //                               color: Colors.transparent,
                              //                               padding:
                              //                                   const EdgeInsets.all(
                              //                                       0),
                              //                               shape:
                              //                                   RoundedRectangleBorder(
                              //                                 borderRadius:
                              //                                     BorderRadius
                              //                                         .circular(10.0),
                              //                               ),
                              //                               child: Container(
                              //                                 alignment: Alignment
                              //                                     .centerLeft,
                              //                                 child: Text(
                              //                                   'View All Reviews',
                              //                                   style: GoogleFonts
                              //                                       .tajawal(
                              //                                     color:
                              //                                         Colors.black87,
                              //                                     fontSize: 14.0,
                              //                                     fontWeight:
                              //                                         FontWeight.w500,
                              //                                     letterSpacing: 0.3,
                              //                                   ),
                              //                                 ),
                              //                               ),
                              //                             ),
                              //                           ),
                              //                         ],
                              //                       )
                              //                     : SizedBox(),
                              //               ],
                              //             ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          );
                        } else
                          return Shimmer.fromColors(
                            period: Duration(milliseconds: 1000),
                            baseColor: Colors.grey.withOpacity(0.5),
                            highlightColor: Colors.black.withOpacity(0.5),
                            child: ShimmerProductDetail(),
                          );
                      },
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Divider(),
                    // ),
                    // SizedBox(
                    //   height: 5.0,
                    // ),
                    // Padding(
                    //   padding:
                    //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisSize: MainAxisSize.max,
                    //     children: <Widget>[
                    //       Text(
                    //         'Similar Products',
                    //         style: TextStyle(
                    //           fontSize: 16.0,
                    //           fontWeight: FontWeight.w600,
                    //           letterSpacing: 0.3,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10.0,
                    // ),
                    // BlocBuilder(
                    //   cubit: similarProductBloc,
                    //   builder: (context, state) {
                    //     print('SIMILAR PRODUCTS :: $state');
                    //     if (state is LoadSimilarProductsInProgressState) {
                    //       return Container(
                    //         height: 280.0,
                    //         child: ListView.separated(
                    //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //           shrinkWrap: true,
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: 5,
                    //           itemBuilder: (context, index) {
                    //             return Shimmer.fromColors(
                    //               period: Duration(milliseconds: 800),
                    //               baseColor: Colors.grey.withOpacity(0.5),
                    //               highlightColor: Colors.black.withOpacity(0.5),
                    //               child: ShimmerProductListItem(),
                    //             );
                    //           },
                    //           separatorBuilder: (context, index) {
                    //             return SizedBox(
                    //               width: 20.0,
                    //             );
                    //           },
                    //         ),
                    //       );
                    //     } else if (state is LoadSimilarProductsFailedState) {
                    //       return Center(
                    //         child: Text(
                    //           'Failed to load similar products!',
                    //           style: TextStyle(
                    //             fontSize: 15.0,
                    //             fontWeight: FontWeight.w600,
                    //             letterSpacing: 0.3,
                    //           ),
                    //         ),
                    //       );
                    //     } else if (state is LoadSimilarProductsCompletedState) {
                    //       if (state.productList.length == 0) {
                    //         return Center(
                    //           child: Text(
                    //             'No similar products found!',
                    //             textAlign: TextAlign.center,
                    //             overflow: TextOverflow.clip,
                    //             style: TextStyle(
                    //               color: Colors.black.withOpacity(0.7),
                    //               fontSize: 14.5,
                    //               fontWeight: FontWeight.w500,
                    //               letterSpacing: 0.3,
                    //             ),
                    //           ),
                    //         );
                    //       }
                    //       _similarProducts = state.productList;
                    //       return Container(
                    //         height: 320.0,
                    //         child: ListView.separated(
                    //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //           shrinkWrap: true,
                    //           scrollDirection: Axis.horizontal,
                    //           itemCount: _similarProducts.length,
                    //           itemBuilder: (context, index) {
                    //             return ProductListItem(
                    //               product: _similarProducts[index],
                    //               cartBloc: cartBloc,
                    //               currentUser: _currentUser,
                    //             );
                    //           },
                    //           separatorBuilder: (context, index) {
                    //             return SizedBox(
                    //               width: 20.0,
                    //             );
                    //           },
                    //         ),
                    //       );
                    //     } else {
                    //       return SizedBox();
                    //     }
                    //   },
                    // ),
                    // SizedBox(
                    //   height: 85.0,
                    // ),
                    SizedBox(
                      height: 80,
                    )
                  ],
                ),
                buildAddToCart(size, context),
              ],
            ),
          );
    // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
  }

  Widget buildAddToCart(Size size, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          // width: double.infinity,
          color: Colors.white,
          child: Row(
            children: [
              Container(
                height: 90.0,
                width: size.width,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Colors.white,
                  //     Colors.white70,
                  //     Colors.white54,
                  //   ],
                  //   begin: Alignment.bottomCenter,
                  //   end: Alignment.topCenter,
                  // ),.
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                        color: Theme.of(context).accentColor, width: 2),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      //add to cart

                      addToCart();

                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // Icon(
                        //   Icons.add_shopping_cart,
                        //   color: Colors.white,
                        // ),
                        // SizedBox(
                        //   width: 15.0,
                        // ),
                        Text(
                          ' أضف الي قائمة المشتريات',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // child: BlocBuilder(
                //   cubit: cartBloc,
                //   builder: (context, state) {
                //     if (state is AddToCartInProgressState) {
                //       return FlatButton(
                //         onPressed: () {
                //           //temporary
                //         },
                //         color: Theme.of(context).primaryColor,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(15.0),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           mainAxisSize: MainAxisSize.max,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: <Widget>[
                //             Container(
                //               height: 25.0,
                //               width: 25.0,
                //               child: CircularProgressIndicator(
                //                 backgroundColor: Colors.white,
                //                 strokeWidth: 3.0,
                //                 valueColor:
                //                     AlwaysStoppedAnimation<Color>(Colors.black38),
                //               ),
                //             ),
                //             SizedBox(
                //               width: 15.0,
                //             ),
                //             Text(
                //               'Adding to cart',
                //               style: TextStyle(
                //                 fontSize: 15.0,
                //                 fontWeight: FontWeight.w500,
                //                 letterSpacing: 0.3,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ],
                //         ),
                //       );
                //     }
                //     if (state is AddToCartFailedState) {
                //       //create snack
                //     }
                //     if (state is AddToCartCompletedState) {
                //       //create snack
                //       // showSnack();
                //       // return FlatButton(
                //       //   onPressed: () {
                //       //     //temporary
                //       //   },
                //       //   color: Theme.of(context).primaryColor,
                //       //   shape: RoundedRectangleBorder(
                //       //     borderRadius: BorderRadius.circular(15.0),
                //       //   ),
                //       //   child: Row(
                //       //     mainAxisAlignment: MainAxisAlignment.center,
                //       //     mainAxisSize: MainAxisSize.max,
                //       //     crossAxisAlignment: CrossAxisAlignment.center,
                //       //     children: <Widget>[
                //       //       Icon(
                //       //         Icons.shopping_cart,
                //       //         color: Colors.white,
                //       //       ),
                //       //       SizedBox(
                //       //         width: 15.0,
                //       //       ),
                //       //       Text(
                //       //         'Added to cart',
                //       //         style: TextStyle(
                //       //           fontSize: 15.0,
                //       //           fontWeight: FontWeight.w500,
                //       //           letterSpacing: 0.3,
                //       //           color: Colors.white,
                //       //         ),
                //       //       ),
                //       //     ],
                //       //   ),
                //       // );

                //       return FlatButton(
                //         onPressed: () {
                //           //add to cart
                //           addToCart();
                //         },
                //         color: Theme.of(context).primaryColor,
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(15.0),
                //         ),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           mainAxisSize: MainAxisSize.max,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: <Widget>[
                //             Icon(
                //               Icons.add_shopping_cart,
                //               color: Colors.white,
                //             ),
                //             SizedBox(
                //               width: 15.0,
                //             ),
                //             Text(
                //               'Add to cart',
                //               style: TextStyle(
                //                 fontSize: 15.0,
                //                 fontWeight: FontWeight.w500,
                //                 letterSpacing: 0.3,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ],
                //         ),
                //       );
                //     }
                //     return FlatButton(
                //       onPressed: () {
                //         //add to cart
                //         addToCart();
                //       },
                //       color: Theme.of(context).primaryColor,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(15.0),
                //       ),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         mainAxisSize: MainAxisSize.max,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: <Widget>[
                //           Icon(
                //             Icons.add_shopping_cart,
                //             color: Colors.white,
                //           ),
                //           SizedBox(
                //             width: 15.0,
                //           ),
                //           Text(
                //             'Add to cart',
                //             style: TextStyle(
                //               fontSize: 15.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.3,
                //               color: Colors.white,
                //             ),
                //           ),
                //         ],
                //       ),
                //     );
                //   },
                // ),
              ),
              // SizedBox(
              //   width: 10,
              // ),
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
              //   child: GestureDetector(
              //     onTap: () {
              //       FirebaseAuth.instance.currentUser == null
              //           ? Navigator.of(context).push(MaterialPageRoute(
              //               builder: (context) => SignInScreen()))
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
              //                       left: 20.0,
              //                       top: 15.0,
              //                       child: Container(
              //                         height: 16.0,
              //                         width: 16.0,
              //                         alignment: Alignment.center,
              //                         decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(15.0),
              //                           color: Colors.black,
              //                         ),
              //                         child: Padding(
              //                           padding: const EdgeInsets.only(top: 2),
              //                           child: Center(
              //                             child: Text(
              //                               '$cartCount',
              //                               style: TextStyle(
              //                                 color:
              //                                     Theme.of(context).primaryColor,
              //                                 fontSize: 10.0,
              //                                 fontWeight: FontWeight.w500,
              //                               ),
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                     )
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
              //   //               style: TextStyle(
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
              //   //       //         style: TextStyle(
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
              //   //               style: TextStyle(
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
              //   //             style: TextStyle(
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
              // SizedBox(
              //   width: 30,
              // ),
            ],
          ),
        ),
      ],
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

  ClipRRect wishListIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Material(
        child: InkWell(
          splashColor: Colors.blue.withOpacity(0.5),
          onTap: () {
            print('Wishlist');
            FirebaseAuth.instance.currentUser == null
                ? Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignInScreen()))
                : wishlistProductBloc.add(AddToWishlistEvent(
                    _product.id,
                    FirebaseAuth.instance.currentUser.uid,
                  ));
            FirebaseAuth.instance.currentUser == null
                ? SizedBox()
                : widget._interstitialAd.show();

            setState(() {
              wishListProduct = true;
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                border: Border.all(color: Theme.of(context).accentColor)),
            child: Text(
              "أضافة الي قائمة الاحتياجات",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }

  ClipRRect removewishListIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Material(
        child: InkWell(
          splashColor: Colors.blue.withOpacity(0.5),
          onTap: () {
            print('Wishlist');
            FirebaseAuth.instance.currentUser == null
                ? Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignInScreen()))
                : wishlistProductBloc.add(RemoveFromWishlistEvent(
                    _product.id,
                    FirebaseAuth.instance.currentUser.uid,
                  ));
            setState(() {
              wishListProduct = false;
            });
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25), color: Colors.red),
            child: Text(
              "تم الاضافة",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void showReportSnack(String text, String type, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      backgroundColor: type == 'FAILED' ? Colors.red : Colors.green,
      animationDuration: Duration(milliseconds: 350),
      isDismissible: true,
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
}
