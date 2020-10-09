import 'package:flutter/material.dart';
import 'package:awaazpay_v1/send_money_flow/select_account_page.dart';
import 'package:awaazpay_v1/widgets/bank_card.dart';
import 'package:awaazpay_v1/utilities/navigation_router.dart';
//import 'package:awaazpay_v1/main.dart';
import 'package:awaazpay_v1/history/history_page.dart';
import 'package:awaazpay_v1/profile/profile_page.dart';
import 'package:awaazpay_v1/settings/settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();

}
class HomePageState extends State<HomePage> {
  int _curIndex = 0;
  final List<BankCardModel> cards = [
    BankCardModel('images/bg_red_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 10000000),
    BankCardModel('images/bg_blue_circle_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 1500000),
    BankCardModel('images/bg_purple_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 100250),
    BankCardModel('images/bg_blue_card.png', 'Hamza Abbasi',
        '4221 5168 7464 2283', '08/20', 1000),
  ];

  double screenWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    // TODO: implement build

    Widget _getWidget() {
    switch (_curIndex) {
    case 0:
    return Container(
    color: Colors.red,
    child: HomePage(),
    );
    break;
    case 1:
    return Container(
    child: HistoryPage(),
    );
    break;
    case 2:
    return Container(
    child: ProfilePage(),
    );
    break;
    default:
    return Container(
    child: SettingsPage(),
    );
    break;
    }
    }
    body: new Center(
    child: _getWidget(),
    );



    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _curIndex,
//          iconSize: 22.0,
            onTap: (Index) {
              _curIndex = Index;
              setState(() { });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 0 ? 'images/ico_home_selected.png' : 'images/ico_home.png'),
                title: Text(
                  'Home',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 1 ? 'images/ico_history_selected.png' : 'images/ico_history.png'),
                title: Text(
                  'History',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 2 ? 'images/ico_profile_selected.png' : 'images/ico_profile.png'),
                title: Text(
                  'Profile',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_curIndex == 3 ? 'images/ico_settings_selected.png' : 'images/ico_settings.png'),
                title: Text(
                  'Settings',
                  style: TextStyle(
                      color: Colors.black
                  ),
                ),
              ),
            ]),
      backgroundColor: Color(0xFFF4F4F4),
      body: ListView.builder(
          itemCount: 4,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _userInfoWidget();
            } else if (index == 1) {
              return _userBankCardsWidget();
            } else if (index == 2) {
              return _sendMoneySectionWidget();
            } else {
              return _utilitesSectionWidget();
            }
          }),
    );
  }

  Widget _userInfoWidget() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    child: Text('T'),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Hamza Abbasi',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              )),
          Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new Icon(Icons.notifications_none,
                    size: 30.0,),
                ),
                new Positioned(  // draw a red marble
                  top: 3.0,
                  left: 3.0,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFE95482),
                        borderRadius: BorderRadius.circular(8.0)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        '02',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  ),
                )
              ]
          ),
        ],
      ),
    );
  }

  Widget _userBankCardsWidget() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
//      height: 400.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Text('My Bank Accounts')),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            height: 166.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return _getBankCard(index);
              },
            ),
          ),
          Container(
            height: 80.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTapUp: (tapDetail) {
                      Navigator.push(context,
                          SelectAccountPageRoute());
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset('images/ico_send_money.png'),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Send\nmoney',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          Image.asset('images/ico_receive_money.png'),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Receive\nmoney',
                              style: TextStyle(fontWeight: FontWeight.w700),),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sendMoneySectionWidget() {
    var smallItemPadding = EdgeInsets.only(
        left: 12.0, right: 12.0, top: 12.0);
    if (screenWidth <= 320) {
      smallItemPadding = EdgeInsets.only(
          left: 10.0, right: 10.0, top: 12.0);
    }
    return Container(
//      color: Colors.yellow,
      margin: EdgeInsets.all(16.0),
//      height: 200.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Send money to',
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTapUp: null,
                child: Text('View all'),
              )
            ],
          ),
          Container(
            height: 100.0,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_add_new.png',
                          height: 40.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Add new'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          child: Text('T'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Salina'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          child: Text('T'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Emily'),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          child: Text('T'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Nichole'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _utilitesSectionWidget() {
    var smallItemPadding = EdgeInsets.only(
        left: 12.0, right: 12.0, top: 12.0);
    if (screenWidth <= 320) {
      smallItemPadding = EdgeInsets.only(
          left: 10.0, right: 10.0, top: 12.0);
    }
    return Container(
//      color: Colors.yellow,
      margin: EdgeInsets.all(16.0),
//      height: 200.0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Utilities',
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: 80.0,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_phone.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child:
                          Text('Mobile', style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_elect.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Electricity',
                            style: TextStyle(fontSize: 12.0),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_broad.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Broadband',
                              style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: smallItemPadding,
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'images/ico_pay_gas.png',
                          height: 26.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Gas', style: TextStyle(fontSize: 12.0)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getBankCard(int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BankCard(card: cards[index]),
    );
  }
}
