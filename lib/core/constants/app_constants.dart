abstract final class AppConstants {
  // --- App Info ---
  static const String appName = 'Where Am I?';
  static const String appVersion = '1.0.0';

  // --- Interpol API ---
  static const String interpolBaseUrl = 'https://ws-public.interpol.int/notices/v1';
  static const String interpolYellowPath = '/yellow';
  static const String interpolRedPath = '/red';
  static const int interpolPageSize = 20;
  static const int interpolMaxRetries = 3;

  // --- Firebase Collections ---
  static const String casesCollection = 'cases';
  static const String usersCollection = 'users';
  static const String reportsCollection = 'reports';

  // --- Firebase Storage ---
  static const String casePhotosPath = 'case_photos';

  // --- Supported Nationalities (for Interpol filter) ---
  static const List<String> defaultNationalities = ['BR', 'PT', 'AO', 'MZ', 'CV'];

  // --- Filter Defaults ---
  static const int minAge = 0;
  static const int maxAge = 100;

  // --- SOS ---
  static const String emergencyNumber = 'tel:112';
  static const String sosWhatsappUrl = 'https://wa.me/';

  // --- Pagination ---
  static const int pageSize = 20;

  // --- Cache ---
  static const Duration cacheExpiry = Duration(minutes: 15);

  // --- Animation Durations ---
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 280);
  static const Duration animSlow = Duration(milliseconds: 450);
  static const Duration animVerySlow = Duration(milliseconds: 700);
}
