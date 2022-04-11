import 'dart:async';

import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/navicationBarScreen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'ReadyScreen.dart';

class VerificationScreen extends StatefulWidget {
  final String mobileNo;
  final String name;
  final String email;
  final bool isSigningIn;

  const VerificationScreen({
    this.mobileNo,
    this.email,
    this.name,
    this.isSigningIn,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _timer;
  SignupBloc signupBloc;
  MaskedTextController otpController = MaskedTextController(mask: '000000');
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer timer;

  bool inProgress;

  String smsCode;

  @override
  void initState() {
    super.initState();

    signupBloc = BlocProvider.of<SignupBloc>(context);
    inProgress = false;

    signupBloc.listen((state) {
      if (state is VerifyMobileNoCompleted) {
        //proceed and save the data
        print('USER ID: ${state.user.uid}');
        // setState(() {
        //   inProgress = false;
        // });

        if (widget.isSigningIn) {
          //sign in
          //proceed to home
          //close signupBloc

          signupBloc.close();
          // Navigator.pushNamed(
          //   context,
          //   '/home',
          //   // (route) => false,
          // );
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => NavicationBarScreen(),));
        } else {
          //sign up
          signupBloc.add(
            SaveUserDetails(
              name: widget.name,
              mobileNo: widget.mobileNo,
              email: widget.email,
              firebaseUser: state.user,
              loggedInVia: 'MOBILE_NO',
            ),
          );
        }
      }
      if (state is VerifyMobileNoInProgress) {
        //show progress bar
        print('verification in progress');
        setState(() {
          inProgress = true;
        });
      }
      if (state is VerifyMobileNoFailed) {
        //failed
        print('verification failed');
        showFailedSnakbar('Verification failed!');
        setState(() {
          inProgress = false;
        });
      }
      if (state is VerificationCompleted) {
        //proceed and save the data
        print('sent otp');
        setState(() {
          inProgress = false;
        });
      }
      if (state is VerificationInProgress) {
        //show progress bar
        print('verification in progress');
        setState(() {
          inProgress = true;
        });
      }
      if (state is VerificationFailed) {
        //failed
        print('verification failed');
        showFailedSnakbar('Failed to send otp!');
        setState(() {
          inProgress = false;
        });
      }
      if (state is CompletedSavingUserDetails) {
        print(state.user.mobileNo);
        //proceed to home
        //close signupBloc

        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   '/home',
        //   (route) => false,
        // );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NavicationBarScreen(),)
        );
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

    signupBloc.add(
      SignupWithMobileNo(
        name: widget.name,
        mobileNo: widget.mobileNo,
        email: widget.email,
      ),
    );

    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = 60;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timer--;
      });
      if (_timer == 0) {
        timer.cancel();
      }
    });
  }

  void showFailedSnakbar(String s) {
    SnackBar snackbar = SnackBar(
      content: Text(
        s,
        style: GoogleFonts.poppins(
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
  StreamController<ErrorAnimationType> errorController;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon:SvgPicture.asset("assets/icon/back.svg",color: Colors.grey.shade900,),
            onPressed: ()=>Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              // Text("${_timer}",style: TextStyle(fontSize: 40),),
              // Container(
              //   height: 228,
              //   width: 252.37,
              //   // width: double.infinity,
              //   // width: MediaQuery.of(context).size.width-100,
              //   // child: SvgPicture.asset("assets/icons/SmsIcon.svg",fit: BoxFit.cover,),
              // ),
              Row(
                children: [
                  Text(
                    'تأكيد الدخول',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Row(
                children: [
                  Text(
                    'لقد تم ارسال الكود الخاص بكم',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                   letterSpacing: 2 ),

                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'الى رقم الهاتف',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,  letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${widget.mobileNo}",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.85),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40.0,
              ),

              Container(
                height: 70.0,
                padding:
                    const EdgeInsets.only(left: 40),
                child:  Directionality(
                  textDirection:TextDirection.ltr,
                  child:PinCodeTextField(
                    length: 6,
                    cursorColor: Theme.of(context).primaryColor,
                    obscureText: false,
                    animationType: AnimationType.fade,textStyle: TextStyle(
                      color:Colors.black,fontSize: 30
                  ),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.circle,
                      inactiveColor: Theme.of(context).accentColor,
                      activeColor: Theme.of(context).primaryColor,
                      disabledColor: Colors.black.withOpacity(.04),
                      inactiveFillColor: Colors.grey.shade200,
                      selectedFillColor: Colors.transparent,
                      fieldHeight: 50,
                      fieldWidth: 50,
                      selectedColor: Colors.grey,
                      activeFillColor: Colors.white,
                    ),
                    animationDuration: Duration(milliseconds: 300),
                    // backgroundColor: Colors.blue.shade50,
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    keyboardType: TextInputType.number,
                    enablePinAutofill: true,
                    controller: otpController,
                    validator: (String val) {
                      if (val.isEmpty) {
                        return '*هذة الحقل مطلوب';
                      } else if (val.length < 6) {
                        // return 'الكود غير صحيح';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      smsCode = val;
                    }, appContext: context,
                  )
                ),


                ),
              SizedBox(
                height: 130.0,
              ),

              buildVerificationBtn(context, inProgress),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVerificationBtn(BuildContext context, bool inProgress) {
    return inProgress
        ? Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              width: double.infinity,
              height: 48.0,
              padding:   EdgeInsets.symmetric(horizontal: 0.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Theme.of(context).accentColor,width: 1.5)
              ),
              child: FlatButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/checkout');
                  signupBloc.add(VerifyMobileNo(smsCode));
                  setState(() {
                    inProgress = true;
                  });
                },
                color:Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Text(
                  'تأكيـــد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        );
  }
}
