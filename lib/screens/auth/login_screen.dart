import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_button.dart';

/// Sadeleştirilmiş Giriş Ekranı (İskelet Görünümü, Logosuz)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'berke@ogr.edu.tr');
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Giriş Yap (1. Hafta İskeleti)',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 32),

              // E-posta
              const Text(
                'E-Posta',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'ornek@ogr.edu.tr',
                ),
              ),
              const SizedBox(height: 16),

              // Parola
              const Text(
                'Parola',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '••••••••',
                ),
              ),
              const SizedBox(height: 24),

              // Giriş Butonu
              AppButton(
                label: 'Giriş Yap',
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabınız yok mu?',
                    style: TextStyle(color: Color(0xFF71717A), fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.register);
                    },
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
