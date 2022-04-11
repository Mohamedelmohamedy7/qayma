import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/pages/search_page.dart';
import 'package:grocery_store/screens/sign_in_screen.dart';
import 'package:grocery_store/screens/srartScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import 'cart_screen.dart';
import '../screens/sub_categories_screen.dart';
import 'navicationBarScreen.dart';
class NavicationBarScreen extends StatefulWidget {
  const NavicationBarScreen({Key key}) : super(key: key);
static bool colorData=false;
  @override
  _NavicationBarScreenState createState() => _NavicationBarScreenState();
}
class _NavicationBarScreenState extends State<NavicationBarScreen> {
  SigninBloc signinBloc;
  @override
  int _index = 0;
  List<Widget> screens(BuildContext context) {
    return [
      data==true?CartScreen():StartPage(),
      HomePage(),
      SearchPage(),
      ProfilePage(),
      // ChatScreen(
      //   uid: ,// ),
    ];
  }
  var data;firstTime()async{
    SharedPreferences _pred=await SharedPreferences.getInstance();
    setState(() {
      data=  _pred.getBool("DoneData");
    });
     return data;
  }
  Widget build(BuildContext context) {
    data==null? firstTime():SizedBox();
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: screens(context)[_index],
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //     floatingActionButton: Padding(
    //   padding: const EdgeInsets.only(right: 150,),
    //   child: Center(
    //     child: BoomMenu(
    //       animatedIcon: AnimatedIcons.menu_close,
    //       animatedIconTheme: IconThemeData(size: 22.0),
    //       //child: Icon(Icons.add),
    //       onOpen: () => print('OPENING DIAL'),
    //       onClose: () => print('DIAL CLOSED'),
    //       // scrollVisible: scrollVisible,
    //       overlayColor: Colors.black,
    //       overlayOpacity: 0.7,
    //       children: [
    //         MenuItem(
    //           child: Icon(Icons.accessibility, color: Colors.black),
    //           title: "Profiles",
    //           titleColor: Colors.white,
    //           subtitle: "You Can View the Noel Profile",
    //           subTitleColor: Colors.white,
    //           backgroundColor: Colors.deepOrange,
    //           onTap: () => print('FIRST CHILD'),
    //         ),
    //         MenuItem(
    //           child: Icon(Icons.brush, color: Colors.black),
    //           title: "Profiles",
    //           titleColor: Colors.white,
    //           subtitle: "You Can View the Noel Profile",
    //           subTitleColor: Colors.white,
    //           backgroundColor: Colors.green,
    //           onTap: () => print('SECOND CHILD'),
    //         ),
    //         MenuItem(
    //           child: Icon(Icons.keyboard_voice, color: Colors.black),
    //           title: "Profile",
    //           titleColor: Colors.white,
    //           subtitle: "You Can View the Noel Profile",
    //           subTitleColor: Colors.white,
    //           backgroundColor: Colors.blue,
    //           onTap: () => print('THIRD CHILD'),
    //         ),
    //         MenuItem(
    //           child: Icon(Icons.ac_unit, color: Colors.black),
    //           title: "Profiles",
    //           titleColor: Colors.white,
    //           subtitle: "You Can View the Noel Profile",
    //           subTitleColor: Colors.white,
    //           backgroundColor: Colors.blue,
    //           onTap: () => print('FOURTH CHILD'),
    //         )
    //       ],
    //     ),
    //   ),
    // ),
    //
    //     bottomNavigationBar: Container(
    //       // color: Colors.grey.shade200,
    //       height: 60,
    //       child: BottomAppBar(
    //         notchMargin: 10,
    //         shape: CircularNotchedRectangle(),
    //         child: new Row(
    //           mainAxisSize: MainAxisSize.max,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: <Widget>[
    //             IconButton(
    //               icon: Icon(Icons.menu),
    //               color: Colors.grey,
    //               onPressed: () {},
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: IconButton(
    //                 icon: Icon(Icons.menu),
    //                 color: Colors.grey,
    //                 onPressed: () {},
    //               ),
    //             ), IconButton(
    //               icon: Icon(Icons.menu),
    //               color: Colors.grey,
    //               onPressed: () {},
    //             ), IconButton(
    //               icon: Icon(Icons.menu),
    //               color: Colors.grey,
    //               onPressed: () {},
    //             ),
    //           ],
    //         ),
    //         // color: Utiles.primary_bg_color,
    //       ),
    //     ),
        // bottomNavigationBar:FirebaseAuth.instance.currentUser==null&&_index==2? SizedBox():BottomNavigationBar(
        //   unselectedItemColor: Color(0xffB8B8B8),
        //   showSelectedLabels: false,
        //   showUnselectedLabels: false,
        //   type: BottomNavigationBarType.fixed,
        //   onTap: (newIndex) => setState(() => _index = newIndex),
        //   selectedItemColor: Theme.of(context).primaryColor,
        //   currentIndex: _index,
        //   items: <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(icon:_index==0?
        //     SvgPicture.asset("assets/icons/home.svg")
        //         :ImageIcon(
        //         AssetImage(
        //           'assets/images/homeIconImage.png',
        //         ),
        //         // color: Color(0xFF3A5A98),
        //       ), label: 'Home',),
        //
        //     ///sub-categories-screen
        //
        //     BottomNavigationBarItem(
        //       icon:_index==1?
        //       SvgPicture.asset("assets/icons/chat (2).Svg")
        //           : SvgPicture.asset("assets/icons/chatporder.Svg"),
        //         // color: Color(0xFF3A5A98),
        //       label: 'category',
        //     ),
        //     BottomNavigationBarItem(
        //       icon:_index==2?
        //       SvgPicture.asset("assets/icons/card.svg")
        //       : SvgPicture.asset(
        //           'assets/icons/cardBorder.Svg',
        //         ),
        //         // color: Color(0xFF3A5A98),
        //       label: 'Cart',
        //     ),
        //     BottomNavigationBarItem(
        //       icon:_index==3?
        //       SvgPicture.asset("assets/icons/person.Svg")
        //           :  SvgPicture.asset("assets/icons/personporder.Svg"),
        //       label: 'Profile',
        //     ),
        //
        //     // BottomNavigationBarItem(
        //     //   icon: Icon(Icons.messenger),
        //     //   label: 'Chat',
        //     // ),
        //   ],
        // ),
      ),
    );
  }
}
