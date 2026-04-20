import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:urbanestia/presentation/pages/dashboard/dashboard_page.dart';
import 'package:urbanestia/presentation/pages/editProfile/activity_profile.dart';
import 'package:urbanestia/presentation/pages/home.dart';
import 'package:urbanestia/presentation/pages/message/message_page.dart';
import 'package:urbanestia/presentation/pages/notification/notification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pageList = [Home(), NotificationPage(), MessagePage()];
  int _currentIndex = 0;
  PageController _pageController = new PageController();
  DateTime? _lastPressed;

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    final maxDuration = Duration(seconds: 2);

    if (_lastPressed == null || now.difference(_lastPressed!) > maxDuration) {
      _lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Presiona de nuevo para salir'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // No salgas todavía
    }

    return true; // Segunda vez: salir
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          allowImplicitScrolling: false,
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          children: _pageList,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 15)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.green,
              unselectedItemColor: Colors.black,
              currentIndex: _currentIndex,
              backgroundColor: Colors.white,
              selectedLabelStyle: TextStyle(color: Colors.black),
              unselectedLabelStyle: TextStyle(color: Colors.orange),
              onTap: (value) {
                if (value == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage()),
                  );
                  return;
                } else if (value == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ActivityProfile()),
                  );
                  return;
                } else {
                  setState(() {
                    _currentIndex = value;
                    _pageController.jumpToPage(_currentIndex);
                    print('${value} ${_currentIndex}');
                  });
                }
              },
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/vectors/icons_home.svg',
                    color: _currentIndex == 0 ? Colors.green : Colors.black,
                  ),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/vectors/ion_notifications.svg',
                    color: _currentIndex == 1 ? Colors.green : Colors.black,
                  ),
                  label: 'Notificaciones',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/vectors/ion_chatbox-ellipses-outline.svg',
                    color: _currentIndex == 2 ? Colors.green : Colors.black,
                  ),
                  label: 'Mensajes',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/vectors/icon_dashboard.svg',
                    color: _currentIndex == 3 ? Colors.green : Colors.black,
                    width: 30,
                    height: 30,
                  ),
                  label: 'Dashboard',
                ),

                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/vectors/mdi_account.svg',
                    color: _currentIndex == 4 ? Colors.green : Colors.black,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
