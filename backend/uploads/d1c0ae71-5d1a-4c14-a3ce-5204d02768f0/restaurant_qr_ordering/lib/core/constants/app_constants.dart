/// App-wide constants: collection names, routes, restaurant info.
class AppConstants {
  AppConstants._();

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String tablesCollection = 'tables';
  static const String menuCollection = 'menu';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String offersCollection = 'offers';

  // Restaurant info (could be moved to a `settings` doc in Firestore)
  static const String restaurantName = 'The Fork & Flame';
  static const String restaurantAddress = '221B Baker Street, Food City';
  static const String restaurantTagline = 'Fresh. Fast. Flavorful.';

  // Deep link / QR scheme: restaurant://menu?table=1
  static const String qrScheme = 'restaurant';
  static const String qrHost = 'menu';

  // Number of physical tables
  static const int totalTables = 4;

  // Shared preferences keys
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefFavorites = 'pref_favorites';
  static const String prefCustomerId = 'pref_customer_id';
}
