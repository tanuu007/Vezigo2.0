import 'package:flutter/material.dart';
import 'package:vezigo/models/colors.dart';

class CustomRadioButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

const  CustomRadioButton({required this.isSelected, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.appbarColor : Colors.transparent,
          border: Border.all(color: AppColors.appbarColor),
        ),
        child: isSelected
            ?const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }
}