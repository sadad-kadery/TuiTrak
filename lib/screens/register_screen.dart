import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truitrak2/constants/pallete.dart';

import 'package:truitrak2/services/auth/auth_exceptions.dart';

import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/services/auth/bloc/auth_state.dart';
import 'package:truitrak2/utilities/dialogs/error_dialog.dart';
import 'package:truitrak2/utilities/registration_complete.dart';

import 'package:truitrak2/widgets/login_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final TextEditingController reEmailController;

  late final TextEditingController reg_passController;

  late final TextEditingController reg_rePasscontroller;

  @override
  void initState() {
    reEmailController = TextEditingController();
    reg_passController = TextEditingController();
    reg_rePasscontroller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    reEmailController.dispose();
    reg_passController.dispose();
    reg_rePasscontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(context, 'Weak password');
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email is already in use');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Failed to register');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email');
          } 
        }
        
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Image.asset('assets/images/signin_balls.png'),
                const SizedBox(height: 50),
                const Text(
                  'Sign up.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 20),
                LoginField(
                  hintText: 'Email',
                  obs: false,
                  textController: reEmailController,
                ),
                const SizedBox(height: 15),
                LoginField(
                  hintText: 'Password',
                  obs: true,
                  textController: reg_passController,
                ),
                const SizedBox(height: 20),
                LoginField(
                  hintText: 'Re-type Password',
                  obs: true,
                  textController: reg_rePasscontroller,
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
                      final email = reEmailController.text;
                      final password = reg_passController.text;
                      final rePassword = reg_rePasscontroller.text;
                      if (password == rePassword) {
                        context.read<AuthBloc>().add(
                              AuthEventRegister(
                                email,
                                password,
                              ),
                            );
                      } else {
                        await showErrorDialog(
                          context,
                          "Passwords don't match.",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(395, 55),
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    },
                    child: const Text("Already have an account? Sign In"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
