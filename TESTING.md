# Katkı ve test rehberi

Bu depo Kalori Hesaplayıcı uygulamasına aittir. TaskFlow ayrı bir projedir.

## Değişiklik öncesi
- Yeni özellikleri ayrı bir dalda geliştirin.
- Mevcut SQLite kayıtlarının ve sürüm geçişlerinin korunmasını doğrulayın.
- Şifreleri, API anahtarlarını, kişisel sağlık kayıtlarını ve veritabanı dosyalarını commit etmeyin.
- Tamamlanmamış ekranları çalışıyormuş gibi tanıtmayın.

## Manuel test listesi
- [ ] Uygulama açılıyor ve ekranlar arasında geçiş yapılabiliyor.
- [ ] Besin eklenince kalori ve makrolar doğru hesaplanıyor.
- [ ] Porsiyon değiştirildiğinde toplamlar güncelleniyor.
- [ ] Besin silinince günlük toplamlar yeniden hesaplanıyor.
- [ ] Su miktarı ekleme ve gün değişimi doğru çalışıyor.
- [ ] Kapatıp açınca SQLite kayıtları korunuyor.
- [ ] Trendler ve raporlar boş veride hata vermiyor.
- [ ] Açık/koyu tema ve farklı ekran boyutları kontrol ediliyor.
- [ ] Android APK derlemesi başarıyla tamamlanıyor.

## Planlanan modüller
Fotoğrafla besin analizi, antrenman, adım takibi, öğün planlama ve AI koç, ayrı geliştirme ve test gerektirir. Ekran görüntüleri tek başına bu işlevlerin kaynak kodunu sağlamaz.
