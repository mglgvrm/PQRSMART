import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pqrsmart/presentation/blocs/auth_bloc.dart';
import 'package:pqrsmart/presentation/states/auth_event.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  void _showProfile(BuildContext context) {
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PerfilPage()),
    );*/
  }
  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
        content: Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: conectar con el evento del Bloc para cerrar sesión
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Administración'),
        centerTitle: true,
        backgroundColor: Color(0xFF4A6B5A),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'perfil') {
                _showProfile(context);
              } else if (value == 'cerrar_sesion') {
                _signOut(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Perfil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // 🔹 Título
              const Text(
                "Bienvenido",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              // 🔹 Card Misión
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      "Misión",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Brindar soluciones efectivas a través de un servicio ágil, transparente y empático, gestionando cada petición, queja, reclamo y sugerencia con el compromiso de mejorar continuamente la experiencia de nuestros usuarios.",
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 Puedes agregar más cards aquí
            ],
          ),
        ),
      ),
    );
  }
}
