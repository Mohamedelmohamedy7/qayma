// import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
// import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
// import 'package:grocery_store/blocs/banner_bloc/banner_product_bloc.dart';
// import 'package:grocery_store/blocs/card_bloc/card_bloc.dart';
// import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
// import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
// import 'package:grocery_store/blocs/category_bloc/category_bloc.dart';
// import 'package:grocery_store/blocs/checkout_bloc/checkout_bloc.dart';
// import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/category_products_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/increment_view_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/post_question_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/rate_product_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/recommended_product_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/report_product_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/similar_product_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/trending_product_bloc.dart';
// import 'package:grocery_store/blocs/product_bloc/wishlist_product_bloc.dart';
// import 'package:grocery_store/blocs/search_bloc/search_bloc.dart';
// import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
// import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
// import 'package:grocery_store/repositories/authentication_repository.dart';
// import 'package:grocery_store/repositories/user_data_repository.dart';
// import 'package:grocery_store/screens/add_card_screen.dart';
// import 'package:grocery_store/screens/cart_screen.dart';
// import 'package:grocery_store/screens/checkout_screen.dart';
// import 'package:grocery_store/screens/my_orders_screen.dart';
// import 'package:grocery_store/screens/onboarding_screen.dart';
// import 'package:grocery_store/screens/product_screen.dart';
// import 'package:grocery_store/screens/sign_in_screen.dart';
// import 'package:grocery_store/screens/sign_up_screen.dart';
// import 'package:grocery_store/screens/splash_screen.dart';
// import 'package:grocery_store/screens/verification_screen.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:localize_and_translate/localize_and_translate.dart';
// import 'package:provider/provider.dart';
//
// import 'blocs/manage_coupons_bloc/manage_coupons_bloc.dart';
// import 'blocs/my_orders_bloc/my_orders_bloc.dart';
// import 'config/config.dart';
// import 'home_provider.dart';
// import 'screens/card_payment_screen.dart';
// import 'screens/home_screen.dart';
// import 'package:grocery_store/settings_repository.dart' as settingRepo;
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await translator.init(
//     localeType: LocalizationDefaultType.device,
//     languagesList: <String>['ar'],
//     assetsDirectory: 'assets/lang/',
//   );
//   final AuthenticationRepository authenticationRepository =
//       AuthenticationRepository();
//   final UserDataRepository userDataRepository = UserDataRepository();
//
//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider<SignupBloc>(
//           create: (context) => SignupBloc(
//             authenticationRepository: authenticationRepository,
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<SigninBloc>(
//           create: (context) => SigninBloc(
//             authenticationRepository: authenticationRepository,
//           ),
//         ),
//         BlocProvider<CategoryBloc>(
//           create: (context) => CategoryBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<BannerBloc>(
//           create: (context) => BannerBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<BannerProductBloc>(
//           create: (context) => BannerProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<ProductBloc>(
//           create: (context) => ProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<TrendingProductBloc>(
//           create: (context) => TrendingProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<FeaturedProductBloc>(
//           create: (context) => FeaturedProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<SimilarProductBloc>(
//           create: (context) => SimilarProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<CartBloc>(
//           create: (context) => CartBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<CartCountBloc>(
//           create: (context) => CartCountBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<CategoryProductsBloc>(
//           create: (context) => CategoryProductsBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<WishlistProductBloc>(
//           create: (context) => WishlistProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<SearchBloc>(
//           create: (context) => SearchBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<CheckoutBloc>(
//           create: (context) => CheckoutBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<CardBloc>(
//           create: (context) => CardBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<MyOrdersBloc>(
//           create: (context) => MyOrdersBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<AccountBloc>(
//           create: (context) => AccountBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<PostQuestionBloc>(
//           create: (context) => PostQuestionBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<RateProductBloc>(
//           create: (context) => RateProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<IncrementViewBloc>(
//           create: (context) => IncrementViewBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<NotificationBloc>(
//           create: (context) => NotificationBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<ReportProductBloc>(
//           create: (context) => ReportProductBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//         BlocProvider<ManageCouponsBloc>(
//           create: (context) => ManageCouponsBloc(
//             userDataRepository: userDataRepository,
//           ),
//         ),
//       ],
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarBrightness: Brightness.dark,
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ));
//     return ValueListenableBuilder(
//         valueListenable: settingRepo.setting,
//         builder: (context, Setting _setting, _) => MultiProvider(
//       providers: [
//         ChangeNotifierProvider<HomeProvider>(
//             create: (context) => HomeProvider()),
//       ],
//       child: MaterialApp(
//         localizationsDelegates: translator.delegates, // Android + iOS Delegates
//         locale: translator.locale, // Active locale
//         supportedLocales: translator.locals(),
//         debugShowCheckedModeBanner: false,
//         title: '${Config().appName}',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           primaryColorDark: Color(0xFF7936ff),
//           primaryColor: Color(0xFFFFBD2F),
//           accentColor: Colors.pink,
//           backgroundColor: Colors.white,
//           canvasColor: Colors.white,
//         ),
//         initialRoute: '/',
//         routes: {
//           '/': (context) => SplashScreen(),
//           '/onboarding': (context) => OnboardingScreen(),
//           '/verification': (context) => VerificationScreen(),
//           '/home': (context) => HomeScreen(),
//           '/sign_up': (context) => SignUpScreen(),
//           '/sign_in': (context) => SignInScreen(),
//           '/product': (context) => ProductScreen(),
//           '/cart': (context) => CartScreen(),
//           '/checkout': (context) => CheckoutScreen(),
//           '/add_card': (context) => AddCardScreen(),
//           '/card_payment': (context) => CardPaymentScreen(),
//           '/my_orders': (context) => MyOrdersScreen(),
//         },
//       ),
//     );
//   }
// }
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_bloc.dart';
import 'package:grocery_store/blocs/banner_bloc/banner_product_bloc.dart';
import 'package:grocery_store/blocs/card_bloc/card_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_count_bloc.dart';
import 'package:grocery_store/blocs/category_bloc/category_bloc.dart';
import 'package:grocery_store/blocs/checkout_bloc/checkout_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/category_products_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/increment_view_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/post_question_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/rate_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/recommended_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/report_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/similar_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/trending_product_bloc.dart';
import 'package:grocery_store/blocs/product_bloc/wishlist_product_bloc.dart';
import 'package:grocery_store/blocs/search_bloc/search_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/providers/authentication_provider.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:grocery_store/screens/add_card_screen.dart';
import 'package:grocery_store/screens/cart_screen.dart';
import 'package:grocery_store/screens/checkout_screen.dart';
import 'package:grocery_store/screens/my_orders_screen.dart';
import 'package:grocery_store/screens/onboarding_screen.dart';
import 'package:grocery_store/screens/product_screen.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import 'package:grocery_store/screens/splash_screen.dart';
import 'package:grocery_store/screens/verification_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/settings_repository.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocery_store/settings_repository.dart' as settingRepo;
import 'blocs/manage_coupons_bloc/manage_coupons_bloc.dart';
import 'blocs/my_orders_bloc/my_orders_bloc.dart';
import 'config/config.dart';
import 'home_provider.dart';
import 'screens/card_payment_screen.dart';
import 'screens/home_screen.dart';
int initScreen;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  await translator.init(
    localeType: LocalizationDefaultType.device,
    languagesList: <String>['ar'],
    assetsDirectory: 'assets/lang/',
  );
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // initScreen = await prefs.getInt("initScreen");
  // await prefs.setInt("initScreen", 1);
  // print('initScreen ${initScreen}');


  await Firebase.initializeApp();

  final AuthenticationRepository authenticationRepository =
  AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
          create: (context) => SignupBloc(
            authenticationRepository: authenticationRepository,
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<SigninBloc>(
          create: (context) => SigninBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => CategoryBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<BannerBloc>(
          create: (context) => BannerBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<BannerProductBloc>(
          create: (context) => BannerProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<TrendingProductBloc>(
          create: (context) => TrendingProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<FeaturedProductBloc>(
          create: (context) => FeaturedProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<SimilarProductBloc>(
          create: (context) => SimilarProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<CartCountBloc>(
          create: (context) => CartCountBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<CategoryProductsBloc>(
          create: (context) => CategoryProductsBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<WishlistProductBloc>(
          create: (context) => WishlistProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<CheckoutBloc>(
          create: (context) => CheckoutBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<CardBloc>(
          create: (context) => CardBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<MyOrdersBloc>(
          create: (context) => MyOrdersBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<PostQuestionBloc>(
          create: (context) => PostQuestionBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<RateProductBloc>(
          create: (context) => RateProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<IncrementViewBloc>(
          create: (context) => IncrementViewBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<ReportProductBloc>(
          create: (context) => ReportProductBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<ManageCouponsBloc>(
          create: (context) => ManageCouponsBloc(
            userDataRepository: userDataRepository,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}
class MyApp extends StatefulWidget {

  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
 initState() {

    // TODO: implement initState
    settingRepo.initSettings();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>(
                  create: (context) => HomeProvider()),
            ],
            child: MaterialApp(
              localizationsDelegates: translator.delegates, // Android + iOS Delegates
              locale: translator.activeLocale, // Active locale
              supportedLocales: translator.locals(),

              debugShowCheckedModeBanner: false,
              title: '${Config().appName}',
              theme: ThemeData(
                fontFamily: "ExpoArabic",
                // textTheme: GoogleFonts.tajawalTextTheme(
                //   Theme.of(context).textTheme,
                // ),
          primarySwatch: Colors.blue,
          primaryColorDark: Color(0xFF7936ff),
          primaryColor: Color(0xFFe12d64),
          accentColor: Color(0xfff7cb5a),
          backgroundColor: Colors.white,
          canvasColor: Colors.white,
              ),
              initialRoute: '/',
              routes: {
                '/': (context) => SplashScreen(),
                '/onboarding': (context) => OnboardingScreen(),
                '/verification': (context) => VerificationScreen(),
                '/home': (context) => HomeScreen(),
                '/sign_up': (context) => SignUpScreen(),
                '/sign_in': (context) => SignInScreen(),
                '/product': (context) => ProductScreen(),
                '/cart': (context) => CartScreen(),
                '/checkout': (context) => CheckoutScreen(),
                '/add_card': (context) => AddCardScreen(),
                '/card_payment': (context) => CardPaymentScreen(),
                '/my_orders': (context) => MyOrdersScreen(),
              },
            )
        )
    );
  }
}
