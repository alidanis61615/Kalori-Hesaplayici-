# Kalori Takip — Teknik Portföy Özeti

Kalori Takip, Flutter ve Dart ile geliştirilen Android beslenme takip uygulamasıdır. Öğün, kalori, makro, su ve kilo kayıtlarını tek yerde toplar; günlük hedefler ve dönemsel özetler sunar.

## Teknik olarak gösterdiği çalışmalar

| Çalışma | Uygulamadaki karşılığı |
| --- | --- |
| Mobil arayüz | Material 3; gün özeti, trendler, besin ekleme, raporlar ve profil |
| Kalıcı veri | SQLite'ta besin, su, favori, hedef ve kilo tabloları |
| Hesaplama | Porsiyon gramına göre kalori ve makro değerleri |
| Trend analizi | 7/30/90 günlük özet; kayıt olmayan günleri ortalamaya katmama |
| Veri aktarımı | JSON yedeği doğrulama ve transaction içinde geri yükleme |
| Test ve derleme | 34 birim/arayüz testi; gerçek SQLite geri yükleme ve Android yeniden açılış kontrolü |

## İki dakikalık demo

1. Günlük kalori ve makro hedeflerini gösterin.
2. Bir besin ekleyin; toplamın gram miktarına göre değişimini inceleyin.
3. 250 ml su ekleyin; ilerleme çubuğunu gösterin.
4. Trendler ekranında dönem, kalori ve su grafiklerini inceleyin.
5. Profil ekranında hedef düzenleme ve JSON yedekleme akışını açın.

## Kaynaklara hızlı erişim

- [Özellikler, dolu Android ekranları ve kurulum](../README.md)
- [Arayüz](../lib/screens/home.dart) · [Modeller](../lib/models/) · [SQLite](../lib/services/store.dart) · [Yedek doğrulama](../lib/services/backup_codec.dart)
- [Bağımsız trend hesapları](../lib/nutrition_trends.dart)
- [Otomatik testler](../test/)
- [Manuel test rehberi](../TESTING.md)
- [APK derlemeleri](https://github.com/alidanis61615/Kalori-Takip/actions/workflows/build-apk.yml)

## Mevcut kapsam

Besinler elle veya örnek katalogdan kaydedilir. Fotoğraftan otomatik analiz ve bulut eşitleme bulunmaz. Proje kimliği `kalori_hesaplayici`, ürün adı Kalori Takip'tir.

[Kalıcı Android indirme sayfası](https://github.com/alidanis61615/Kalori-Takip/releases/latest), `Kalori-Takip-Android.apk` dosyasını içerir. `Build Android APK` iş akışı analiz ve testlerden sonra APK üretir. Bu sürüm, Android kontrolünü geçen APK’yı `Publish reviewed Android release` iş akışıyla kalıcı olarak yayımlar; kontrol sonrası uygulama kaynağının değişmediği doğrulanır. Mağaza dağıtımı ayrıca yapılandırılır.
