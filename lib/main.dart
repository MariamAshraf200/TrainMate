import 'package:check_weather/core/routs.dart';
import 'package:check_weather/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:check_weather/features/getWeather/presentation/bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:check_weather/core/depency_injection.dart' as di;
import 'core/depency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await di.init();

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
routes route = routes();
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider(create: (_) => sl<WeatherBloc>())
      ],
      child: MaterialApp(
        initialRoute: '/login',
        routes: route.getRoute(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}