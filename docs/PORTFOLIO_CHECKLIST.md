# Ekran Görüntüleri ve Yayın Kontrol Listesi

Bu belge, Kalori Hesaplayıcı projesini GitHub portföyünde doğru ve güvenli biçimde sergilemek içindir.

## Önerilen ekran görüntüleri

1. **Gün özeti:** Günlük kalori ve makro hedefleri (örnek kayıtlarla).
2. **Öğün ekleme:** Besin adı, gram ve makro alanları.
3. **Su takibi:** Günlük su ilerlemesi.
4. **Trendler:** Haftalık kalori grafiği ve örnek kilo grafiği.
5. **Raporlar:** Son 7 günün kayıt özeti.
6. **Profil:** Hedef ayarları ve yedekleme seçenekleri.

## Ekran görüntüsü hazırlama

- Gerçek isim, kişisel sağlık bilgisi veya başka özel bilgi göstermeyen **örnek veriler** kullanın.
- Bildirim çubuğunda telefon numarası, e-posta ve diğer kişisel bilgilerin görünmediğini kontrol edin.
- Görselleri PNG olarak `docs/screenshots/` klasörüne ekleyin.
- Önerilen adlar: `today.png`, `add-food.png`, `water.png`, `trends.png`, `reports.png`, `profile.png`.
- Görseller eklendikten sonra README içinde bağlantılarını açın. Henüz eklenmeyen dosyalara kırık bağlantı vermeyin.

## APK yayın kontrolü

- [ ] `flutter analyze --no-fatal-infos` başarılı
- [ ] `flutter test` başarılı
- [ ] `flutter build apk --debug` başarılı
- [ ] Yeni APK mevcut uygulamanın üzerine kurulabiliyor
- [ ] Besin ekleme, düzenleme ve silme çalışıyor
- [ ] Su ve kilo kayıtları uygulama yeniden açıldığında korunuyor
- [ ] JSON yedeği alınıyor ve test verileriyle geri yüklenebiliyor
- [ ] Günlük ve haftalık grafikler doğru görünüyor
- [ ] Ekran görüntüleri kişisel veri içermiyor

> Not: GitHub Actions tarafından üretilen APK bir **debug** derlemesidir. Google Play için ayrı bir imzalı release derlemesi ve mağaza gereklilikleri gerekir.
