import 'dart:io';

// import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/config/config.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';
import 'navicationBarScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignupBloc signupBloc;

  MaskedTextController mobileNoController;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String mobileNo, email, name;
  bool inProgress, inProgressApple;

  @override
  void initState() {
    super.initState();
    inProgress = false;
    inProgressApple = false;

    mobileNoController = MaskedTextController(mask: '0000000000');
    signupBloc = BlocProvider.of<SignupBloc>(context);

    signupBloc.listen((state) {
      if (state is SignupWithGoogleInitialCompleted) {
        //proceed to save details
        name = state.firebaseUser.displayName;
        email = state.firebaseUser.email;

        signupBloc.add(SaveUserDetails(
          name: name,
          mobileNo: '',
          email: email,
          firebaseUser: state.firebaseUser,
          loggedInVia: 'GOOGLE',
        ));
      }
      if (state is SignupWithGoogleInitialFailed) {
        //failed to sign in with google
        print('failed to sign in with google');
        showFailedSnakbar('Failed to sign in');
        setState(() {
          inProgress = false;
        });
      }
      if (state is CompletedSavingUserDetails) {
        print(state.user.email);
        //proceed to home
        //close signupBloc

        signupBloc.close();
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NavicationBarScreen()));

        // Navigator.popAndPushNamed(context, '/home');
      }
      if (state is FailedSavingUserDetails) {
        //failed saving user details
        print('failed to save');
        showFailedSnakbar('Failed to save user details!');

        setState(() {
          inProgress = false;
        });
      }
      if (state is SavingUserDetails) {
        //saving user details
        print('Saving user details');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // signupBloc.close();
  }

  signUpWithMobileNo() {
    //validate first
    if (_formKey.currentState.validate()) {
      //proceed
      _formKey.currentState.save();
      // signupBloc.add(
      //     SignupWithMobileNo(email: email, mobileNo: mobileNo, name: name));
      mobileNo = '${Config().countryMobileNoPrefix}$mobileNo';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: email,
            mobileNo: mobileNo,
            name: name,
            isSigningIn: false,
          ),
        ),
      );
    }
  }

  signUpWithGoogle() {
    signupBloc.add(SignupWithGoogle());
  }

  signInWithApple() async {
    setState(() {
      inProgressApple = true;
    });

    try {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(
          requestedScopes: [
            Scope.fullName,
            Scope.email,
          ],
        )
      ]);

      // 2. check the result
      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );
          final authResult =
              await FirebaseAuth.instance.signInWithCredential(credential);
          final firebaseUser = authResult.user;
          final displayName =
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(displayName: displayName);

          User user = FirebaseAuth.instance.currentUser;

          name = firebaseUser.displayName;
          email = firebaseUser.email;

          signupBloc.add(SaveUserDetails(
            name: '',
            mobileNo: '',
            email: email,
            firebaseUser: firebaseUser,
            loggedInVia: 'APPLE',
          ));

          // DocumentSnapshot snapshot = await FirebaseFirestore.instance
          //     .collection(Paths.usersPath)
          //     .doc(user.uid)
          //     .get();

          // if (snapshot.exists) {
          //   if (snapshot.data()['isBlocked']) {
          //     await FirebaseAuth.instance.signOut();
          //     setState(() {
          //       inProgressApple = false;
          //     });
          //     return showFailedSnakbar('Your account has been blocked');
          //   }
          // } else {
          //   await FirebaseAuth.instance.signOut();
          //   setState(() {
          //     inProgressApple = false;
          //   });
          //   return showFailedSnakbar('Account already exists');
          // }

          // return firebaseUser;
          print('SIGNED IN');
          break;

        case AuthorizationStatus.error:
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error.toString(),
          );

        case AuthorizationStatus.cancelled:
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign in aborted by user',
          );
        default:
          throw UnimplementedError();
      }
    } catch (e) {
      print(e);
      setState(() {
        inProgressApple = false;
      });
      showFailedSnakbar('Sign in with Apple failed!');
    }
  }

  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Theme.of(context).primaryColor,
      action: SnackBarAction(
          label: 'OK', textColor: Colors.white, onPressed: () {}),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            SizedBox(height: 120,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "??????????",
                        style: TextStyle(
                          color:  Colors.black
                          ,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        " ???????? ????????",
                        style: TextStyle(
                          color:  Theme.of(context).accentColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        "???????? ???????????? ???????? ?????????????? ?????????????????? ???????????? ???? ??????????????",
                        style: TextStyle(
                          color:  Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
            // Padding(
            //   padding: const EdgeInsets.only(right: 18.0),
            //   child: Container(
            //       height: 250,
            //       width: MediaQuery.of(context).size.width,
            //       child: Padding(
            //         padding: const EdgeInsets.only(bottom: 10.0),
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.end,
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //
            //           ],
            //         ),
            //       )),
            // ),
            ,
            Container(
              height: size.height - 200.0,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                children: <Widget>[
                  SizedBox(
                    height: 60.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Text(
                      " ??????????",
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: nameController,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            name = val;
                          },
                          enableInteractiveSelection: false,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            helperStyle: TextStyle(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w400,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            contentPadding: EdgeInsets.only(right: 15),

                            suffixIcon: Icon(Icons.person,color: Theme.of(context).primaryColor,),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            hintText: '?????????????? ??????????????????',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),

                              borderSide:   BorderSide(
                                color:  Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text(
                                " ?????? ????????????",
                                style: TextStyle(color: Colors.grey.shade800),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          // controller: mobileNoController,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.isEmpty) {
                              return 'Mobile No. is required';
                            }

                            return null;
                          },
                          onSaved: (val) {
                            mobileNo = val;
                          },
                          enableInteractiveSelection: false,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(right: 15),
                            helperStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),

                            prefixText: '20+ ',
                            prefixStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            errorStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            suffixIcon: SvgPicture.asset(
                                "assets/icons/IconPhone.Svg",
                                height: 7,
                                width: 7,color: Theme.of(context).primaryColor,
                                fit: BoxFit.scaleDown),
                            // prefixIconConstraints: BoxConstraints(
                            //   minWidth: 50.0,
                            // ),
                            // labelText: '${S
                            //     .of(context)
                            //     .mobile}',
                            hintText: "???????? ?????? ????????????",
                            // labelStyle: TextStyle(
                            //   color: Colors.black,
                            //   fontSize: 16,
                            //   fontWeight: FontWeight.w400,
                            //
                            // ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(
                                color: Colors.black,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:   BorderSide(
                                color: Theme.of(context).accentColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        // TextFormField(
                        //   controller: emailController,
                        //   textAlignVertical: TextAlignVertical.center,
                        //   validator: (String val) {
                        //     if (val.trim().isEmpty) {
                        //       return 'Email Address is required';
                        //     }
                        //     if (!RegExp(
                        //             r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$")
                        //         .hasMatch(val)) {
                        //       return 'Please enter a valid email address';
                        //     }
                        //     return null;
                        //   },
                        //   onSaved: (val) {
                        //     email = val;
                        //   },
                        //   enableInteractiveSelection: false,
                        //   style: GoogleFonts.poppins(
                        //     color: Colors.black,
                        //     fontSize: 14.5,
                        //     fontWeight: FontWeight.w500,
                        //     letterSpacing: 0.5,
                        //   ),
                        //   textInputAction: TextInputAction.done,
                        //   keyboardType: TextInputType.emailAddress,
                        //   decoration: InputDecoration(
                        //     contentPadding: EdgeInsets.all(0),
                        //     helperStyle: GoogleFonts.poppins(
                        //       color: Colors.black.withOpacity(0.65),
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     errorStyle: GoogleFonts.poppins(
                        //       fontSize: 13.0,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     hintStyle: GoogleFonts.poppins(
                        //       color: Colors.black54,
                        //       fontSize: 14.5,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     prefixIcon: Icon(
                        //     prefixIcon: Icon
                        //       Icons.email,
                        //     ),
                        //     prefixIconConstraints: BoxConstraints(
                        //       minWidth: 50.0,
                        //     ),
                        //     labelText: 'Email address',
                        //     labelStyle: GoogleFonts.poppins(
                        //       fontSize: 14.5,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12.0),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                  //   child: Text(
                  //     'By signing up you\'re accepting the Terms and Conditions',
                  //     textAlign: TextAlign.center,
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 12.0,
                  //       color: Colors.black54,
                  //       fontWeight: FontWeight.w400,
                  //       letterSpacing: 0.5,
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Center(
                    child: Container(
                      width: size.width,
                      height: 48.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).accentColor,width: 1.5),
                        borderRadius: BorderRadius.circular(25,)
                      ),
                      child: FlatButton(
                        onPressed: () {
                          //validate inputs
                          signUpWithMobileNo();
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Text(
                          '?????????? ??????????????',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Row(children: <Widget>[
                      Expanded(
                          child:  Divider(
                            color:  Theme.of(context).accentColor,
                          )),
                      Text(
                        "     ????    ",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w400
                        ),
                      ),
                      Expanded(
                          child:  Divider(
                            color: Theme.of(context).accentColor,
                          )),
                    ]),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  buildGoogleSignupButton(size),
                  Platform.isIOS ?    buildAppleSignInButton(size):SizedBox(),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "???????? ???????? ????????????  ??",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/sign_in');
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          "?????????? ????????????",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            // letterSpacing: 0.5,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoogleSignupButton(Size size) {
    return Center(
      child: inProgress
          ? CircularProgressIndicator()
          : Container(
              width: size.width,
              height: 48.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).accentColor), borderRadius: BorderRadius.circular(25)),
              child: FlatButton(
                onPressed: () {
                  signUpWithGoogle();
                  setState(() {
                    inProgress = true;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '?????????????? ?????????????? ?????????????? ????????',
                      style: TextStyle(
                        color:Theme.of(context).primaryColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Icon(
                      FontAwesomeIcons.google,
                      color: Theme.of(context).primaryColor,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildAppleSignInButton(Size size) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Center(
          child: inProgressApple
              ? CircularProgressIndicator()
              : Container(
                  width: size.width,
                  height: 48.0,
                  decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(25)),
                  child: FlatButton(
                    onPressed: () async {
                      // signinBloc.add(SignInWithGoogle());

                      signInWithApple();
                    },
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '?????????? ???????????? ???????????? Apple',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Icon(
                          FontAwesomeIcons.apple,
                          color: Colors.grey.shade800,
                          size: 24.0,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
