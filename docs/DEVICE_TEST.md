# Android cihaz kontrolü

## Otomatik Android kontrolü

`Android demo and persistence` iş akışı yeni, geçici bir Android API 35 emülatöründe çalışır. Gösterilen tüm kayıtlar kurgusal portföy verileridir.

1. Gerçek sqflite veritabanına örnek kayıtlar eklenir.
2. Uygulama açılır; ilgili ekranlar ve kontroller denenir.
3. Ekran görüntüleri ve kısa video alınır.
4. Aynı test ortamına üretim APK'sı `adb install -r` ile kurulur.
5. Uygulama zorla kapatılıp yeniden açılır; kayıtların görünür kaldığı denetlenir.

Sonuç, `docs/media/verification.json` dosyasındaki commit ve çalışma bağlantısıyla izlenebilir. Bu kontrol, fiziksel telefonun bütün özelliklerini doğrulamaz.

## Fiziksel telefonda yapılacak kontrol

Bu liste fiziksel cihazda çalıştırılmadıkça tamamlandı olarak işaretlenmez. Mevcut kayıtlarınız varsa yeni kurulumdan önce yedek alın. Demo APK'ları mağaza için üretim imzasıyla dağıtılmaz; eski kurulumunuz farklı imzalıysa Android güncellemeyi kabul etmeyebilir.

- [ ] Cihaz modeli ve Android sürümü kaydedildi.
- [ ] GitHub Releases'daki APK indirildi ve uygulama açıldı.
- [ ] Yeni bir kayıt eklendi; listede ve toplamda doğru gösterildi.
- [ ] Uygulama kapatılıp açıldı; kayıt korundu.
- [ ] Düzenleme/silme ve ekranlar arası geçiş denendi.
- [ ] Klavye açıkken ve küçük ekranda form kontrollerine erişildi.
- [ ] Kalori Takip için JSON yedek alma/geri yükleme ayrıca denendi.

Cihaz: … / Android: … / APK sürümü: … / Tarih: …
