import 'dart:async';
import 'package:bseera/screens/azkar_screen.dart';
import 'package:bseera/screens/qibla_compass_screen.dart';
import '../services/azan_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'quran_screen.dart';
import 'prayer_times_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final AzanService _azan = AzanService.instance;

  bool _isLoadingPrayers = true;
  Timer? _timeTimer;

  // قيم مؤقتة فقط لحد ما توصل أوقات الصلاة الحقيقية المحسوبة حسب موقع
  // المستخدم الفعلي (AzanService) - مش قيم ثابتة نهائية.
  String _fajrTime = '--:--';
  String _dhuhrTime = '--:--';
  String _asrTime = '--:--';
  String _maghribTime = '--:--';
  String _ishaTime = '--:--';
  String _currentPrayerName = '';
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _notificationsOn = _azan.notificationsEnabled;
    _loadPrayerTimes();
    // مؤقت لتحديث الوقت والتاريخ في الواجهة كل دقيقة تلقائياً
    _timeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    super.dispose();
  }

  /// بدل ما نجيب الموقع ونحسب من جديد، نسحب من AzanService المركزية
  /// (نفس المصدر يلي بتستخدمه شاشة أوقات الصلاة والجدولة بالخلفية).
  Future<void> _loadPrayerTimes() async {
    try {
      if (!_azan.isInitialized) {
        await _azan.init();
      } else {
        await _azan.ensureScheduleIsFresh();
      }
    } catch (e) {
      // ما منسيب الواجهة عالقة على القيم المؤقتة بصمت لو صار خطأ غير متوقع.
      debugPrint('HomeScreen: prayer times load error -> $e');
      if (mounted) setState(() => _isLoadingPrayers = false);
      return;
    }

    final prayerTimesData = _azan.todayPrayerTimes;
    if (prayerTimesData == null || !mounted) return;

    final timeFormat = DateFormat('hh:mm');

    setState(() {
      _fajrTime = timeFormat.format(prayerTimesData.fajr.toLocal());
      _dhuhrTime = timeFormat.format(prayerTimesData.dhuhr.toLocal());
      _asrTime = timeFormat.format(prayerTimesData.asr.toLocal());
      _maghribTime = timeFormat.format(prayerTimesData.maghrib.toLocal());
      _ishaTime = timeFormat.format(prayerTimesData.isha.toLocal());
      _currentPrayerName = prayerTimesData.currentPrayer().name;
      _isLoadingPrayers = false;
    });
  }

  Future<void> _toggleNotifications() async {
    final newValue = !_notificationsOn;
    setState(() => _notificationsOn = newValue);
    await _azan.setNotificationsEnabled(newValue);

    Get.snackbar(
      newValue ? 'success_title'.tr : 'info_title'.tr,
      newValue ? 'notifications_enabled_msg'.tr : 'notifications_disabled_msg'.tr,
      backgroundColor: newValue ? Colors.green : Colors.grey,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _getCurrentBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const QuranScreen();
      case 2:
        return const PrayerTimesScreen();
      case 3:
        return QiblaCompassScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 نقل قائمة التنقل إلى هنا لتقرأ الـ .tr بشكل ديناميكي متجدد
    final List<Map<String, dynamic>> _navItems = [
      {'icon': 'assets/images/home (1).png', 'label': 'home'.tr},
      {'icon': 'assets/images/quran (1).png', 'label': 'quran'.tr},
      {'icon': 'assets/images/salat.png', 'label': 'prayer'.tr},
      {'icon': 'assets/images/kaaba.png', 'label': 'Qibla'.tr},
    ];

    return Scaffold(
      body: _getCurrentBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: _navItems.map((item) {
            return BottomNavigationBarItem(
              // نستخدم ImageIcon ونمرر له AssetImage
              icon: ImageIcon(
                AssetImage(item['icon']),
                size: 28, // يمكنك التحكم بالحجم
              ),
              label: item['label'],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final now = DateTime.now();

    final time = DateFormat('hh:mm').format(now);
    final period = DateFormat('a', 'ar').format(now);

    // التطبيق عربي فقط، فصيغة التاريخ الهجري دايماً بالشكل العربي.
    final hijriDate =
        "${HijriCalendar.now().toFormat("DD, dd MMMM yyyy")} ${'hijri_symbol'.tr}";

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.toNamed('/settings'),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                ),
                                onPressed: () => Get.toNamed('/favorites'),
                              ),
                              IconButton(
                                icon: Icon(
                                  _notificationsOn
                                      ? Icons.notifications
                                      : Icons.notifications_off_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleNotifications,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Mosque Image & Greeting
                    Container(
                      height: 160,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryGreen.withOpacity(0.7),
                              AppTheme.primaryGreen.withOpacity(0.3),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  'islamic_greeting'.tr,
                                  // 🌟 ترجمة السلام عليكم...
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'welcome_bseera'.tr,
                                // 🌟 ترجمة أهلاً بكم في تطبيق بصيرة
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    // Time Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          time.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          period.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      hijriDate.tr,
                      style: const TextStyle(
                        color: AppTheme.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _buildQuickAction(
                    icon: Icons.menu_book,
                    title: 'quran_kareem'.tr,
                    // 🌟 مترجم سابقاً
                    subtitle: 'read_and_listen'.tr,
                    // 🌟 ترجمة اقرأ واستمع
                    color: AppTheme.primaryGreen,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.access_time_filled,
                    title: 'prayer_times'.tr,
                    // 🌟 مترجم سابقاً
                    subtitle: 'next_prayer'.tr,
                    // 🌟 ترجمة الصلاة القادمة
                    color: AppTheme.teal,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.format_list_bulleted,
                    title: 'azkar_title'.tr,
                    // 🌟 ترجمة الأذكار
                    subtitle: 'today_azkar'.tr,
                    // 🌟 ترجمة أذكار اليوم
                    color: AppTheme.gold,
                    onTap: () => Get.toNamed('/azkar'),
                  ),
                  _buildQuickAction(
                    icon: Icons.fingerprint,
                    title: 'tasbeeh_title'.tr,
                    // 🌟 ترجمة التسبيح
                    subtitle: 'electronic_rosary'.tr,
                    // 🌟 ترجمة المسبحة الإلكترونية
                    color: AppTheme.navy,
                    onTap: () => Get.toNamed('/tasbeeh'),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Daily Hadith
              _buildSectionTitle('hadith_today'.tr),
              // 🌟 ترجمة عنوان حديث اليوم
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, AppTheme.gold],
                    stops: [0.0, 1.0],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'hadith_content'.tr, // 🌟 ترجمة متن الحديث النبوي
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                        height: 1.8,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'hadith_narrator'.tr, // 🌟 ترجمة الراوي (رواه مسلم)
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Prayer Times Summary (تعمل ديناميكياً الآن بألوانك الأصلية الفاتحة)
              _buildSectionTitle('today_prayer_times'.tr),
              // 🌟 ترجمة مواقيت الصلاة اليوم
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: _isLoadingPrayers
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  ),
                )
                    : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPrayerTimeCard(
                      'fajr'.tr,
                      _fajrTime,
                      Icons.wb_twilight,
                      _currentPrayerName == 'fajr',
                    ),
                    // 🌟 ترجمة الصلوات الخمس
                    _buildPrayerTimeCard(
                      'dhuhr'.tr,
                      _dhuhrTime,
                      Icons.wb_sunny,
                      _currentPrayerName == 'dhuhr',
                    ),
                    _buildPrayerTimeCard(
                      'asr'.tr,
                      _asrTime,
                      Icons.wb_cloudy,
                      _currentPrayerName == 'asr',
                    ),
                    _buildPrayerTimeCard(
                      'maghrib'.tr,
                      _maghribTime,
                      Icons.nights_stay,
                      _currentPrayerName == 'maghrib',
                    ),
                    _buildPrayerTimeCard(
                      'isha'.tr,
                      _ishaTime,
                      Icons.bedtime,
                      _currentPrayerName == 'isha',
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideX(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Books Section
              _buildSectionTitle('islamic_books'.tr),
              // 🌟 ترجمة كتب إسلامية
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                
                  children: [
                    _buildBookCard('assets/images/book3.png'),
                    _buildBookCard('assets/images/book1.png'),
                    _buildBookCard('assets/images/book2.png'),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 800.ms)
                  .slideX(begin: -0.2, end: 0),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.goldDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(
      String name,
      String time,
      IconData icon,
      bool isNext,
      ) {
    return Container(
      width: 85,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isNext
                ? AppTheme.primaryGreen.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isNext ? AppTheme.gold : AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: isNext ? Colors.white : AppTheme.charcoal,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              color: isNext ? AppTheme.gold : AppTheme.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Image.asset(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}