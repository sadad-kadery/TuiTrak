import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/services/auth/bloc/auth_state.dart';
import 'package:truitrak2/utilities/dialogs/error_dialog.dart';
import 'package:truitrak2/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:truitrak2/widgets/login_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null) {
            // ignore: use_build_context_synchronously
            await showErrorDialog(context,
                'We could not process your request. Please make sure that you are a registered user, or if not, register a user now by going back one step. Or make sure your internet connection is Ok.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Reset Password',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 236, 96, 154),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              
              const Text(
                  'If you forgot your password, simply enter your email and we will send you a password reset link.',
                  style: TextStyle(
                    fontSize: 20,
                  ),),
                  const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              LoginField(
                hintText: 'Enter your email.',
                obs: false,
                textController: _controller,
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: const Text('Send me password reset link',
                style: TextStyle(
                  fontSize: 20
                ),),
              ), const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text('Back to login page',
                style: TextStyle(
                  fontSize: 17
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
