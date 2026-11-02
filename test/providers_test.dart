import 'package:flutter_test/flutter_test.dart';
import 'package:fixcampus_mobile/providers/listings_provider.dart';
import 'package:fixcampus_mobile/models/models.dart';

void main() {
  group('ListingsProvider Testleri', () {
    late ListingsProvider provider;

    setUp(() {
      provider = ListingsProvider();
    });

    test('Varsayılan ilanlar, kategoriler ve katilimlar yüklenmiş olmalı', () {
      expect(provider.ilanlar.isNotEmpty, isTrue);
      expect(provider.kategoriler.isNotEmpty, isTrue);
      expect(provider.katilimlar.isNotEmpty, isTrue);
      expect(provider.radarListings.isNotEmpty, isTrue);
    });

    test('Katılımcı sayısı doğru hesaplanmalı', () {
      // ilan-1 için başlangıçta 2 katılımcı mock verisi var
      final count = provider.getAttendanceCount('ilan-1');
      expect(count, 2);
    });

    test('Kullanıcı katılım durumu doğru sorgulanmalı', () {
      const berkeId = '00000000-0000-0000-0000-000000000001';
      final isAttending = provider.isUserAttending('ilan-1', berkeId);
      expect(isAttending, isTrue);

      expect(provider.isUserAttending('ilan-1', 'bilinmeyen-kullanici'), isFalse);
    });

    test('Kullanıcının kendi ilanları doğru filtrelenmeli', () {
      const berkeId = '00000000-0000-0000-0000-000000000001';
      final userListings = provider.getUserListings(berkeId);
      expect(userListings.isNotEmpty, isTrue);
      for (final ilan in userListings) {
        expect(ilan.sahipId, berkeId);
      }
    });

    test('Kayıp ve buluntu ilanları doğru ayrılmalı', () {
      final lostListings = provider.getLostFoundListings(turFilter: IlanTuru.kayip);
      for (final ilan in lostListings) {
        expect(ilan.tur, IlanTuru.kayip);
      }

      final foundListings = provider.getLostFoundListings(turFilter: IlanTuru.buluntu);
      for (final ilan in foundListings) {
        expect(ilan.tur, IlanTuru.buluntu);
      }
    });

    test('Katılım toggle işlemi çalışmalı', () {
      const ilanId = 'ilan-3';
      const userId = '00000000-0000-0000-0000-000000000001';
      final initialCount = provider.getAttendanceCount(ilanId);
      final initialAttending = provider.isUserAttending(ilanId, userId);

      provider.toggleAttendance(ilanId, userId);
      expect(provider.isUserAttending(ilanId, userId), !initialAttending);
      expect(provider.getAttendanceCount(ilanId), initialCount + 1);

      // Tekrar toggle edildiğinde geri alınmalı
      provider.toggleAttendance(ilanId, userId);
      expect(provider.isUserAttending(ilanId, userId), initialAttending);
      expect(provider.getAttendanceCount(ilanId), initialCount);
    });

    test('İlan çözüldü olarak işaretlenebilmeli', () {
      const ilanId = 'ilan-4';
      provider.markAsResolved(ilanId);
      final resolved = provider.ilanlar.firstWhere((i) => i.id == ilanId);
      expect(resolved.durum, IlanDurumu.cozuldu);
    });

    test('3. Hafta CRUD: createListing yeni ilanı listeye eklemeli', () async {
      final initialCount = provider.ilanlar.length;
      final created = await provider.createListing(
        baslik: 'Yeni Provider İlanı',
        aciklama: 'Açıklama metni en az beş karakter',
        kategoriId: 'kat-1',
        tur: IlanTuru.sosyal,
        yer: 'Kampüs Meydanı',
        bulusmaTarihi: DateTime.now().add(const Duration(days: 2)),
        sahipId: '00000000-0000-0000-0000-000000000001',
      );

      expect(created, isNotNull);
      expect(provider.ilanlar.length, initialCount + 1);
      expect(provider.ilanlar.first.baslik, 'Yeni Provider İlanı');
      expect(provider.getListingById(created!.id), isNotNull);
    });

    test('3. Hafta CRUD: updateListing mevcut ilanı güncellemeli', () async {
      const targetId = 'ilan-1';
      final updated = await provider.updateListing(
        id: targetId,
        baslik: 'Güncellenmiş Algoritma Çalışması',
        aciklama: 'Güncellenen açıklama metni...',
        kategoriId: 'kat-2',
        tur: IlanTuru.sosyal,
        yer: 'Yeni Kütüphane Katı',
        bulusmaTarihi: DateTime.now().add(const Duration(days: 3)),
      );

      expect(updated, isNotNull);
      final found = provider.getListingById(targetId);
      expect(found?.baslik, 'Güncellenmiş Algoritma Çalışması');
      expect(found?.yer, 'Yeni Kütüphane Katı');
    });

    test('3. Hafta CRUD: deleteListing ilanı ve katılımlarını silmeli', () async {
      const targetId = 'ilan-1';
      expect(provider.getListingById(targetId), isNotNull);
      expect(provider.getAttendanceCount(targetId), greaterThan(0));

      final result = await provider.deleteListing(targetId);
      expect(result, isTrue);
      expect(provider.getListingById(targetId), isNull);
      expect(provider.getAttendanceCount(targetId), 0);
    });
  });
}

