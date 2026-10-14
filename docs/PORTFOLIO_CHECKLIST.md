# Kalori Takip — Portföy ve Sürüm Kontrolü

## 1.2.0 sürümünde doğrulananlar

- [x] Analiz ve 34 birim/arayüz testi başarılı.
- [x] Ana ekran sekmelere, formlara ve controller'a ayrıldı.
- [x] Dolu öğünler, hedefler ve grafikler çalışan Android uygulamasından kaydedildi.
- [x] Yaklaşık 31 saniyelik Android demosu eklendi.
- [x] Sürüm APK'sı Android API 35 emülatörüne kuruldu.
- [x] Uygulama kapatılıp yeniden açıldı; kaydedilen öğünler görünür kaldı.
- [x] Android kontrolündeki APK ve video kalıcı GitHub Releases dosyaları olarak yayımlandı.
- [ ] Fiziksel telefon modeli ve Android sürümü kaydedilerek cihaz kontrolü tamamlandı.

Yeni galeri ve video `docs/media/` içindedir. Kök dizindeki eski ekran görüntüleri önceki sürüme aittir. Gösterilen kayıtlar kurgusal demo verileridir.

## Kontrolün kaynağı

[Doğrulama kaydı](media/verification.json), test edilen commit'i ve başarılı Android çalışmasının bağlantısını içerir. [Fiziksel cihaz rehberi](DEVICE_TEST.md) ayrı kontrol listesidir; emülatör sonucu fiziksel telefon testi olarak işaretlenmez.

## Yeni sürüm hazırlarken

- [ ] Değişen uygulama kaynağında analiz ve otomatik testler çalıştırıldı.
- [ ] Android akışı, yeniden açılış ve veri korunması tekrar doğrulandı.
- [ ] Ekran görüntüleri ve demo güncellendi.
- [ ] JSON yedek alma/geri yükleme ve farklı ekran boyutları kontrol edildi.
- [ ] Sürüm dosyasındaki commit ve başarılı çalışma numarası güncellendi.
- [ ] APK ve demo sürüm sayfasında indirilebilir durumda.

`Android demo and persistence` geçici artefaktı 30 gün saklar. [Kalıcı sürüm dosyaları](https://github.com/alidanis61615/Kalori-Takip/releases/latest) bu süreye bağlı değildir. Mağaza dağıtımı için kalıcı üretim imzası ayrıca yapılandırılmalıdır.
