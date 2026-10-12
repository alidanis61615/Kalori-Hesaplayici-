# Kalori Hesaplayıcı — Flutter

Gönderilen beslenme uygulaması ekranlarından ilham alınarak geliştirilen, çevrimdışı çalışan Flutter/Dart portföy projesi. Özgün ve sade bir arayüz kullanır.

## Özellikler
- **Bugün:** Günlük kalori, protein, karbonhidrat ve yağ toplamları ile hedef ilerleme çubukları
- **Öğünler:** Kahvaltı, öğle, akşam, atıştırmalık ve diğer kategorileri; filtreleme, ekleme, düzenleme ve silme
- **Hesaplama:** Porsiyon gramı × 100 gramdaki besin değeri / 100
- **Su takibi:** 100, 250 veya 500 ml ekleme; günlük kayıt
- **Trendler:** Son yedi günün kalori kayıtları ve hedef karşılaştırması
- **Raporlar:** Seçili günün kalori, makro, su ve öğün dağılımı; son 7 günün kayıt özeti
- **Profil:** Kalori ve makro hedeflerini düzenleme
- **SQLite:** Çevrimdışı saklama; eski sürümün yiyecek kayıtlarını koruyan v1 → v2 veritabanı geçişi

## Teknolojiler
Flutter, Dart, Material 3, sqflite, path, GitHub Actions.

## Çalıştırma
```bash
flutter create --platforms=android --project-name kalori_hesaplayici .
flutter pub get
flutter run
```

## APK
GitHub deposundaki **Actions → Build Android APK** iş akışını açın. Başarılı çalışmanın **Artifacts** bölümünden APK'yı indirebilirsiniz.

## Sınırlar ve geliştirme planı
- Besin değerleri kullanıcı tarafından elle girilir; hazır besin veri tabanı yoktur.
- Fotoğrafla yapay zekâ analizi, Samsung Health/Health Connect, adım ve uyku ölçümü **henüz entegre edilmemiştir**.
- Su hedefi şimdilik 2000 ml örnek değerdir; kişisel sağlık önerisi değildir.
- Mevcut besin kayıtlarının yeni eklenen makro alanları 0 olarak başlar; eski kayıtlar için makrolar otomatik tahmin edilmez.
- Cihazda gerçek kullanım, farklı ekran boyutları ve APK derlemesi ayrıca doğrulanmalıdır.

## Geliştirme
Bu depo, Flutter becerilerini geliştirmek ve portföy oluşturmak amacıyla hazırlanmıştır.
