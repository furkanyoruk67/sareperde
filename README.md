# Sare Perde - Flutter Shopping App

A modern Flutter shopping app for curtain products with a complete cart system.

## Features

### Cart System
- **Add to Cart**: Tap "Add to Cart" button on any product to add it to your cart
- **Quantity Management**: If an item is already in cart, quantity increases automatically
- **Cart Page**: View all cart items with quantity controls and remove functionality
- **Total Price**: Real-time calculation of total cart value
- **Cart Confirmation**: Complete checkout process with order confirmation

### Product Management
- **Product Catalog**: Browse through various curtain products
- **Filtering**: Filter products by category, type, size, quality, color, and brand
- **Favorites**: Add products to favorites list
- **Product Details**: View detailed product information in modal

### State Management
- **Provider Pattern**: Clean state management using Provider package
- **Cart Provider**: Centralized cart state management
- **Real-time Updates**: UI updates automatically when cart changes

## Project Structure

```
lib/
├── constants/
│   └── app_colors.dart          # App color constants
├── data/
│   └── product_data.dart        # Product data and filter options
├── models/
│   ├── product.dart             # Product model
│   └── cart_item.dart          # Cart item model with quantity
├── providers/
│   └── cart_provider.dart      # Cart state management
├── pages/
│   ├── catalog_page.dart        # Main product catalog
│   ├── cart_page.dart          # Cart management page
│   └── favorites_page.dart     # Favorites page
├── widgets/
│   ├── product_card.dart        # Product display card
│   ├── product_modal.dart      # Product detail modal
│   ├── filter_panel.dart       # Product filtering
│   └── pagination_controls.dart
└── main.dart                   # App entry point
```

## Cart System Implementation

### CartItem Model
- Represents items in cart with product and quantity
- Includes total price calculation
- Supports quantity updates

### CartProvider
- Manages cart state using ChangeNotifier
- Methods for adding, removing, and updating cart items
- Provides cart statistics (item count, total price)
- Handles duplicate items by increasing quantity

### CartPage
- Displays all cart items with product details
- Quantity controls with +/- buttons
- Remove item functionality
- Total price display
- Checkout confirmation dialog

### Integration
- Product cards show cart status (in cart/not in cart)
- Floating action button shows cart item count
- Snackbar notifications for cart actions
- Modal integration for product details

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `provider: ^6.1.1` - State management
- `flutter` - UI framework
- `cupertino_icons: ^1.0.8` - Icons

## Usage

1. **Browse Products**: Navigate through the product catalog
2. **Add to Cart**: Tap "Add to Cart" on any product
3. **View Cart**: Tap the floating cart button to see your cart
4. **Manage Cart**: Adjust quantities or remove items
5. **Checkout**: Tap "Sepeti Onayla" to complete your order
