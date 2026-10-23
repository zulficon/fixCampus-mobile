import 'json_fields.dart';
import 'model_enums.dart';

/// Ortak API veri modeli: Ilan. Kimlikler UUID metni olarak taşınır.
class Ilan {
  const Ilan({
    required this.id,
    required this.sahipId,
    required this.kategoriId,
    required this.baslik,
    required this.aciklama,
    required this.tur,
    required this.yer,
    required this.bulusmaTarihi,
    required this.durum,
    required this.olusturulmaTarihi,
  });

  final String id;
  final String sahipId;
  final String kategoriId;
  final String baslik;
  final String aciklama;
  final IlanTuru tur;
  final String yer;
  final DateTime? bulusmaTarihi;
  final IlanDurumu durum;
  final DateTime olusturulmaTarihi;

  factory Ilan.fromJson(Map<String, dynamic> json) => Ilan(
        id: JsonFields.string(json, 'id'),
        sahipId: JsonFields.string(json, 'sahipId'),
        kategoriId: JsonFields.string(json, 'kategoriId'),
        baslik: JsonFields.string(json, 'baslik'),
        aciklama: JsonFields.string(json, 'aciklama'),
        tur: IlanTuru.fromJson(JsonFields.string(json, 'tur')),
        yer: JsonFields.string(json, 'yer'),
        bulusmaTarihi: JsonFields.nullableDateTime(json, 'bulusmaTarihi'),
        durum: IlanDurumu.fromJson(JsonFields.string(json, 'durum')),
        olusturulmaTarihi: JsonFields.dateTime(json, 'olusturulmaTarihi'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'sahipId': sahipId,
        'kategoriId': kategoriId,
        'baslik': baslik,
        'aciklama': aciklama,
        'tur': tur.apiValue,
        'yer': yer,
        'bulusmaTarihi': bulusmaTarihi?.toUtc().toIso8601String(),
        'durum': durum.apiValue,
        'olusturulmaTarihi': olusturulmaTarihi.toUtc().toIso8601String(),
      };
}
