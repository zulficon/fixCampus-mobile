import 'package:flutter/material.dart';
import '../models/models.dart';

/// İlanlar, Filtreleme ve Katılım Yönetimi Sağlayıcısı
class ListingsProvider extends ChangeNotifier {
  ListingsProvider() {
    _initSampleData();
  }

  final List<Kategori> _kategoriler = [];
  final List<Ilan> _ilanlar = [];
  final List<Katilim> _katilimlar = [];

  List<Kategori> get kategoriler => List.unmodifiable(_kategoriler);
  List<Ilan> get ilanlar => List.unmodifiable(_ilanlar);
  List<Katilim> get katilimlar => List.unmodifiable(_katilimlar);

  /// Sosyal Radar ilanları (yalnızca Sosyal türündeki aktif buluşmalar)
  List<Ilan> get radarListings {
    return _ilanlar
        .where((i) => i.tur == IlanTuru.sosyal && i.durum == IlanDurumu.aktif)
        .toList();
  }

  /// Kayıp & Buluntu ilanları
  List<Ilan> getLostFoundListings({IlanTuru? turFilter}) {
    return _ilanlar.where((i) {
      final isLostOrFound = i.tur == IlanTuru.kayip || i.tur == IlanTuru.buluntu;
      if (!isLostOrFound) return false;
      if (turFilter != null && i.tur != turFilter) return false;
      return true;
    }).toList();
  }

  /// Belirli bir kullanıcının ilanları
  List<Ilan> getUserListings(String userId) {
    return _ilanlar.where((i) => i.sahipId == userId).toList();
  }

  /// Kullanıcının bu buluşmaya katılıp katılmadığı
  bool isUserAttending(String ilanId, String userId) {
    return _katilimlar.any((k) => k.ilanId == ilanId && k.profilId == userId);
  }

  /// Bir ilanın katılımcı sayısı
  int getAttendanceCount(String ilanId) {
    return _katilimlar.where((k) => k.ilanId == ilanId).length;
  }

  /// Yeni İlan Ekleme
  void addListing(Ilan yeniIlan) {
    _ilanlar.insert(0, yeniIlan);
    notifyListeners();
  }

  /// Sosyal Buluşmaya Katılma / Katılımı Geri Alma ("Geliyorum")
  void toggleAttendance(String ilanId, String userId) {
    final existingIndex = _katilimlar.indexWhere(
      (k) => k.ilanId == ilanId && k.profilId == userId,
    );

    if (existingIndex >= 0) {
      // Katılımı geri al
      _katilimlar.removeAt(existingIndex);
    } else {
      // Katıl
      _katilimlar.add(
        Katilim(
          id: 'katilim-${DateTime.now().millisecondsSinceEpoch}',
          ilanId: ilanId,
          profilId: userId,
          katilimTarihi: DateTime.now().toUtc(),
        ),
      );
    }
    notifyListeners();
  }

  /// İlanı Çözüldü Olarak İşaretle
  void markAsResolved(String ilanId) {
    final index = _ilanlar.indexWhere((i) => i.id == ilanId);
    if (index != -1) {
      final old = _ilanlar[index];
      _ilanlar[index] = Ilan(
        id: old.id,
        sahipId: old.sahipId,
        kategoriId: old.kategoriId,
        baslik: old.baslik,
        aciklama: old.aciklama,
        tur: old.tur,
        yer: old.yer,
        bulusmaTarihi: old.bulusmaTarihi,
        durum: IlanDurumu.cozuldu,
        olusturulmaTarihi: old.olusturulmaTarihi,
      );
      notifyListeners();
    }
  }

