# Çok Satanlar ve Anasayfa Ürünleri Yönetimi

## 📋 Genel Bakış

Bu sistem çok satanlar ve anasayfa ürünlerini ayrı ayrı yönetmenizi sağlar. Artık iki farklı ürün listesi vardır:

1. **Anasayfa Ürünleri** (`homepageProducts`) - Ana katalogda gösterilen ürünler
2. **Çok Satanlar** (`bestSellers`) - Özel carousel'da gösterilen popüler ürünler

## 🎯 Nasıl Çalışır?

### Anasayfa Ürünleri
- `lib/data/product_data.dart` dosyasında `homepageProducts` listesi
- Ana katalog sayfasında grid şeklinde gösterilir
- Filtreleme ve arama işlemleri sadece bu ürünlerde yapılır

### Çok Satanlar
- `lib/data/product_data.dart` dosyasında `bestSellers` listesi  
- Özel carousel widget'ında yatay scroll ile gösterilir
- Otomatik kaydırma özelliği vardır
- Anasayfa ürünlerinden bağımsızdır

## ✏️ Çok Satanları Nasıl Değiştirirsiniz?

### 1. Adım: Görsel Ekleme
1. `assets/bestsellers/` klasörüne görsellerinizi ekleyin
2. Dosya adları: `urun1.jpg`, `urun2.png` vs. gibi olabilir

### 2. Adım: Kod Tanımlama
1. `lib/data/product_data.dart` dosyasını açın
2. `bestSellers` listesini bulun (satır ~113)
3. İstediğiniz ürünleri ekleyin

### Örnek: Yeni Ürün Ekleme
```dart
static final List<Product> bestSellers = [
  Product(
    name: 'Çok Satan Perde 1',
    image: 'assets/bestsellers/urun1.jpg',  // YENİ KLASÖR!
    category: 'Black-Out Perde',
    productType: 'Fon Perdeler',
    size: '300',
    quality: 'Polyester',
    color: 'Beyaz',
    brand: 'By Halit',
    price: 1599,
  ),
  // Daha fazla ürün ekleyebilirsiniz...
];
```

### Örnek: Ürün Çıkarma
Listeden istediğiniz ürünü silmeniz yeterli.

### Örnek: Ürün Sırasını Değiştirme
Listedeki ürünlerin yerini değiştirin - carousel'da da o sırayla görünecek.

## 🔄 Tüm Ürünler (`allProducts`)

Sistem otomatik olarak `homepageProducts + bestSellers` birleştirip `allProducts` listesini oluşturur. Siz sadece iki ana listeyi yönetmeniz yeterli.

## 💡 İpuçları

- **Çok satanları sık güncelleyin**: Sezonluk veya kampanya ürünlerini öne çıkarın
- **Görsel uyumu**: Carousel'da görünecek ürünlerin resimlerinin kaliteli olduğundan emin olun
- **Ürün sayısı**: Çok satanlarda 10-30 arası ürün optimal carousel deneyimi sağlar
- **Kategorik denge**: Farklı kategorilerden ürünler ekleyerek çeşitlilik sağlayın

## 🎨 Görünüm

- **Anasayfa**: Grid layout'ta ürün kartları
- **Çok Satanlar**: Yatay scroll carousel, otomatik kaydırma
- **Responsive**: Hem mobil hem masaüstü uyumlu

Bu sistem sayesinde çok satanlarınızı anasayfadan bağımsız olarak kolayca yönetebilir, müşterilerinize özel deneyim sunabilirsiniz.
