# Kalori Hesaplayıcı — Flutter

Flutter ve Dart ile geliştirilmekte olan çevrimdışı günlük kalori takip uygulaması.

## Özellikler
- Yiyecek adı, porsiyon gramı ve 100 gram başına kalori değeri girişi
- Porsiyon kalorisi: gram × (100 g başına kcal) / 100
- Günlük kalori toplamı ve tarihe göre kayıt görüntüleme
- SQLite ile cihazda kayıt saklama ve kayıt silme

## Teknolojiler
Flutter, Dart, sqflite, path, GitHub Actions.

## Çalıştırma
```bash
flutter create --platforms=android --project-name kalori_hesaplayici .
flutter pub get
flutter run
```

## Durum
Portföy için sıfırdan geliştirilen ikinci uygulama. APK derleme ve telefon testleri henüz tamamlanmadı. Kalori değerleri kullanıcı tarafından girilir; uygulama besin veritabanı kullanmaz.
