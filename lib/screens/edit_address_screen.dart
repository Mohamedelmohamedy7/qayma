import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/models/user.dart';
import 'package:location/location.dart';
import '../widget/processing_dialog.dart';

class EditAddressScreen extends StatefulWidget {
  final User currentUser;
  final GroceryUser user;
  final int index;
  LatLng currentPostion;
  List addresses;
  var currentadd;
  EditAddressScreen({this.currentUser, this.user, this.index});

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Addresscust> allAddresses = List();

  AccountBloc accountBloc;
  bool isEdited;
  String addressLine1,
      addressLine2,
      houseNo,
      landmark,
      city,
      state,
      pincode,
      country;

  Addresscust address = Addresscust();

  bool isDefault;
  int defaultAddress;
  TextEditingController _controller = new TextEditingController();
  TextEditingController _controllerpin = new TextEditingController();
  TextEditingController _controllerlandmark = new TextEditingController();
  TextEditingController _controller4 = new TextEditingController();
  TextEditingController _controllerStat = new TextEditingController();
  TextEditingController _controllerAddresLine = new TextEditingController();
  TextEditingController _controllerHouseNumber = new TextEditingController();
  TextEditingController _controllerAddresLat = new TextEditingController();
  TextEditingController _controllerLongr = new TextEditingController();
  LatLng currentPostion;
  List addresses;
  var currentadd;
  @override
  void initState() {
    super.initState();
    // getUserLocation();
    isEdited = false;
    accountBloc = BlocProvider.of<AccountBloc>(context);

    allAddresses = widget.user.address.cast<Addresscust>();
    address = allAddresses[widget.index];
    _controllerAddresLine.text = address.addressLine1;
    addressLine2 = address.addressLine2;
    _controller4.text = address.city;
    _controllerStat.text = address.state;
    _controller.text = address.country;

    pincode = address.pincode;
    _controllerlandmark.text = address.landmark;
    houseNo = address.houseNo;

    defaultAddress = int.parse(widget.user.defaultAddress);
    if (defaultAddress == widget.index) {
      isDefault = true;
    } else {
      isDefault = false;
    }

    print('INDEX :: ${widget.index}');

    accountBloc.listen((state) {
      print(state);
      if (isEdited) {
        if (state is EditAddressCompletedState) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
        if (state is EditAddressFailedState) {
          //show popup
          showSnack('فشل تحديث العنوان', context);
        }
        if (state is EditAddressInProgressState) {
          //show popup
          showPopupDialog(
              'جاري تحديث العنوان\nالرجاء الانتظار!');
        }
        if (state is RemoveAddressCompletedState) {
          Navigator.pop(context);
          Navigator.pop(context, true);
        }
        if (state is RemoveAddressFailedState) {
          //show popup
          showSnack('فشل حذف العنوان', context);
        }
        if (state is RemoveAddressInProgressState) {
          //show popup
          showPopupDialog(
              'جاري حذف العنوان\nالرجاء الانتظار!');
        }
      }
    });
  }

  var location = new Location();

