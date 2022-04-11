import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// import 'dart:js';

// import 'package:google_fonts/google_fonts.dart' as fonts;
// import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:open_file/open_file.dart';

import 'models/cart.dart';

class PdfApi {
  // Future<List<int>> _readFontData() async {
  //   final ByteData bytes = await rootBundle.load('assets/fonts/Tajawal-Regular.ttf');
  //   return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  // }

  static Future<File> generatePdfApi(List<Cart> dataProduct, dataValues,womanData) async {
    var dataQuantity = 0;
    var dataPrice = 0;
    final pdf = Document();
    var data1 = await rootBundle.load(
      "assets/fonts/HacenTunisia.ttf",
    );
    // var myFont = Font.ttf(data);
    // final Uint8List fontDa   ta = File('Tajawal-Regular.ttf').readAsBytesSync();
    final myFont = Font.ttf(data1.buffer.asByteData());
    // var images =
    // (await rootBundle.load("assets/images/logo.png")).buffer.asUint8List();
    // var imagespdf =
    // (await rootBundle.load("assets/logopdf.png")).buffer.asUint8List();
    // var images1 =
    //     (await rootBundle.load("assets/logotrans.png")).buffer.asUint8List();

    // var name = utf8.encode(brandName);
    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: ThemeData.withFont(
          base: myFont,
        ),
        build: (context) {
        return [
          Column(children: [
          Text(
            "نموذج قائمة منقولات زوجية",
            style: TextStyle(font: myFont),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 20),
          Directionality(
            child: Text(
              dataValues,
              style: TextStyle(font: myFont),
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(height: 20),
          Directionality(
            child: Container(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  dataQuantity = 0;
                  dataPrice = 0;
                  for (int i = 0; i < dataProduct.length; i++) {
                    dataQuantity =
                        int.parse(dataProduct[i].skuName) + dataQuantity;
                    dataPrice =
                    (int.parse(dataProduct[i].priceDate)*int.parse(dataProduct[i].skuName)) + dataPrice;
                  }
                  return Column(
                    children: [
                      Container(
                        child: Table(
                          // border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)),
                          columnWidths: {
                            3: FlexColumnWidth(0.3),
                            2: FlexColumnWidth(2),
                            1: FlexColumnWidth(0.5),
                            0: FlexColumnWidth(0.8),
                          },
                          border: TableBorder.all(),
                          children: [
                            if (index == 0)
                              TableRow(children: [
                                Center(
                                    child: Text('  سعر المنتج الواحد ',
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                                Center(
                                    child: Text('الكمية ',
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                                Center(
                                  child: Text('اسم المنتج',
                                      style: TextStyle(font: myFont),
                                      textDirection: TextDirection.rtl),
                                ),
                                Center(
                                    child: Text("م",
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                              ]),
                            TableRow(children: [
                              Center(
                                  child: Text(
                                      '${dataProduct[index].priceDate}',
                                      style: TextStyle(font: myFont),
                                      textDirection: TextDirection.rtl)),
                              Center(
                                  child: Text('${dataProduct[index].skuName}',
                                      style: TextStyle(font: myFont),
                                      textDirection: TextDirection.rtl)),
                              Center(
                                  child: Text(
                                      '${dataProduct[index].product.name}',
                                      style: TextStyle(font: myFont),
                                      textDirection: TextDirection.rtl)),
                              Center(child: Text("${index}")),
                            ]),
                            if (index == dataProduct.length - 1)
                              TableRow(children: [
                                Center(
                                    child: Text('${dataPrice}  ج.م ',
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                                Center(
                                    child: Text('${dataQuantity} ',
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                                Center(
                                    child: Text(
                                        'العدد الاجمالي : ${index + 1} ',
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                                Center(
                                    child: Text("ج",
                                        style: TextStyle(font: myFont),
                                        textDirection: TextDirection.rtl)),
                              ]),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: index == dataProduct.length - 1 ? 15 : 0),
                      index == dataProduct.length - 1
                          ? Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("${dataPrice} ج.م ",   style: TextStyle(
                                    font: myFont, fontSize: 15)),
                                Text("إجمالي قيمة المنقولات مبلغ وقدره: ",
                                  style: TextStyle(
                                      font: myFont, fontSize: 15),

                                )
                              ]))
                          : SizedBox()
                    ],
                  );
                },
                itemCount: dataProduct.length,
              ),
            ),
          ),
          Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                    children: [
                      Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
                        font: myFont,),),
                      Text("زوجتي السيدة/ ${womanData==null ? "..................................":womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
                        font: myFont,),),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("وهذا إقرار منى بذلك .",style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("المقر بما فيه:", style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("الاسم/",style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                Text("التوقيع/",style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("الشهود:-",style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("-1",style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("-2",style:TextStyle(
                                  font: myFont,)),
                              ],
                            ),





                          ]
                      )
                    ] )
            ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
            // Directionality(
            //     textDirection: TextDirection.rtl,
            //     child: Column(
            //         children: [
            //           Text("اقر أنني تسلمت هذه المنقولات بعد معاينتها على الطبيعة ومعرفتي الكاملة لها وأتعهد بالحفاظ عليها من التلف كما يحافظ الشخص على أمواله الخاصة ولا يجوز لي التصرف بأي منها إلا بعد إذن مــن مالكتها ",style:TextStyle(
            //             font: myFont,),),
            //           Text("زوجتي السيدة / ${womanData} ولا يجوز لي تبديده .وأتعهد بالحفاظ عليها وعدم تبديدها وتسليمها إليها عند طلبها بحالتها التي كانت عليها عند استلامي لها أو رد قيمتها أو قيمة ما تلف منها دون التوقف على شرط وفى حال الإمتناع أكون خائنا ومبددًا للأمانة و إلا أكون مسئولًا مسئولية مدنية و جنائية.",style:TextStyle(
            //             font: myFont,),),
            //           Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               mainAxisAlignment: MainAxisAlignment.start,
            //               children: [
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("وهذا إقرار منى بذلك .",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("المقر بما فيه:", style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الاسم/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //
            //                     Text("التوقيع/",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("الشهود:-",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-1",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //                 Row(
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     Text("-2",style:TextStyle(
            //                       font: myFont,)),
            //                   ],
            //                 ),
            //
            //
            //
            //
            //
            //               ]
            //           )
            //         ] )
            // ),
        ])
         ];
        }));

    return saveDocument(name: 'pdf.pdf', pdf: pdf);
  }

  static Future<File> saveDocument({String name, Document pdf}) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }
}
