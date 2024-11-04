import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_registro/screens/pages/qr_code_scanner.dart';
import 'package:flutter_registro/screens/pages/registros_screen.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:flutter_registro/screens/widgets/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'screens/pages/login_screen.dart'; // Asegúrate de que la ruta es correcta
import 'screens/providers/auth_provider.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TurnProvider()),
        ChangeNotifierProvider(create: (_) => DotacionProvider()),
        ChangeNotifierProvider(create: (_) => VueltasProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'App de Registro de Vueltas',
        theme: ThemeData(
          primaryColor: Colors.blue[400],
        ),
        // Configura las rutas de tu aplicación
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) =>
              BottomNavBarApp(), // Ruta que redirige al HomeScreen con BottomNavigationBar
          '/qr': (context) => QRScannerScreen(),
          '/registros': (context) => RegistrosScreen(),
        },
      ),
    );
  }
}
