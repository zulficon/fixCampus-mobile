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
    this.katilimciSayisi = 0,
    this.katiliyor = false,
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
  final int katilimciSayisi;
  final bool katiliyor;

  factory Ilan.fromJson(Map<String, dynamic> json) {
    final count = json['katilimciSayisi'] ?? 0;
    final attending = json['katiliyor'] ?? false;
    if (count is! int || count < 0 || attending is! bool) {
      throw const FormatException('Geçersiz katılım bilgisi.');
    }
    return Ilan(
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
      katilimciSayisi: count,
      katiliyor: attending,
    );
  }

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
    'katilimciSayisi': katilimciSayisi,
    'katiliyor': katiliyor,
  };

  Ilan copyWith({
    String? id,
    String? sahipId,
    String? kategoriId,
    String? baslik,
    String? aciklama,
    IlanTuru? tur,
    String? yer,
    DateTime? bulusmaTarihi,
    bool clearBulusmaTarihi = false,
    IlanDurumu? durum,
    DateTime? olusturulmaTarihi,
    int? katilimciSayisi,
    bool? katiliyor,
  }) => Ilan(
    id: id ?? this.id,
    sahipId: sahipId ?? this.sahipId,
    kategoriId: kategoriId ?? this.kategoriId,
    baslik: baslik ?? this.baslik,
    aciklama: aciklama ?? this.aciklama,
    tur: tur ?? this.tur,
    yer: yer ?? this.yer,
    bulusmaTarihi: clearBulusmaTarihi
        ? null
        : (bulusmaTarihi ?? this.bulusmaTarihi),
    durum: durum ?? this.durum,
    olusturulmaTarihi: olusturulmaTarihi ?? this.olusturulmaTarihi,
    katilimciSayisi: katilimciSayisi ?? this.katilimciSayisi,
    katiliyor: katiliyor ?? this.katiliyor,
  );
}
