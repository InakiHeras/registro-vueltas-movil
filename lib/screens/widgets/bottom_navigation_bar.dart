import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/pages/home_screen.dart';
import 'package:flutter_registro/screens/pages/qr_code_scanner.dart';
import 'package:flutter_registro/screens/pages/registros_screen.dart';
import 'package:flutter_registro/screens/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBarApp extends StatefulWidget {
  const BottomNavBarApp({super.key});

  @override
  State<BottomNavBarApp> createState() => _BottomNavBarAppState();
}

class ExampleDestination {
  const ExampleDestination(
      this.label, this.icon, this.selectedIcon, this.screen);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}

List<ExampleDestination> destinations = <ExampleDestination>[
  ExampleDestination(
    'Inicio',
    Icons.home_outlined,
    Icons.home,
    HomeScreen(),
  ),
  ExampleDestination(
    'Escáner',
    Icons.qr_code_scanner_outlined,
    Icons.qr_code_scanner,
    QRScannerScreen(),
  ),
  ExampleDestination(
    'Registros',
    Icons.edit_document,
    Icons.edit_document,
    RegistrosScreen(),
  ),
  ExampleDestination(
    'Cerrar sesión',
    Icons.logout_outlined,
    Icons.logout,
    Placeholder(), // No es una pantalla, solo logout
  ),
];

class _BottomNavBarAppState extends State<BottomNavBarApp> {
  int screenIndex = 0;

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      if (selectedScreen == 3) {
        // Logout cuando se selecciona el tercer ítem
        Provider.of<AuthProvider>(context, listen: false).logout(context);
      } else {
        screenIndex = selectedScreen;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ExampleDestination routeView = destinations[screenIndex];

    return Scaffold(
      body: routeView.screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: screenIndex,
        selectedItemColor:
            Colors.blue[800], // Define el color de los íconos seleccionados
        unselectedItemColor: Colors.grey,
        onTap: handleScreenChanged,
        items: destinations.map((ExampleDestination destination) {
          return BottomNavigationBarItem(
            icon: Icon(destination.icon),
            label: destination.label,
            activeIcon: Icon(destination.selectedIcon),
          );
        }).toList(),
      ),
    );
  }
}
