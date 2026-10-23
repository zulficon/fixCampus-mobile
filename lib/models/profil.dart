import 'json_fields.dart';
import 'model_enums.dart';

/// Ortak API veri modeli: Profil. Kimlikler UUID metni olarak taşınır.
class Profil {
  const Profil({
    required this.id,
    required this.adSoyad,
    required this.rol,
    required this.olusturulmaTarihi,
  });

  final String id;
  final String adSoyad;
  final KullaniciRolu rol;
  final DateTime olusturulmaTarihi;

  factory Profil.fromJson(Map<String, dynamic> json) => Profil(
        id: JsonFields.string(json, 'id'),
        adSoyad: JsonFields.string(json, 'adSoyad'),
        rol: KullaniciRolu.fromJson(JsonFields.string(json, 'rol')),
        olusturulmaTarihi: JsonFields.dateTime(json, 'olusturulmaTarihi'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'adSoyad': adSoyad,
        'rol': rol.apiValue,
        'olusturulmaTarihi': olusturulmaTarihi.toUtc().toIso8601String(),
      };
}
