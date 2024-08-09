import 'package:flutter/material.dart';

import '../constants/pallete.dart';

class GradientButton2 extends StatelessWidget {
  
  final Widget button;

  const GradientButton2({Key? key,  required this.button}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Pallete.gradient1,
            Pallete.gradient2,
            Pallete.gradient3,
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: button,
    );
  }
}
