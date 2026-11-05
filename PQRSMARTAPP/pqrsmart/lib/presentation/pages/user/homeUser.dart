import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/ChatBoxBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_chat_screen.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_home_screen.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_profile_screen.dart';
import 'package:pqrsmart/presentation/pages/user/pqr_requests_screen.dart';
import 'package:pqrsmart/presentation/states/ChatBoxEvent.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  int _currentIndex = 0;
  String? _selectedType;

  void _showRequests(String? type) {
    context.read<RequestBloc>().add(LoadRequestEvent());
    setState(() {
      _selectedType = type;
      _currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<RequestBloc>(
        create: (_) =>
            RequestBloc(RequestRepository(RequestService()))
              ..add(LoadRequestEvent()),
      ),
      BlocProvider<UserBloc>(
        create: (_) =>
            UserBloc(UserRepository(UserService()))..add(GetMyUserEvent()),
      ),
      BlocProvider<ChatBoxBloc>(
        create: (_) => ChatBoxBloc()..add(LoadChatBoxUser()),
      ),
    ],
    child: Scaffold(
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            PqrHomeScreen(onShowRequests: _showRequests),
            PqrRequestsScreen(
              key: ValueKey(_selectedType),
              initialType: _selectedType,
            ),
            const PqrChatScreen(),
            const PqrProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 1) _selectedType = null;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.action,
          unselectedItemColor: AppColors.muted,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Solicitudes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    ),
  );
}
