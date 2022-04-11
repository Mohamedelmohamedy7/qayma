// import 'package:grocery_store/config/config.dart';
// import 'package:grocery_store/screens/home_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:introduction_screen/introduction_screen.dart';
//
// class ReadyTools extends StatefulWidget {
//   static final String id = 'onboarding_screen_id';
//
//   @override
//   _ReadyToolsState createState() => _ReadyToolsState();
// }
//
// class _ReadyToolsState extends State<ReadyTools> {
//   Config config;
//
//   @override
//   void initState() {
//     super.initState();
//
//     config = Config();
//   }
//
//   List<PageViewModel> getPages() {
//     return [
//       PageViewModel(
//         image: Image.asset(
//           "assets/images/firstOnBordingRead.png",
//           width: double.infinity,
//           fit: BoxFit.cover,
//         ),
//         // SvgPicture.asset(
//         //   config.onboardingImage1,
//         //   width: MediaQuery.of(context).size.width,
//         //   alignment: Alignment.center,
//         //   fit: BoxFit.contain,
//         // ),
//         title: config.onboardingPage1Title,
//         body: config.onboardingPage1Subtitle,
//         decoration: PageDecoration(
//           imageFlex: 18,
//           bodyTextStyle: GoogleFonts.poppins(
//             color: Colors.black87,
//             fontSize: 15.0,
//             fontWeight: FontWeight.w500,
//             letterSpacing: 0.4,
//           ),
//           titleTextStyle: GoogleFonts.poppins(
//             color: Colors.black87,
//             fontSize: 18.0,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ),
//       // PageViewModel(
//       //   image: Image.asset("assets/images/onboardingscreen.png",width: double.infinity,fit: BoxFit.cover,),
//       //   // SvgPicture.asset(
//       //   //   config.onboardingImage1,
//       //   //   width: MediaQuery.of(context).size.width,
//       //   //   alignment: Alignment.center,
//       //   //   fit: BoxFit.contain,
//       //   // ),
//       //   title: config.onboardingPage1Title,
//       //   body: config.onboardingPage1Subtitle,
//       //   decoration: PageDecoration(
//       //     imageFlex: 2,
//       //     bodyTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 15.0,
//       //       fontWeight: FontWeight.w500,
//       //       letterSpacing: 0.4,
//       //     ),
//       //     titleTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 18.0,
//       //       fontWeight: FontWeight.w600,
//       //       letterSpacing: 0.3,
//       //     ),
//       //   ),
//       // ),
//       // PageViewModel(
//       //   image: Image.asset("assets/images/onboardingscreen.png",width: double.infinity,fit: BoxFit.cover,),
//       //   // SvgPicture.asset(
//       //   //   config.onboardingImage1,
//       //   //   width: MediaQuery.of(context).size.width,
//       //   //   alignment: Alignment.center,
//       //   //   fit: BoxFit.contain,
//       //   // ),
//       //   title: config.onboardingPage1Title,
//       //   body: config.onboardingPage1Subtitle,
//       //   decoration: PageDecoration(
//       //     imageFlex: 2,
//       //     bodyTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 15.0,
//       //       fontWeight: FontWeight.w500,
//       //       letterSpacing: 0.4,
//       //     ),
//       //     titleTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 18.0,
//       //       fontWeight: FontWeight.w600,
//       //       letterSpacing: 0.3,
//       //     ),
//       //   ),
//       // ),
//       // PageViewModel(
//       //   image: SvgPicture.asset(
//       //     config.onboardingImage2,
//       //     width: MediaQuery.of(context).size.width,
//       //     alignment: Alignment.center,
//       //     fit: BoxFit.contain,
//       //   ),
//       //   title: config.onboardingPage2Title,
//       //   body: config.onboardingPage2Subtitle,
//       //   decoration: PageDecoration(
//       //     imageFlex: 1,
//       //     bodyTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 15.0,
//       //       fontWeight: FontWeight.w500,
//       //       letterSpacing: 0.4,
//       //     ),
//       //     titleTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 18.0,
//       //       fontWeight: FontWeight.w600,
//       //       letterSpacing: 0.3,
//       //     ),
//       //   ),
//       // ),
//       // PageViewModel(
//       //   image: SvgPicture.asset(
//       //     config.onboardingImage3,
//       //     width: MediaQuery.of(context).size.width,
//       //     alignment: Alignment.center,
//       //     fit: BoxFit.contain,
//       //   ),
//       //   title: config.onboardingPage3Title,
//       //   body: config.onboardingPage3Subtitle,
//       //   decoration: PageDecoration(
//       //     imageFlex: 1,
//       //     bodyTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 15.0,
//       //       fontWeight: FontWeight.w500,
//       //       letterSpacing: 0.4,
//       //     ),
//       //     titleTextStyle: GoogleFonts.poppins(
//       //       color: Colors.black87,
//       //       fontSize: 18.0,
//       //       fontWeight: FontWeight.w600,
//       //       letterSpacing: 0.3,
//       //     ),
//       //   ),
//       // )
//     ];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IntroductionScreen(
//         pages: getPages(),
//         showNextButton: true,
//         next: Padding(
//           padding: const EdgeInsets.only(right: 40),
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration:
//                 BoxDecoration(color: Color(0xff00B6E6), shape: BoxShape.circle),
//             child: Icon(
//               Icons.arrow_forward,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         onDone: () {
//           //TODO: change it to sign in screen
//           Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HomeScreen(),
//               ),
//               (route) => false);
//         },
//         done: Padding(
//           padding: const EdgeInsets.only(right: 40),
//           child: Container(
//             width: 60,
//             height: 60,
//             decoration:
//                 BoxDecoration(color: Color(0xff00B6E6), shape: BoxShape.circle),
//             child: Icon(
//               Icons.arrow_forward,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
