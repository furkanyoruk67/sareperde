import '../models/product.dart';

class ProductData {
  // Filter options
  static const List<String> categories = [
    'Tül',
    'Stor',
    'Jaluzi',
    'Fon Perde',
    'Aksesuar',
  ];

  static const List<String> productTypes = [
    'Tül',
    'Stor'
    'Fon Perdeler',
    'Güneşlikler',
    'Stor Perde',
    'Jaluzi',
  ];

  static const List<String> sizes = [
    '280', '288', '290', "2'li Set", '300', '305', '310', '320', 'STANDART', 'Tek Kanat', 'Tekli'
  ];

  static const List<String> qualities = ['Polyester', 'Keten'];

  static const List<String> colors = [
    'Antrasit', 'Bakır', 'Bej', 'Beyaz', 'Çok Renkli', 'Ekru', 'Füme', 'Gri', 'Kahve',
    'Kahverengi', 'Keten', 'Krem', 'Lacivert', 'Mavi', 'Pembe', 'Petrol', 'Siyah', 'Taba', 'Yeşil'
  ];

  static const List<String> brands = [
    'Nevada', 'By Halit Collection'
  ];

  // ===========================================
  // ANASayfa ÜRÜN LİSTESİ
  // ===========================================
  // Bu liste anasayfada (ana katalog) gösterilecek ürünleri içerir
  // Çok satanlar buraya dahil DEĞİLDİR
  static final List<Product> homepageProducts = [
   
    // Anasayfa ürünleri burada biter
    // By Halit ürünleri çok satanlar bölümünde yer alacak
    
    // Extracted Pages katalog ürünleri otomatik olarak ekleniyor
    ...extractedPagesProducts,
  ];

  // ===========================================
  // EXTRACTED PAGES KATALOG ÜRÜNLERİ
  // ===========================================
  // Bu ürünler otomatik olarak assets/extracted_pages klasöründen oluşturulur
  // SADECE anasayfada görünür, çok satanlarda GÖZÜKMEZLİR
  static List<Product> get extractedPagesProducts {
    List<Product> products = [];
    
    // ByHalitCollection2022sweb klasörü (70 ürün)
    for (int i = 1; i <= 70; i++) {
      products.add(Product(
        name: 'By Halit Collection 2022 - Sayfa ${i.toString().padLeft(3, '0')}',
        image: 'assets/extracted_pages/ByHalitCollection2022sweb/sayfa_${i.toString().padLeft(3, '0')}.png',
        category: 'By Halit Collection',
      productType: 'Fon Perdeler',
        size: 'Çoklu Ebat',
        quality: 'Premium Polyester',
      color: 'Çok Renkli',
        brand: 'By Halit',
        price: 1200 + (i * 50), // 1250-4700 arası fiyat aralığı
      ));
    }
    
    // ByHalitCollectionAksesuarKatalog klasörü (78 ürün)
    for (int i = 1; i <= 78; i++) {
      products.add(Product(
        name: 'By Halit Aksesuar Koleksiyonu - Sayfa ${i.toString().padLeft(3, '0')}',
        image: 'assets/extracted_pages/ByHalitCollectionAksesuarKatalog/sayfa_${i.toString().padLeft(3, '0')}.png',
        category: 'Aksesuar',
        productType: 'Aksesuar',
        size: 'Standart',
        quality: 'Premium',
        color: 'Çeşitli',
      brand: 'By Halit',
        price: 299 + (i * 25), // 324-2249 arası fiyat aralığı
      ));
    }
    
    // Stor_Katalogu klasörü (31 ürün)
    for (int i = 1; i <= 31; i++) {
      products.add(Product(
        name: 'Stor Katalogu - Sayfa ${i.toString().padLeft(3, '0')}',
        image: 'assets/extracted_pages/Stor_Katalogu/sayfa_${i.toString().padLeft(3, '0')}.png',
        category: 'Stor',
        productType: 'Stor Perde',
        size: 'Çoklu Ebat',
        quality: 'Premium',
        color: 'Çeşitli',
        brand: 'Stor Koleksiyonu',
        price: 800 + (i * 30), // 830-1730 arası fiyat aralığı
      ));
    }
    
    // Guzzi_Brosur klasörü (23 ürün)
    for (int i = 1; i <= 23; i++) {
      products.add(Product(
        name: 'Guzzi Brosür - Sayfa ${i.toString().padLeft(3, '0')}',
        image: 'assets/extracted_pages/Guzzi_Brosur/sayfa_${i.toString().padLeft(3, '0')}.png',
        category: 'Fon Perde',
        productType: 'Fon Perdeler',
        size: 'Çoklu Ebat',
        quality: 'Premium Polyester',
        color: 'Çeşitli',
        brand: 'Guzzi',
        price: 950 + (i * 40), // 990-1870 arası fiyat aralığı
      ));
    }
    
    // Basic_Collection klasörü (52 ürün)
    for (int i = 1; i <= 52; i++) {
      products.add(Product(
        name: 'Basic Collection - Sayfa ${i.toString().padLeft(3, '0')}',
        image: 'assets/extracted_pages/Basic_Collection/sayfa_${i.toString().padLeft(3, '0')}.png',
        category: 'Tül',
        productType: 'Tül',
        size: 'Çoklu Ebat',
        quality: 'Polyester',
        color: 'Çeşitli',
        brand: 'Basic Collection',
        price: 600 + (i * 20), // 620-1640 arası fiyat aralığı
      ));
    }
    
    return products;
  }

