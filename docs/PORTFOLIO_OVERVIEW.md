# PaketKap — Portföy Tanıtımı

## Proje özeti
PaketKap, Flutter ve Dart ile geliştirilmiş, çevrimdışı çalışan bir Android beslenme ve kalori takip uygulamasıdır. Veriler SQLite ile cihazda saklanır.

## Çözdüğü problem
Kullanıcıların öğün, kalori, makro besin, su tüketimi ve kilo kayıtlarını tek yerde takip etmesini; günlük ve haftalık değişimi görmesini sağlar.

## Teknik olarak yaptıklarım
- Flutter/Material 3 ile çok ekranlı mobil arayüz.
- SQLite üzerinde besin, su, kilo, favori ve kullanıcı hedefleri için kalıcı veri yönetimi.
- Porsiyona göre kalori ve makro besin hesaplamaları.
- 7/30/90 günlük özetler ve kayıt bazlı grafikler.
- JSON yedeği doğrulama, kullanıcı onayı ve SQLite transaction ile geri yükleme.
- GitHub Actions üzerinden statik analiz, test ve debug APK üretimi.

## İşverene 2 dakikalık demo
1. **Gün Özeti**: Kalori ve makro hedeflerini göster.
2. **Ekle**: Örnek bir besin kaydet; günlük toplamın değiştiğini göster.
3. **Su**: 250 ml ekle; ilerleme çubuğunun değiştiğini göster.
4. **Trendler**: Son 7 günlük su ve kalori grafiğini aç.
5. **Raporlar**: Günlük rapor ve hedefe yakın günleri göster.
6. **Profil**: Hedef düzenleme ve yedek alma seçeneklerini göster.

## Teknik sınırlar
- Katalog besin değerleri yaklaşık örneklerdir; tıbbi tavsiye verilmez.
- Bulut senkronizasyonu ve otomatik fotoğraf analizi yoktur.
- APK, CI üzerinden üretilen debug sürümüdür.
- Kod deposunun eski adı teknik uyumluluk için korunmaktadır.

## Yayın öncesi son kontroller
- [ ] Son commit için GitHub Actions yeşil
- [ ] Gerçek cihazda temel akışlar test edildi
- [ ] Örnek verilerle kişisel bilgi içermeyen ekran görüntüleri eklendi
- [ ] README'ye gerçek ekran görüntüleri bağlandı
- [ ] Geliştirme dalındaki değişiklikler incelenip ana dala birleştirildi

Detaylı kurulum ve özellikler için kök dizindeki [README](../README.md) dosyasına bakın.
