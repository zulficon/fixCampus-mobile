import '../models/models.dart';

/// Oluşturma ve düzenleme formlarının ortak alan kuralları.
/// Sunucu uzunluk sınırları API sözleşmesiyle ayrıca eşleştirilir.
class ListingValidator {
  const ListingValidator();

  String? title(String? value) => _required(value, 'İlan başlığını girin.');
  String? description(String? value) =>
      _required(value, 'İlan açıklamasını girin.');
  String? location(String? value) => _required(value, 'İlan yerini girin.');

  bool acceptsCategory(IlanTuru type, Kategori category) =>
      type == IlanTuru.sosyal
      ? category.tur == IlanTuru.sosyal
      : category.tur != IlanTuru.sosyal;

  String? category(
    String? id, {
    required IlanTuru type,
    required Iterable<Kategori> categories,
  }) {
    if (id == null || id.trim().isEmpty) return 'Kategori seçin.';
    for (final item in categories) {
      if (item.id == id && acceptsCategory(type, item)) return null;
    }
    return 'İlan türüne uygun bir kategori seçin.';
  }

  String? _required(String? value, String message) =>
      value == null || value.trim().isEmpty ? message : null;
}
