# PaketKap — Teknik Portföy Özeti

PaketKap, Flutter ve Dart ile geliştirilen Android beslenme takip uygulamasıdır. Öğün, kalori, makro, su ve kilo kayıtlarını tek yerde toplar; günlük hedefler ve dönemsel özetler sunar.

## Teknik olarak gösterdiği çalışmalar

| Çalışma | Uygulamadaki karşılığı |
| --- | --- |
| Mobil arayüz | Material 3; gün özeti, trendler, besin ekleme, raporlar ve profil |
| Kalıcı veri | SQLite'ta besin, su, favori, hedef ve kilo tabloları |
| Hesaplama | Porsiyon gramına göre kalori ve makro değerleri |
| Trend analizi | 7/30/90 günlük özet; kayıt olmayan günleri ortalamaya katmama |
| Veri aktarımı | JSON yedeği doğrulama ve transaction içinde geri yükleme |
| Test ve derleme | Besin/model/trend testleri; GitHub Actions ile analiz ve APK |

## İki dakikalık demo

1. Günlük kalori ve makro hedeflerini gösterin.
2. Bir besin ekleyin; toplamın gram miktarına göre değişimini inceleyin.
3. 250 ml su ekleyin; ilerleme çubuğunu gösterin.
4. Trendler ekranında dönem, kalori ve su grafiklerini inceleyin.
5. Profil ekranında hedef düzenleme ve JSON yedekleme akışını açın.

## Kaynaklara hızlı erişim

- [Özellikler, gerçek cihaz ekranları ve kurulum](../README.md)
- [Arayüz, modeller ve SQLite erişimi](../lib/main.dart)
- [Bağımsız trend hesapları](../lib/nutrition_trends.dart)
- [Otomatik testler](../test/)
- [Manuel test rehberi](../TESTING.md)
- [APK derlemeleri](https://github.com/alidanis61615/PaketKap/actions/workflows/build-apk.yml)

## Mevcut kapsam

Besinler elle veya örnek katalogdan kaydedilir. Fotoğraftan otomatik analiz ve bulut eşitleme bulunmaz. Proje kimliği `kalori_hesaplayici`, ürün adı PaketKap'tır.

`Build Android APK` iş akışı `Kalori-Hesaplayici-APK` adlı release APK artefaktı üretir. `Flutter checks` çalışmalarındaki `kalori-hesaplayici-debug-apk` test derlemesidir. Mağaza dağıtımı ayrıca yapılandırılır.

**Geliştirici:** [Ali Danış](https://github.com/alidanis61615) · Mobil Teknolojileri mezunu, Yazılım Geliştirici
