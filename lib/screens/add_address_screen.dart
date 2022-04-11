// import 'dart:io';
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flushbar/flushbar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geocoder/geocoder.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
// import 'package:grocery_store/models/user.dart';
// import 'package:location/location.dart';
// import 'package:location_permissions/location_permissions.dart';
// import 'package:provider/provider.dart';
// import '../home_provider.dart';
// import '../widget/processing_dialog.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/models/user.dart';
// import 'package:grocery_store/models/user.dart';
import 'package:location/location.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:provider/provider.dart';
import '../home_provider.dart';
import '../widget/processing_dialog.dart';

class
AddAddressScreen extends StatefulWidget {
  final User currentUser;
  final GroceryUser user;

  AddAddressScreen({this.currentUser, this.user});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AccountBloc accountBloc;
  bool isAdded;
  String addressLine1,
      addressLine2,
      houseNo,
      landmark,
      city,
      state,
      pincode,
      country;
  LatLng currentPostion;
  List<Address> addresses;
  Address currentadd;
  bool loading = true;
  var currentLocation = LocationData;

  var location = new Location();
  Addresscust address = Addresscust();
  List<Addresscust> allAddresses = List();

  bool isDefault = true;
  int defaultAddress;

  @override
  void initState() {
    super.initState();

    isDefault = false;
    isAdded = false;

    if (Provider.of<HomeProvider>(context, listen: false).locationResult !=
        null) {
      _controllerAddresLine.text =
          Provider.of<HomeProvider>(context, listen: false)
              .locationResult
              .placeId;
      _controllerAddresLat.text =
          Provider.of<HomeProvider>(context, listen: false)
              .locationResult
              .latLng
              .latitude
              .toString();
      print(_controllerAddresLat.text);

      _controllerLongr.text = Provider.of<HomeProvider>(context, listen: false)
          .locationResult
          .latLng
          .longitude
          .toString();
      print(_controllerLongr.text);

      _controller.text = Provider.of<HomeProvider>(context, listen: false)
          .locationResult
          .country
          .toString();
      _controllerpin.text = Provider.of<HomeProvider>(context, listen: false)
          .locationResult
          .placeId;

      _controllerStat.text = Provider.of<HomeProvider>(context, listen: false)
          .locationResult
          .placeId;
      _controller4.text = Provider.of<HomeProvider>(context, listen: false)
          .locationResult
          .placeId;
      _controllerHouseNumber.text =
          Provider.of<HomeProvider>(context, listen: false)
              .locationResult
              .placeId;
    } else
      getUserLocation();
    widget.user.address.length == 0
        ? defaultAddress = 0
        : defaultAddress = int.parse(widget.user.defaultAddress);

    accountBloc = BlocProvider.of<AccountBloc>(context);

    allAddresses = widget.user.address.cast<Addresscust>();

    accountBloc.listen((state) {
      print(state);

      if (isAdded) {
        if (state is AddAddressCompletedState) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
        if (state is AddAddressFailedState) {
          //show popup
          showSnack('فشل إضافة العنوان', context);
        }
        if (state is AddAddressInProgressState) {
          //show popup
          showUpdatingDialog();
        }
      }
    });
  }

  Future getUserLocation() async {
    await LocationPermissions().requestPermissions();

    var position = await location.getLocation();
    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
    });
    await yourFunction();
    setState(() {
      loading = false;
    });
    print("done");
    return position;
  }

  yourFunction() async {
    // PublicProvider publicProvider =
    // Provider.of<PublicProvider>(context,listen: false );
    try {
      final coordinates =
      new Coordinates(currentPostion.latitude, currentPostion.longitude);
      addresses = await Geocoder.google(
          Platform.isAndroid
              ? "AIzaSyA_kAFbSnsXuzplkJ5WwP1nT1lCD9KIw6U"
              : "AIzaSyDfa9shr2ot5xoa0h2yDbzEPIKPzbHVTb8",
          language: "ar")
          .findAddressesFromCoordinates(coordinates);
      // await Geocoder.local.findAddressesFromCoordinates(coordinates);
      currentadd = addresses.first;
      _controllerAddresLine.text = currentadd.addressLine;
      _controllerAddresLat.text = currentadd.coordinates.latitude.toString();
      print(_controllerAddresLat.text);

      _controllerLongr.text = currentadd.coordinates.longitude.toString();
      print(_controllerLongr.text);

      _controller.text = currentadd.countryName.toString();
      _controllerpin.text = currentadd.postalCode;

      _controllerStat.text = currentadd.adminArea;
      _controller4.text = currentadd.locality;
      _controllerHouseNumber.text = currentadd.subThoroughfare;
      // publicProvider.listenAddress(Frist: first);
    } catch (e) {
      print(e);
    }
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message:
          'جاري إضافة العنوان\nالرجاء الانتظار',
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
        style: GoogleFonts.tajawal(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  void addAddress() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      print('save address');
      print(addressLine1);
      print(addressLine2);
      print(city);
      print(state);
      print(country);
      print(pincode);
      print(landmark);
      print(houseNo);

      Map<String, dynamic> addressMap = Map();
      addressMap.putIfAbsent(
          'addressLine1', () => _controllerAddresLine.text ?? '');
      addressMap.putIfAbsent('addressLine2', () => addressLine2 ?? '');
      addressMap.putIfAbsent('city', () => _controller4.text ?? '');
      addressMap.putIfAbsent('state', () => _controllerStat.text ?? '');
      addressMap.putIfAbsent('country', () => _controller.text ?? '');
      addressMap.putIfAbsent('pincode', () => _controllerpin.text ?? '');
      addressMap.putIfAbsent('landmark', () => landmark ?? '');
      addressMap.putIfAbsent('lat', () => _controllerAddresLat.text ?? '');
      addressMap.putIfAbsent('long', () => _controllerLongr.text ?? '');
      addressMap.putIfAbsent(
          'houseNo', () => _controllerHouseNumber.text ?? '');

      // widget.user.address.add(address);
      allAddresses.add(Addresscust.fromHashmap(addressMap));

      accountBloc.add(
        AddAddressEvent(
          allAddresses,
          widget.currentUser.uid,
          defaultAddress,
        ),
      );
      print('after');

      isAdded = true;
    }
  }

  TextEditingController _controller = new TextEditingController();
  TextEditingController _controllerpin = new TextEditingController();
  TextEditingController _controllerlandmark = new TextEditingController();
  TextEditingController _controller4 = new TextEditingController();
  TextEditingController _controllerStat = new TextEditingController();
  TextEditingController _controllerAddresLine = new TextEditingController();
  TextEditingController _controllerHouseNumber = new TextEditingController();
  TextEditingController _controllerAddresLat = new TextEditingController();
  TextEditingController _controllerLongr = new TextEditingController();
  final Set<Marker> markers = Set()
    ..add(
      Marker(
        position: LatLng(31.037933, 31.381523),
        markerId: MarkerId("selected-location"),
      ),
    );
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: InkWell(
            splashColor: Colors.white.withOpacity(0.5),
            onTap: () {
              Navigator.pop(context);
            },
            child: SvgPicture.asset('assets/icons/backarrow.svg', fit: BoxFit.scaleDown,)
        ),
        title: Text(
          'إضافة عنوان',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          // loading ==false?
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // TextFormField(
                        //   controller: _controllerHouseNumber,
                        //   textAlignVertical: TextAlignVertical.center,
                        //   validator: (String val) {
                        //     if (val.trim().isEmpty) {
                        //       return 'House no. is required';
                        //     }
                        //     return null;
                        //   },
                        //   onSaved: (val) {
                        //     houseNo = val.trim();
                        //   },
                        //   enableInteractiveSelection: false,
                        //   style: GoogleFonts.tajawal(
                        //     color: Colors.black,
                        //     fontSize: 14.5,
                        //     fontWeight: FontWeight.w500,
                        //     letterSpacing: 0.5,
                        //   ),
                        //   textInputAction: TextInputAction.done,
                        //   keyboardType: TextInputType.number,
                        //   decoration: InputDecoration(
                        //     contentPadding: EdgeInsets.all(0),
                        //     helperStyle: GoogleFonts.tajawal(
                        //       color: Colors.black.withOpacity(0.65),
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     errorStyle: GoogleFonts.tajawal(
                        //       fontSize: 13.0,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     hintStyle: GoogleFonts.tajawal(
                        //       color: Colors.black54,
                        //       fontSize: 14.5,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     prefixIcon: Icon(
                        //       Icons.home,
                        //     ),
                        //     prefixIconConstraints: BoxConstraints(
                        //       minWidth: 50.0,
                        //     ),
                        //     labelText: '${S.of(context).HouseBuilding}.',
                        //     labelStyle: GoogleFonts.tajawal(
                        //       fontSize: 14.5,
                        //       fontWeight: FontWeight.w500,
                        //       letterSpacing: 0.5,
                        //     ),
                        //     border: OutlineInputBorder(
                        //       borderRadius: BorderRadius.circular(12.0),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'العنوان بالكامل مطلوب';
                            }
                            return null;
                          },
                          controller: _controllerAddresLine,
                          onSaved: (val) {
                            addressLine1 = val.trim();
                          },
                          style: GoogleFonts.tajawal(
                            fontSize: 14.5,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,

                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey.shade300,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),

                            errorStyle: GoogleFonts.tajawal(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            suffixIcon: Icon(
                              Icons.location_on, color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'العنوان بالكامل',
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return "العنوان مطلوب";
                            }
                            return null;
                          },
                          onSaved: (val) {
                            // val = currentadd.;
                            addressLine2 = val.trim();
                          },
                          style: GoogleFonts.tajawal(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,

                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey.shade300,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            suffixIcon: Icon(
                              Icons.location_on, color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: "العنوان",
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          onSaved: (val) {
                            landmark = val.trim();
                          },
                          controller: _controllerlandmark,
                          style: GoogleFonts.tajawal(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,

                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey.shade300,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            suffixIcon: Icon(
                              Icons.local_convenience_store, color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'علامة مميزة (اختياري)',
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return "حقل المدينة مطلوب";
                            }
                            return null;
                          },
                          controller: _controller4,
                          onSaved: (val) {
                            city = val.trim();
                          },
                          style: GoogleFonts.tajawal(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,

                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey.shade300,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: GoogleFonts.tajawal(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.tajawal(
                              color: Colors.black54,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            suffixIcon: Icon(
                              Icons.location_city, color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'المدينة',
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'حقل المحافظة مطلوب';
                            }
                            return null;
                          },
                          controller: _controllerStat,
                          onSaved: (val) {
                            state = val.trim();
                          },
                          style: GoogleFonts.tajawal(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,

                          cursorColor: Theme.of(context).primaryColor,

                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey.shade300,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: GoogleFonts.tajawal(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.tajawal(
                              color: Colors.black54,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            suffixIcon: Icon(
                              Icons.map, color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'المحافظة',
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: _controller,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'حقل الدولة مطلوب';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            country = val.trim();
                          },
                          style: GoogleFonts.tajawal(
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,

                          cursorColor: Theme.of(context).primaryColor,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Colors.grey.shade300,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: GoogleFonts.tajawal(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            hintStyle: GoogleFonts.tajawal(
                              color: Colors.black54,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            suffixIcon: Icon(
                              Icons.location_on, color: Theme.of(context).primaryColor,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),
                            labelText: 'الدولة',
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),

                        CheckboxListTile(
                          dense: true,
                          value: isDefault,
                          onChanged: (value) {
                            if (value) {
                              defaultAddress = widget.user.address.length;
                            } else {
                              defaultAddress =
                                  int.parse(widget.user.defaultAddress);
                            }
                            setState(() {
                              isDefault = value;
                            });

                            print(defaultAddress);
                          },
                          activeColor: Theme.of(context).primaryColor,
                          title: Text(
                            'تعيين كعنوان رئيسي',
                            style: GoogleFonts.tajawal(
                              color: Colors.black87,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 10.0,
                        ),
                        // Container(
                        //   height: 45.0,
                        //   width: double.infinity,
                        //   padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        //   child: FlatButton(
                        //     onPressed: () {
                        //       //add address
                        //       getUserLocation();
                        //       _controllerAddresLine.text =
                        //           currentadd.subLocality;
                        //       _controller.text =
                        //           currentadd.countryName.toString();
                        //       _controllerpin.text =
                        //           currentadd.postalCode;
                        //       _controllerStat.text = currentadd.adminArea;
                        //       // _controller4.text = currentadd.locality;
                        //       _controllerHouseNumber.text =
                        //           currentadd.subThoroughfare;
                        //       print(currentadd.countryName);
                        //     },
                        //     color: Theme.of(context).primaryColor,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(15.0),
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: <Widget>[
                        //         Icon(
                        //           Icons.add_location,
                        //           color: Colors.white,
                        //           size: 20.0,
                        //         ),
                        //         SizedBox(
                        //           width: 10.0,
                        //         ),
                        //         Text(
                        //           '${S.of(context).get_Current_Location}',
                        //           style: GoogleFonts.tajawal(
                        //             color: Colors.white,
                        //             fontSize: 15.0,
                        //             fontWeight: FontWeight.w600,
                        //             letterSpacing: 0.3,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   height: 20.0,
                        // ),
                        Container(
                          height: 63,
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 30),
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: FlatButton(
                            onPressed: () {
                              //add address
                              addAddress();
                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'احفظ العنوان',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),

                                SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 22.0,
                                ),

                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )

          //     :Expanded(child: Center(child: CircularProgressIndicator()),
          // )
        ],
      ),
    );
  }

  Padding appBarRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(50.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.white.withOpacity(0.5),
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  width: 38.0,
                  height: 35.0,
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.black,
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            '{S.of(context).add_address}',
            style: GoogleFonts.tajawal(
              color: Colors.black,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
