import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/admin/admin_panel_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/listings/create_listing_screen.dart';
import '../screens/listings/listing_detail_screen.dart';
import '../screens/shell/main_shell_screen.dart';
import '../screens/splash/splash_screen.dart';

/// fixCampus Mobil Sayfa Rotaları ve Gezinme Yöneticisi
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String createListing = '/create-listing';
  static const String listingDetail = '/listing-detail';
  static const String adminPanel = '/admin-panel';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());

      case createListing:
        return MaterialPageRoute(builder: (_) => const CreateListingScreen());

      case listingDetail:
        final ilan = settings.arguments as Ilan?;
        if (ilan != null) {
          return MaterialPageRoute(
            builder: (_) => ListingDetailScreen(ilan: ilan),
          );
        }
        return _errorRoute('İlan parametresi eksik.');

      case adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminPanelScreen());

      default:
        return _errorRoute('Rota bulunamadı: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Hata')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
