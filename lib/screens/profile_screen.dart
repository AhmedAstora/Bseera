import 'dart:io';
import 'package:bseera/Controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    // 🌟 فحص اتجاه اللغة الحالية ديناميكياً للتطبيق
    final bool isRtl = Get.locale?.languageCode == 'ar';

    // مصفوفة الأنشطة تم نقلها هنا لتقرأ مفاتيح الترجمة .tr ديناميكياً عند التغيير
    final List<Map<String, dynamic>> activities = [
      {'title': 'activity_quran'.tr, 'time': 'today'.tr, 'icon': Icons.menu_book},
      {'title': 'activity_hadith'.tr, 'time': 'yesterday'.tr, 'icon': Icons.format_quote},
      {'title': 'activity_tasbeeh'.tr, 'time': 'days_ago_2'.tr, 'icon': Icons.self_improvement},
      {'title': 'activity_book'.tr, 'time': 'days_ago_3'.tr, 'icon': Icons.auto_stories},
      {'title': 'activity_memorize'.tr, 'time': 'week_ago'.tr, 'icon': Icons.school},
    ];

    return Scaffold(
      body: Directionality(
        // 🌟 ضبط اتجاه واجهة الشاشة بالكامل حسب اللغة الحالية
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              // يظهر زر العودة فقط في حال لم تكن الشاشة تابعة للـ BottomNavigationBar الرئيسي
              automaticallyImplyLeading: Navigator.canPop(context),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => Get.toNamed('/settings'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Obx(() {
                          return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: controller.profileImagePath.value.isNotEmpty
                                ? FileImage(File(controller.profileImagePath.value)) as ImageProvider
                                : const AssetImage('assets/images/person.png') as ImageProvider,
                          );
                        }),
                        Obx(() => Text(
                          controller.name.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                        Obx(() => Text(
                          controller.email.value,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        )),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.menu_book,
                            value: '12',
                            label: 'surahs_completed'.tr, // 🌟 ترجمة سورة ختمتها
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.timer,
                            value: '45',
                            label: 'reading_hours'.tr, // 🌟 ترجمة ساعة قراءة
                            color: AppTheme.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.self_improvement,
                            value: '1.2K',
                            label: 'tasbeeh_count'.tr, // 🌟 ترجمة تسبيحة
                            color: AppTheme.gold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent Activity
                    Row(
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
                          'recent_activity'.tr, // 🌟 ترجمة النشاط الأخير
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        return _buildActivityItem(activities[index], isRtl);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
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
                          'quick_actions'.tr, // 🌟 ترجمة إجراءات سريعة
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildQuickAction(
                          icon: Icons.bookmark,
                          title: 'bookmarks'.tr, // 🌟 ترجمة الإشارات المرجعية
                          color: AppTheme.primaryGreen,
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.history,
                          title: 'reading_history'.tr, // 🌟 ترجمة سجل القراءة
                          color: AppTheme.teal,
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.favorite,
                          title: 'favorites'.tr, // 🌟 ترجمة المفضلة
                          color: AppTheme.gold,
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.settings,
                          title: 'settings_title'.tr, // 🌟 ترجمة الإعدادات
                          color: AppTheme.navy,
                          onTap: () => Get.toNamed('/settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark,width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, bool isRtl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark,width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: AppTheme.primaryGreen.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),

            ),
            child: Icon(
              activity['icon'] as IconData,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // 🌟 تدويل أيقونة المؤشر الجانبي لتناسب اتجاه اللغة
          Icon(
            isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
            color: AppTheme.primaryGreen,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
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
          border: Border.all(color: AppTheme.goldDark,width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}