  // ===========================================
  // ÇOK SATANLAR LİSTESİ
  // ===========================================
  // Bu liste "Çok Satanlar" carousel'ında gösterilecek ürünleri içerir
  // İstediğiniz zaman bu listeyi değiştirerek çok satanları güncelleyebilirsiniz
  // Anasayfa ürünlerinden AYRIDIR
  // 
  // NOT: assets/bestsellers/ klasörüne görsel ekledikten sonra buraya ürünleri tanımlayın
  // Örnek kullanım:
  // Product(
  //   name: 'Çok Satan Ürün 1',
  //   image: 'assets/bestsellers/urun1.jpg',
  //   category: 'Black-Out Perde',
  //   productType: 'Fon Perdeler',
  //   size: '280',
  //   quality: 'Polyester',
  //   color: 'Gri',
  //   brand: 'By Halit',
  //   price: 1299,
  // ),
  static final List<Product> bestSellers = [
    Product(
      name: 'Çok Satan Black-Out Perde 1',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 203134.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Gri',
      brand: 'By Halit',
      price: 1299,
    ),
    Product(
      name: 'Çok Satan Tül Perde 1',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 203116.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Beyaz',
      brand: 'Basic Collection',
      price: 899,
    ),
    Product(
      name: 'Çok Satan Stor Perde 1',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 203105.png',
      category: 'Stor',
      productType: 'Stor Perde',
      size: '280',
      quality: 'Premium',
      color: 'Bej',
      brand: 'Stor Koleksiyonu',
      price: 1450,
    ),
    Product(
      name: 'Çok Satan Fon Perde 1',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202927.png',
      category: 'Fon Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Mavi',
      brand: 'Guzzi',
      price: 1650,
    ),
    Product(
      name: 'Çok Satan Aksesuar 1',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202916.png',
      category: 'Aksesuar',
      productType: 'Aksesuar',
      size: 'Standart',
      quality: 'Premium',
      color: 'Çeşitli',
      brand: 'By Halit',
      price: 450,
    ),
    Product(
      name: 'Çok Satan Black-Out Perde 2',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202906.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Siyah',
      brand: 'By Halit',
      price: 1399,
    ),
    Product(
      name: 'Çok Satan Tül Perde 2',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202857.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Krem',
      brand: 'Basic Collection',
      price: 799,
    ),
    Product(
      name: 'Çok Satan Stor Perde 2',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202848.png',
      category: 'Stor',
      productType: 'Stor Perde',
      size: '280',
      quality: 'Premium',
      color: 'Gri',
      brand: 'Stor Koleksiyonu',
      price: 1550,
    ),
    Product(
      name: 'Çok Satan Fon Perde 2',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202841.png',
      category: 'Fon Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Yeşil',
      brand: 'Guzzi',
      price: 1750,
    ),
    Product(
      name: 'Çok Satan Aksesuar 2',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202832.png',
      category: 'Aksesuar',
      productType: 'Aksesuar',
      size: 'Standart',
      quality: 'Premium',
      color: 'Çeşitli',
      brand: 'By Halit',
      price: 550,
    ),
    Product(
      name: 'Çok Satan Black-Out Perde 3',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202754.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Kahverengi',
      brand: 'By Halit',
      price: 1499,
    ),
    Product(
      name: 'Çok Satan Tül Perde 3',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202747.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Açık Mavi',
      brand: 'Basic Collection',
      price: 849,
    ),
    Product(
      name: 'Çok Satan Stor Perde 3',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202738.png',
      category: 'Stor',
      productType: 'Stor Perde',
      size: '280',
      quality: 'Premium',
      color: 'Beyaz',
      brand: 'Stor Koleksiyonu',
      price: 1650,
    ),
    Product(
      name: 'Çok Satan Fon Perde 3',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202729.png',
      category: 'Fon Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Kırmızı',
      brand: 'Guzzi',
      price: 1850,
    ),
    Product(
      name: 'Çok Satan Aksesuar 3',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202721.png',
      category: 'Aksesuar',
      productType: 'Aksesuar',
      size: 'Standart',
      quality: 'Premium',
      color: 'Çeşitli',
      brand: 'By Halit',
      price: 650,
    ),
    Product(
      name: 'Çok Satan Black-Out Perde 4',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202704.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Lacivert',
      brand: 'By Halit',
      price: 1599,
    ),
    Product(
      name: 'Çok Satan Tül Perde 4',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202654.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Pembe',
      brand: 'Basic Collection',
      price: 899,
    ),
    Product(
      name: 'Çok Satan Stor Perde 4',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202645.png',
      category: 'Stor',
      productType: 'Stor Perde',
      size: '280',
      quality: 'Premium',
      color: 'Kahverengi',
      brand: 'Stor Koleksiyonu',
      price: 1750,
    ),
    Product(
      name: 'Çok Satan Fon Perde 4',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202635.png',
      category: 'Fon Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Turuncu',
      brand: 'Guzzi',
      price: 1950,
    ),
    Product(
      name: 'Çok Satan Aksesuar 4',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202627.png',
      category: 'Aksesuar',
      productType: 'Aksesuar',
      size: 'Standart',
      quality: 'Premium',
      color: 'Çeşitli',
      brand: 'By Halit',
      price: 750,
    ),
    Product(
      name: 'Çok Satan Black-Out Perde 5',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202618.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Bordo',
      brand: 'By Halit',
      price: 1699,
    ),
    Product(
      name: 'Çok Satan Tül Perde 5',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202608.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Mor',
      brand: 'Basic Collection',
      price: 949,
    ),
    Product(
      name: 'Çok Satan Stor Perde 5',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202559.png',
      category: 'Stor',
      productType: 'Stor Perde',
      size: '280',
      quality: 'Premium',
      color: 'Lacivert',
      brand: 'Stor Koleksiyonu',
      price: 1850,
    ),
    Product(
      name: 'Çok Satan Fon Perde 5',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202353.png',
      category: 'Fon Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Sarı',
      brand: 'Guzzi',
      price: 2050,
    ),
    Product(
      name: 'Çok Satan Aksesuar 5',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202344.png',
      category: 'Aksesuar',
      productType: 'Aksesuar',
      size: 'Standart',
      quality: 'Premium',
      color: 'Çeşitli',
      brand: 'By Halit',
      price: 850,
    ),
    Product(
      name: 'Çok Satan Black-Out Perde 6',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202335.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Yeşil',
      brand: 'By Halit',
      price: 1799,
    ),
    Product(
      name: 'Çok Satan Tül Perde 6',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202323.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Turkuaz',
      brand: 'Basic Collection',
      price: 999,
    ),
    Product(
      name: 'Çok Satan Stor Perde 6',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202313.png',
      category: 'Stor',
      productType: 'Stor Perde',
      size: '280',
      quality: 'Premium',
      color: 'Bordo',
      brand: 'Stor Koleksiyonu',
      price: 1950,
    ),
    Product(
      name: 'Çok Satan Fon Perde 6',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 202302.png',
      category: 'Fon Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Pembe',
      brand: 'Guzzi',
      price: 2150,
    ),
    Product(
      name: 'Çok Satan Aksesuar 6',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 184320.png',
      category: 'Aksesuar',
      productType: 'Aksesuar',
      size: 'Standart',
      quality: 'Premium',
      color: 'Çeşitli',
      brand: 'By Halit',
      price: 950,
    ),
    Product(
      name: 'Çok Satan Black-Out Perde 7',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 183059.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Premium Polyester',
      color: 'Altın',
      brand: 'By Halit',
      price: 1899,
    ),
    Product(
      name: 'Çok Satan Tül Perde 7',
      image: 'assets/bestsellers/Ekran görüntüsü 2025-08-12 182858.png',
      category: 'Tül',
      productType: 'Tül',
      size: '280',
      quality: 'Polyester',
      color: 'Altın',
      brand: 'Basic Collection',
      price: 1049,
    ),
  ];

  // ===========================================
  // TÜM ÜRÜNLER LİSTESİ
  // ===========================================
  // Bu liste anasayfa + çok satanlar olmak üzere TÜM ürünleri içerir
  // Arama ve filtreleme işlemlerinde kullanılır
  static List<Product> get allProducts => [
    ...homepageProducts,
    ...bestSellers,
  ];
}