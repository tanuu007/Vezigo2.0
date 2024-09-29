import 'package:flutter/material.dart';
import 'package:vezigo/models/colors.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onPressed;

  const CategoryItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: 180,
        decoration: BoxDecoration(
          color:AppColors.lightTheme,
          borderRadius: BorderRadius.circular(20),
           
            boxShadow: [
              BoxShadow(
                 color: Colors.grey.shade100,
              blurRadius: 3,
              offset:const Offset(0, 3),
              )
            ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          Center(child: Image.asset(imagePath,height: 100,width: 100,)),
          const  SizedBox(height: 10),
            Text(title),
          const  SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


   