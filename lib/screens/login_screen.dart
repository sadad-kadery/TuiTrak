import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:truitrak2/constants/pallete.dart';

import 'package:truitrak2/services/auth/auth_exceptions.dart';

import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/services/auth/bloc/auth_state.dart';

import 'package:truitrak2/utilities/dialogs/error_dialog.dart';

import 'package:truitrak2/widgets/login_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;

  late final TextEditingController passController;

  @override
  void initState() {
    emailController = TextEditingController();
    passController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context,
              'Cannot find a user with the entered credentials!',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, 'Wrong credentials');
          } else if (state.exception is NetworkAuthException) {
            await showErrorDialog(context, 'Sign In Failed! Check your internet connection');
          }else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication error');
          }
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Image.asset('assets/images/signin_balls.png'),
                const Text(
                  'Welcome to TuiTrak',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 50,
                      color: Pallete.borderColor),
                ),
                const SizedBox(height: 50),
                const SizedBox(height: 15),
                const SizedBox(height: 15),
                const Text(
                  'Sign in.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                  ),
                ),
                const SizedBox(height: 50),
                LoginField(
                  hintText: 'Email',
                  obs: false,
                  textController: emailController,
                ),
                const SizedBox(height: 15),
                LoginField(
                  hintText: 'Password',
                  obs: true,
                  textController: passController,
                ),
                const SizedBox(height: 20),
                Container(
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
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text;
                      final password = passController.text;
                      context.read<AuthBloc>().add(
                            AuthEventLogIn(
                              email,
                              password,
                            ),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(395, 55),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventForgotPassword(),
                        );
                  },
                  child: const Text(
                    'I Forgot My Password!',
                    style: TextStyle(
                        fontSize: 17,
                        color: Pallete.gradient2,
                        backgroundColor: Colors.transparent),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          const AuthEventShouldRegister(),
                        );
                  },
                  child: const Text(
                    'Not registered yet? Register here!',
                    style: TextStyle(
                      fontSize: 17,
                      color: Pallete.gradient2,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        backgroundColor: Pallete.whiteColor,
      ),
    );
  }
}
