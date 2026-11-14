import '../models/models.dart';

/// API ile aynı sınır: sosyal buluşma zamanı şimdiden kesinlikle sonra olmalı.
class ListingExpiryPolicy {
  const ListingExpiryPolicy();

  bool isExpired(Ilan listing, DateTime now) =>
      listing.tur == IlanTuru.sosyal &&
      (listing.bulusmaTarihi == null || !listing.bulusmaTarihi!.isAfter(now));
}
