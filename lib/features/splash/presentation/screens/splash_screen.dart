import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/main_navigation_screen.dart';

/// Splash Screen with app initialization
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNextScreen();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _textController.forward();
    });
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              KrushakColors.primaryGreen,
              KrushakColors.secondaryGreen,
              KrushakColors.accentTeal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Spacer to center content
              const Spacer(flex: 2),

              // Logo and App Name Section
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: _logoScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: KrushakColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.agriculture,
                              size: 60,
                              color: KrushakColors.primaryGreen,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: KrushakSpacing.xl),

                    // Animated App Name and Tagline
                    AnimatedBuilder(
                      animation: _textOpacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textOpacityAnimation.value,
                          child: Column(
                            children: [
                              // App Name
                              Text(
                                'Krushak',
                                style: KrushakTextStyles.h1.copyWith(
                                  color: KrushakColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              ),

                              // Sanskrit Name
                              Text(
                                'कृषक',
                                style: KrushakTextStyles.h3.copyWith(
                                  color: KrushakColors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),

                              const SizedBox(height: KrushakSpacing.md),

                              // Tagline
                              Text(
                                'The Farmer Operating System',
                                style: KrushakTextStyles.bodyLarge.copyWith(
                                  color: KrushakColors.white.withOpacity(0.8),
                                  letterSpacing: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: KrushakSpacing.sm),

                              // Subtitle
                              Text(
                                'Empowering Indian Agriculture',
                                style: KrushakTextStyles.bodyMedium.copyWith(
                                  color: KrushakColors.white.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Loading indicator
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        KrushakColors.white,
                      ),
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: KrushakSpacing.md),
                    Text(
                      'Initializing...',
                      style: KrushakTextStyles.bodyMedium.copyWith(
                        color: KrushakColors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Version and attribution
              Padding(
                padding: const EdgeInsets.all(KrushakSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: KrushakTextStyles.caption.copyWith(
                        color: KrushakColors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: KrushakSpacing.xs),
                    Text(
                      'Built with ❤️ for Indian Farmers',
                      style: KrushakTextStyles.caption.copyWith(
                        color: KrushakColors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
