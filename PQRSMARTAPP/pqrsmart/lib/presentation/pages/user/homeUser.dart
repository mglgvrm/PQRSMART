import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pqrsmart/data/repository/CategoryRepository.dart';
import 'package:pqrsmart/data/repository/DependenceRepository.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/CategoryService.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/CategoryBloc.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/pages/user/Request.dart';
import 'package:pqrsmart/presentation/pages/user/home.dart';
import 'package:pqrsmart/presentation/states/CategoryEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  final List<Widget> _pageList = [HomePage(), RequestPage()];
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<RequestBloc>(
          create: (_) => RequestBloc(RequestRepository(RequestService()))
            ..add(LoadRequestEvent()),
        ),
        BlocProvider<UserBloc>(
          create: (_) => UserBloc(UserRepository(UserService()))
            ..add( GetMyUserEvent()),
        ),


      ],
      child: WillPopScope(
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
                  setState(() {
                    _currentIndex = value;
                    _pageController.jumpToPage(_currentIndex);
                    print('${value} ${_currentIndex}');
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home_outlined,
                      color: _currentIndex == 0 ? Colors.green : Colors.black,
                    ),
                    label: 'Home',
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.description_outlined,
                      color: _currentIndex == 1 ? Colors.green : Colors.black,
                    ),
                    label: 'PQRS',
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
