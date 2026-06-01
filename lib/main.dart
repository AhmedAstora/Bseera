import 'package:bseera/main.dart';
import 'package:bseera/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/dhikr_screen.dart';
import 'screens/books_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/quran_reader_screen.dart';
import 'screens/azkar_screen.dart';
import 'screens/tasbeeh_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'utils/performance_optimizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة بيانات التواريخ للغة العربية لمنع انهيار شاشة مواقيت الصلاة
  await initializeDateFormatting('ar_EG', null);

  // Performance optimizations
  PerformanceOptimizer.optimize();

  // Lock orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const IslamicApp());
}



class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bseera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 🌟 2. تعديل الأسطر الخاصة باللغة والترجمة هنا:
      translations: AppTranslations(), // ربط كلاس الترجمة الذي أنشأناه في الأعلى
      locale: const Locale('ar', 'AE'), // تغيير اللغة الافتراضية للتطبيق لتصبح العربية أولاً
      fallbackLocale: const Locale('ar', 'AE'), // اللغة الاحتياطية في حال حدوث خطأ هي العربية

      // Performance settings
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 250),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/prayer-times', page: () => const PrayerTimesScreen()),
        GetPage(name: '/quran', page: () => const QuranScreen()),
        GetPage(name: '/dhikr', page: () => const DhikrScreen()),
        GetPage(name: '/books', page: () => const BooksScreen()),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/book-detail', page: () => const BookDetailScreen()),
        GetPage(name: '/quran-reader', page: () => const QuranReaderScreen()),
        GetPage(name: '/azkar', page: () => const AzkarScreen()),
        GetPage(name: '/tasbeeh', page: () => const TasbeehScreen()),
        GetPage(name: '/profile', page: () =>  ProfileScreen()),
      ],
      initialRoute: '/splash',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}