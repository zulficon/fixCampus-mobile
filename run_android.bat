@echo off
chcp 65001 >nul
title fixCampus Mobil Uygulamasi (Android Emulator)
echo ========================================================
echo   fixCampus Mobil - Android Emulator Baslatici
echo ========================================================
echo.
echo Flutter Android emulator ortaminda baslatiliyor...
echo.
echo [Baglanti Ayarlari]:
echo   - Supabase: https://nfbmanrrhjuynaarozzs.supabase.co
echo   - Web API:  http://10.0.2.2:5168 (Android Host Loopback)
echo.
flutter run --dart-define=SUPABASE_URL=https://nfbmanrrhjuynaarozzs.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.fixcampus_dev_anon_key --dart-define=API_BASE_URL=http://10.0.2.2:5168

