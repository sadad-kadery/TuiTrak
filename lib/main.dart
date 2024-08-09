import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truitrak2/constants/pallete.dart';
import 'package:truitrak2/constants/routes.dart';
import 'package:truitrak2/helpers/loading/loading_screen.dart';
import 'package:truitrak2/screens/forgot_password_view.dart';

import 'package:truitrak2/screens/login_screen.dart';
import 'package:truitrak2/screens/notes/create_update_note_view.dart';
import 'package:truitrak2/screens/notes/main_screen.dart';
import 'package:truitrak2/screens/register_screen.dart';
import 'package:truitrak2/screens/test2.dart';
import 'package:truitrak2/screens/tuitions/test.dart';
import 'package:truitrak2/screens/tuitions/tuitions_home_view.dart';
import 'package:truitrak2/screens/tuitions_home.dart';

import 'package:truitrak2/services/auth/bloc/auth_bloc.dart';
import 'package:truitrak2/services/auth/bloc/auth_event.dart';
import 'package:truitrak2/services/auth/bloc/auth_state.dart';
import 'package:truitrak2/services/auth/firebase_auth_provider.dart';
import 'package:truitrak2/utilities/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotifications.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'TuiTrak',
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        '/login/': (context) => const LoginScreen(),
        '/register/': (context) => RegisterScreen(),
        '/main/': (context) => const NotesView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return MyHomePage();
        } else if (state is AuthStateLoggedOut) {
          return const LoginScreen();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return RegisterScreen();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                
              ),
            ),
          );
        }
      },
    );
  }
}
