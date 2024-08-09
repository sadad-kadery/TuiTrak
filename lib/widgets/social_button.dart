import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:truitrak2/constants/pallete.dart';



class SocialButton extends StatelessWidget {
  
  final String label;
  final double horizontalPadding;
  const SocialButton({
    Key? key,
    
    required this.label,
    this.horizontalPadding = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      
        onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        await user?.sendEmailVerification();
                      }
      ,
      icon: const Icon(Icons.email),
      label: Text(
        label,
        style: const TextStyle(
          color: Pallete.borderColor,
          fontSize: 17,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: horizontalPadding),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Pallete.borderColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