  yourFunction() async {
    // PublicProvider publicProvider =
    // Provider.of<PublicProvider>(context,listen: false );ب

    try {
      final coordinates =
      new Coordinates(currentPostion.latitude, currentPostion.longitude);
      addresses = await Geocoder.google(
          "AIzaSyD-Aoly1mSKaaPljkgdkT0niwW_zeHDOrA",
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

  showPopupDialog(String message) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: message,
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
      duration: Duration(milliseconds: 2500),
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

  void updateAddress() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      Map<String, dynamic> addressMap = Map();
      addressMap.putIfAbsent(
          'addressLine1', () => _controllerAddresLine.text ?? '');
      addressMap.putIfAbsent('addressLine2', () => addressLine2 ?? '');
      addressMap.putIfAbsent('city', () => _controller4.text ?? '');
      addressMap.putIfAbsent('state', () => _controllerStat.text ?? '');
      addressMap.putIfAbsent('country', () => _controller.text ?? '');
      addressMap.putIfAbsent('pincode', () => _controllerpin.text ?? '');
      addressMap.putIfAbsent('landmark', () => landmark ?? '');
      addressMap.putIfAbsent(
          'houseNo', () => _controllerHouseNumber.text ?? '');
      addressMap.putIfAbsent('lat', () => _controllerAddresLat.text ?? '');
      addressMap.putIfAbsent('long', () => _controllerLongr.text ?? '');
      // addressMap.putIfAbsent('addressLine1', () => addressLine1);
      // addressMap.putIfAbsent('addressLine2', () => addressLine2);
      // addressMap.putIfAbsent('city', () => city);
      // addressMap.putIfAbsent('state', () => state);
      // addressMap.putIfAbsent('country', () => country);
      // addressMap.putIfAbsent('pincode', () => pincode);
      // addressMap.putIfAbsent('landmark', () => landmark);
      // addressMap.putIfAbsent('houseNo', () => houseNo);

      allAddresses.removeAt(widget.index);

      allAddresses.insert(widget.index, Addresscust.fromHashmap(addressMap));

      accountBloc.add(
        EditAddressEvent(
          allAddresses,
          widget.currentUser.uid,
          defaultAddress,
        ),
      );

      isEdited = true;
    }
  }

  void deleteAddress() {
    allAddresses.removeAt(widget.index);

    if (widget.user.defaultAddress == widget.index.toString()) {
      isDefault = true;
    } else {
      isDefault = false;
    }

    accountBloc.add(
      RemoveAddressEvent(
        allAddresses,
        widget.currentUser.uid,
        isDefault,
      ),
    );
    isEdited = true;
  }

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
          'تعديل العنوان',
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
          Expanded(
            child: ListView(
              shrinkWrap: true,
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
                            color: Colors.black,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          readOnly: true,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          cursorColor: Theme.of(context).primaryColor,

                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.5, color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
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
                              Icons.location_on,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 50.0,
                            ),

                            labelText: 'العنوان بالكامل',
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return "العنوان";
                            }
                            return null;
                          },
                          initialValue: addressLine2,
                          onSaved: (val) {
                            // val = currentadd.addressLine;
                            addressLine2 = val.trim();
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
                                    width: 0.5, color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                            labelText: "العنوان",
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
                                    width: 0.5, color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                                    width: 0.5, color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Colors.orange.shade600,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                              color: Theme.of(context).primaryColor,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
                                    width: 0.5, color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color:Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                              color: Theme.of(context).primaryColor,

                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
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
                                    width: 0.5, color: Colors.grey.shade400)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 0.5,
                                  color: Theme.of(context).primaryColor,
                                )),
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            helperStyle: GoogleFonts.tajawal(
                              color: Colors.black.withOpacity(0.65),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
                              color: Theme.of(context).primaryColor,
                              fontSize: 14.5,
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
                            if (int.parse(widget.user.defaultAddress) ==
                                widget.index) {
                              //show popup of cant unset as default address
                              showSnack(
                                'لا يمكنك إلغاء تعيين العنوان الافتراضي\nانتقل إلى عنوان آخر وقم بتعيينه كعنوان افتراضي',
                                context,
                              );
                            } else {
                              if (value) {
                                defaultAddress = widget.index;
                              } else {
                                defaultAddress =
                                    int.parse(widget.user.defaultAddress);
                              }
                              setState(() {
                                isDefault = value;
                              });
                            }

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
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          height: 63.0,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: FlatButton(
                            onPressed: () {
                              //add address
                              updateAddress();
                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "تحديث العنوان",
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
                                  Icons.add_location,
                                  color: Colors.white,
                                  size: 20.0,
                                ),


                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          height: 45.0,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: FlatButton(
                            onPressed: () {
                              //add address
                              deleteAddress();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "حذف العنوان",
                                  style: GoogleFonts.tajawal(
                                    color: Colors.red,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20.0,
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

                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 20.0,
                //   ),
                //   child: Form(
                //     key: _formKey,
                //     child: Column(
                //       children: <Widget>[
                //         // getlocation(context),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'House no. is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             houseNo = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.houseNo,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.number,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.home,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'House/Building no.',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'Address line 1 is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             addressLine1 = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.addressLine1,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.text,
                //           textCapitalization: TextCapitalization.words,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.location_on,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'Address line 1',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'Address line 2 is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             addressLine2 = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.addressLine2,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.text,
                //           textCapitalization: TextCapitalization.words,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.location_on,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'Address line 2',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           onSaved: (val) {
                //             landmark = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.landmark,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.text,
                //           textCapitalization: TextCapitalization.words,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.local_convenience_store,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'Landmark (optional)',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'City is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             city = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.city,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.text,
                //           textCapitalization: TextCapitalization.words,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.location_city,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'City',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'State is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             state = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.state,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.text,
                //           textCapitalization: TextCapitalization.words,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.map,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'State',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'Pincode is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             pincode = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.pincode,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.number,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.my_location,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'Pincode',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         TextFormField(
                //           textAlignVertical: TextAlignVertical.center,
                //           validator: (String val) {
                //             if (val.trim().isEmpty) {
                //               return 'Country is required';
                //             }
                //             return null;
                //           },
                //           onSaved: (val) {
                //             country = val.trim();
                //           },
                //           enableInteractiveSelection: false,
                //           style: GoogleFonts.cairo(
                //             color: Colors.black,
                //             fontSize: 14.5,
                //             fontWeight: FontWeight.w500,
                //             letterSpacing: 0.5,
                //           ),
                //           initialValue: address.country,
                //           textInputAction: TextInputAction.done,
                //           keyboardType: TextInputType.text,
                //           textCapitalization: TextCapitalization.words,
                //           decoration: InputDecoration(
                //             contentPadding: EdgeInsets.all(0),
                //             helperStyle: GoogleFonts.cairo(
                //               color: Colors.black.withOpacity(0.65),
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             errorStyle: GoogleFonts.cairo(
                //               fontSize: 13.0,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             hintStyle: GoogleFonts.cairo(
                //               color: Colors.black54,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             prefixIcon: Icon(
                //               Icons.location_on,
                //             ),
                //             prefixIconConstraints: BoxConstraints(
                //               minWidth: 50.0,
                //             ),
                //             labelText: 'Country',
                //             labelStyle: GoogleFonts.cairo(
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.5,
                //             ),
                //             border: OutlineInputBorder(
                //               borderRadius: BorderRadius.circular(12.0),
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10.0,
                //         ),
                //         CheckboxListTile(
                //           dense: true,
                //           value: isDefault,
                //           onChanged: (value) {
                //             if (int.parse(widget.user.defaultAddress) ==
                //                 widget.index) {
                //               //show popup of cant unset as default address
                //               showSnack(
                //                 'You cannot unset the default address\nGo to other address and set it as default',
                //                 context,
                //               );
                //             } else {
                //               if (value) {
                //                 defaultAddress = widget.index;
                //               } else {
                //                 defaultAddress =
                //                     int.parse(widget.user.defaultAddress);
                //               }
                //               setState(() {
                //                 isDefault = value;
                //               });
                //             }
                //
                //             print(defaultAddress);
                //           },
                //           activeColor: Theme.of(context).primaryColor,
                //           title: Text(
                //             'Set as default address',
                //             style: GoogleFonts.cairo(
                //               color: Colors.black87,
                //               fontSize: 14.5,
                //               fontWeight: FontWeight.w500,
                //               letterSpacing: 0.3,
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 10.0,
                //         ),
                //         Container(
                //           height: 45.0,
                //           width: double.infinity,
                //           padding: const EdgeInsets.symmetric(horizontal: 0.0),
                //           child: FlatButton(
                //             onPressed: () {
                //               //add address
                //               updateAddress();
                //             },
                //             color: Theme.of(context).primaryColor,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(15.0),
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: <Widget>[
                //                 Icon(
                //                   Icons.add_location,
                //                   color: Colors.white,
                //                   size: 20.0,
                //                 ),
                //                 SizedBox(
                //                   width: 10.0,
                //                 ),
                //                 Text(
                //                   'Update Address',
                //                   style: GoogleFonts.cairo(
                //                     color: Colors.white,
                //                     fontSize: 15.0,
                //                     fontWeight: FontWeight.w600,
                //                     letterSpacing: 0.3,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //         Container(
                //           height: 45.0,
                //           width: double.infinity,
                //           padding: const EdgeInsets.symmetric(horizontal: 0.0),
                //           child: FlatButton(
                //             onPressed: () {
                //               //add address
                //               deleteAddress();
                //             },
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(15.0),
                //             ),
                //             child: Row(
                //               mainAxisAlignment: MainAxisAlignment.center,
                //               children: <Widget>[
                //                 Icon(
                //                   Icons.delete,
                //                   color: Colors.red,
                //                   size: 20.0,
                //                 ),
                //                 SizedBox(
                //                   width: 10.0,
                //                 ),
                //                 Text(
                //                   'Delete Address',
                //                   style: GoogleFonts.cairo(
                //                     color: Colors.red,
                //                     fontSize: 15.0,
                //                     fontWeight: FontWeight.w600,
                //                     letterSpacing: 0.3,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         SizedBox(
                //           height: 20.0,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
