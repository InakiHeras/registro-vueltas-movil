import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/pages/home_screen.dart';
import 'package:flutter_registro/screens/pages/qr_code_scanner.dart';
import 'package:flutter_registro/screens/pages/registros_screen.dart';
import 'package:flutter_registro/screens/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BottomNavBarApp extends StatefulWidget {
  const BottomNavBarApp({Key? key}) : super(key: key);

  @override
  State<BottomNavBarApp> createState() => _BottomNavBarAppState();
}

class _BottomNavBarAppState extends State<BottomNavBarApp> {
  int screenIndex = 0;
  bool refreshRegistros = false; // Flag to refresh RegistrosScreen

  void navigateToRegistrosScreen() {
    setState(() {
      screenIndex = 2; // Set the index for RegistrosScreen
      refreshRegistros = true; // Set the refresh flag
    });
  }

  void handleScreenChanged(int selectedScreen) {
    setState(() {
      if (selectedScreen == 3) {
        // Logout when selecting the last item
        Provider.of<AuthProvider>(context, listen: false).logout(context);
      } else {
        screenIndex = selectedScreen;
        // Reset refresh flag if switching to RegistrosScreen
        if (screenIndex == 2) refreshRegistros = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      HomeScreen(),
      QRScannerScreen(),
      RegistrosScreen(
        refresh: refreshRegistros,
      ),
      Placeholder(), // Placeholder for logout action
    ];

    return Scaffold(
      body: screens[screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: screenIndex,
        selectedItemColor: Colors.blue[800],
        unselectedItemColor: Colors.grey,
        onTap: handleScreenChanged,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Escáner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Cerrar sesión',
          ),
        ],
      ),
    );
  }
}
