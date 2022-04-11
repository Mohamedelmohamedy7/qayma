import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:grocery_store/models/cart.dart';
import 'package:grocery_store/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ad_help.dart';
import '../generate.dart';
import 'commanText.dart';

class PatmentData extends StatefulWidget {
  List<Cart> category = [];

  PatmentData({this.category}) {
    addMop();
  }

  var _rewardedAd;
  Banner ad;

  addMop() {
    RewardedAd.load(
        adUnitId: AdHelper.rewordAdUnitId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(onAdLoaded: (ad) {
          print('$ad loaded.');
          // Keep a reference to the ad so you can show it later.
          this._rewardedAd = ad;
        }, onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
        }));
  }

  @override
  _PatmentDataState createState() => _PatmentDataState();
}

class _PatmentDataState extends State<PatmentData> {
  var dataQuantity = 0;
  var dataPrice = 0;

  @override
  void initState() {
    getData();
    getData2();
    super.initState();
  }

  createReawardAd() {
    // Re
  }

  //////////Man////////////
  var manName;
  var manId;
  var manAddress;
  var manCivil;

  //////////woMan////////////
  var womanName;
  var womanId;
  var womanAddress;
  var womanCivil;

  //////////woMan////////////
  var street;
  var floor;
  var flat;
  var state;
  var building;
  var city;

  //////////woMan////////////
  var dateName;
  var dateNumber;

  var firstTextData;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  TextEditingController dateNameController = TextEditingController();
  TextEditingController dateNumberController = TextEditingController();

  /////////// Man Data
  TextEditingController manNameController = TextEditingController();
  TextEditingController manIdController = TextEditingController();
  TextEditingController addressManController = TextEditingController();
  TextEditingController civilManController = TextEditingController();

  /////////// woman Data
  TextEditingController womanNameController = TextEditingController();
  TextEditingController womanIdController = TextEditingController();
  TextEditingController addressWomanController = TextEditingController();
  TextEditingController civilWomanController = TextEditingController();

  /////////// address Data
  TextEditingController flatNumberController = TextEditingController();
  TextEditingController floorNumberController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  var data;

  var womanData;

