import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_exception.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_badge.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.ilan});
  final Ilan ilan;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  Ilan? _ilan;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ilan = await context.read<ListingsProvider>().getListing(
        widget.ilan.id,
      );
      if (mounted) setState(() => _ilan = ilan);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiException ? e.message : 'İlan yüklenemedi.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlan silinsin mi?'),
        content: const Text('Bu ilan kalıcı olarak silinecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      await context.read<ListingsProvider>().deleteListing(widget.ilan.id);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'İlan silinemedi.'),
          ),
        );
      }
    }
  }

  Future<void> _edit() async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.editListing,
      arguments: _ilan,
    );
    if (mounted && changed == true) await _load();
  }

  void _skeleton(String action) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('“$action” işlemi yakında kullanıma sunulacaktır.')),
  );

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();
    final ilan = _ilan;
    return Scaffold(
      appBar: AppBar(title: const Text('İlan Detayı')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
            )
          : ilan == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge.tur(tur: ilan.tur),
                      const SizedBox(width: 8),
                      StatusBadge.durum(durum: ilan.durum),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ilan.baslik,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Yer: ${ilan.yer}'),
                  if (ilan.bulusmaTarihi != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      DateFormat(
                        'dd.MM.yyyy, HH:mm',
                      ).format(ilan.bulusmaTarihi!.toLocal()),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Açıklama',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(ilan.aciklama),
                  const SizedBox(height: 24),
                  if (auth.currentUser?.id == ilan.sahipId) ...[
                    AppButton(
                      label: 'İlanı Düzenle',
                      onPressed: provider.isSaving ? null : _edit,
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'İlanı Sil',
                      isOutlined: true,
                      isLoading: provider.isSaving,
                      onPressed: _delete,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (ilan.tur == IlanTuru.sosyal) ...[
                    AppButton(
                      label: 'Geliyorum (İskelet Buton)',
                      onPressed: () => _skeleton('Geliyorum'),
                    ),
                    const SizedBox(height: 10),
                  ],
                  AppButton(
                    label: 'İlanı Şikâyet Et (İskelet)',
                    isOutlined: true,
                    onPressed: () => _skeleton('Şikâyet Et'),
                  ),
                ],
              ),
            ),
    );
  }
}
