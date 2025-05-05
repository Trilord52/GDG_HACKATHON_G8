import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_campus/features/core/presentation/bloc/NavigationCubit.dart';
import 'package:safe_campus/features/core/presentation/screens/home.dart';
import 'features/core/presentation/providers/auth/auth_bloc.dart';
import 'features/core/presentation/screens/intro_page.dart';
import 'features/core/presentation/screens/sign_in_page.dart';
import 'features/core/presentation/screens/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/core/presentation/bloc/register/register_bloc.dart';
import 'features/core/presentation/bloc/auth/login_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(
          create: (context) => NavigationCubit(),
          child: Container(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SafeCampus',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Poppins',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const IntroPage(),
          '/signin': (context) => const SignInPage(),
          '/register': (context) =>  RegisterPage(),
          '/home': (context) => const Home(),
        },
      ),
    );
  }
}
