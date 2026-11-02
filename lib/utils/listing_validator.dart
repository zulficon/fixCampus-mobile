import '../models/models.dart';

/// İlan Alan Doğrulama ve Sahiplik Denetim Kuralları
class ListingValidator {
  static const int minTitleLength = 3;
  static const int maxTitleLength = 150;
  static const int minDescriptionLength = 5;
  static const int maxDescriptionLength = 3000;
  static const int minLocationLength = 2;
  static const int maxLocationLength = 200;

  /// Başlık alan doğrulaması (3-150 karakter)
  static String? validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'İlan başlığı zorunludur.';
    if (trimmed.length < minTitleLength) {
      return 'Başlık en az $minTitleLength karakter olmalıdır.';
    }
    if (trimmed.length > maxTitleLength) {
      return 'Başlık en fazla $maxTitleLength karakter olabilir.';
    }
    return null;
  }

  /// Açıklama alan doğrulaması (5-3000 karakter)
  static String? validateDescription(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'İlan açıklaması zorunludur.';
    if (trimmed.length < minDescriptionLength) {
      return 'Açıklama en az $minDescriptionLength karakter olmalıdır.';
    }
    if (trimmed.length > maxDescriptionLength) {
      return 'Açıklama en fazla $maxDescriptionLength karakter olabilir.';
    }
    return null;
  }

  /// Konum/Yer alan doğrulaması (2-200 karakter)
  static String? validateLocation(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Konum veya yer bilgisi zorunludur.';
    if (trimmed.length < minLocationLength) {
      return 'Yer bilgisi en az $minLocationLength karakter olmalıdır.';
    }
    if (trimmed.length > maxLocationLength) {
      return 'Yer bilgisi en fazla $maxLocationLength karakter olabilir.';
    }
    return null;
  }

  /// Kategori seçimi ve kategori-tür uyum doğrulaması
  static String? validateCategory(
    String? kategoriId,
    IlanTuru tur,
    List<Kategori> availableCategories,
  ) {
    if (kategoriId == null || kategoriId.trim().isEmpty) {
      return 'Lütfen bir kategori seçin.';
    }
    final matching =
        availableCategories.where((k) => k.id == kategoriId).toList();
    if (matching.isEmpty) {
      return 'Seçilen kategori geçerli değil.';
    }
    if (matching.first.tur != tur) {
      return 'Seçilen kategori ilan türü ile uyuşmuyor.';
    }
    return null;
  }

  /// Buluşma tarihi kuralı: Sosyal için zorunlu ve gelecek zaman, Kayıp/Buluntu için null
  static String? validateMeetingDate(
    DateTime? date,
    IlanTuru tur, {
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    if (tur == IlanTuru.sosyal) {
      if (date == null) {
        return 'Sosyal buluşmalar için buluşma tarihi zorunludur.';
      }
      if (!date.isAfter(currentTime)) {
        return 'Buluşma tarihi ileri bir zaman olmalıdır.';
      }
    } else {
      if (date != null) {
        return 'Kayıp ve buluntu ilanlarında buluşma tarihi girilemez.';
      }
    }
    return null;
  }

  /// İlanı düzenleme ve silme sahiplik kontrolü (Sahip veya Yönetici)
  static bool canEditOrDelete({
    required Ilan ilan,
    required Profil? user,
  }) {
    if (user == null) return false;
    if (user.rol == KullaniciRolu.yonetici) return true;
    return ilan.sahipId == user.id;
  }
}

