# Kalori Hesaplayıcı | Flutter & Dart

Türkçe arayüzlü, çevrimdışı çalışan Android kalori ve beslenme takip uygulaması. Flutter, Dart, Material 3 ve SQLite ile geliştirilmiştir.

## Özellikler
- **Gün özeti:** Kalori, protein, karbonhidrat ve yağ hedefleri; kalan kalori bilgisi.
- **Öğün takibi:** Besin ekleme, düzenleme, silme; kahvaltı/öğle/akşam/atıştırmalık kategorileri.
- **Besin kataloğu ve favoriler:** Örnek besinlerden hızlı ekleme; gram ve 100 gramlık değerleri düzenleme.
- **Su takibi:** Günlük içilen suyu kaydetme.
- **Trendler:** 7/30/90 günlük beslenme ortalamaları, son 7 gün kalori grafiği, kilo ölçümleri ve kilo grafiği.
- **Raporlar:** Günlük ve haftalık özetler.
- **Profil:** Kalori ve makro hedeflerini düzenleme.
- **Yerel yedek:** Besin, su, kilo, favori ve hedefleri JSON biçiminde panoya kopyalama; panodan geri yükleme. Geri yükleme mevcut kayıtların **tamamını değiştirir** ve onay ister.

Besin değerleri elle girilir; katalogdaki değerler yaklaşık örneklerdir. Uygulama tıbbi tavsiye sunmaz.

## Teknolojiler
- Flutter / Dart / Material 3
- SQLite (`sqflite`) ve `path`
- Flutter testleri ve GitHub Actions (analiz, test, debug APK)

## Yerelde çalıştırma
Flutter SDK ve Android geliştirme araçları gerekir.

```bash
git clone https://github.com/alidanis61615/Kalori-Hesaplayici-.git
cd Kalori-Hesaplayici-
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
