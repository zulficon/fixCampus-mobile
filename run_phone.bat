@echo off
chcp 65001 >nul
title fixCampus Mobil Uygulamasi
echo ========================================================
echo   fixCampus Mobil - Gelistirici Baslatici (Chrome Web)
echo ========================================================
echo.
echo Flutter gelistirici ortami baslatiliyor ve Chrome aciliyor...
echo.
echo [Baglanti Ayarlari]:
echo   - Supabase: https://nfbmanrrhjuynaarozzs.supabase.co
echo   - Web API:  http://localhost:5168
echo.
echo [Kisayollar]:
echo   - Kodda degisiklik yaptiginizda bu pencerede 'r' tusuna basarak Hot Reload yapabilirsiniz.
echo   - Tam yeniden baslatma icin 'R' tusuna basabilirsiniz.
echo   - Kapatmak icin 'q' tusuna basabilirsiniz.
echo.
flutter run -d chrome --dart-define=SUPABASE_URL=https://nfbmanrrhjuynaarozzs.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.fixcampus_dev_anon_key --dart-define=API_BASE_URL=http://localhost:5168
