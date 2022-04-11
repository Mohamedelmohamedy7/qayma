import 'package:flutter/foundation.dart';
import 'package:place_picker/place_picker.dart';

class HomeProvider with ChangeNotifier {
  int count = 1;
  bool small;
  bool meduim;
  String size;
  bool large = false;
  String price = "";
  LocationResult locationResult;
  int addressIndex = 0;
  changeprice({value}) {
    price = value.toString();
    notifyListeners();
  }

  changeAddreses({value}) {
    addressIndex = value;
    notifyListeners();
  }

  changeSize({value}) {
    size = value;
    notifyListeners();
  }

  changeLocation({value}) {
    locationResult = value;
    notifyListeners();
  }

  // int get count=>count;
  bool get Small => small;
  bool get Large => small;
  bool get Medum => meduim;

  incrementCounter() {
    count++;
    notifyListeners();
  }

  decrementCounter() {
    if (count > 1) count--;
    notifyListeners();
  }
}
