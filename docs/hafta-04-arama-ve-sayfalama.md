# Hafta 4 — Berke Mahmut Acar: Arama Ekranı, Kategori Filtreleme ve Sayfalama

Dönem projesi plan belgesinin 4. hafta görev dağılımı kapsamında; kategori filtreleme, Türkçe karakter duyarlı metin arama, sayfalama (pagination) ve kapsamlı **İlan Arama (`ListingSearchScreen`)** ekranı geliştirilmiştir.

## 1. Geliştirilen Bileşenler ve Mimarisi

| Dosya | Sorumluluk |
|---|---|
| `lib/utils/listing_search_filter.dart` | Türkçe karakter duyarlı (`İ`/`i`, `I`/`ı`, `Ş`/`ş`, `Ğ`/`ğ`, `Ü`/`ü`, `Ö`/`ö`, `Ç`/`ç`) metin normalizasyonu, çoklu kelime arama (`baslik`, `aciklama`, `yer`, `kategori.ad`), tür/kategori filtreleme, yeniden eskiye sıralama ve sayfalama (`ListingPaginationResult`) hesaplamaları. |
| `lib/widgets/listing_search_bar.dart` | Anlık metin arama kutusu, temizleme (`Icons.close`) aksiyonu, bulunan ilan sayısı göstergesi (`X ilan bulundu`) ve tek tıkla `Filtreleri Temizle` sıfırlama düğmesi. |
| `lib/widgets/pagination_controls.dart` | Çok sayfalı sonuçlarda `Önceki` / `Sonraki` sayfa geçiş düğmeleri, geçerli sayfa (`Sayfa X / Y`) ve kayıt aralığı (`A-B / Toplam ilan`) bilgisi. |
| `lib/screens/listings/listing_search_screen.dart` | `RoleSessionGuard` ile oturum ve profil korumalı, tüm ilan türlerinde (`Tümü`, `Sosyal`, `Kayıp`, `Buluntu`) arama, dinamik kategori filtreleme ve sayfalama sunan kapsamlı arama ekranı. |
| `lib/screens/radar/radar_feed_screen.dart` | Sosyal Radar akışı içinde doğrudan metin arama, sosyal kategori filtreleme, sayfalama ve üst başlıktan detaylı arama ekranına geçiş. |
| `lib/screens/lost_found/lost_found_feed_screen.dart` | Kayıp & Buluntu akışı içinde tür segmenti (`Tümü` / `Kayıp` / `Bulunan`), uyumlu kategori çipleri, metin arama ve sayfalama. |

## 2. Uygulama Davranışı

- **Metin ve Kategori Kombinasyonu:** Arama çubuğuna girilen anahtar kelimeler ile seçili tür ve kategori filtreleri eşzamanlı uygulanır. Tür değiştirildiğinde seçili kategori yeni türle uyumsuzsa otomatik sıfırlanır.
- **Sayfalama (Pagination):** Filtre veya arama metni değiştiğinde geçerli sayfa otomatik olarak `1`. sayfaya döner. Sonuçlar sayfa boyutuna göre bölünür ve alt kısımdaki sayfalama denetimleriyle gezilir.
- **Boş Durum ve Sıfırlama:** Aktif arama/filtre sonucunda eşleşen kayıt bulunamazsa kullanıcıya filtreleri tek dokunuşla sıfırlama (`Filtreleri Temizle`) olanağı sunulur.
- **Ortak Veri ve Güvenlik:** Tüm ekranlar mevcut `ListingsProvider` üzerinden ortak Web API verisini kullanır; detay ekranına geçişte mevcut sahiplik ve doğrulama kuralları korunur.

## 3. Doğrulama

```sh
flutter analyze
flutter test test/listing_search_pagination_test.dart
```

`test/listing_search_pagination_test.dart` dosyası; Türkçe karakter duyarlı arama, tür/kategori kombinasyonu, sayfalama sınırları ve `RadarFeedScreen`, `LostFoundFeedScreen`, `ListingSearchScreen` ekranlarının dar mobil görünümde (390×844) taşma olmadan çalışmasını doğrular.