  void _initSampleData() {
    _kategoriler.addAll([
      const Kategori(id: 'kat-1', ad: 'Spor', tur: IlanTuru.sosyal),
      const Kategori(id: 'kat-2', ad: 'Ders & Çalışma', tur: IlanTuru.sosyal),
      const Kategori(id: 'kat-3', ad: 'Kahve & Sohbet', tur: IlanTuru.sosyal),
      const Kategori(id: 'kat-4', ad: 'Elektronik Eşya', tur: IlanTuru.kayip),
      const Kategori(id: 'kat-5', ad: 'Kart & Cüzdan', tur: IlanTuru.kayip),
      const Kategori(id: 'kat-6', ad: 'Kırtasiye & Kitap', tur: IlanTuru.buluntu),
    ]);

    final now = DateTime.now().toUtc();

    _ilanlar.addAll([
      // Sosyal Radar İlanları
      Ilan(
        id: 'ilan-1',
        sahipId: '00000000-0000-0000-0000-000000000001',
        kategoriId: 'kat-2',
        baslik: 'Merkez Kütüphanede Algoritma Vize Çalışması',
        aciklama: 'BLM4587 ve algoritma dersi için kütüphane B blok 2. katta birlikte soru çözeceğiz.',
        tur: IlanTuru.sosyal,
        yer: 'Merkez Kütüphane B Blok 2. Kat',
        bulusmaTarihi: now.add(const Duration(days: 1, hours: 2)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 3)),
      ),
      Ilan(
        id: 'ilan-2',
        sahipId: '00000000-0000-0000-0000-000000000003',
        kategoriId: 'kat-1',
        baslik: 'Kampüs Açık Sahada Voleybol Maçı',
        aciklama: 'Saat 17.00 sahada 2 kişi eksiğimiz var, katılmak isteyen herkes gelebilir!',
        tur: IlanTuru.sosyal,
        yer: 'Spor Tesisleri Açık Voleybol Sahası',
        bulusmaTarihi: now.add(const Duration(hours: 18)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 5)),
      ),
      Ilan(
        id: 'ilan-3',
        sahipId: '00000000-0000-0000-0000-000000000004',
        kategoriId: 'kat-3',
        baslik: 'Mühendislik Kantininde Kahve & Sohbet',
        aciklama: 'Ders arası kahve içip mobil proje fikirleri tartışıyoruz.',
        tur: IlanTuru.sosyal,
        yer: 'Mühendislik Fakültesi Zemin Kat Kantin',
        bulusmaTarihi: now.add(const Duration(hours: 4)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 1)),
      ),

      // Kayıp & Buluntu İlanları
      Ilan(
        id: 'ilan-4',
        sahipId: '00000000-0000-0000-0000-000000000005',
        kategoriId: 'kat-4',
        baslik: 'Siyah Kablosuz Kulaklık Kutusu Kayıp',
        aciklama: 'D204 nolu amfide masada unuttum, üzerinde gri çıkartma var. Görenlerin yazmasını rica ederim.',
        tur: IlanTuru.kayip,
        yer: 'Mühendislik D204 Amfisi',
        bulusmaTarihi: null,
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(days: 1)),
      ),
      Ilan(
        id: 'ilan-5',
        sahipId: '00000000-0000-0000-0000-000000000001',
        kategoriId: 'kat-5',
        baslik: 'Yemekhanede Bulunan Öğrenci Kimlik Kartı',
        aciklama: '1. kat turnikelerin hemen yanında bulundu, yemekhane danışmasına teslim edildi.',
        tur: IlanTuru.buluntu,
        yer: 'Merkez Yemekhane Turnikeleri',
        bulusmaTarihi: null,
        durum: IlanDurumu.cozuldu,
        olusturulmaTarihi: now.subtract(const Duration(days: 2)),
      ),
      Ilan(
        id: 'ilan-6',
        sahipId: '00000000-0000-0000-0000-000000000006',
        kategoriId: 'kat-6',
        baslik: 'Mavi Spiral Defter ve Kalemlik Kayıp',
        aciklama: 'Kütüphane girişindeki dinlenme koltuklarında unutulmuştur.',
        tur: IlanTuru.kayip,
        yer: 'Merkez Kütüphane Giriş Holü',
        bulusmaTarihi: null,
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now.subtract(const Duration(hours: 8)),
      ),
    ]);

    // Örnek Katılımlar
    _katilimlar.addAll([
      Katilim(
        id: 'kat-1',
        ilanId: 'ilan-1',
        profilId: '00000000-0000-0000-0000-000000000001',
        katilimTarihi: now.subtract(const Duration(hours: 2)),
      ),
      Katilim(
        id: 'kat-2',
        ilanId: 'ilan-1',
        profilId: '00000000-0000-0000-0000-000000000003',
        katilimTarihi: now.subtract(const Duration(hours: 1)),
      ),
      Katilim(
        id: 'kat-3',
        ilanId: 'ilan-2',
        profilId: '00000000-0000-0000-0000-000000000001',
        katilimTarihi: now.subtract(const Duration(hours: 4)),
      ),
    ]);
  }
}
