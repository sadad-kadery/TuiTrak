import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/screens/login_screen.dart';

import 'package:truitrak2/widgets/gradient_button_2.dart';
import 'package:truitrak2/widgets/social_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email verification'),
      ),
      backgroundColor: Pallete.whiteColor,
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Please verify your email.',
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(
              "We've just sent and email to you. Tap on the link to verify your account.",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 17,
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialButton(
                label: 'Send verification mail again',
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(height: 20),
          GradientButton2(
            button: ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  print('verified');
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false);
                } else {
                  print('not verified');
                  const SnackBar(content: Text('Email not verified!'));
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(395, 55),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                "After verifying your email, tap Here",
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
