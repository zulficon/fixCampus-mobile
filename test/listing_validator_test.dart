import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/models/models.dart';
import 'package:fixcampus_mobile/utils/listing_validator.dart';

void main() {
  group('3. Hafta İlan Doğrulama ve Sahiplik Kuralları Testleri', () {
    test('Başlık doğrulaması: boş, kısa, uzun ve geçerli durumlar', () {
      expect(ListingValidator.validateTitle(null), isNotNull);
      expect(ListingValidator.validateTitle(''), isNotNull);
      expect(ListingValidator.validateTitle('   '), isNotNull);
      expect(ListingValidator.validateTitle('ab'), isNotNull); // < 3 karakter
      expect(ListingValidator.validateTitle('abc'), isNull); // 3 karakter geçerli
      expect(ListingValidator.validateTitle('Algoritma Vize Çalışması'), isNull);

      final tooLong = 'A' * 151;
      expect(ListingValidator.validateTitle(tooLong), isNotNull);
      final maxValid = 'A' * 150;
      expect(ListingValidator.validateTitle(maxValid), isNull);
    });

    test('Açıklama doğrulaması: boş, kısa, uzun ve geçerli durumlar', () {
      expect(ListingValidator.validateDescription(null), isNotNull);
      expect(ListingValidator.validateDescription(''), isNotNull);
      expect(ListingValidator.validateDescription('1234'), isNotNull); // < 5 karakter
      expect(ListingValidator.validateDescription('12345'), isNull); // 5 karakter geçerli
      expect(ListingValidator.validateDescription('Kütüphanede buluşup soru çözeceğiz.'), isNull);

      final tooLong = 'A' * 3001;
      expect(ListingValidator.validateDescription(tooLong), isNotNull);
      final maxValid = 'A' * 3000;
      expect(ListingValidator.validateDescription(maxValid), isNull);
    });

    test('Yer/Konum doğrulaması: boş, kısa, uzun ve geçerli durumlar', () {
      expect(ListingValidator.validateLocation(null), isNotNull);
      expect(ListingValidator.validateLocation(''), isNotNull);
      expect(ListingValidator.validateLocation('A'), isNotNull); // < 2 karakter
      expect(ListingValidator.validateLocation('AB'), isNull); // 2 karakter geçerli
      expect(ListingValidator.validateLocation('Merkez Kütüphane B Blok'), isNull);

      final tooLong = 'A' * 201;
      expect(ListingValidator.validateLocation(tooLong), isNotNull);
      final maxValid = 'A' * 200;
      expect(ListingValidator.validateLocation(maxValid), isNull);
    });

    test('Kategori seçimi ve kategori-tür uyumu doğrulaması', () {
      const categories = [
        Kategori(id: 'kat-1', ad: 'Spor', tur: IlanTuru.sosyal),
        Kategori(id: 'kat-2', ad: 'Elektronik', tur: IlanTuru.kayip),
        Kategori(id: 'kat-3', ad: 'Cüzdan', tur: IlanTuru.buluntu),
      ];

      expect(ListingValidator.validateCategory(null, IlanTuru.sosyal, categories), isNotNull);
      expect(ListingValidator.validateCategory('', IlanTuru.sosyal, categories), isNotNull);
      expect(ListingValidator.validateCategory('olmayan-id', IlanTuru.sosyal, categories), isNotNull);

      // Kategori türü ile ilan türü uyuşmazlığı
      expect(ListingValidator.validateCategory('kat-2', IlanTuru.sosyal, categories), isNotNull);

      // Doğru eşleşme
      expect(ListingValidator.validateCategory('kat-1', IlanTuru.sosyal, categories), isNull);
      expect(ListingValidator.validateCategory('kat-2', IlanTuru.kayip, categories), isNull);
      expect(ListingValidator.validateCategory('kat-3', IlanTuru.buluntu, categories), isNull);
    });

    test('Buluşma tarihi kuralları: Sosyal için zorunlu ve gelecek tarih, Kayıp/Buluntu için null', () {
      final now = DateTime.utc(2026, 11, 2, 12, 0);

      // Sosyal ilan için testler
      expect(ListingValidator.validateMeetingDate(null, IlanTuru.sosyal, now: now), isNotNull);

      final pastDate = now.subtract(const Duration(hours: 1));
      expect(ListingValidator.validateMeetingDate(pastDate, IlanTuru.sosyal, now: now), isNotNull);

      final futureDate = now.add(const Duration(hours: 2));
      expect(ListingValidator.validateMeetingDate(futureDate, IlanTuru.sosyal, now: now), isNull);

      // Kayıp & Buluntu için testler
      expect(ListingValidator.validateMeetingDate(null, IlanTuru.kayip, now: now), isNull);
      expect(ListingValidator.validateMeetingDate(null, IlanTuru.buluntu, now: now), isNull);

      expect(ListingValidator.validateMeetingDate(futureDate, IlanTuru.kayip, now: now), isNotNull);
      expect(ListingValidator.validateMeetingDate(futureDate, IlanTuru.buluntu, now: now), isNotNull);
    });

    test('Sahiplik denetimi: İlan sahibi, yabancı kullanıcı ve yönetici rolleri', () {
      final now = DateTime.utc(2026, 11, 2);
      final ilan = Ilan(
        id: 'ilan-1',
        sahipId: 'sahip-uuid',
        kategoriId: 'kat-1',
        baslik: 'Örnek İlan',
        aciklama: 'Açıklama metni',
        tur: IlanTuru.sosyal,
        yer: 'Kampüs',
        bulusmaTarihi: now.add(const Duration(days: 1)),
        durum: IlanDurumu.aktif,
        olusturulmaTarihi: now,
      );

      final sahipKullanici = Profil(
        id: 'sahip-uuid',
        adSoyad: 'İlan Sahibi',
        rol: KullaniciRolu.ogrenci,
        olusturulmaTarihi: now,
      );

      final yabanciKullanici = Profil(
        id: 'farkli-uuid',
        adSoyad: 'Başka Öğrenci',
        rol: KullaniciRolu.ogrenci,
        olusturulmaTarihi: now,
      );

      final yoneticiKullanici = Profil(
        id: 'farkli-uuid',
        adSoyad: 'Admin Kullanıcı',
        rol: KullaniciRolu.yonetici,
        olusturulmaTarihi: now,
      );

      expect(ListingValidator.canEditOrDelete(ilan: ilan, user: null), isFalse);
      expect(ListingValidator.canEditOrDelete(ilan: ilan, user: sahipKullanici), isTrue);
      expect(ListingValidator.canEditOrDelete(ilan: ilan, user: yabanciKullanici), isFalse);
      expect(ListingValidator.canEditOrDelete(ilan: ilan, user: yoneticiKullanici), isTrue);
    });
  });
}