  getData() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      data =
          " إنه في يوم ${_pref.getString("dateName") == null ? "......................................." : _pref.getString("dateName")} الموافق ${_pref.getString("dateNumber") == null ? "........................" : _pref.getString("dateNumber")}"
          " أقر أنا ${_pref.getString("manName") == null ? "..........................................." : _pref.getString("manName")} المقيم ف ${_pref.getString("addressMan") == null ? "..............................." : _pref.getString("addressMan")}  رقم قومي   ${_pref.getString("manId") == null ? "................................" : _pref.getString("manId")}  سجل مدني ${_pref.getString("civilMan") == null ? ".................................." : _pref.getString("civilMan")} والكامل الأهلية للإتفاق والتصرف  "
          "  بأنني استلمت من زوجتي السيدة/  ${_pref.getString("womanName") == null ? "........................" : _pref.getString("womanName")}  المقيمة ف  ${_pref.getString("addressWoman") == null ? "................................." : _pref.getString("addressWoman")} رقم قومي ${_pref.getString("womanId") == null ? ".............................." : _pref.getString("womanId")} سجل مدني   ${_pref.getString("civilWoman") == null ? ".............................." : _pref.getString("civilWoman")}    والكاملة الأهلية للإتفاق والتصرف منقولات زوجية ملك لها وذلك لتقوم بتأثيث مسكن الزوجية الخاص بنا والكائن بالشقة رقم  ${_pref.getString("flat") == null ? "................................." : _pref.getString("flat")}الدور رقم ${_pref.getString("floor") == null ? "........................." : _pref.getString("floor")} عمارة رقم ${_pref.getString("building") == null ? ".............................." : _pref.getString("building")} شارع ${_pref.getString("street") == null ? ".........................." : _pref.getString("street")} مدينة ${_pref.getString("state") == null ? "........................" : _pref.getString("state")} محافظة ${_pref.getString("city") == null ? ".........................." : _pref.getString("city")} وحيث أنها أحضرت تلك المنقولات من مالها الخاص لذا لايكون لي حق التصرف فيها,وأي تصرف أو تبديد من جانبي في هذه المنقولات يكون تبديدًا لأشياء في حراستي في منزلي وهذه المنقولات عبارة عن الآتي:";
      womanData = _pref.getString("womanName") == null
          ? "........................"
          : _pref.getString("womanName");
    });

    return data;
  }

  var tex1;
  var tex2;
  var tex3;
  var tex4;
  var tex5;
  var tex6;
  var tex7;
  var tex8;
  var tex9;
  var tex10;
  var tex11;
  var tex12;
  var tex13;
  var tex14;
  var tex15;
  var tex16;

  getData2() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      dateName = _pref.getString("dateName");
      dateNumber = _pref.getString("dateNumber");
      floor = _pref.getString("floor");
      flat = _pref.getString("flat");
      building = _pref.getString("building");
      city = _pref.getString("city");
      street = _pref.getString("street");
      state = _pref.getString("state");
      manName = _pref.getString("manName");
      manId = _pref.getString("manId");
      manAddress = _pref.getString("addressMan");
      manCivil = _pref.getString("civilMan");
      womanName = _pref.getString("womanName");
      womanId = _pref.getString("womanId");
      womanAddress = _pref.getString("addressWoman");
      womanCivil = _pref.getString("civilWoman");
      dateNameController = TextEditingController(text: dateName);
      dateNumberController = TextEditingController(text: dateNumber);
      floorNumberController = TextEditingController(text: floor);
      flatNumberController = TextEditingController(text: flat);
      buildingController = TextEditingController(text: building);
      cityController = TextEditingController(text: city);
      streetController = TextEditingController(text: street);
      stateController = TextEditingController(text: state);
      manNameController = TextEditingController(text: manName);
      manIdController = TextEditingController(text: manId);
      addressManController = TextEditingController(text: manAddress);
      civilManController = TextEditingController(text: manCivil);
      womanNameController = TextEditingController(text: womanName);
      womanIdController = TextEditingController(text: womanId);
      addressWomanController = TextEditingController(text: womanAddress);
      civilWomanController = TextEditingController(text: womanCivil);
    });
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Container(
      decoration: new BoxDecoration(
          color: Color(0xffF2F6F9),
          borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(25.0),
              topRight: const Radius.circular(25.0))),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  // Text("${data}", style: TextStyle(fontSize: 16),),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 10),
                  //   child: TextFormField(
                  //     maxLines: 17,
                  //     textAlignVertical: TextAlignVertical.center,
                  //     //initialValue: data,
                  //     onSaved: (val) {
                  //       // addressLine1 = val.trim();
                  //     },
                  //     onChanged: (_) {
                  //       setState(() {
                  //         manName = manName;
                  //       });
                  //     },
                  //     style: TextStyle(
                  //       color: Colors.black,
                  //       fontSize: 14.5,
                  //       fontWeight: FontWeight.w500,
                  //       letterSpacing: 0.5,
                  //     ),
                  //     textInputAction: TextInputAction.done,
                  //     keyboardType: TextInputType ,
                  //     cursorColor: Theme.of(context).primaryColor,
                  //     textCapitalization: TextCapitalization.words,
                  //     decoration: InputDecoration(
                  //       enabledBorder: OutlineInputBorder(
                  //           borderSide:
                  //               BorderSide(width: 0.5, color: Colors.grey.shade400)),
                  //       focusedBorder: OutlineInputBorder(
                  //           borderSide: BorderSide(
                  //         width: 0.5,
                  //         color: Theme.of(context).primaryColor,
                  //       )),
                  //       contentPadding:
                  //           EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  //       helperStyle: TextStyle(
                  //         color: Colors.black.withOpacity(0.65),
                  //         fontWeight: FontWeight.w500,
                  //         letterSpacing: 0.5,
                  //       ),
                  //       errorStyle: TextStyle(
                  //         fontSize: 13.0,
                  //         fontWeight: FontWeight.w500,
                  //         letterSpacing: 0.5,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Container(
                              height: 35,
                              width: 35,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 20,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop()),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Theme.of(context).accentColor,
                                      width: 2),
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: TextButton(
                                    onPressed: () async {
                                      widget._rewardedAd.show().then((value) {
                                        Future.delayed(Duration(seconds: 10),
                                            () async {
                                          final pdfFile =
                                              await PdfApi.generatePdfApi(
                                                  widget.category,
                                                  data,
                                                  womanName);
                                          PdfApi.openFile(pdfFile);
                                        });
                                      });
                                    },
                                    child: Text(
                                      ' انشاء pdf للقايمة',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      child: Container(
                    width: 400,
                    // height: 600,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ListTileTheme(
                        contentPadding: EdgeInsets.all(0),
                        dense: true,
                        horizontalTitleGap: 0.0,
                        minLeadingWidth: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: ExpansionTile(
                            collapsedIconColor: Color(0xffF2F6F9),
                            iconColor: Color(0xffF2F6F9),
                            initiallyExpanded: true,
                            title: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text("اضافة بعض البيانات ",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16))),
                            children: [
                              Form(
                                key: _globalKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /////////// Date data
                                    TextFormField(
                                      //initialValue: dateName,
                                      controller: dateNameController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'اليوم',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          dateName = val;
                                        });
                                      },
                                      onSaved: (value) {
                                        setState(() {
                                          // manName = value;
                                          dateName = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: dateNumber,

                                      controller: dateNumberController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText:
                                            'تاريخ اليوم .....-.....-......',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          dateNumber = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          dateNumber = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    /////////// address data
                                    TextFormField(
                                      //initialValue: floor,

                                      controller: flatNumberController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'رقم الدور',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          flat = val;
                                        });
                                      },
                                      onSaved: (value) {
                                        setState(() {
                                          // manName = value;
                                          flat = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: flat,
                                      controller: floorNumberController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'رقم الشقة',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          floor = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          floor = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: building,
                                      controller: buildingController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'رقم العمارة',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          building = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          building = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: city,
                                      controller: cityController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'أسم المحافظة ',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          city = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          city = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: street,

                                      controller: streetController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'أسم الشارع ',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          street = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          street = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: state,

                                      controller: stateController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'أسم المدينة ',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          state = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          state = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    /////////// Man data
                                    TextFormField(
                                      //initialValue: manName,

                                      controller: manNameController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'اسم الزوج',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          manName = val;
                                        });
                                      },
                                      onSaved: (value) {
                                        setState(() {
                                          // manName = value;
                                          manName = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: manId,
                                      controller: manIdController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'الرقم القومى للزوج',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          manId = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          manId = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: manAddress,

                                      controller: addressManController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'عنوان الزوج',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          manAddress = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          manAddress = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: manCivil,

                                      controller: civilManController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'سجل مدنى الزوج ',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          manCivil = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          manCivil = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ///////////  woman data
                                    TextFormField(
                                      //initialValue: womanName,

                                      controller: womanNameController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'اسم الزوجة',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          womanName = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          womanName = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: womanId,

                                      controller: womanIdController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'الرقم القومى للزوجة',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          womanId = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          womanId = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: womanAddress,

                                      controller: addressWomanController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'عنوان الزوجة',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          womanAddress = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          womanAddress = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    TextFormField(
                                      //initialValue: womanCivil,

                                      controller: civilWomanController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(25.0),
                                          borderSide: new BorderSide(
                                              color: Theme.of(context)
                                                  .accentColor),
                                        ),
                                        hintText: 'سجل مدنى الزوجة',
                                        hintStyle: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          // dataPrice = val;
                                          womanCivil = val;
                                        });
                                      },
                                      onSaved: (String value) {
                                        setState(() {
                                          womanCivil = value;
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),

                                    ///////////
                                    Column(
                                      children: [
                                        Container(
                                            width: double.infinity,
                                            height: 50,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Theme.of(context)
                                                        .accentColor),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Center(
                                              child: new FlatButton(
                                                onPressed: () async {
                                                  SharedPreferences _pref =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  setState(() {
                                                    // if (_globalKey.currentState
                                                    //     .validate()) {
                                                    //   _globalKey.currentState.save();
                                                    _pref.setString(
                                                        "manName", manName);
                                                    _pref.setString(
                                                        "manId", manId);
                                                    _pref.setString(
                                                        "civilMan", manCivil);
                                                    _pref.setString(
                                                        "addressMan",
                                                        manAddress);
                                                    _pref.setString(
                                                        "dateNumber",
                                                        dateNumber);
                                                    _pref.setString(
                                                        "dateName", dateName);
                                                    _pref.setString(
                                                        "womanName", womanName);
                                                    _pref.setString(
                                                        "womanId", womanId);
                                                    _pref.setString(
                                                        "civilWoman",
                                                        womanCivil);
                                                    _pref.setString(
                                                        "addressWoman",
                                                        womanAddress);
                                                    _pref.setString(
                                                        "state", state);
                                                    _pref.setString(
                                                        "city", city);
                                                    _pref.setString(
                                                        "street", street);
                                                    _pref.setString(
                                                        "flat", flat);
                                                    _pref.setString(
                                                        "floor", floor);
                                                    _pref.setString(
                                                        "building", building);
                                                    setState(() {
                                                      data =
                                                          " إنه في يوم ${dateName} الموافق ${dateNumber}"
                                                          " أقر أنا ${manName}المقيم في ${manAddress} رقم قومي ${manId} سجل مدني ${manCivil} والكامل الأهلية للإتفاق والتصرف "
                                                          " ${womanCivil} بأنني استلمت من زوجتي السيدة/ ${womanName} المقيمة  ${womanAddress} رقم قومي ${womanId} سجل مدني ${womanCivil} والكاملة الأهلية للإتفاق والتصرف منقولات زوجية ملك لها وذلك لتقوم بتأثيث مسكن الزوجية الخاص بنا والكائن بالشقة رقم  ${flat} الدور رقم  ${floor}  عمارة رقم  ${building}  شارع  ${street}  مدينة ${state}  محافظة  ${city} وحيث أنها أحضرت تلك المنقولات من مالها الخاص لذا لايكون لي حق التصرف فيها,وأي تصرف أو تبديد من جانبي في هذه المنقولات يكون تبديدًا لأشياء في حراستي في منزلي وهذه المنقولات عبارة عن الآتي:  ";
                                                    });
                                                    Flushbar(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      borderRadius: 8.0,
                                                      backgroundColor:
                                                          Colors.red.shade500,
                                                      animationDuration:
                                                          Duration(
                                                              milliseconds:
                                                                  300),
                                                      isDismissible: true,
                                                      boxShadows: [
                                                        BoxShadow(
                                                          color: Colors.black12,
                                                          spreadRadius: 1.0,
                                                          blurRadius: 5.0,
                                                          offset:
                                                              Offset(0.0, 2.0),
                                                        )
                                                      ],
                                                      shouldIconPulse: false,
                                                      duration: Duration(
                                                          milliseconds: 2500),
                                                      icon: Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                      messageText: Text(
                                                        'تم اضافة البيانات بنجاح',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          letterSpacing: 0.3,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )..show(context);
                                                  });

                                                  // Navigator.pop(context);
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
                                            )),
                                        new FlatButton(
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop(); // dismisses only the dialog and returns nothing
                                          },
                                          child: Text(
                                            'الغاء',
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  Colors.black.withOpacity(0.9),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style: TextStyle(fontSize: 16),),
                    // Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style: TextStyle(fontSize: 16),),
                    //
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         Text("وهذا إقرار منى بذلك .",style: TextStyle(fontSize: 16,),textAlign: TextAlign.start,),
                    //       ],
                    //     ),
                    //     Text("المقر بما فيه:",style: TextStyle(fontSize: 16)),
                    //     Text("الاسم/",style: TextStyle(fontSize: 16)),
                    //     Text("التوقيع/",style: TextStyle(fontSize: 16)),
                    //     Text("الشهود :-",style: TextStyle(fontSize: 16)),
                    //     Text("1-",style: TextStyle(fontSize: 16)),
                    //     Text("2-",style: TextStyle(fontSize: 16)),
                    //   ],
                    // ),
                    // Container(
                    //   width: 400,
                    //   height: 500,
                    //   child: ListView.builder(
                    //     itemBuilder: (context, index) {
                    //       dataQuantity = 0;
                    //       dataPrice = 0;
                    //       for (int i = 0; i < widget.category.length; i++) {
                    //         dataQuantity =
                    //             int.parse(widget.category[i].skuName) + dataQuantity;
                    //         dataPrice =
                    //             int.parse(widget.category[i].priceDate) + dataPrice;
                    //       }
                    //       return Column(
                    //         children: [
                    //           index == 0
                    //               ? Divider(
                    //             color: Colors.black,
                    //           )
                    //               : SizedBox(),
                    //           Container(
                    //             color: Colors.white,
                    //             child: Table(
                    //               // border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)),
                    //               columnWidths: {
                    //                 0: FlexColumnWidth(0.3),
                    //                 1: FlexColumnWidth(2),
                    //                 2: FlexColumnWidth(0.5),
                    //                 3: FlexColumnWidth(0.8),
                    //               },
                    //
                    //               border: TableBorder.symmetric(
                    //                   inside: BorderSide.merge(BorderSide(width: 0.5),
                    //                       BorderSide(width: 0.5)),
                    //                   outside: BorderSide.merge(BorderSide(width: 0.5),
                    //                       BorderSide(width: 0.5))),
                    //               children: [
                    //                 if (index == 0)
                    //                   TableRow(children: [
                    //                     Center(
                    //                         child: Text(
                    //                           "م",
                    //                           style: TextStyle(),
                    //                         )),
                    //                     Center(
                    //                         child: Text('اسم المنتج',
                    //                             style: TextStyle())),
                    //                     Center(
                    //                         child: Text('الكمية ',
                    //                             style: TextStyle())),
                    //                     Center(
                    //                         child: Text('السعر',
                    //                             style: TextStyle())),
                    //                   ]),
                    //                 TableRow(children: [
                    //                   Center(child: Text("${index}")),
                    //                   Center(
                    //                       child: Text(
                    //                           '${widget.category[index].product.name}',
                    //                           style: TextStyle())),
                    //                   Center(
                    //                       child: Text(
                    //                           '${widget.category[index].skuName}',
                    //                           style: TextStyle())),
                    //                   Center(
                    //                       child: Text(
                    //                           '${widget.category[index].priceDate}',
                    //                           style: TextStyle())),
                    //                 ]),
                    //                 if (index == widget.category.length - 1)
                    //                   TableRow(children: [
                    //                     Center(
                    //                         child: Text("ج",
                    //                             style: TextStyle())),
                    //                     Center(
                    //                         child: Text('العدد الاجمالي : ${index + 1}',
                    //                             style: TextStyle())),
                    //                     Center(
                    //                         child: Text('${dataQuantity} ',
                    //                             style: TextStyle())),
                    //                     Center(
                    //                         child: Text('${dataPrice} ',
                    //                             style: TextStyle())),
                    //                   ])
                    //               ],
                    //             ),
                    //           )
                    //         ],
                    //       );
                    //     },
                    //     itemCount: widget.category.length,
                    //   ),
                    // ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
