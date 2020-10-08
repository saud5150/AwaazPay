import 'package:flutter/material.dart';
import 'package:awaazpay_v1/home/homepage.dart';

class NavigationRouter {
  static void switchToLogin(BuildContext context) {
    Navigator.pushNamed(context, "/LoginScreen");
  }

  static void switchToRegistration(BuildContext context) {
    Navigator.pushNamed(context, "/RegistrationScreen");
  }

  static void switchToHomePage(BuildContext context) {
    //Navigator.pushNamed(context, "/HomePage");
    Navigator.push(context, new MaterialPageRoute(
        builder: (context) =>
        new HomePage())
    );
  }
}