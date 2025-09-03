import 'package:flutter/material.dart';

/// Onboarding Screen with app introduction
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to Krushak',
      subtitle: 'Your Digital Farming Companion',
      description:
          'Empowering Indian farmers with AI-powered insights, sustainable practices, and market access.',
      imagePath: 'assets/images/onboarding_1.png',
      backgroundColor: const Color(0xFF1E523A),
    ),
    OnboardingPage(
      title: 'Smart Farming',
      subtitle: 'AI-Powered Crop Analysis',
      description:
          'Get instant crop health diagnosis, soil analysis, and personalized farming recommendations.',
      imagePath: 'assets/images/onboarding_2.png',
      backgroundColor: const Color(0xFF35906A),
    ),
    OnboardingPage(
      title: 'Sustainable Practices',
      subtitle: 'Earn Carbon Credits',
      description:
          'Log your sustainable farming practices and earn carbon credits while helping the environment.',
      imagePath: 'assets/images/onboarding_3.png',
      backgroundColor: const Color(0xFF40B0B0),
    ),
    OnboardingPage(
      title: 'Market Connect',
      subtitle: 'Direct Sales & Fair Prices',
      description:
          'Connect directly with buyers, get real-time market prices, and maximize your income.',
      imagePath: 'assets/images/onboarding_4.png',
      backgroundColor: const Color(0xFF35906A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [page.backgroundColor, page.backgroundColor.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              // Image placeholder
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(125),
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                page.subtitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                page.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 140,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentPage == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                _currentPage == index ? 1.0 : 0.4,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      bottom: 48,
      left: 24,
      right: 24,
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage > 0 ? 2 : 3,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // Navigate to sign in
                  Navigator.pushReplacementNamed(context, '/sign-in');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _pages[_currentPage].backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
  });
}
