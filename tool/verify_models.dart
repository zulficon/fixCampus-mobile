import 'dart:convert';
import 'dart:io';
import 'package:fixcampus_mobile/models/models.dart';

void main() {
  final profil = jsonDecode(r'''{"id": "00000000-0000-4000-8000-000000000001", "adSoyad": "Ornek", "rol": "Ogrenci", "olusturulmaTarihi": "2026-10-23T12:00:00.000Z"}''') as Map<String, dynamic>;
  check(jsonEncode(Profil.fromJson(profil).toJson()) == jsonEncode(profil),
      'Profil JSON dönüşümü');
  final kategori = jsonDecode(r'''{"id": "00000000-0000-4000-8000-000000000001", "ad": "Ornek", "tur": "Sosyal"}''') as Map<String, dynamic>;
  check(jsonEncode(Kategori.fromJson(kategori).toJson()) == jsonEncode(kategori),
      'Kategori JSON dönüşümü');
  final ilan = jsonDecode(r'''{"id": "00000000-0000-4000-8000-000000000001", "sahipId": "00000000-0000-4000-8000-000000000001", "kategoriId": "00000000-0000-4000-8000-000000000001", "baslik": "Ornek", "aciklama": "Ornek", "tur": "Sosyal", "yer": "Ornek", "bulusmaTarihi": null, "durum": "Aktif", "olusturulmaTarihi": "2026-10-23T12:00:00.000Z"}''') as Map<String, dynamic>;
  check(jsonEncode(Ilan.fromJson(ilan).toJson()) == jsonEncode(ilan),
      'Ilan JSON dönüşümü');
  final katilim = jsonDecode(r'''{"id": "00000000-0000-4000-8000-000000000001", "ilanId": "00000000-0000-4000-8000-000000000001", "profilId": "00000000-0000-4000-8000-000000000001", "katilimTarihi": "2026-10-23T12:00:00.000Z"}''') as Map<String, dynamic>;
  check(jsonEncode(Katilim.fromJson(katilim).toJson()) == jsonEncode(katilim),
      'Katilim JSON dönüşümü');
  final ilanFotografi = jsonDecode(r'''{"id": "00000000-0000-4000-8000-000000000001", "ilanId": "00000000-0000-4000-8000-000000000001", "dosyaYolu": "Ornek", "yuklemeTarihi": "2026-10-23T12:00:00.000Z"}''') as Map<String, dynamic>;
  check(jsonEncode(IlanFotografi.fromJson(ilanFotografi).toJson()) == jsonEncode(ilanFotografi),
      'IlanFotografi JSON dönüşümü');
  final sikayet = jsonDecode(r'''{"id": "00000000-0000-4000-8000-000000000001", "ilanId": "00000000-0000-4000-8000-000000000001", "bildirenId": "00000000-0000-4000-8000-000000000001", "neden": "Ornek", "durum": "Bekliyor", "olusturulmaTarihi": "2026-10-23T12:00:00.000Z"}''') as Map<String, dynamic>;
  check(jsonEncode(Sikayet.fromJson(sikayet).toJson()) == jsonEncode(sikayet),
      'Sikayet JSON dönüşümü');

  final offset = Map<String, dynamic>.from(profil);
  offset['olusturulmaTarihi'] = '2026-10-23T15:00:00+03:00';
  check(Profil.fromJson(offset).olusturulmaTarihi ==
      DateTime.utc(2026, 10, 23, 12), 'UTC dönüşümü');
  final dated = Map<String, dynamic>.from(ilan);
  dated['bulusmaTarihi'] = '2026-10-24T12:00:00Z';
  check(Ilan.fromJson(dated).bulusmaTarihi ==
      DateTime.utc(2026, 10, 24, 12), 'Buluşma tarihi');
  rejects(() => Profil.fromJson({...profil, 'rol': 'Admin'}));
  rejects(() => Kategori.fromJson({...kategori, 'tur': 'Bilinmeyen'}));
  rejects(() => Ilan.fromJson({...ilan, 'durum': 'Bilinmeyen'}));
  rejects(() => Sikayet.fromJson({...sikayet, 'durum': 'Bilinmeyen'}));
  rejects(() => Profil.fromJson({...profil, 'adSoyad': null}));
  rejects(() => Katilim.fromJson({...katilim, 'profilId': 42}));
  rejects(() => IlanFotografi.fromJson({...ilanFotografi, 'dosyaYolu': null}));
  rejects(() => Profil.fromJson({...profil, 'olusturulmaTarihi': 'yanlis'}));
  rejects(() => Profil.fromJson({...profil, 'olusturulmaTarihi': '2026-10-23T12:00:00'}));
  stdout.writeln('PASS: 6 model, JSON dönüşümü, UTC, null tarih ve hatalı veri kontrolleri.');
}

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void rejects(void Function() action) {
  try {
    action();
  } on FormatException {
    return;
  }
  throw StateError('Geçersiz JSON kabul edildi.');
}

