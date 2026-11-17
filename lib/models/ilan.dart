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
    this.haritaUrl,
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
  final String? haritaUrl;
  final DateTime? bulusmaTarihi;
  final IlanDurumu durum;
  final DateTime olusturulmaTarihi;
  final int katilimciSayisi;
  final bool katiliyor;

  Uri? get haritaBaglantisi {
    final place = yer.trim();
    if (place.isEmpty) return null;

    final provided = Uri.tryParse(haritaUrl ?? '');
    final params = provided?.queryParametersAll;
    if (provided != null &&
        provided.scheme == 'https' &&
        provided.host == 'www.google.com' &&
        !provided.hasPort &&
        provided.userInfo.isEmpty &&
        !provided.hasFragment &&
        provided.path == '/maps/search/' &&
        params?.length == 2 &&
        params?['api']?.length == 1 &&
        params?['api']?.first == '1' &&
        params?['query']?.length == 1 &&
        params?['query']?.first == place) {
      return provided;
    }

    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': place,
    });
  }

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
      haritaUrl: json['haritaUrl'] is String
          ? json['haritaUrl'] as String
          : null,
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
    if (haritaUrl != null) 'haritaUrl': haritaUrl,
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
    haritaUrl: yer == null || yer == this.yer ? haritaUrl : null,
    bulusmaTarihi: clearBulusmaTarihi
        ? null
        : (bulusmaTarihi ?? this.bulusmaTarihi),
    durum: durum ?? this.durum,
    olusturulmaTarihi: olusturulmaTarihi ?? this.olusturulmaTarihi,
    katilimciSayisi: katilimciSayisi ?? this.katilimciSayisi,
    katiliyor: katiliyor ?? this.katiliyor,
  );
}
