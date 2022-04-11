import 'package:grocery_store/blocs/cart_bloc/cart_bloc.dart';
import 'package:grocery_store/models/category.dart';
import 'package:grocery_store/screens/sub_categories_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllCategoryItem extends StatelessWidget {
  final Category category;
  final int index;
  final CartBloc cartBloc;
  final User firebaseUser;
   var num=0;
   AllCategoryItem({
    @required this.category,
    @required this.index,
    @required this.cartBloc,
    @required this.firebaseUser,
    this.num,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GestureDetector(
        onTap: () {
          print('go to category');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategoriesScreen(
                category: category.categoryName,
                subCategories: category.subCategories,
                selectedCategory: index,
                cartBloc: cartBloc,
                firebaseUser: firebaseUser,
              ),
            ),
          );
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/icons/category_placeholder.png',
                    image: category.imageLink,
                    fadeInCurve: Curves.easeInOut,
                    fadeInDuration: Duration(milliseconds: 250),
                    fadeOutCurve: Curves.easeInOut,
                    fadeOutDuration: Duration(milliseconds: 150),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:20.0,right: 20),
                    child: Text(
                      category.categoryName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                       style: GoogleFonts.tajawal(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:2.0,right: 20),
                    child: Text(
                      "${num}أطباق",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}
