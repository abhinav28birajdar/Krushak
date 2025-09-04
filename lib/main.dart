import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/simple_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/localization/language_provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/app_providers.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'core/navigation/main_navigation_screen.dart';
import 'features/auth/presentation/screens/signin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('Environment variables loaded successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error loading .env file: $e');
    }
    // Continue without .env file - will use default values
  }

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: KrushakApp()));
}

/// Main Krushak Application Widget with Real-time Features
class KrushakApp extends ConsumerWidget {
  const KrushakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Krushak - FarmerOS',
      debugShowCheckedModeBanner: false,

      // Dynamic theme based on user preference
      theme: AppTheme.lightTheme,
      themeMode: themeMode.themeMode == AppThemeMode.dark
          ? ThemeMode.dark
          : themeMode.themeMode == AppThemeMode.light
          ? ThemeMode.light
          : ThemeMode.system,

      // Localization support
      locale: Locale(_getLocaleCode(language.currentLanguage)),

      // Initial screen with authentication check
      home: _buildInitialScreen(appState, authState),

      // Routes
      routes: {
        '/main': (context) => const MainNavigationScreen(),
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const SignInScreen(),
      },

      // Global builder for real-time updates
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: _buildAppWrapper(context, ref, child),
        );
      },
    );
  }

  Widget _buildInitialScreen(AppState appState, UserState authState) {
    // Show loading screen during initialization
    if (appState.isLoading) {
      return const SplashScreen();
    }

    // Show error screen if initialization failed
    if (appState.error != null) {
      return _buildErrorScreen(appState.error!);
    }

    // Check authentication state only after initialization is complete
    if (authState.isLoading) {
      return const SplashScreen();
    }

    if (authState.error != null && !authState.isAuthenticated) {
      return const SignInScreen();
    }

    if (authState.isAuthenticated) {
      return const MainNavigationScreen();
    } else {
      return const SignInScreen();
    }
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Restart the app by reinitializing
                  _restartApp();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(fontSize: 14, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _restartApp() {
    // This would typically restart the app
    // For now, we'll just trigger a rebuild
  }

  Widget _buildAppWrapper(BuildContext context, WidgetRef ref, Widget? child) {
    return Consumer(
      builder: (context, ref, _) {
        final connectivity = ref.watch(connectivityProvider);

        return Stack(
          children: [
            child ?? const SizedBox.shrink(),

            // Connectivity indicator
            if (!connectivity)
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.red,
                  child: const Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Real-time notification overlay
            _buildNotificationOverlay(ref),
          ],
        );
      },
    );
  }

  Widget _buildNotificationOverlay(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        // Simple notification indicator without real-time providers for now
        return const SizedBox.shrink();
      },
    );
  }

  String _getLocaleCode(AppLanguage language) {
    switch (language) {
      case AppLanguage.hindi:
        return 'hi';
      case AppLanguage.marathi:
        return 'mr';
      case AppLanguage.english:
        return 'en';
    }
  }
}

/// Real-time App State Manager
class AppStateManager extends ConsumerWidget {
  final Widget child;

  const AppStateManager({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to authentication state changes
    ref.listen<UserState?>(authProvider, (previous, next) {
      if (previous?.isAuthenticated != next?.isAuthenticated) {
        // Handle authentication state change
        if (next?.isAuthenticated == true) {
          // User logged in - navigate to main screen
          Navigator.of(context).pushReplacementNamed('/main');
        } else {
          // User logged out - navigate to auth page
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      }
    });

    // Listen to app state errors
    ref.listen<String?>(appErrorProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear the error after showing
        ref.read(appStateProvider.notifier).clearError();
      }
    });

    // Listen to connectivity changes
    ref.listen<bool>(connectivityProvider, (previous, next) {
      if (previous == true && next == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection lost. Some features may not work.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (previous == false && next == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection restored.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return child;
  }
}
