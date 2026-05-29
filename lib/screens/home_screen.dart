import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'quran_screen.dart';
import 'prayer_times_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'الرئيسية'},
    {'icon': Icons.menu_book, 'label': 'القرآن'},
    {'icon': Icons.self_improvement, 'label': 'الصلاة'},
    {'icon': Icons.person, 'label': 'حسابي'},
  ];

  Widget _getCurrentBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const QuranScreen();
      case 2:
        return const PrayerTimesScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 تم تعديل السطر بالأسفل ليصبح TextDirection.RTL بحروف كبيرة لحل خطأ البناء تماماً
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
              icon: Icon(item['icon']),
              label: item['label'],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final now = DateTime.now();
    final hijriDate = 'الجمعة 28 رمضان 1445';
    final time = DateFormat('hh:mm').format(now);
    final period = DateFormat('a').format(now);

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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () => Get.toNamed('/settings'),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border, color: Colors.white),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                onPressed: () {},
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
                          image: NetworkImage('https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800'),
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
                              Text(
                                'السلام عليكم ورحمة الله وبركاته',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أهلاً بك في تطبيق إسلامي',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          period,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    Text(
                      hijriDate,
                      style: TextStyle(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                      title: 'القرآن الكريم',
                      subtitle: 'اقرأ واستمع',
                      color: AppTheme.primaryGreen,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.access_time_filled,
                      title: 'مواقيت الصلاة',
                      subtitle: 'الصلاة القادمة',
                      color: AppTheme.teal,
                      onTap: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.format_list_bulleted,
                      title: 'الأذكار',
                      subtitle: 'أذكار اليوم',
                      color: AppTheme.gold,
                      onTap: () => Get.toNamed('/azkar'),
                    ),
                    _buildQuickAction(
                      icon: Icons.fingerprint,
                      title: 'التسبيح',
                      subtitle: 'المسبحة الإلكترونية',
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
                _buildSectionTitle('حديث اليوم'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.1),
                        AppTheme.gold.withOpacity(0.1),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'قال رسول الله صلى الله عليه وسلم: "من صلى علي صلاة واحدة صلى الله عليه عشر صلوات"',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.8,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'رواه مسلم',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

                // Prayer Times Summary
                _buildSectionTitle('مواقيت الصلاة اليوم'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    reverse: true, // يضمن بدء التمرير من اليمين في الاتجاه العربي
                    children: [
                      _buildPrayerTimeCard('الفجر', '04:30', Icons.wb_twilight, true),
                      _buildPrayerTimeCard('الظهر', '12:15', Icons.wb_sunny, false),
                      _buildPrayerTimeCard('العصر', '15:45', Icons.wb_cloudy, false),
                      _buildPrayerTimeCard('المغرب', '18:20', Icons.nights_stay, false),
                      _buildPrayerTimeCard('العشاء', '19:45', Icons.bedtime, false),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                // Books Section
                _buildSectionTitle('كتب إسلامية'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    reverse: true, // يضمن ترتيب الكتب من اليمين إلى اليسار بشكل صحيح
                    children: [
                      _buildBookCard(
                        'لا تحزن',
                        'عائض القرني',
                        'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400',
                      ),
                      _buildBookCard(
                        'سورة البقرة',
                        'علمتني',
                        'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400',
                      ),
                      _buildBookCard(
                        'الأذكار',
                        'الإمام النووي',
                        'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400',
                      ),
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
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(String name, String time, IconData icon, bool isNext) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildBookCard(String title, String author, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: 150,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}