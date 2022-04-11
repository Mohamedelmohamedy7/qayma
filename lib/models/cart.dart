import 'package:cloud_firestore/cloud_firestore.dart';

import 'product.dart';

class Cart {
  var product;
  var quantity;
  var sku;
  var payImageForUpload;
  var productImageForUpload;
  var priceDate;
  var skuName;
  var dateOfProduct;
  Cart({
    this.product,
    this.quantity,
    this.sku,
    this.payImageForUpload,
    this.productImageForUpload,
    this.priceDate,
    this.skuName,
    this.dateOfProduct
  });

  factory Cart.fromFirestore(DocumentSnapshot documentSnapshot, String quantity, Sku sku,
      String payImageForUpload,String productImageForUpload,String priceDate,String skuName,var dateOfProduct) {
    return Cart(
      product: Product.fromFirestore(documentSnapshot),
      quantity: quantity,
      sku: sku,
      payImageForUpload: payImageForUpload,
      priceDate: priceDate,
      productImageForUpload: productImageForUpload,
      skuName: skuName,
      dateOfProduct: dateOfProduct,
    );
  }
}
