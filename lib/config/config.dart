class Config {
  String onboardingImage1 = 'assets/images/onboardingscreen.png';
  String onboardingImage2 = 'assets/banners/wide_categories.svg';
  String onboardingImage3 = 'assets/banners/easy_returns.svg';

//TODO: change below given title and subtitle as per your requirement
  String onboardingPage1Title = 'أكتب قايمتك بسهولة';
  String onboardingPage1Subtitle =
      ' تقدر تضيف المنتجات الي أشترتها بوقت شرائها وصورة الفاتورة وتحسب المبلغ الكلي للقايمة';

  String onboardingPage2Title = 'قايمة الاحتياجات';
  String onboardingPage2Subtitle =
      'عشان متنساش حاجة هتلاقي اهم المنتجات الاساسية في القايمة وتقدر تضيفها لقايمة الاحتياجات علشان تفتكرها وتضيفها للقايمة لما تشتريها';

  String onboardingPage3Title = 'Easy returns';
  String onboardingPage3Subtitle =
      'Hand over the product to our delivery agent with no questions asked';

//TODO: change the currency and country prefix as per your need
  String currency = 'ج.م';
  String countryMobileNoPrefix = "+2";

  //stripe api keys
  String apiBase = 'https://api.stripe.com';
  String currencyCode = 'inr';

  String appName = 'Grocery Store';

  //dynamic link url
  String urlPrefix = 'https://grocerydemo.page.link';

  String packageName = 'com.dokkan.qayma';

  List<String> reportList = [
    'Inappropriate product description',
    'Fake product',
    'Product title is misleading',
    'Product price is too high',
    'Other',
  ];

  List<String> cancelOrderReasons = [
    'Order no longer needed',
    'Order placed by mistake',
    'Wrong products ordered',
    'Product prices changed after ordering',
    'Other',
  ];

  //razorpay
  String companyName = 'b2x_codes';
  String razorpayCreateOrderIdUrl = 'RAZORPAY_FIREBASE_FUNCTION_URL';
  String razorpayKey = 'RAZORPAY_KEY';
}
