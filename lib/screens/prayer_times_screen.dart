import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final List<Map<String, dynamic>> _prayerTimes = [
    {'name': 'الفجر', 'time': '04:30', 'icon': Icons.wb_twilight, 'isNext': true},
    {'name': 'الشروق', 'time': '05:55', 'icon': Icons.wb_sunny, 'isNext': false},
    {'name': 'الظهر', 'time': '12:15', 'icon': Icons.wb_sunny_outlined, 'isNext': false},
    {'name': 'العصر', 'time': '15:45', 'icon': Icons.wb_cloudy, 'isNext': false},
    {'name': 'المغرب', 'time': '18:20', 'icon': Icons.nights_stay, 'isNext': false},
    {'name': 'العشاء', 'time': '19:45', 'icon': Icons.bedtime, 'isNext': false},
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijriDate = '28 رمضان 1445 هـ';
    final gregorianDate = DateFormat('EEEE, d MMMM yyyy', 'ar').format(now);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'مواقيت الصلاة',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        hijriDate,
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gregorianDate,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'القاهرة، مصر',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Next Prayer Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, color: AppTheme.gold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'الصلاة القادمة: الفجر',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '02:15:30',
                          style: TextStyle(
                            color: AppTheme.gold,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'متبقي على صلاة الفجر',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Prayer Times List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _prayerTimes.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final prayer = _prayerTimes[index];
                      return _buildPrayerCard(prayer);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Qibla Direction
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore, color: AppTheme.primaryGreen),
                            const SizedBox(width: 8),
                            Text(
                              'اتجاه القبلة',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.gold.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.navigation,
                                  size: 40,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '125°',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                Text(
                                  'شمال شرق',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
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
        ],
      ),
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer) {
    final isNext = prayer['isNext'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isNext
                ? AppTheme.primaryGreen.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNext ? AppTheme.gold.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              prayer['icon'] as IconData,
              color: isNext ? AppTheme.gold : AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayer['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isNext ? Colors.white : AppTheme.charcoal,
                  ),
                ),
                if (isNext)
                  Text(
                    'الصلاة القادمة',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.gold,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            prayer['time'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isNext ? AppTheme.gold : AppTheme.primaryGreen,
            ),
          ),
          if (isNext)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.notifications_active,
                color: AppTheme.gold,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
