import 'package:flutter/material.dart';
import 'package:vezigo/Models/colors.dart';
import 'package:vezigo/Screens/homescreen.dart';
import 'package:vezigo/Screens/favorites.dart';
import 'package:vezigo/Screens/profile.dart';

class BottomBars extends StatefulWidget {
  const BottomBars({super.key});

  @override
  State<BottomBars> createState() => _BottomBarsState();
}

class _BottomBarsState extends State<BottomBars> {
  int _currentIndex = 0;

  final List<Widget> screens = [
  const  MyHomeScreen(),
  const  FavoritesScreen(),
   const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 30,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.buttonColor,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              size: 30,
            ),
            label: 'Fav',
          ),
         
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}




