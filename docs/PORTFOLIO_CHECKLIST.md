# PaketKap — Portföy ve Sürüm Kontrolü

## Depodaki sunum

- [x] Gerçek Android cihaz ekran görüntüleri depoya eklendi.
- [x] README içinde görüntülere bağlantı verildi.
- [x] Özellikler, teknik yapı ve yerel kurulum belgelendi.
- [x] Besin/model/trend testleri depoda bulunuyor.
- [x] APK indirme adımları mevcut iş akışlarıyla eşleştirildi.

Görseller kök dizindeki `Screenshot_20261012_*.jpg` dosyalarıdır. Galeri için [README](../README.md) dosyasına bakın.

## Her sürümde kontrol edin

- [ ] Değiştirilen commit için analiz ve test sonucu başarılı.
- [ ] APK derlemesi ve gerçek cihaza kurulum tamamlandı.
- [ ] Besin ekleme, düzenleme ve silme doğru çalışıyor.
- [ ] Su/kilo/hedef kayıtları yeniden açılışta korunuyor.
- [ ] JSON yedek ve geri yükleme örnek verilerle çalışıyor.
- [ ] Boş veri ve farklı ekran boyutları kontrol edildi.
- [ ] Ekran görüntüleri güncel sürümü temsil ediyor.

## Derleme türleri

| İş akışı | Artefakt | Çıktı |
| --- | --- | --- |
| Build Android APK | Kalori-Hesaplayici-APK | app-release.apk |
| Flutter checks | kalori-hesaplayici-debug-apk | app-debug.apk |

Artefaktlar 14 gün saklanır. Mağaza yayını için imzalama ve dağıtım ayrıca yapılandırılmalıdır.
