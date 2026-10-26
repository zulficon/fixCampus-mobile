@echo off
chcp 65001 >nul
title fixCampus Mobil Uygulaması
echo ========================================================
echo   fixCampus Mobil - 2. Hafta Uygulaması
echo ========================================================
echo.
echo Flutter geliştirici ortamı başlatılıyor ve Chrome açılıyor...
echo.
echo [Kısayollar]:
echo   - Kodda değişiklik yaptığınızda bu pencerede 'r' tuşuna basarak anında Hot Reload yapabilirsiniz.
echo   - Tam yeniden başlatma için 'R' tuşuna basabilirsiniz.
echo   - Kapatmak için 'q' tuşuna basabilirsiniz.
echo.
flutter run -d chrome
