import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/listings_provider.dart';
import '../../services/api_exception.dart';
import '../../services/listings_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/listings_load_status.dart';

/// Mevcut ilan formunun ortak API'ye bağlanan oluşturma/düzenleme akışı.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key, this.ilan});
  final Ilan? ilan;

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
  bool _saving = false;

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

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);
    final last = DateTime(now.year + 5, 12, 31);
    final initial =
        _tarih != null && !_tarih!.isBefore(first) && !_tarih!.isAfter(last)
        ? _tarih!
        : now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted || time == null) return;
    setState(
      () => _tarih = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (_tur == IlanTuru.sosyal &&
        (_tarih == null || !_tarih!.isAfter(DateTime.now()))) {
      setState(
        () => _error = 'Sosyal ilan için gelecekte bir buluşma zamanı seçin.',
      );
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
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
          _tur = IlanTuru.sosyal;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('İlan yayınlandı.')));
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : 'İlan kaydedilemedi. Tekrar deneyin.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Bu alan zorunludur.' : null;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final categories = provider.kategoriler
        .where((k) => k.tur == _tur)
        .toList();
    final selected = categories.any((k) => k.id == _kategoriId)
        ? _kategoriId
        : null;
    final busy = _saving || provider.isSaving;
    return Scaffold(
      appBar: widget.ilan == null
          ? null
          : AppBar(title: const Text('İlanı Düzenle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.ilan == null ? 'Yeni İlan' : 'İlan Bilgileri',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ListingsLoadStatus(provider: provider),
              DropdownButtonFormField<IlanTuru>(
                key: ValueKey(_tur),
                initialValue: _tur,
                decoration: const InputDecoration(labelText: 'İlan türü'),
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
                      }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _baslik,
                enabled: !busy,
                maxLength: 150,
                decoration: const InputDecoration(labelText: 'İlan Başlığı'),
                validator: (value) =>
                    _required(value) ??
                    (value!.trim().length < 2
                        ? 'Başlık en az 2 karakter olmalıdır.'
                        : null),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: ValueKey('${_tur.name}:$selected'),
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Kategori'),
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
                validator: (_) => selected == null
                    ? 'İlan türüne uygun kategori seçin.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yer,
                enabled: !busy,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Yer'),
                validator: _required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _aciklama,
                enabled: !busy,
                maxLength: 3000,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                validator: _required,
              ),
              if (_tur == IlanTuru.sosyal) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: busy ? null : _selectDate,
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    _tarih == null
                        ? 'Buluşma tarihi ve saati seçin'
                        : DateFormat('dd.MM.yyyy HH:mm').format(_tarih!),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: widget.ilan == null
                    ? 'İlanı Yayınla'
                    : 'Değişiklikleri Kaydet',
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
