import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

/// Giriş Formu (Öğrenci / Yönetici Rol Seçimi, Validasyonlar ve Hata Yönetimi)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'berke@ogr.edu.tr');
  final _passwordController = TextEditingController(text: '123456');

  bool _isStudent = true; // true: Öğrenci, false: Yönetici
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(bool isStudentSelected) {
    if (_isStudent == isStudentSelected) return;

    setState(() {
      _isStudent = isStudentSelected;
      if (_isStudent) {
        if (_emailController.text == 'admin@kampus.edu.tr' || _emailController.text.isEmpty) {
          _emailController.text = 'berke@ogr.edu.tr';
        }
      } else {
        if (_emailController.text == 'berke@ogr.edu.tr' || _emailController.text.isEmpty) {
          _emailController.text = 'admin@kampus.edu.tr';
        }
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final asAdmin = !_isStudent;
    final success = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
      asAdmin: asAdmin,
    );

    if (!mounted) return;

    if (success) {
      final roleTitle = asAdmin ? 'Yönetici' : 'Öğrenci';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$roleTitle olarak giriş yapıldı. Hoş geldiniz!'),
          backgroundColor: AppTheme.primaryBlack,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      final error = auth.errorMessage ?? 'Giriş yapılamadı.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Hesap türünüzü seçip giriş yapınız',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF71717A),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Üst Kısım: Öğrenci / Yönetici Seçim Çubuğu
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE4E4E7)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onRoleChanged(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isStudent ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: _isStudent
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x10000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_outlined,
                                    size: 18,
                                    color: _isStudent ? const Color(0xFF18181B) : const Color(0xFF71717A),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Öğrenci',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _isStudent ? FontWeight.w700 : FontWeight.w500,
                                      color: _isStudent ? const Color(0xFF18181B) : const Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _onRoleChanged(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isStudent ? const Color(0xFF18181B) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: !_isStudent
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x20000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    size: 18,
                                    color: !_isStudent ? Colors.white : const Color(0xFF71717A),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Yönetici',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: !_isStudent ? FontWeight.w700 : FontWeight.w500,
                                      color: !_isStudent ? Colors.white : const Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hata Bildirim Çubuğu
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // E-posta Alanı
                  Text(
                    _isStudent ? 'Öğrenci E-Postası' : 'Yönetici E-Postası',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: _isStudent ? 'ornek@ogr.edu.tr' : 'admin@kampus.edu.tr',
                      prefixIcon: Icon(
                        _isStudent ? Icons.school_outlined : Icons.shield_outlined,
                        size: 20,
                        color: const Color(0xFF71717A),
                      ),
                    ),
                    validator: (val) {
                      final text = val?.trim() ?? '';
                      if (text.isEmpty) return 'Lütfen e-posta adresinizi giriniz.';
                      if (!text.contains('@') || !text.contains('.')) {
                        return 'Lütfen geçerli bir e-posta formatı giriniz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Parola Alanı
                  const Text(
                    'Parola',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF71717A)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFF71717A),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      final text = val?.trim() ?? '';
                      if (text.isEmpty) return 'Lütfen parolanızı giriniz.';
                      if (text.length < 6) return 'Parola en az 6 karakter olmalıdır.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Giriş Butonu
                  AppButton(
                    label: _isStudent ? 'Öğrenci Olarak Giriş Yap' : 'Yönetici Olarak Giriş Yap',
                    isLoading: auth.isLoading,
                    onPressed: auth.isLoading ? null : _handleLogin,
                  ),
                  const SizedBox(height: 24),

                  // Kayıt Ol Yönlendirmesi (Yalnızca Öğrenci için)
                  if (_isStudent)
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Hesabınız yok mu?',
                            style: TextStyle(color: Color(0xFF71717A), fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () {
                              auth.clearError();
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
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
