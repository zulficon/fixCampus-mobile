/// fixCampus Mobil Uygulama Sabitleri
class AppConstants {
  static const String appName = 'fixCampus';
  static const String appTagline =
      'Kampüs Sosyal Buluşma ve Kayıp-Buluntu Platformu';
  static const String appVersion = '1.0.0';

  // API Bağlantı Varsayılanları (Yerel geliştirme)
  // Android Emülatör: http://10.0.2.2:5168
  // Fiziksel Cihaz veya Web: http://localhost:5168 veya yerel IP
  static const String defaultApiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.0.2.2:5168');

  // Supabase Varsayılanları (Geliştirme aşamasında konfigüre edilir)
  static const String supabaseUrlPlaceholder =
      'https://your-project.supabase.co';
  static const String supabaseAnonKeyPlaceholder = 'your-anon-key';

  // Depolama Bucket Adı
  static const String listingsBucket = 'ilan-fotograflari';
}
