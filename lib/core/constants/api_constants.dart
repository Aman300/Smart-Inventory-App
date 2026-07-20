class ApiConstants {
  // Default host configuration
  // Use '10.0.2.2' for default Android Emulator to access localhost
  // Use '72.60.97.186' or 'localhost' for iOS simulator or desktop builds
  static String _host = '72.60.97.186';
  static const int port = 5001;

  static String get host => _host;

  static set host(String newHost) {
    _host = newHost;
  }

  static String get baseUrl => 'http://$host:$port/api';
  static String get uploadsUrl => 'http://$host:$port';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';

  // Product endpoints
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';
}
