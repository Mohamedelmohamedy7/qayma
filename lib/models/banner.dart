import 'package:cloud_firestore/cloud_firestore.dart';

class Banner {
  Map<dynamic, dynamic> bottomBanner;
  Map<dynamic, dynamic> middleBanner;
  List topBanner;
  var popUpBanner;
  Banner({
    this.bottomBanner,
    this.middleBanner,
    this.topBanner,
    this.popUpBanner,
  });

  factory Banner.fromFirestore(DocumentSnapshot documentSnapshot) {
    Map data = documentSnapshot.data();

    return Banner(
        popUpBanner: data['popUpBanner'],
        bottomBanner: data['bottomBanner'],
        middleBanner: data['middleBanner'],
        topBanner: data['topBanner']);
  }
}
