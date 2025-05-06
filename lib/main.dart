import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safe_campus/features/core/presentation/bloc/auth/login_state.dart';
import 'package:safe_campus/features/core/presentation/screens/admin/security_dashboard.dart';
import 'package:safe_campus/features/core/presentation/screens/admin_page.dart' show AdminPage;
import 'features/core/presentation/bloc/add_contacts_cubit/contact_cubit.dart';
import 'features/core/presentation/bloc/panic_alert/panic_alert_bloc.dart';
import 'features/core/presentation/firebase_notification_handler.dart';
import 'features/core/presentation/bloc/NavigationCubit.dart';
import 'features/core/presentation/bloc/socket/socket_bloc.dart';
import 'features/core/presentation/screens/home.dart';
import 'features/core/presentation/screens/sos_cubit/sos_cubit.dart';
import 'features/core/presentation/screens/intro_page.dart';
import 'features/core/presentation/screens/sign_in_page.dart';
import 'features/core/presentation/screens/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/core/presentation/bloc/register/register_bloc.dart';
import 'features/core/presentation/bloc/auth/login_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  final prefs = await SharedPreferences.getInstance();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

await flutterLocalNotificationsPlugin.initialize(initializationSettings);

 
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PanicAlertBloc()),
        BlocProvider(create: (_) => RegisterBloc()),

        BlocProvider(create: (_) => LoginBloc()),

        BlocProvider(
          create: (context) => NavigationCubit(),
          child: Container(),
        ),
        BlocProvider(create: (_) => SocketBloc()),
        BlocProvider(create: (BuildContext context) => SosCubit()),

        BlocProvider(
          create: (context) => ContactCubit(token: prefs.getString('token') ?? ''),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SafeCampus',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Poppins',
        ),
        home: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state is LoginSuccess) {
              switch (state.user.role) {
                case 'admin':
                  return const AdminPage();
                case 'security':
                  return const SecurityDashboard();
                default:
                  return const Home();
              }
            }
            return const IntroPage();
          },
        ),
        routes: {
          '/signin': (context) => const SignInPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => const Home(),
        },
      ),
    );
  }
}
