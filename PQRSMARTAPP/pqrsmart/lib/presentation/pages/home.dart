import 'package:flutter/material.dart';
import 'package:urbanestia/presentation/pages/drawer_user.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> _dropdownItems = [
    'Todos',
    'Casas',
    'Departamentos',
    'Oficinas',
  ];
  String _selectedValue = 'Todos';
  int selectedIndex = 0;

  final List<String> menuItems = ['INICIO', 'VENTA', 'ALQUILER', 'CONTACTO'];

  final List<Widget> views = [
    const Center(child: Text('Vista de INICIO')),
    const Center(child: Text('Vista de VENTA')),
    const Center(child: Text('Vista de ALQUILER')),
    const Center(child: Text('Vista de CONTACTO')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 170,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Image.asset(
            'assets/vectors/logo.png',
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.business,
                size: 40,
              ); // Fallback si no encuentra la imagen
            },
          ),
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
          ),
        ],
      ),
      drawer: const DrawerUser(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.07,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '¿Qué quieres buscar?',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.grey,
                          ),
                          items:
                              _dropdownItems.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedValue = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // Menú horizontal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(menuItems.length, (index) {
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          menuItems[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[400],
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 2,
                          width: isSelected ? 40 : 30,
                          color: isSelected ? Colors.black : Colors.grey[300],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            // Vista correspondiente al botón seleccionado
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                  0.5, // Altura fija para evitar problemas de renderizado
              child: IndexedStack(index: selectedIndex, children: views),
            ),
          ],
        ),
      ),
    );
  }
}
