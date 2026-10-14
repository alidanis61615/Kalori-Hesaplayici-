# Kalori Takip — Kalori ve Beslenme Takibi

Flutter ve Dart ile geliştirilen Android uygulaması; besin kayıtlarını, kişisel kalori ve makro hedeflerini, su tüketimini ve kilo değişimini tek yerde takip etmeyi kolaylaştırır. Veriler SQLite ile cihazda saklanır.

[![Android build](https://github.com/alidanis61615/Kalori-Takip/actions/workflows/build-apk.yml/badge.svg?branch=main)](https://github.com/alidanis61615/Kalori-Takip/actions/workflows/build-apk.yml)

**[Android APK indir](https://github.com/alidanis61615/Kalori-Takip/releases/latest) · [Ekranlar](#uygulama-ekranları) · [Kurulum](#yerelde-çalıştırma) · [Teknik özet](docs/PORTFOLIO_OVERVIEW.md) · [Test rehberi](TESTING.md)**

## Bu portföy sürümündeki katkım

Besinlerin porsiyona göre kalori ve makro hesaplarını, SQLite kayıt akışını, su/kilo takibini ve hedef ekranlarını geliştirdim. Ekranları, form bileşenlerini ve veriyi yükleyen controller'ı ayrı dosyalarda düzenledim.

**Teknik kararım:** Verileri cihazda SQLite ile saklamak ve JSON yedeğinin tamamını mevcut kayıtları değiştirmeden önce doğrulamak. Geri yükleme sırasında bir hata olursa transaction önceki kayıtları korur.

**Çözdüğüm hata:** Sayısal alanlarda metin veya geçersiz tarih içeren bir yedeğin kayıtları bozma ihtimalini giderdim. Doğrulama ve gerçek SQLite rollback testleriyle bu davranışı kontrol ettim. Arayüz testleri form, su, filtre ve hedef akışlarını; Android testleri veri kalıcılığını denetler.


## Teknik incelemeye hızlı başlangıç

| İnceleme | Kaynak |
| --- | --- |
| Ekranlar ve form bileşenleri | [Sekmeler](lib/screens/tabs/) · [Formlar](lib/widgets/) · [Controller](lib/controllers/nutrition_controller.dart) |
| Besin hesapları, SQLite ve JSON yedek doğrulama | [Besin modeli](lib/models/food.dart) · [SQLite servisi](lib/services/store.dart) · [Yedek doğrulama](lib/services/backup_codec.dart) |
| Arayüzden bağımsız dönemsel analiz | [Trend hesapları](lib/nutrition_trends.dart) |
| Porsiyon ve makro hesaplarının doğrulanması | [Hesaplama testleri](test/food_calculation_test.dart) |
| Kayıt olmayan günler ve dönem özetleri | [Trend testleri](test/nutrition_trends_test.dart) |
| Geçersiz yedek ve veritabanı hata durumları | [Doğrulama](test/backup_codec_test.dart) · [SQLite geri yükleme](test/store_backup_test.dart) · [Arayüz akışları](test/home_widget_test.dart) |

Projenin tasarımını ve demo akışını tek sayfada incelemek için [teknik portföy özetine](docs/PORTFOLIO_OVERVIEW.md) bakabilirsiniz.

## Uygulama ekranları

Gerçek Android cihazda çalışan uygulamadan alınan görüntüler. Görsellere tıklayarak büyük hâllerini açabilirsiniz.

<p align="center">
<a href="Screenshot_20261012_185949.jpg"><img src="Screenshot_20261012_185949.jpg" alt="Kalori Takip gün özeti" width="220"></a>
<a href="Screenshot_20261012_185953.jpg"><img src="Screenshot_20261012_185953.jpg" alt="Kalori Takip öğün işlemleri" width="220"></a>
<a href="Screenshot_20261012_185955.jpg"><img src="Screenshot_20261012_185955.jpg" alt="Kalori Takip su takibi" width="220"></a>
</p>
<p align="center">
<a href="Screenshot_20261012_185959.jpg"><img src="Screenshot_20261012_185959.jpg" alt="Kalori Takip beslenme trendleri" width="220"></a>
<a href="Screenshot_20261012_190002.jpg"><img src="Screenshot_20261012_190002.jpg" alt="Kalori Takip su tüketim grafiği" width="220"></a>
<a href="Screenshot_20261012_190006.jpg"><img src="Screenshot_20261012_190006.jpg" alt="Kalori Takip besin ekleme formu" width="220"></a>
</p>
<p align="center">
<a href="Screenshot_20261012_190013.jpg"><img src="Screenshot_20261012_190013.jpg" alt="Kalori Takip günlük raporları" width="220"></a>
<a href="Screenshot_20261012_190016.jpg"><img src="Screenshot_20261012_190016.jpg" alt="Kalori Takip profil ve veri yedeği" width="220"></a>
</p>

Bazı görüntüler boş kayıt durumunu gösterir. Güncel kodda sunulan özellikleri denemek için aşağıdaki demo akışını kullanın.

## Özellikler

| Alan | İşlevler |
| --- | --- |
| Gün özeti | Kalori, protein, karbonhidrat ve yağ hedefleri; kalan kalori ve tarih seçimi |
| Öğünler | Besin ekleme, düzenleme, onayla silme; öğüne göre filtreleme |
| Besin kataloğu | Örnek besinlerde arama, favoriler ve öğünleri yarına kopyalama |
| Su takibi | 100/250/500 ml ekleme, 100 ml geri alma, günlük hedef ve haftalık grafik |
| Trendler | 7/30/90 günlük beslenme özetleri, kalori grafiği ve kilo kayıtları |
| Raporlar | Günlük/haftalık özetler, makrolar ve hedefe yakın günler |
| Profil ve yedek | Hedefleri düzenleme; JSON yedeğini panoya kopyalama ve onayla geri yükleme |

## Hızlı demo

1. **Bugün** ekranında bir besin ekleyin; gram miktarına göre kalori ve makroların değişimini inceleyin.
2. **Su takibi** bölümünde 250 ml ekleyin ve hedef ilerlemesini kontrol edin.
3. **Trendler** ekranında dönem seçin; kalori, su ve kilo kayıtlarını inceleyin.
4. **Profil** ekranında günlük hedefleri düzenleyin ve JSON yedeğini alın.

## Teknik yapı

- **Arayüz:** Flutter Material 3; ayrı Bugün/Trendler/Raporlar/Profil sekmeleri, form bileşenleri ve `NutritionController` ile ekran durumu.
- **Modeller:** `Food`, `WeightRecord`; gram miktarına göre enerji ve makro hesapları.
- **Veri erişimi:** `Store` sınıfı ve SQLite; besin, su, hedef, favori ve kilo tabloları, veritabanı sürüm geçişleri.
- **Analiz:** `lib/nutrition_trends.dart` arayüz ve SQLite'tan bağımsızdır. Ortalamalara yalnızca kayıt bulunan günler katılır.
- **Yedekleme:** JSON biçim/sürüm, sayısal tür, takvim tarihi, öğün ve hedef kontrolleri; 5 MB boyut sınırı; tüm kontrollerden sonra transaction içinde geri yükleme.
- **Kontroller:** Besin, model, trend, yedek doğrulama ve gerçek SQLite geri yükleme testleri; GitHub Actions ile analiz, test ve APK üretimi.

## Yerelde çalıştırma

Flutter stable (Dart 3.12 veya üstü), Android araçları ve bir cihaz/emülatör gerekir. Android proje dosyaları ilk kurulumda üretilir.

```bash
git clone https://github.com/alidanis61615/Kalori-Takip.git
cd Kalori-Takip
flutter create --platforms=android --project-name kalori_hesaplayici .
rm -f test/widget_test.dart
flutter pub get
flutter run
```

Oluşturulan örnek `widget_test.dart`, uygulamanın `CalorieApp` sınıfını kullanmadığı için kaldırılır; depodaki proje testleri korunur. Windows PowerShell'de `Remove-Item test/widget_test.dart -ErrorAction SilentlyContinue` kullanılabilir.

## Analiz ve test

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## APK indirme

**[GitHub Releases → Android APK indir](https://github.com/alidanis61615/Kalori-Takip/releases/latest)**. **Assets** bölümündeki `Kalori-Takip-Android.apk` dosyasını indirin. Bu kalıcı dosya geçici Actions artefaktının saklama süresine bağlı değildir.

APK analiz ve testlerden sonra derlenir. Portföy demosudur; mağaza dağıtımı için ayrı üretim imzası gerekir. Yeni sürüm, `Build Android APK` iş akışında `main` üzerinden **publish** seçeneğiyle elle yayımlanır.

## Veri ve kapsam

Kayıtlar cihazda tutulur; bulut eşitleme veya kullanıcı hesabı bulunmaz. JSON geri yükleme mevcut kayıtların tamamını değiştirir ve onay ister. Uygulamayı kaldırmadan önce yedek alın.

Besin değerleri elle girilir; katalog örnek değerler içerir. Fotoğraftan otomatik besin analizi, barkod tarama ve Health Connect bu sürümde bulunmaz. Uygulama kişisel kayıt takibi içindir.

**İsimlendirme:** Ürün adı Kalori Takip'tir. Flutter proje kimliği `kalori_hesaplayici` olarak korunur.

**Geliştirici:** [Ali Danış](https://github.com/alidanis61615) · Mobil Teknolojileri mezunu, Yazılım Geliştirici
