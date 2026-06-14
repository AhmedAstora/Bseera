import 'package:bseera/Controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // تهيئة الـ Controller مركزياً
    Get.put(ProfileController(), permanent: true);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );

    _controller.forward();

    // المنطق الذكي للانتقال بعد 3 ثوانٍ
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        final box = GetStorage();
        // التحقق من هل أتم المستخدم الـ Onboarding سابقاً
        bool hasCompletedOnboarding = box.read('hasCompletedOnboarding') ?? false;

        if (hasCompletedOnboarding) {
          // إذا كان المستخدم قديماً، انتقل للـ Home
          Get.offAllNamed('/home');
        } else {
          // إذا كان مستخدماً جديداً، انتقل للـ Onboarding
          Get.offAllNamed('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1713),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.6,
                  colors: [
                    AppTheme.primaryGreen.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mosque_outlined,
                            size: 64,
                            color: AppTheme.gold.withOpacity(0.85),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'app_name'.tr,
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                              fontFamily: 'Cairo',
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: AppTheme.gold.withOpacity(0.3),
                                  blurRadius: 35,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'B S E E R A',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 80,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, AppTheme.gold.withOpacity(0.5), Colors.transparent],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'app_description'.tr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.45),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.gold.withOpacity(0.6),
                        ),
                        strokeWidth: 2,
                        backgroundColor: Colors.white.withOpacity(0.03),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'loading'.tr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}