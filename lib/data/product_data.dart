import '../models/product.dart';

class ProductData {
  // Filter options
  static const List<String> categories = [
    'Black-Out Perde',
    'Hazır Perde',
    'Çocuk Odası Perdeleri',
    'Taç Collection Serisi',
  ];

  static const List<String> productTypes = [
    'Astar',
    'Tül Perde',
    'Fon Hazır Perdeler',
    'Fon Perdeler',
    'Güneşlikler',
    'Hazır Stor Perde',
    'Tül Hazır Perdeler',
    'Tül Perdeler',
  ];

  static const List<String> sizes = [
    '280', '288', '290', "2'li Set", '300', '305', '310', '320', 'STANDART', 'Tek Kanat', 'Tekli'
  ];

  static const List<String> qualities = ['Polyester'];

  static const List<String> colors = [
    'Antrasit', 'Bakır', 'Bej', 'Beyaz', 'Çok Renkli', 'Ekru', 'Füme', 'Gri', 'Kahve',
    'Kahverengi', 'Keten', 'Krem', 'Lacivert', 'Mavi', 'Pembe', 'Petrol', 'Siyah', 'Taba', 'Yeşil'
  ];

  static const List<String> brands = [
    'Taç', 'Taç Boutique', 'Taç Collection', 'Taç Lisanslı', 'Taç Ortak'
  ];

  // Sample product data
  static final List<Product> allProducts = [
    Product(
      name: 'Black-Out Perde 280',
      image: 'assets/products/perde1.png',
      category: 'Black-Out Perde',
      productType: 'Fon Perdeler',
      size: '280',
      quality: 'Polyester',
      color: 'Gri',
      brand: 'Taç',
      price: 899,
    ),
    Product(
      name: 'Hazır Stor Perde',
      image: 'assets/products/perde2.png',
      category: 'Hazır Perde',
      productType: 'Hazır Stor Perde',
      size: 'STANDART',
      quality: 'Polyester',
      color: 'Beyaz',
      brand: 'Taç Boutique',
      price: 549,
    ),
    Product(
      name: 'Çocuk Odası Tül',
      image: 'assets/products/perde3.png',
      category: 'Çocuk Odası Perdeleri',
      productType: 'Tül Perdeler',
      size: '300',
      quality: 'Polyester',
      color: 'Çok Renkli',
      brand: 'Taç Lisanslı',
      price: 749,
    ),
    Product(
      name: 'Fon Hazır Perde 305',
      image: 'assets/products/perde1.png',
      category: 'Hazır Perde',
      productType: 'Fon Hazır Perdeler',
      size: '305',
      quality: 'Polyester',
      color: 'Antrasit',
      brand: 'Taç Collection',
      price: 1199,
    ),
    Product(
      name: 'Tül Hazır Perde 290',
      image: 'assets/products/perde2.png',
      category: 'Hazır Perde',
      productType: 'Tül Hazır Perdeler',
      size: '290',
      quality: 'Polyester',
      color: 'Ekru',
      brand: 'Taç',
      price: 659,
    ),
    Product(
      name: 'Güneşlik 320',
      image: 'assets/products/perde3.png',
      category: 'Taç Collection Serisi',
      productType: 'Güneşlikler',
      size: '320',
      quality: 'Polyester',
      color: 'Krem',
      brand: 'Taç Collection',
      price: 999,
    ),
  ];
}