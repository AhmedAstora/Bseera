import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

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
      image: Image.asset('assets/images/prayer.png',),
      title: 'مواقيت الصلاة',
      description: 'تطبيق إنتاجي للمسلمين يجمع بين مواقيت الصلاة وإدارة المهام والملاحظات لتعزيز الحياة اليومية بالإيمان',
      color: AppTheme.primaryGreen,
    ),
    OnboardingPage(
      image: Image.asset('assets/images/Qur’an.png',),
      title: 'القرآن الكريم',
      description: 'اقرأ واستمع إلى القرآن الكريم مع تفسير وترجمة متعددة اللغات',
      color: AppTheme.primaryGreen,
    ),
    OnboardingPage(
      image: Image.asset('assets/images/Night_and_day.png'),
      title: 'الأذكار والأدعية',
      description: 'أذكار الصباح والمساء والتسبيح الإلكتروني لتعزيز ذكرك اليومي',
      color: AppTheme.primaryGreen,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.warmWhite, AppTheme.cream],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () => Get.offNamed('/login'),
                    child: Text(
                      'تخطي',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
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
              ),

              // Page Indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppTheme.primaryGreen,
                  dotColor: AppTheme.sand,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                  expansionFactor: 3,
                ),
              ),

              const SizedBox(height: 32),

              // Navigation Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('السابق'),
                        ),
                      )
                    else
                      const SizedBox(width: 100),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Get.offNamed('/login');
                          }
                        },
                        icon: Icon(
                          _currentPage < _pages.length - 1
                              ? Icons.arrow_forward
                              : Icons.check,
                        ),
                        label: Text(
                          _currentPage < _pages.length - 1 ? 'التالي' : 'ابدأ',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
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

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.1),
              border: Border.all(
                color: page.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: page.image,
          )
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(duration: 1200.ms),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: page.color,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.charcoal.withOpacity(0.7),
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final Widget image;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });
}
