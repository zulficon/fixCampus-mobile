import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key, required this.child, this.adminOnly = false});
  final Widget child;
  final bool adminOnly;
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const LoginScreen();
    if (adminOnly && !auth.isAdmin) {
      return const Scaffold(
          body: Center(child: Text('Bu ekran için yönetici yetkisi gerekir.')));
    }
    return child;
  }
}
