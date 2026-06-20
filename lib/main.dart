import 'package:bseera/screens/about_us_screen.dart';
import 'package:bseera/screens/contact_us_screen.dart';
import 'package:bseera/screens/faq_screen.dart';
import 'package:bseera/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
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
import 'theme/app_theme.dart';
import 'utils/performance_optimizer.dart';

// تعريف الـ Plugin بشكل عام
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // تهيئة الإشعارات واللغات
  await _initializeBackgroundServices();
  await initializeDateFormatting('ar', null);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const IslamicApp(initialRoute: '/splash'));
}

Future<void> _initializeBackgroundServices() async {
  // تحديث المسار إلى ic_notification الموجود في mipmap
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_notification');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  PerformanceOptimizer.optimize();
}

class IslamicApp extends StatelessWidget {
  final String initialRoute;
  const IslamicApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();

    return GetMaterialApp(
      title: 'Bseera',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      translations: AppTranslations(),

      // هنا جعلنا اللغة تعتمد على جهاز المستخدم، أو الخيار المحفوظ في GetStorage
      locale: box.read('user_lang') != null
          ? Locale(box.read('user_lang'))
          : Get.deviceLocale,
      fallbackLocale: const Locale('ar', 'AE'),

      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 250),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/faq_screen', page: () => FaqScreen()),
        GetPage(name: '/about_us_screen', page: () => const AboutUsScreen()),
        GetPage(name: '/contact_us_screen', page: () => const ContactUsScreen()),
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
      ],
      initialRoute: initialRoute,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}