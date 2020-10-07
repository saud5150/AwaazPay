import 'package:flutter/material.dart';
import 'package:awaazpay_v1/screens/login_screen.dart';
import 'package:awaazpay_v1/screens/registration_screen.dart';

var routes = <String, WidgetBuilder>{
  "/RegistrationScreen": (BuildContext context) => RegistrationScreen(),
  "/LoginScreen": (BuildContext context) => LoginScreen(),
//"/HomeScreen": (BuildContext context) => HomeScreen(),
};
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AwaazPay Login UI',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      routes: routes,
    );
  }
}
