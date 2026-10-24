import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const FixCampusApp());
}

/// fixCampus Mobil Uygulama Kök Bileşeni (Android Telefon Çerçevesi Destekli)
class FixCampusApp extends StatelessWidget {
  const FixCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        builder: (context, child) {
          final screenSize = MediaQuery.of(context).size;
          // Masaüstü ekranında tam boy yayılmak yerine Android telefon görünümünde göster
          if (screenSize.width > 500) {
            return Scaffold(
              backgroundColor: const Color(0xFF09090B), // Koyu masaüstü zemini
              body: Center(
                child: Container(
                  width: 412,
                  height: 870,
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFF27272A), width: 8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 36,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          }
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
