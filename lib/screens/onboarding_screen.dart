import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/config/config.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../ad_help.dart';
import 'navicationBarScreen.dart';

class OnboardingScreen extends StatefulWidget {
  static final String id = 'onboarding_screen_id';
  OnboardingScreen(){adMOp();}
  BannerAd _ad;
  InterstitialAd _interstitialAd;
  bool isLoaded=false;

  void adMOp() {
    InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded:onloadMethod , onAdFailedToLoad: (_) {
        }));
  }
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();

  void onloadMethod(InterstitialAd ad) {
    _interstitialAd=ad;
    isLoaded=true;
  }
}

enum Mode {
  defaultTheme,
  customTheme,
  advancedTheme,
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Config config;


  @override
  void initState() {
    super.initState();

    config = Config();
  }

  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        image: Image.asset(
          "assets/images/onboardingscreen.png",
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // SvgPicture.asset(
        //   config.onboardingImage1,
        //   width: MediaQuery.of(context).size.width,
        //   alignment: Alignment.center,
        //   fit: BoxFit.contain,
        // ),
        title: config.onboardingPage1Title,
        body: config.onboardingPage1Subtitle,
        decoration: PageDecoration(
          imageFlex: 2,
          bodyTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      PageViewModel(
        image: Image.asset(
          "assets/images/onboardingscreen.png",
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // SvgPicture.asset(
        //   config.onboardingImage1,
        //   width: MediaQuery.of(context).size.width,
        //   alignment: Alignment.center,
        //   fit: BoxFit.contain,
        // ),
        title: config.onboardingPage2Title,
        body: config.onboardingPage2Subtitle,
        decoration: PageDecoration(
          imageFlex: 2,
          bodyTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // PageViewModel(
      //   image: SvgPicture.asset(
      //     config.onboardingImage2,
      //     width: MediaQuery.of(context).size.width,
      //     alignment: Alignment.center,
      //     fit: BoxFit.contain,
      //   ),
      //   title: config.onboardingPage2Title,
      //   body: config.onboardingPage2Subtitle,
      //   decoration: PageDecoration(
      //     imageFlex: 1,
      //     bodyTextStyle: TextStyle(
      //       color: Colors.black87,
      //       fontSize: 15.0,
      //       fontWeight: FontWeight.w500,
      //       letterSpacing: 0.4,
      //     ),
      //     titleTextStyle: TextStyle(
      //       color: Colors.black87,
      //       fontSize: 18.0,
      //       fontWeight: FontWeight.w600,
      //       letterSpacing: 0.3,
      //     ),
      //   ),
      // ),
      // PageViewModel(
      //   image: SvgPicture.asset(
      //     config.onboardingImage3,
      //     width: MediaQuery.of(context).size.width,
      //     alignment: Alignment.center,
      //     fit: BoxFit.contain,
      //   ),
      //   title: config.onboardingPage3Title,
      //   body: config.onboardingPage3Subtitle,
      //   decoration: PageDecoration(
      //     imageFlex: 1,
      //     bodyTextStyle: TextStyle(
      //       color: Colors.black87,
      //       fontSize: 15.0,
      //       fontWeight: FontWeight.w500,
      //       letterSpacing: 0.4,
      //     ),
      //     titleTextStyle: TextStyle(
      //       color: Colors.black87,
      //       fontSize: 18.0,
      //       fontWeight: FontWeight.w600,
      //       letterSpacing: 0.3,
      //     ),
      //   ),
      // )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: getPages(),
        showNextButton: true,
        dotsDecorator: DotsDecorator(
          activeColor: Theme.of(context).primaryColor,
        ),
        next: Padding(
          padding:   EdgeInsets.only(right: 40),
          child: Container(
            width: 60,
            height: 60,
            decoration:
                BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ),
        onDone: () {

          if (widget.isLoaded==true) {
            widget._interstitialAd.show();

          }
          //TODO: change it to sign in screen
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => NavicationBarScreen(),
              ),
              (route) => false);
        },
        done: Padding(
          padding: const EdgeInsets.only(right: 40),
          child: Container(
            width: 60,
            height: 60,
            decoration:
                BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
// PageViewModel(
// image:
// SvgPicture.asset(
//   config.onboardingImage1,
//   width: MediaQuery.of(context).size.width,
//   alignment: Alignment.center,
//   fit: BoxFit.contain,
// ),
// title: config.onboardingPage1Title,
// body: config.onboardingPage1Subtitle,
// decoration: PageDecoration(
// imageFlex: 2,
// bodyTextStyle: TextStyle(
// color: Colors.black87,
// fontSize: 15.0,
// fontWeight: FontWeight.w500,
// letterSpacing: 0.4,
// ),
// titleTextStyle: TextStyle(
// color: Colors.black87,
// fontSize: 18.0,
// fontWeight: FontWeight.w600,
// letterSpacing: 0.3,
// ),
// ),
// ),
