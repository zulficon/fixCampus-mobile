import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../security/listing_mutation_policy.dart';
import '../../security/role_session_policy.dart';
import '../../validation/listing_validator.dart';
import '../../widgets/app_button.dart';

/// Sadeleştirilmiş İlan Verme Ekranı (Tarih/Saat ve Fotoğraf Fonksiyonları Kaldırıldı)
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  final _yerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const _validator = ListingValidator();

  IlanTuru _secilenTur = IlanTuru.sosyal;
  String? _secilenKategoriId;

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _yerController.dispose();
    super.dispose();
  }

  void _handleMockSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final access = const ListingMutationPolicy().evaluate(
      action: ListingMutation.create,
      hasSession: auth.isLoggedIn,
      isLoading: auth.isLoading,
      profile: auth.currentUser,
      hasSessionError: auth.hasSessionError,
    );
    if (access != RoleAccess.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan vermek için oturumunuzu doğrulayın.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF18181B),
        content: Text('İlan oluşturma özelliği yakında aktifleşecektir.'),
      ),
    );
  }

  void _changeType(IlanTuru type) {
    setState(() {
      _secilenTur = type;
      _secilenKategoriId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();

    final availableCategories = listingsProvider.kategoriler
        .where((k) => _validator.acceptsCategory(_secilenTur, k))
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Yeni İlan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Kampüs ile paylaşmak istediğiniz ilanı oluşturun',
                style: TextStyle(fontSize: 13, color: Color(0xFF71717A)),
              ),
              const SizedBox(height: 16),

              // Tür Seçimi
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Sosyal',
                      isSelected: _secilenTur == IlanTuru.sosyal,
                      onTap: () => _changeType(IlanTuru.sosyal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeButton(
                      label: 'Kayıp',
                      isSelected: _secilenTur == IlanTuru.kayip,
                      onTap: () => _changeType(IlanTuru.kayip),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypeButton(
                      label: 'Buluntu',
                      isSelected: _secilenTur == IlanTuru.buluntu,
                      onTap: () => _changeType(IlanTuru.buluntu),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Başlık
              const Text(
                'İlan Başlığı',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _baslikController,
                validator: _validator.title,
                decoration: const InputDecoration(hintText: 'Başlık girin...'),
              ),
              const SizedBox(height: 16),

              // Kategori
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                key: ValueKey(_secilenTur),
                isExpanded: true,
                initialValue: _secilenKategoriId,
                validator: (value) => _validator.category(
                  value,
                  type: _secilenTur,
                  categories: listingsProvider.kategoriler,
                ),
                hint: const Text('Kategori seçin'),
                items: availableCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.ad, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _secilenKategoriId = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Açıklama
              const Text(
                'Açıklama',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF27272A),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _aciklamaController,
                validator: _validator.description,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Detaylı bilgi girin...',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yerController,
                validator: _validator.location,
                decoration: const InputDecoration(
                  labelText: 'İlan Yeri',
                  hintText: 'Bina, kat veya buluşma yeri',
                ),
              ),
              const SizedBox(height: 24),

              // Buton (İskelet)
              AppButton(
                label: 'İlanı Yayınla (İskelet)',
                onPressed: _handleMockSubmit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF27272A),
            ),
          ),
        ),
      ),
    );
  }
}
