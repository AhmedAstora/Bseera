import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 نقل المصفوفة إلى هنا لتقرأ الـ .tr بشكل ديناميكي متجدد عند تبديل اللغة
    final List<OnboardingPage> _pages = [
      OnboardingPage(
        image: Image.asset('assets/images/prayer.png'),
        title: 'prayer_times'.tr, // 🌟 مفتاح مواقيت الصلاة
        description: 'onboarding_desc_1'.tr, // 🌟 وصف الصفحة الأولى
        color: AppTheme.primaryGreen,
      ),
      OnboardingPage(
        image: Image.asset('assets/images/Qur’an.png'),
        title: 'quran_kareem'.tr, // 🌟 مفتاح القرآن الكريم
        description: 'onboarding_desc_2'.tr, // 🌟 وصف الصفحة الثانية
        color: AppTheme.primaryGreen,
      ),
      OnboardingPage(
        image: Image.asset('assets/images/Night_and_day.png'),
        title: 'azkar_prayers'.tr, // 🌟 مفتاح الأذكار والأدعية
        description: 'onboarding_desc_3'.tr, // 🌟 وصف الصفحة الثالثة
        color: AppTheme.primaryGreen,
      ),
    ];

    // فحص اتجاه اللغة الحالية (RTL للعربية و LTR للإنجليزية)
    final bool isRtl = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.goldLight, AppTheme.cream],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Skip Button
                Align(
                  // 🌟 جعل زر التخطي في اليمين للعربية وفي اليسار للإنجليزية تلقائياً
                  alignment: isRtl ? Alignment.topRight : Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () {
                        GetStorage().write('hasCompletedOnboarding', true);
                        Get.offAllNamed('/home');
                      },

                      child: Text(
                        'skip'.tr, // 🌟 ترجمة كلمة "تخطي"
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
                  effect: const ExpandingDotsEffect(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                              foregroundColor: MaterialStateProperty.all(
                                AppTheme.primaryGreen,
                              ),
                              shadowColor: MaterialStateProperty.all(
                                Colors.transparent,
                              ),
                              side: MaterialStateProperty.all(
                                BorderSide(color: AppTheme.primaryGreen),
                              ),
                            ),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            // 🌟 قلب اتجاه سهم العودة حسب اللغة
                            icon: Directionality(
                              // هنا السحر: إذا كان التطبيق عربي، اجعل الاتجاه RTL فيقلب الأيقونات تلقائياً
                              textDirection: Get.locale?.languageCode == 'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back,),
                                ],
                              ),
                            ),
                            label: Text('previous'.tr), // 🌟 ترجمة "السابق"
                          ),
                        )
                      else
                        const SizedBox(width: 100),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              GetStorage().write('hasCompletedOnboarding', true);
                              Get.offAllNamed('/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          // 🌟 استخدام Row لتحديد الترتيب: النص أولاً ثم الأيقونة
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, // لجعل المحتوى متمركزاً وفي المنتصف
                            children: [
                              Text(
                                _currentPage < _pages.length - 1 ? 'next'.tr : 'start'.tr,
                              ),
                              const SizedBox(width: 8), // مسافة بين النص والأيقونة
                              Directionality(
                                // هنا السحر: إذا كان التطبيق عربي، اجعل الاتجاه RTL فيقلب الأيقونات تلقائياً
                                textDirection: Get.locale?.languageCode == 'ar'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Icon(_currentPage < _pages.length - 1?
                                 Icons.arrow_forward
                                    : Icons.check,
                              ),
                                  ],
                                ),
                              ),
                            ],
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
              width: 250, height: 250, child: page.image)
              .animate()
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .then()
              .shimmer(duration: 1200.ms),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(
              context,
            ).textTheme.displayMedium?.copyWith(color: page.color),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0),
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