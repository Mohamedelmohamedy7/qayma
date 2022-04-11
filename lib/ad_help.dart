import 'dart:io';

class AdHelper {
  // static String get bannerAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3068683377779257/7473019505";
  //   } else if (Platform.isIOS) {
  //     return "ca-app-pub-3068683377779257/5559789142";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/6300978111";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3068683377779257/5559789142";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3068683377779257/5724220922";
  //    } else if (Platform.isIOS) {
  //     return "ca-app-pub-3068683377779257/9074091388";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
     } else if (Platform.isIOS) {
      return "ca-app-pub-3068683377779257/9074091388";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
  // static String get rewordAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-3068683377779257/8406827227";
  //     // return "ca-app-pub-3068683377779257/5724220922";
  //   } else if (Platform.isIOS) {
  //     return "ca-app-pub-3068683377779257/4036638695";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }
  static String get rewordAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
      // return "ca-app-pub-3068683377779257/5724220922";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3068683377779257/4036638695";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
// 1234589936    6829020