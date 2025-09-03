import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/simple_theme.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'shared/presentation/widgets/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const KrushakApp());
}

/// Main Krushak Application Widget
class KrushakApp extends StatelessWidget {
  const KrushakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krushak - FarmerOS',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,

      // Initial screen
      home: const SplashScreen(),

      // Routes
      routes: {'/main': (context) => const MainNavigation()},

      // Builder for global configuration
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
