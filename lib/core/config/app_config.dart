import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase Configuration and Helper
class SupabaseConfig {
  SupabaseConfig._();

  static late final Supabase _instance;
  static SupabaseClient get client => _instance.client;

  /// Initialize Supabase with environment variables
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Supabase URL and Anon Key must be provided in .env file',
      );
    }

    _instance = await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: dotenv.env['DEBUG_MODE'] == 'true',
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
        eventsPerSecond: 10,
      ),
      storageOptions: const StorageClientOptions(retryAttempts: 3),
      postgrestOptions: const PostgrestClientOptions(schema: 'public'),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );
  }

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  /// Sign out user
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}

/// Database table names constants
class DbTables {
  DbTables._();

  // Core User Tables
  static const String profiles = 'profiles';
  static const String userSettings = 'user_settings';
  static const String kycDocuments = 'kyc_documents';
  static const String mrCredentials = 'mr_credentials';

  // Farm Tables
  static const String crops = 'crops';
  static const String farms = 'farms';
  static const String farmDiagnoses = 'farm_diagnoses';

  // Sustainability Tables
  static const String sustainablePractices = 'sustainable_practices';
  static const String carbonCredits = 'carbon_credits';
  static const String creditTransactions = 'credit_transactions';

  // Weather & Irrigation Tables
  static const String weatherForecasts = 'weather_forecasts';
  static const String irrigationRecommendations = 'irrigation_recommendations';
  static const String iotSensorData = 'iot_sensor_data';
  static const String systemAlerts = 'system_alerts';

  // Market Tables
  static const String produceListings = 'produce_listings';
  static const String marketDataPoints = 'market_data_points';
  static const String tradeInquiries = 'trade_inquiries';
  static const String tradeContracts = 'trade_contracts';

  // Finance Tables
  static const String loanApplications = 'loan_applications';
  static const String loans = 'loans';
  static const String insurancePolicies = 'insurance_policies';
  static const String insuranceClaims = 'insurance_claims';

  // FPO Tables
  static const String fpos = 'fpos';
  static const String fpoMembers = 'fpo_members';
  static const String fpoChats = 'fpo_chats';
  static const String fpoForumPosts = 'fpo_forum_posts';
  static const String fpoForumComments = 'fpo_forum_comments';

  // Learning Tables
  static const String learningModules = 'learning_modules';
  static const String userLearningProgress = 'user_learning_progress';
  static const String badges = 'badges';
  static const String userBadges = 'user_badges';
  static const String userGamificationStats = 'user_gamification_stats';

  // Communication Tables
  static const String pushNotifications = 'push_notifications';
  static const String userActivityLogs = 'user_activity_logs';
  static const String appAnalytics = 'app_analytics';
}

/// Storage bucket names
class StorageBuckets {
  StorageBuckets._();

  static const String profilePics = 'profile-pics';
  static const String kycDocuments = 'kyc-documents';
  static const String practiceProofs = 'practice-proofs';
  static const String diagnosisImages = 'diagnosis-images';
  static const String producePhotos = 'produce-photos';
  static const String learningContent = 'learning-content';
  static const String fpoFiles = 'fpo-files';
  static const String insuranceDocuments = 'insurance-documents';
}

/// Realtime channel names
class RealtimeChannels {
  RealtimeChannels._();

  static const String fpoChats = 'fpo_chats_channel';
  static const String notifications = 'notifications_channel';
  static const String systemAlerts = 'alerts_channel';
  static const String tradeInquiries = 'trade_inquiries_channel';
  static const String iotSensorData = 'iot_data_channel';
}

/// API Endpoints and external services
class ApiEndpoints {
  ApiEndpoints._();

  // External APIs
  static String get openWeatherBaseUrl =>
      'https://api.openweathermap.org/data/2.5';
  static String get openWeatherApiKey =>
      dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Supabase Edge Functions
  static String get edgeFunctionsBaseUrl =>
      '${dotenv.env['SUPABASE_URL']}/functions/v1';

  static const String aiDiagnosisHandler = 'ai-diagnosis-handler';
  static const String weatherUpdater = 'weather-updater';
  static const String irrigationAdvisor = 'irrigation-advisor';
  static const String carbonCreditCalculator = 'carbon-credit-calculator';
  static const String loanEligibilityScorer = 'loan-eligibility-scorer';
  static const String parametricInsuranceTrigger =
      'parametric-insurance-trigger';
  static const String marketDataUpdater = 'market-data-updater';
  static const String geminiVoiceHandler = 'gemini-voice-handler';
  static const String notificationSender = 'notification-sender';
  static const String tradeContractManager = 'trade-contract-manager';
}

/// App-level configuration constants
class AppConfig {
  AppConfig._();

  static String get appName => 'Krushak';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get isDebugMode => dotenv.env['DEBUG_MODE'] == 'true';
  static String get environment => dotenv.env['APP_ENV'] ?? 'development';

  // Feature flags
  static bool get enableVoiceFeatures => true;
  static bool get enableOfflineMode => true;
  static bool get enableAnalytics => environment != 'development';
  static bool get enableCrashlytics => environment != 'development';

  // Pagination and limits
  static const int defaultPageSize = 20;
  static const int maxFileUploadSizeMB = 10;
  static const int maxImageUploadSizeMB = 5;
  static const int maxVideoUploadSizeMB = 50;

