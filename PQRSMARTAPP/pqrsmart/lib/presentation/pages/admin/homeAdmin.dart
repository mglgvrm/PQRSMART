import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/core/theme/app_colors.dart';
import 'package:pqrsmart/data/repository/CategoryRepository.dart';
import 'package:pqrsmart/data/repository/DependenceRepository.dart';
import 'package:pqrsmart/data/repository/RequestRepository.dart';
import 'package:pqrsmart/data/repository/UserRepository.dart';
import 'package:pqrsmart/data/services/CategoryService.dart';
import 'package:pqrsmart/data/services/DependenceService.dart';
import 'package:pqrsmart/data/services/RequestService.dart';
import 'package:pqrsmart/data/services/UserService.dart';
import 'package:pqrsmart/presentation/blocs/CategoryBloc.dart';
import 'package:pqrsmart/presentation/blocs/ChatBoxBloc.dart';
import 'package:pqrsmart/presentation/blocs/DependenceBloc.dart';
import 'package:pqrsmart/presentation/blocs/RequestBloc.dart';
import 'package:pqrsmart/presentation/blocs/UserBloc.dart';
import 'package:pqrsmart/presentation/pages/admin/Category.dart';
import 'package:pqrsmart/presentation/pages/admin/Dependence.dart';
import 'package:pqrsmart/presentation/pages/admin/admin_profile_screen.dart';
import 'package:pqrsmart/presentation/pages/admin/dashboard.dart';
import 'package:pqrsmart/presentation/pages/admin/home.dart';
import 'package:pqrsmart/presentation/pages/admin/requests_admin_page.dart';
import 'package:pqrsmart/presentation/pages/admin/user.dart';
import 'package:pqrsmart/presentation/states/CategoryEvent.dart';
import 'package:pqrsmart/presentation/states/ChatBoxEvent.dart';
import 'package:pqrsmart/presentation/states/DependenceEvent.dart';
import 'package:pqrsmart/presentation/states/RequestEvent.dart';
import 'package:pqrsmart/presentation/states/UserEvent.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  static const _destinations = [
    _AdminDestination('Inicio', Icons.home_outlined),
    _AdminDestination('Dashboard', Icons.dashboard_outlined),
    _AdminDestination('Usuarios', Icons.people_outline),
    _AdminDestination('Dependencias', Icons.account_tree_outlined),
    _AdminDestination('Categorías', Icons.category_outlined),
    _AdminDestination('Solicitudes', Icons.description_outlined),
    _AdminDestination('Perfil', Icons.person_outline),
  ];

  late final PageController _pageController;
  late final List<Widget> _pages;
  int _currentIndex = 0;
  DateTime? _lastPressed;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = const [
      Home(),
      Dashboard(),
      User(),
      DependencePage(),
      CategoryPage(),
      RequestsAdminPage(),
      AdminProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressed == null ||
        now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      _lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presiona de nuevo para salir'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<UserBloc>(
        create: (_) =>
            UserBloc(UserRepository(UserService()))..add(GetUserEvent()),
      ),
      BlocProvider<DependenceBloc>(
        create: (_) =>
            DependenceBloc(DependenceRepository(DependenceService()))
              ..add(LoadDependenceEvent()),
      ),
      BlocProvider<CategoryBloc>(
        create: (_) =>
            CategoryBloc(CategoryRepository(CategoryService()))
              ..add(LoadCategoriesEvent()),
      ),
      BlocProvider<ChatBoxBloc>(
        create: (_) => ChatBoxBloc()..add(LoadChatBoxUser()),
      ),
      BlocProvider<RequestBloc>(
        create: (_) =>
            RequestBloc(RequestRepository(RequestService()))
              ..add(LoadAllRequestsEvent()),
      ),
    ],
    child: WillPopScope(
      onWillPop: _onWillPop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          return Scaffold(
            body: Row(
              children: [
                if (wide) ...[
                  NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: _selectPage,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: AppColors.white,
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.primary,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: AppColors.muted,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: AppColors.muted,
                    ),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Icon(
                        Icons.account_balance,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1, color: AppColors.border),
                ],
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentIndex = index),
                          children: _pages,
                        ),
                      ),
                      if (!wide) _compactNavigation(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _compactNavigation() => Container(
    height: 72,
    decoration: const BoxDecoration(
      color: AppColors.white,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: _destinations.length,
      separatorBuilder: (_, __) => const SizedBox(width: 4),
      itemBuilder: (context, index) {
        final destination = _destinations[index];
        final selected = _currentIndex == index;
        return Semantics(
          button: true,
          selected: selected,
          label: destination.label,
          child: InkWell(
            onTap: () => _selectPage(index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 82,
              decoration: BoxDecoration(
                color: selected ? AppColors.surfaceBlue : AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    destination.icon,
                    size: 20,
                    color: selected ? AppColors.primary : AppColors.muted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: selected ? AppColors.primary : AppColors.muted,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _AdminDestination {
  const _AdminDestination(this.label, this.icon);

  final String label;
  final IconData icon;
}
