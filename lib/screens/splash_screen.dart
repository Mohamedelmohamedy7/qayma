import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:grocery_store/screens/navicationBarScreen.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SigninBloc signinBloc;
  Map<dynamic, Widget> mapping = {
    1: SignInScreen(),
    2: NavicationBarScreen(),
  };

  @override
  void initState() {
    super.initState();
    // InterstitialAd.load(
    //     adUnitId: '<ad unit id>',
    //     request: AdRequest(),
    //     adLoadCallback: InterstitialAdLoadCallback(
    //       onAdLoaded: (InterstitialAd ad) {
    //         // Keep a reference to the ad so you can show it later.
    //         this._interstitialAd = ad;
    //       },
    //       onAdFailedToLoad: (LoadAdError error) {
    //         print('InterstitialAd failed to load: $error');
    //       },
    //     ));
    signinBloc = BlocProvider.of<SigninBloc>(context);

    signinBloc.listen((state) {
      if (state is CheckIfSignedInCompleted) {
        //proceed to home
        print('logged in');

        if (state.res.isEmpty) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>NavicationBarScreen()));
        } else {
          Navigator.popAndPushNamed(context, '/sign_in');
        }
      }
      if (state is NotLoggedIn) {
        //proceed to sign in
        print('not logged in');
      }
      if (state is FailedToCheckLoggedIn) {
        //proceed to sign in
        print('failed to check if logged in');
        Navigator.popAndPushNamed(context, '/sign_in');
      }
    });

    // signinBloc.add(CheckIfSignedIn());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // Timer(Duration(milliseconds: 0), () {
    //   Navigator.popAndPushNamed(context, '/sign_in');
    // });
    Timer(Duration(milliseconds: 300), () {
   FirebaseAuth.instance.currentUser==null?
   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>OnboardingScreen())):
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>NavicationBarScreen()));
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/groceries.svg',
              width: size.width * 0.25,
              height: size.width * 0.25,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Grocery Store',
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.85),
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
