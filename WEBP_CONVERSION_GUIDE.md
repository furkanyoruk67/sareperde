# WebP Image Conversion Guide

Bu rehber, Flutter projenizde bulunan PNG ve JPG görsellerini WebP formatına dönüştürmenize yardımcı olacaktır. WebP formatı, daha küçük dosya boyutları ve daha hızlı yükleme süreleri sağlar.

## 🎯 Faydalar

- **%25-50 daha küçük dosya boyutları**: Aynı kalitede daha az yer kaplar
- **Daha hızlı uygulama yüklenme süreleri**: Özellikle mobil cihazlarda
- **Daha az bant genişliği kullanımı**: Kullanıcılar için daha az veri tüketimi
- **Modern tarayıcı desteği**: Tüm modern tarayıcılarda desteklenir

## 📋 Gereksinimler

### ImageMagick Kurulumu (Otomatik Dönüştürme İçin)

1. [ImageMagick](https://imagemagick.org/script/download.php#windows) indirin
2. Kurulum sırasında **"Add application directory to your system path"** seçeneğini işaretleyin
3. Kurulum tamamlandıktan sonra PowerShell'i yeniden başlatın
4. Test edin: `magick -version`

## 🚀 Hızlı Başlangıç

### Adım 1: Yedekleme (ÖNEMLİ!)
```powershell
# Tüm görsellerinizi yedekleyin
.\backup_images.ps1
```

### Adım 2: WebP'ye Dönüştürme
```powershell
# Varsayılan ayarlarla dönüştürme (80% kalite, orijinalleri sakla)
.\convert_to_webp.ps1

# Yüksek kalitede dönüştürme
.\convert_to_webp.ps1 -Quality 90

# Sadece önizleme (hiçbir dosya değişmez)
.\convert_to_webp.ps1 -DryRun
```

### Adım 3: Flutter Uygulamasını Test Etme
```powershell
flutter clean
flutter pub get
flutter run
```

## 📁 Dönüştürülecek Dosyalar

Projenizde şu görseller bulunuyor:

### Ana Görseller
- `assets/logo1.jpg` → `assets/logo1.webp`
- `assets/hero_slider.jpg` → `assets/hero_slider.webp`
- `assets/gorsel1.jpg` → `assets/gorsel1.webp`

### Slider Görselleri (5 dosya)
- `assets/Slider/*.png` → `assets/Slider/*.webp`

### Ürün Görselleri (3 dosya)
- `assets/products/*.png` → `assets/products/*.webp`

### Katalog Görselleri (800+ dosya)
- `assets/extracted_pages/**/*.png` → WebP formatına dönüştürülecek
- `assets/extracted_products_super_ai/**/*.png` → WebP formatına dönüştürülecek
- `assets/bestsellers/*.png` → WebP formatına dönüştürülecek

### Nevada Koleksiyonu
- `assets/Nevada/*.jpg` → `assets/Nevada/*.webp`

## 🔧 Gelişmiş Kullanım

### Kalite Ayarları
```powershell
# Düşük kalite, çok küçük dosya boyutu
.\convert_to_webp.ps1 -Quality 60

# Orta kalite (önerilen)
.\convert_to_webp.ps1 -Quality 80

# Yüksek kalite
.\convert_to_webp.ps1 -Quality 95
```

### Belirli Klasörleri Dönüştürme
```powershell
# Sadece Slider klasörü
.\convert_to_webp.ps1 -InputDir "assets\Slider"

# Sadece ürün görselleri
.\convert_to_webp.ps1 -InputDir "assets\products"

# Sadece bestsellers
.\convert_to_webp.ps1 -InputDir "assets\bestsellers"
```

### Orijinal Dosyaları Silme
```powershell
# UYARI: Bu işlem orijinal dosyaları siler!
.\convert_to_webp.ps1 -KeepOriginal:$false
```

## 📝 Manuel Dönüştürme

ImageMagick kurulu değilse, online araçlar kullanabilirsiniz:

### Online Araçlar
1. [Squoosh](https://squoosh.app/) - Google tarafından geliştirildi
2. [CloudConvert](https://cloudconvert.com/png-to-webp)
3. [Convertio](https://convertio.co/png-webp/)

### Photoshop/GIMP
- Photoshop: "Export As" → WebP formatını seçin
- GIMP: WebP plugin kurulu olmalı

## 🎨 Kod Güncellemeleri

Aşağıdaki dosyalar otomatik olarak güncellenmiştir:

### ✅ `lib/pages/catalog_page.dart`
```dart
// Eski
final List<String> sliderImages = [
  'assets/Slider/Ekran görüntüsü 2025-08-11 233136.png',
  // ...
];

// Yeni
final List<String> sliderImages = [
  'assets/Slider/Ekran görüntüsü 2025-08-11 233136.webp',
  // ...
];
```

### ✅ `pubspec.yaml`
```yaml
# Eski
assets:
  - assets/logo1.jpg
  - assets/hero_slider.jpg

# Yeni  
assets:
  - assets/logo1.webp
  - assets/hero_slider.webp
```

## 🔍 Diğer Dosyalarda Kontrol Edilmesi Gerekenler

Projenizde başka yerlerde görsel referansları olabilir. Şunları kontrol edin:

```bash
# PNG/JPG referanslarını bulma
grep -r "\.png\|\.jpg\|\.jpeg" lib/
grep -r "\.png\|\.jpg\|\.jpeg" pubspec.yaml
```

## 📊 Beklenen Sonuçlar

### Dosya Boyutu Azalması
- **PNG dosyaları**: %20-40 azalma
- **JPG dosyaları**: %15-25 azalma
- **Toplam proje boyutu**: Yaklaşık %25-35 azalma

### Performans İyileştirmesi
- **İlk yükleme süresinde**: %15-30 azalma
- **Görsel yükleme hızında**: %20-40 artış
- **Bellek kullanımında**: %10-20 azalma

## 🚨 Dikkat Edilmesi Gerekenler

1. **Yedekleme yapın**: Dönüştürme öncesi mutlaka yedek alın
2. **Test edin**: Dönüştürme sonrası uygulamayı test edin
3. **Kalite kontrol**: Görsellerin kalitesini kontrol edin
4. **Geri dönüş planı**: Sorun olursa yedekten geri dönebilirsiniz

## 🔧 Sorun Giderme

### ImageMagick Kurulum Sorunları
```powershell
# PATH kontrolü
echo $env:PATH

# ImageMagick testi
magick -version
```

### Flutter Sorunları
```powershell
# Cache temizleme
flutter clean
flutter pub get

# Tam yeniden derleme
flutter build apk --debug
```

### Görsel Yükleme Sorunları
- Dosya yollarını kontrol edin
- Dosya isimlerindeki özel karakterleri kontrol edin
- `pubspec.yaml` dosyasındaki asset listesini kontrol edin

## 📞 Yardım

Sorun yaşarsanız:
1. Bu rehberi tekrar okuyun
2. Hata mesajlarını kaydedin
3. Yedek dosyalarınızı kontrol edin
4. Gerekirse orijinal dosyalara geri dönün

---

**Not**: Bu dönüştürme işlemi geri alınabilir. Yedek dosyalarınız `assets_backup_*` klasöründe saklanacaktır.
