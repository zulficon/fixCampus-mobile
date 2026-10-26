import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_button.dart';

/// Kayıt Formu (Ad Soyad, E-posta, Bölüm, Sınıf, Parola ve Doğrulama)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bolumController = TextEditingController(text: 'Bilgisayar Mühendisliği');
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _secilenSinif = '1. Sınıf';

  static const List<String> _sinifSecenekleri = [
    'Hazırlık',
    '1. Sınıf',
    '2. Sınıf',
    '3. Sınıf',
    '4. Sınıf',
    'Yüksek Lisans / Doktora',
  ];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bolumController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      adSoyad: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      bolum: _bolumController.text,
      sinif: _secilenSinif,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hesabınız başarıyla oluşturuldu! Hoş geldiniz, ${_nameController.text.trim()}.'),
          backgroundColor: AppTheme.primaryBlack,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
    } else {
      final error = auth.errorMessage ?? 'Kayıt işlemi başarısız oldu.';
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
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yeni Öğrenci Hesabı',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18181B),
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'fixCampus platformuna katılmak için formu doldurunuz.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF71717A),
                  ),
                ),
                const SizedBox(height: 24),

                // Hata Çubuğu
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

                // Ad Soyad
                const Text(
                  'Ad Soyad',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Örn: Berke Mahmut Acar',
                    prefixIcon: Icon(Icons.person_outline, size: 20, color: Color(0xFF71717A)),
                  ),
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) return 'Lütfen ad ve soyadınızı giriniz.';
                    if (text.length < 2) return 'Ad Soyad en az 2 karakter olmalıdır.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kampüs E-Postası
                const Text(
                  'Kampüs E-Postası',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'ornek@ogr.edu.tr',
                    prefixIcon: Icon(Icons.school_outlined, size: 20, color: Color(0xFF71717A)),
                  ),
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) return 'Lütfen e-posta adresinizi giriniz.';
                    if (!text.contains('@') || !text.contains('.')) {
                      return 'Geçerli bir kampüs e-posta adresi giriniz.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bölüm ve Sınıf Alanları
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bölüm',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _bolumController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              hintText: 'Bölümünüz',
                              prefixIcon: Icon(Icons.account_balance_outlined, size: 18, color: Color(0xFF71717A)),
                            ),
                            validator: (val) {
                              final text = val?.trim() ?? '';
                              if (text.isEmpty) return 'Bölüm giriniz.';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sınıf',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _secilenSinif,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            ),
                            items: _sinifSecenekleri
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _secilenSinif = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Parola
                const Text(
                  'Parola',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'En az 6 karakter',
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
                    if (text.isEmpty) return 'Lütfen bir parola belirleyiniz.';
                    if (text.length < 6) return 'Parola en az 6 karakter olmalıdır.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Parola Tekrarı
                const Text(
                  'Parola Tekrarı',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF27272A)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: InputDecoration(
                    hintText: 'Parolayı tekrar giriniz',
                    prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20, color: Color(0xFF71717A)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFF71717A),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (val) {
                    final text = val?.trim() ?? '';
                    if (text.isEmpty) return 'Lütfen parolanızı tekrar giriniz.';
                    if (text != _passwordController.text.trim()) {
                      return 'Parolalar birbiriyle eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Kayıt Ol Butonu
                AppButton(
                  label: 'Kayıt Ol ve Başla',
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : () => _handleRegister(),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Zaten hesabınız var mı?',
                        style: TextStyle(color: Color(0xFF71717A), fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          auth.clearError();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Giriş Yap',
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
    );
  }
}
