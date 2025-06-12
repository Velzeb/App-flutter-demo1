import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screen_manager.dart';
import 'models/Requesthandler.dart';
// Page edit_profile
void main() async{
  runApp(const MyApp());
  //healtcheck
  final handler = RequestHandler();
  final result = await handler.getRequest('health_check/');
 //registro
 /*
  final user = await handler.postRequest('api/user/create/', data:{
    "email":"pedro@gmail.com",
    "password":"securepassword123",
    "name":"Pedro"}
  );*/

  //login
  final login = await handler.postRequest('api/user/login/',data:{
    "email":"popopopopopo@popo.com",
  "password":"popo1234"
  } );
  print(login);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const ScreenManager(),
      },
    );
  }
}
