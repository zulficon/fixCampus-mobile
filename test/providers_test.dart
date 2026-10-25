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
  });
}

