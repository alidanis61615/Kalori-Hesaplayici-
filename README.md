# PaketKap | Flutter & Dart

**PaketKap**, Türkçe arayüzlü, çevrimdışı çalışan Android kalori ve beslenme takip uygulamasıdır. Flutter, Dart, Material 3 ve SQLite ile geliştirilmiştir.

[![Flutter CI](https://github.com/alidanis61615/PaketKap/actions/workflows/flutter-checks.yml/badge.svg)](https://github.com/alidanis61615/PaketKap/actions/workflows/flutter-checks.yml)

**Hızlı bağlantılar:** [Teknik portföy özeti](docs/PORTFOLIO_OVERVIEW.md) · [Ekran görüntüsü ve yayın kontrol listesi](docs/PORTFOLIO_CHECKLIST.md) · [Otomatik testler ve APK](https://github.com/alidanis61615/PaketKap/actions)

> **Portföy demosu:** Gün Özeti ekranında bir besin ekleyin; ardından su takibini ve Trendler ekranındaki 7 günlük grafikleri inceleyin. Uygulama internetsiz çalışır. Gerçek cihaz ekran görüntüleri henüz depoya eklenmedi.

## Özellikler
- **Gün özeti:** Kalori, protein, karbonhidrat ve yağ hedefleri; kalan kalori bilgisi.
- **Öğün takibi:** Besin ekleme, düzenleme, silme; kahvaltı/öğle/akşam/atıştırmalık kategorileri.
- **Besin kataloğu ve favoriler:** Örnek besinlerden hızlı ekleme; gram ve 100 gramlık değerleri düzenleme.
- **Su takibi:** Günlük içilen suyu kaydetme.
- **Trendler:** 7/30/90 günlük beslenme ortalamaları, son 7 gün kalori ve su grafikleri, su istatistikleri, kilo ölçümleri ve kilo grafiği.
- **Raporlar:** Günlük ve haftalık özetler, su hedefi ilerlemesi ve hedefe yakın günler.
- **Profil:** Kalori, makro ve günlük su hedeflerini düzenleme.
- **Yerel yedek:** Besin, su, kilo, favori ve hedefleri JSON biçiminde panoya kopyalama; panodan geri yükleme. Geri yükleme mevcut kayıtların **tamamını değiştirir** ve onay ister.

Besin değerleri elle girilir; katalogdaki değerler yaklaşık örneklerdir. Uygulama tıbbi tavsiye sunmaz.

## Teknolojiler
- Flutter / Dart / Material 3
- SQLite (`sqflite`) ve `path`
- Flutter testleri ve GitHub Actions (analiz, test, debug APK)

## Portföyde öne çıkan teknik noktalar
- Günlük verileri SQLite ile kalıcı saklama ve veritabanı sürüm geçişleri.
- Besinlerin enerji ve makro hesaplamalarını porsiyon gramına göre yapma.
- JSON yedek içeriğini kontrol edip geri yüklemeyi veritabanı işlemi (transaction) içinde gerçekleştirme.
- GitHub Actions ile statik analiz, otomatik test ve Android debug APK üretimi.

> **İsimlendirme notu:** GitHub deposu ve kullanıcıya görünen marka adı PaketKap'tır. Flutter proje kimliği (`kalori_hesaplayici`) mevcut Android uygulama kimliğiyle uyumluluğu korumak için değiştirilmemiştir.

## Yerelde çalıştırma
Flutter SDK ve Android geliştirme araçları gerekir.

```bash
git clone https://github.com/alidanis61615/PaketKap.git
cd PaketKap
flutter create --platforms=android --project-name kalori_hesaplayici .
flutter pub get
flutter run
```

## Android APK
**Actions → Flutter checks / Build Android APK → başarılı çalışma → Artifacts** bölümünden `kalori-hesaplayici-debug-apk` dosyasını indirin. Bu bir **debug** derlemesidir; mağaza yayınına hazır imzalı sürüm değildir.

## Test
```bash
flutter analyze --no-fatal-infos
flutter test
flutter build apk --debug
```

## Veri güvenliği
Kayıtlar varsayılan olarak cihazdaki SQLite veritabanında tutulur; bulut eşitleme yoktur. JSON yedeği panoya kopyalanır; panodaki içerik diğer uygulamalar tarafından okunabilir. Yedeği güvenli bir yerde saklayın. Geri yükleme mevcut kayıtları silip yedektekilerle değiştirir. Güncelleme öncesi uygulamayı kaldırmayın.

## Bilinen sınırlar
- Fotoğraftan otomatik besin analizi, barkod tarama, Health Connect ve bulut senkronizasyonu bulunmaz.
- Kalori ve kilo grafikleri yalnızca kullanıcı tarafından girilen verileri gösterir.
- Su hedefi örnek bir değerdir; kişiye özel sağlık önerisi değildir.
- Android sürümleri ve farklı ekran boyutlarında ek testler yapılmalıdır.

## Proje durumu
Yeni geliştirmeler `feature/portfolio-improvements-2026` dalında, ana dalı koruyan bir pull request üzerinden yürütülür. GitHub'da sergilenecek ekran görüntüleri ayrıca eklenebilir.

**Geliştirme amacı:** Flutter/Dart, yerel veri saklama, kullanıcı arayüzü, hata ayıklama ve CI/CD becerilerini uygulamalı bir portföy projesinde göstermek.
