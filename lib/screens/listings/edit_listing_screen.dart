import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/listing_validator.dart';
import '../../widgets/app_button.dart';

/// İlan Düzenleme Ekranı (Sahip veya Yönetici Yetkisi ile)
class EditListingScreen extends StatefulWidget {
  const EditListingScreen({super.key, required this.ilan});

  final Ilan ilan;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _baslikController;
  late final TextEditingController _yerController;
  late final TextEditingController _aciklamaController;

  late IlanTuru _secilenTur;
  late String? _secilenKategoriId;
  DateTime? _secilenTarih;
  TimeOfDay? _secilenSaat;
  bool _isSubmitting = false;
  String? _tarihHatasi;

  @override
  void initState() {
    super.initState();
    _baslikController = TextEditingController(text: widget.ilan.baslik);
    _yerController = TextEditingController(text: widget.ilan.yer);
    _aciklamaController = TextEditingController(text: widget.ilan.aciklama);
    _secilenTur = widget.ilan.tur;
    _secilenKategoriId = widget.ilan.kategoriId;

    if (widget.ilan.bulusmaTarihi != null) {
      final local = widget.ilan.bulusmaTarihi!.toLocal();
      _secilenTarih = DateTime(local.year, local.month, local.day);
      _secilenSaat = TimeOfDay(hour: local.hour, minute: local.minute);
    }
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _yerController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  DateTime? get _bulusmaZamani {
    if (_secilenTur != IlanTuru.sosyal || _secilenTarih == null) return null;
    final time = _secilenSaat ?? const TimeOfDay(hour: 12, minute: 0);
    return DateTime(
      _secilenTarih!.year,
      _secilenTarih!.month,
      _secilenTarih!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _secilenTarih ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Buluşma Tarihi Seçin',
      confirmText: 'İleri',
      cancelText: 'İptal',
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _secilenSaat ?? const TimeOfDay(hour: 14, minute: 0),
        helpText: 'Buluşma Saati Seçin',
        confirmText: 'Seç',
        cancelText: 'İptal',
      );

      setState(() {
        _secilenTarih = pickedDate;
        if (pickedTime != null) {
          _secilenSaat = pickedTime;
        }
        _tarihHatasi = null;
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _tarihHatasi = null;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (_secilenTur == IlanTuru.sosyal) {
      final dateError = ListingValidator.validateMeetingDate(
        _bulusmaZamani,
        _secilenTur,
      );
      if (dateError != null) {
        setState(() {
          _tarihHatasi = dateError;
        });
        return;
      }
    }

    if (!isFormValid) return;

    setState(() => _isSubmitting = true);

    final listingsProvider = context.read<ListingsProvider>();
    final updated = await listingsProvider.updateListing(
      id: widget.ilan.id,
      baslik: _baslikController.text,
      aciklama: _aciklamaController.text,
      kategoriId: _secilenKategoriId!,
      tur: _secilenTur,
      yer: _yerController.text,
      bulusmaTarihi: _bulusmaZamani,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF18181B),
          content: Text('İlan başarıyla güncellendi.'),
        ),
      );
      Navigator.pop(context, updated);
    } else {
      final error = listingsProvider.errorMessage ?? 'İlan güncellenemedi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();

    final canEdit = ListingValidator.canEditOrDelete(
      ilan: widget.ilan,
      user: auth.currentUser,
    );

    if (!canEdit) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yetkisiz Erişim')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bu ilanı düzenleme yetkiniz bulunmuyor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yalnızca ilanın sahibi veya yönetici rolündeki kullanıcılar düzenleme yapabilir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF71717A),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Geri Dön'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final availableCategories = listingsProvider.kategoriler.where((k) {
      return k.tur == _secilenTur;
    }).toList();

    if (_secilenKategoriId != null &&
        !availableCategories.any((k) => k.id == _secilenKategoriId)) {
      _secilenKategoriId = null;
    }

    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlanı Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'İlan Bilgilerini Düzenle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'İlan başlığı, yeri veya açıklamasını güncelleyin',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 16),

              // Kategori Dropdown
              DropdownButtonFormField<String>(
                key: const Key('edit_listing_category'),
                initialValue: _secilenKategoriId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
                  hintText: 'Bir kategori seçin',
                ),
                items: availableCategories.map((k) {
                  return DropdownMenuItem<String>(
                    value: k.id,
                    child: Text(k.ad),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _secilenKategoriId = val);
                },
                validator: (val) => ListingValidator.validateCategory(
                  val,
                  _secilenTur,
                  availableCategories,
                ),
              ),
              const SizedBox(height: 12),

              // Başlık
              TextFormField(
                key: const Key('edit_listing_title'),
                controller: _baslikController,
                maxLength: ListingValidator.maxTitleLength,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı *',
                  hintText: 'Örn: Kütüphanede Algoritma Vize Çalışması',
                ),
                validator: ListingValidator.validateTitle,
              ),
              const SizedBox(height: 8),

              // Yer / Konum
              TextFormField(
                key: const Key('edit_listing_location'),
                controller: _yerController,
                maxLength: ListingValidator.maxLocationLength,
                decoration: const InputDecoration(
                  labelText: 'Yer / Konum *',
                  hintText: 'Örn: Merkez Kütüphane B Blok 2. Kat',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
                validator: ListingValidator.validateLocation,
              ),
              const SizedBox(height: 8),

              // Sosyal Buluşma için Tarih ve Saat Seçimi
              if (_secilenTur == IlanTuru.sosyal) ...[
                InkWell(
                  key: const Key('edit_listing_date_picker'),
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _tarihHatasi != null
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFE4E4E7),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 20,
                          color: _tarihHatasi != null
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF71717A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _bulusmaZamani != null
                                ? dateFormat.format(_bulusmaZamani!)
                                : 'Buluşma Tarihi ve Saati Seçin *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _bulusmaZamani != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _bulusmaZamani != null
                                  ? const Color(0xFF18181B)
                                  : const Color(0xFFA1A1AA),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Color(0xFF71717A),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_tarihHatasi != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      _tarihHatasi!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],

              // Açıklama
              TextFormField(
                key: const Key('edit_listing_description'),
                controller: _aciklamaController,
                maxLines: 4,
                maxLength: ListingValidator.maxDescriptionLength,
                decoration: const InputDecoration(
                  labelText: 'Açıklama *',
                  hintText: 'Detaylı bilgi veya güncelleme notları...',
                  alignLabelWithHint: true,
                ),
                validator: ListingValidator.validateDescription,
              ),
              const SizedBox(height: 20),

              // Kaydet Butonu
              AppButton(
                key: const Key('edit_listing_save_button'),
                label: 'Değişiklikleri Kaydet',
                icon: Icons.save_outlined,
                isLoading: _isSubmitting,
                onPressed: _submitForm,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

