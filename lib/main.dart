import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:awaazpay_v1/screens/login_screen.dart';
import 'package:awaazpay_v1/screens/registration_screen.dart';
import 'package:awaazpay_v1/home/homepage.dart';
import 'package:awaazpay_v1/history/history_page.dart';
import 'package:awaazpay_v1/profile/profile_page.dart';
import 'package:awaazpay_v1/settings/settings_page.dart';

var routes = <String, WidgetBuilder>{
  "/RegistrationScreen": (BuildContext context) => RegistrationScreen(),
  "/LoginScreen": (BuildContext context) => LoginScreen(),
  "/HomePage": (BuildContext context) => HomePage(),

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

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => new _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _curIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return new Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//           currentIndex: _curIndex,
// //          iconSize: 22.0,
//           onTap: (index) {
//             _curIndex = index;
//             setState(() { });
//           },
//           items: [
//             BottomNavigationBarItem(
//               icon: Image.asset(_curIndex == 0 ? 'images/ico_home_selected.png' : 'images/ico_home.png'),
//               title: Text(
//                 'Home',
//                 style: TextStyle(
//                     color: Colors.black
//                 ),
//               ),
//             ),
//             BottomNavigationBarItem(
//               icon: Image.asset(_curIndex == 1 ? 'images/ico_history_selected.png' : 'images/ico_history.png'),
//               title: Text(
//                 'History',
//                 style: TextStyle(
//                     color: Colors.black
//                 ),
//               ),
//             ),
//             BottomNavigationBarItem(
//               icon: Image.asset(_curIndex == 2 ? 'images/ico_profile_selected.png' : 'images/ico_profile.png'),
//               title: Text(
//                 'Profile',
//                 style: TextStyle(
//                     color: Colors.black
//                 ),
//               ),
//             ),
//             BottomNavigationBarItem(
//               icon: Image.asset(_curIndex == 3 ? 'images/ico_settings_selected.png' : 'images/ico_settings.png'),
//               title: Text(
//                 'Settings',
//                 style: TextStyle(
//                     color: Colors.black
//                 ),
//               ),
//             ),
//           ]),
//       body: new Center(
//         child: _getWidget(),
//       ),
//     );
//   }
//
//   Widget _getWidget() {
//     switch (_curIndex) {
//       case 0:
//         return Container(
//           color: Colors.red,
//           child: HomePage(),
//         );
//         break;
//       case 1:
//         return Container(
//           child: HistoryPage(),
//         );
//         break;
//       case 2:
//         return Container(
//           child: ProfilePage(),
//         );
//         break;
//       default:
//         return Container(
//           child: SettingsPage(),
//         );
//         break;
//     }
//   }
// }

//
// class _MyHomePageState extends State<MyHomePage> {
//
//   int _currentIndex = 0;
//   PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //appBar: AppBar(title: Text("Nav Bar")),
//       body: SizedBox.expand(
//         child: PageView(
//           controller: _pageController,
//           onPageChanged: (index) {
//             setState(() => _currentIndex = index);
//           },
//           children: <Widget>[
//             //Container(color: Colors.blueGrey,),
//             //Container(color: Colors.red,),
//             //Container(color: Colors.green,),
//            // Container(color: Colors.blue,),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavyBar(
//         selectedIndex: _currentIndex,
//         onItemSelected: (index) {
//           setState(() => _currentIndex = index);
//           _pageController.jumpToPage(index);
//         },
//         items: <BottomNavyBarItem>[
//           BottomNavyBarItem(
//               title: Text('Home'),
//               icon: Icon(Icons.home),
//             activeColor: Colors.red,
//           ),
//           BottomNavyBarItem(
//               title: Text('History'),
//               icon: Icon(Icons.apps)
//           ),
//           BottomNavyBarItem(
//               title: Text('Profile'),
//               icon: Icon(Icons.chat_bubble)
//           ),
//           BottomNavyBarItem(
//               title: Text('Settings'),
//               icon: Icon(Icons.settings)
//           ),
//         ],
//       ),
//     );
//   }
// }


