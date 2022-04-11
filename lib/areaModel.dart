class AreaModel{
  var areaName;
  var areaprice;
  AreaModel.fromMap(Map<String, dynamic> map) {
    areaName = map["AreaName"];
    areaprice = map["Price"];

  }
}