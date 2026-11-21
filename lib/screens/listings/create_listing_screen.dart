import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../security/listing_access.dart';
import '../../security/listing_mutation_policy.dart';
import '../../security/role_session_policy.dart';
import '../../theme/app_theme.dart';
import '../../validation/listing_validator.dart';
import '../../services/api_exception.dart';
import '../../services/listings_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/listings_load_status.dart';
import '../../widgets/meeting_date_time_picker.dart';
import '../../widgets/meeting_location_picker.dart';

/// Mevcut ilan formunun ortak API'ye bağlanan oluşturma/düzenleme akışı.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key, this.ilan, this.nowProvider});
  final Ilan? ilan;
  final DateTime Function()? nowProvider;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _baslik;
  late final TextEditingController _aciklama;
  late final TextEditingController _yer;
  late IlanTuru _tur;
  String? _kategoriId;
  DateTime? _tarih;
  String? _error;
  String? _dateError;
  bool _saving = false;
  static const _validator = ListingValidator();

  RoleAccess _access(AuthProvider auth) => listingAccess(
    auth,
    widget.ilan == null ? ListingMutation.create : ListingMutation.update,
    listing: widget.ilan,
  );

  @override
  void initState() {
    super.initState();
    final ilan = widget.ilan;
    _baslik = TextEditingController(text: ilan?.baslik);
    _aciklama = TextEditingController(text: ilan?.aciklama);
    _yer = TextEditingController(text: ilan?.yer);
    _tur = ilan?.tur ?? IlanTuru.sosyal;
    _kategoriId = ilan?.kategoriId;
    _tarih = ilan?.bulusmaTarihi?.toLocal();
  }

  @override
  void dispose() {
    _baslik.dispose();
    _aciklama.dispose();
    _yer.dispose();
    super.dispose();
  }

  DateTime _now() =>
      widget.nowProvider != null ? widget.nowProvider!() : DateTime.now();

  void _onMeetingDateChanged(DateTime? date) {
    setState(() {
      _tarih = date;
      _dateError = date == null
          ? null
          : _validator.meetingDate(_tur, date, now: _now());
    });
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    final access = _access(context.read<AuthProvider>());
    if (access != RoleAccess.allowed) {
      setState(() => _error = listingAccessMessage(access));
      return;
    }
    final dateError = _validator.meetingDate(_tur, _tarih, now: _now());
    if (dateError != null) {
      setState(() => _dateError = dateError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
      _dateError = null;
    });
    final provider = context.read<ListingsProvider>();
    final request = SaveListingRequest(
      baslik: _baslik.text,
      aciklama: _aciklama.text,
      kategoriId: _kategoriId!,
      tur: _tur,
      yer: _yer.text,
      bulusmaTarihi: _tur == IlanTuru.sosyal ? _tarih : null,
    );
    try {
      final original = widget.ilan;
      if (original != null) {
        await provider.updateListing(original.id, request);
        if (mounted) Navigator.pop(context, true);
      } else {
        await provider.createListing(request);
        if (!mounted) return;
        _baslik.clear();
        _aciklama.clear();
        _yer.clear();
        // Dropdown reset'i eski onChanged değerini geri çağırabilir.
        // Önce alanları sıfırla, ardından yeni ilan durumunu uygula.
        _form.currentState!.reset();
        setState(() {
          _kategoriId = null;
          _tarih = null;
          _error = null;
          _dateError = null;
          _tur = IlanTuru.sosyal;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İlan yayınlandı.')));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e is ListingApiException &&
              e.fieldErrors.isNotEmpty &&
              e.fieldErrors.keys.every(
                (key) => key.toLowerCase() == 'bulusmatarihi',
              )) {
            _dateError = e.message;
          } else {
            _error = e is ApiException
                ? e.message
                : 'İlan kaydedilemedi. Tekrar deneyin.';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final access = _access(context.watch<AuthProvider>());
    if (access != RoleAccess.allowed) {
      return Scaffold(
        appBar: AppBar(title: const Text('İlan İşlemi')),
        body: Center(child: Text(listingAccessMessage(access))),
      );
    }
    final provider = context.watch<ListingsProvider>();
    final categories = provider.kategoriler
        .where((k) => _validator.acceptsCategory(_tur, k))
        .toList();
    final selected = categories.any((k) => k.id == _kategoriId)
        ? _kategoriId
        : null;
    final busy = _saving || provider.isSaving;
    final showCreateAppBar =
        widget.ilan == null && (ModalRoute.of(context)?.canPop ?? false);
    return Scaffold(
      appBar: widget.ilan != null
          ? AppBar(title: const Text('İlanı Düzenle'))
          : showCreateAppBar
          ? AppBar(title: const Text('Yeni İlan'))
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Açıklayıcı Kart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.smallCardRadius),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.ink,
                        borderRadius: BorderRadius.circular(
                          AppTheme.iconRadius,
                        ),
                      ),
                      child: Icon(
                        widget.ilan == null
                            ? Icons.add_circle_outline
                            : Icons.edit_outlined,
                        color: AppTheme.surface,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.ilan == null ? 'Yeni İlan' : 'İlan Bilgileri',
                            style: AppTheme.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.ilan == null
                                ? 'Kampüsteki arkadaşlarınla paylaş'
                                : 'İlan detaylarını güncelleyin',
                            style: AppTheme.meta.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListingsLoadStatus(provider: provider),

              // İlan Türü Dropdown
              DropdownButtonFormField<IlanTuru>(
                key: ValueKey(_tur),
                initialValue: _tur,
                decoration: const InputDecoration(
                  labelText: 'İlan türü',
                  prefixIcon: Icon(
                    Icons.campaign_outlined,
                    size: 20,
                    color: AppTheme.muted,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: IlanTuru.sosyal,
                    child: Text('Sosyal'),
                  ),
                  DropdownMenuItem(value: IlanTuru.kayip, child: Text('Kayıp')),
                  DropdownMenuItem(
                    value: IlanTuru.buluntu,
                    child: Text('Buluntu'),
                  ),
                ],
                onChanged: busy
                    ? null
                    : (value) => setState(() {
                        _tur = value!;
                        _kategoriId = null;
                        _tarih = null;
                        _error = null;
                        _dateError = null;
                      }),
              ),
              const SizedBox(height: 16),

              // İlan Başlığı (TextFormField 0)
              TextFormField(
                controller: _baslik,
                enabled: !busy,
                maxLength: 150,
                decoration: const InputDecoration(
                  labelText: 'İlan Başlığı',
                  hintText: 'Örn: Final Çalışma Grubu / Mavi Defter',
                  prefixIcon: Icon(
                    Icons.title_outlined,
                    size: 20,
                    color: AppTheme.muted,
                  ),
                ),
                validator: _validator.title,
              ),
              const SizedBox(height: 16),

              // Kategori Dropdown
              DropdownButtonFormField<String>(
                key: ValueKey('${_tur.name}:$selected'),
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(
                    Icons.category_outlined,
                    size: 20,
                    color: AppTheme.muted,
                  ),
                ),
                hint: Text(
                  categories.isEmpty
                      ? 'Kategori yüklenemedi'
                      : 'Kategori seçin',
                ),
                items: categories
                    .map(
                      (k) => DropdownMenuItem(value: k.id, child: Text(k.ad)),
                    )
                    .toList(),
                onChanged: busy
                    ? null
                    : (value) => setState(() => _kategoriId = value),
                validator: (_) => _validator.category(
                  selected,
                  type: _tur,
                  categories: provider.kategoriler,
                ),
              ),
              const SizedBox(height: 16),

              // Yer (TextFormField 1)
              TextFormField(
                controller: _yer,
                enabled: !busy,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Yer',
                  hintText: 'Örn: Merkez Kütüphane 2. Kat',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppTheme.muted,
                  ),
                ),
                validator: _validator.location,
              ),
              const SizedBox(height: 10),
              MeetingLocationPicker(controller: _yer, enabled: !busy),
              const SizedBox(height: 16),

              // Açıklama (TextFormField 2)
              TextFormField(
                controller: _aciklama,
                enabled: !busy,
                maxLength: 3000,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  hintText: 'Detaylı bilgi, notlar veya koşullar...',
                  prefixIcon: Icon(
                    Icons.notes_outlined,
                    size: 20,
                    color: AppTheme.muted,
                  ),
                  alignLabelWithHint: true,
                ),
                validator: _validator.description,
              ),

              // Sosyal İlan Buluşma Zamanı
              if (_tur == IlanTuru.sosyal) ...[
                const SizedBox(height: 16),
                MeetingDateTimePicker(
                  value: _tarih,
                  enabled: !busy,
                  nowProvider: widget.nowProvider,
                  onChanged: _onMeetingDateChanged,
                ),
              ],
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _dateError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: widget.ilan == null
                    ? 'İlanı Yayınla'
                    : 'Değişiklikleri Kaydet',
                icon: widget.ilan == null
                    ? Icons.check_circle_outline
                    : Icons.save_outlined,
                large: true,
                isLoading: busy,
                onPressed: provider.isLoading || categories.isEmpty
                    ? null
                    : _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
