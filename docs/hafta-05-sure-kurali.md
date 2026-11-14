# Sosyal ilan süre kuralı

`ListingExpiryPolicy` sosyal buluşmanın tarihi yoksa veya buluşma zamanı
şimdiki ana eşit/geçmişse süreyi dolmuş kabul eder. Dart `DateTime`
karşılaştırması aynı UTC anını temsil eden farklı saat dilimlerinde aynı sonucu verir.
Kayıp ve buluntu ilanlarına süre uygulanmaz. Kayıt silinmez veya durum alanı değiştirilmez.

`ListingExpiryBoundary` en yakın buluşma zamanında ekranı yeniden değerlendirir.
Uzun beklemelerde en geç dakikada bir cihaz saatini kontrol eder; uygulama
arka plandan döndüğünde de kontrol yapar. Tarih değişince zamanlayıcı yeniden
kurulur; widget kapandığında zamanlayıcı ve yaşam döngüsü dinleyicisi kaldırılır.

`ExpiryAwareListingResults`, mevcut `ServerListingResults` bileşenini sarar.
Radar ve Arama ekranlarında süresi dolan kart hemen kaldırılır ve mevcut API
yenilemesi çalıştırılır. Toplam kayıt/sayfa bilgisi yerelde tahmin edilmez;
API'nin yeni yanıtı kullanılır. Son sayfanın boşalması mevcut sunucu sayfa
düzeltme akışından geçer. Yenileme başarısızsa mevcut hata/tekrar deneme akışı sürer.

Detay ekranı süre dolunca katılım düğmesini kapatır ve süre mesajı gösterir.
Düğmenin tıklanma anında da tarih tekrar kontrol edilir. Mevcut sahiplik
kurallarıyla düzenleme/silme erişimi korunur. Katılım düğmesinin mevcut yerel
Provider davranışı bu değişiklikle gerçek katılım servisine dönüştürülmez;
bu servis ekip planında ayrı bir görevdir.

Bu kod mobil depoda uygulanmıştır. Ortak API'nin mevcut `ListingQueries.Filter`
kuralı sosyal buluşma tarihini `şimdi` değerinden büyük olacak şekilde filtreler;
bu filtre toplam kayıt hesabından ve sayfalamadan önce uygulanır.
Kaynak: https://github.com/bernakalkann/fixCampus/blob/main/src/FixCampus.Web/Services/ListingQueries.cs
Bu çalışma kapsamında ağ projesinde işlem yapılmamıştır.

`test/listing_expiry_test.dart` sınır anı, saat dilimi, boş tarih, kayıp/buluntu,
zamanlayıcı, yaşam döngüsü, tarih değişimi, kapanış ve sunucu toplamlarıyla yenilemeyi sınar.
`test/listing_expiry_detail_test.dart` geçmiş ve gelecek ilanda katılım görünümünü sınar.
Testler sahte servis/zaman kullanır; gerçek cihazda canlı kontrolün yerine geçmez.