  // Cache settings
  static const Duration cacheTimeout = Duration(hours: 1);
  static const Duration weatherCacheTimeout = Duration(minutes: 30);
  static const Duration marketDataCacheTimeout = Duration(minutes: 15);

  // Animation settings
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 3);

  // Voice settings
  static const Duration voiceRecordingTimeout = Duration(seconds: 30);
  static const Duration voicePlaybackTimeout = Duration(seconds: 60);

  // Background sync settings
  static const Duration backgroundSyncInterval = Duration(minutes: 15);
  static const Duration offlineDataRetentionDays = Duration(days: 7);
}

/// Error messages and codes
class ErrorCodes {
  ErrorCodes._();

  // Authentication errors
  static const String authRequired = 'AUTH_REQUIRED';
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountNotVerified = 'ACCOUNT_NOT_VERIFIED';

  // Network errors
  static const String noInternet = 'NO_INTERNET';
  static const String serverError = 'SERVER_ERROR';
  static const String timeout = 'TIMEOUT';

  // Data errors
  static const String dataNotFound = 'DATA_NOT_FOUND';
  static const String invalidData = 'INVALID_DATA';
  static const String duplicateData = 'DUPLICATE_DATA';

  // File upload errors
  static const String fileTooLarge = 'FILE_TOO_LARGE';
  static const String invalidFileType = 'INVALID_FILE_TYPE';
  static const String uploadFailed = 'UPLOAD_FAILED';

  // Permission errors
  static const String permissionDenied = 'PERMISSION_DENIED';
  static const String locationPermissionDenied = 'LOCATION_PERMISSION_DENIED';
  static const String cameraPermissionDenied = 'CAMERA_PERMISSION_DENIED';
  static const String microphonePermissionDenied =
      'MICROPHONE_PERMISSION_DENIED';

  // Feature-specific errors
  static const String voiceRecognitionFailed = 'VOICE_RECOGNITION_FAILED';
  static const String aiAnalysisFailed = 'AI_ANALYSIS_FAILED';
  static const String weatherDataUnavailable = 'WEATHER_DATA_UNAVAILABLE';
  static const String marketDataUnavailable = 'MARKET_DATA_UNAVAILABLE';
}

/// Success messages
class SuccessMessages {
  SuccessMessages._();

  static const String loginSuccess = 'Successfully logged in';
  static const String registrationSuccess = 'Account created successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String farmAdded = 'Farm added successfully';
  static const String practiceLogged =
      'Sustainable practice logged successfully';
  static const String tradeInquirySent = 'Trade inquiry sent successfully';
  static const String kycDocumentUploaded =
      'KYC document uploaded successfully';
  static const String moduleCompleted =
      'Learning module completed successfully';
  static const String badgeEarned = 'Congratulations! You earned a new badge';
}

/// Route names for navigation
class RouteNames {
  RouteNames._();

  // Authentication routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String verifyOtp = '/verify-otp';

  // Main app routes
  static const String home = '/home';
  static const String market = '/market';
  static const String learn = '/learn';
  static const String community = '/community';
  static const String account = '/account';

  // Feature routes
  static const String farmDetails = '/farm-details';
  static const String cropDiagnosis = '/crop-diagnosis';
  static const String diagnosisResults = '/diagnosis-results';
  static const String sustainablePractices = '/sustainable-practices';
  static const String carbonCredits = '/carbon-credits';
  static const String weatherForecast = '/weather-forecast';
  static const String irrigationAdvice = '/irrigation-advice';
  static const String produceListings = '/produce-listings';
  static const String mandiPrices = '/mandi-prices';
  static const String tradeDetails = '/trade-details';
  static const String loanApplication = '/loan-application';
  static const String insurancePolicies = '/insurance-policies';
  static const String fpoDetails = '/fpo-details';
  static const String fpoChat = '/fpo-chat';
  static const String learningModule = '/learning-module';
  static const String badgesAndAchievements = '/badges-achievements';
  static const String settings = '/settings';
  static const String kycDocuments = '/kyc-documents';
  static const String voiceAssistant = '/voice-assistant';
}

/// Notification types
class NotificationTypes {
  NotificationTypes._();

  static const String weatherAlert = 'weather_alert';
  static const String priceUpdate = 'price_update';
  static const String tradeInquiry = 'trade_inquiry';
  static const String learningReminder = 'learning_reminder';
  static const String systemUpdate = 'system_update';
  static const String communityMessage = 'community_message';
  static const String loanReminder = 'loan_reminder';
  static const String insuranceClaim = 'insurance_claim';
  static const String carbonCreditEarned = 'carbon_credit_earned';
  static const String badgeEarned = 'badge_earned';
}

/// Default values and configurations
class DefaultValues {
  DefaultValues._();

  static const String defaultLanguage = 'en';
  static const String defaultCurrency = 'INR';
  static const String defaultCountry = 'IN';

  // Default farm values
  static const double defaultFarmAreaAcres = 1.0;
  static const String defaultSoilType = 'loam';
  static const String defaultIrrigationType = 'rainfed';

  // Default financial values
  static const double minLoanAmount = 10000.0;
  static const double maxLoanAmount = 1000000.0;
  static const double defaultInterestRate = 8.5;

  // Default UI values
  static const int defaultGridCrossAxisCount = 2;
  static const double defaultListItemHeight = 80.0;
  static const double defaultCardElevation = 2.0;

  // Default permissions
  static const List<String> requiredPermissions = [
    'camera',
    'microphone',
    'location',
    'storage',
    'notification',
  ];
}
