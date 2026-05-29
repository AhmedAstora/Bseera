import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final List<Map<String, dynamic>> _azkarCategories = [
    {
      'title': 'أذكار الصباح',
      'icon': Icons.wb_sunny,
      'color': AppTheme.gold,
      'items': [
        {
          'text': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          'reference': 'رواه مسلم',
          'count': 1,
        },
        {
          'text': 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ',
          'reference': 'رواه الترمذي',
          'count': 1,
        },
        {
          'text': 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
          'reference': 'رواه البخاري',
          'count': 1,
        },
      ],
    },
    {
      'title': 'أذكار المساء',
      'icon': Icons.nights_stay,
      'color': AppTheme.navy,
      'items': [
        {
          'text': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          'reference': 'رواه مسلم',
          'count': 1,
        },
        {
          'text': 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ الْمَصِيرُ',
          'reference': 'رواه الترمذي',
          'count': 1,
        },
      ],
    },
    {
      'title': 'أذكار النوم',
      'icon': Icons.bedtime,
      'color': AppTheme.teal,
      'items': [
        {
          'text': 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
          'reference': 'رواه البخاري',
          'count': 1,
        },
        {
          'text': 'سُبْحَانَ اللَّهِ',
          'reference': 'رواه البخاري',
          'count': 33,
        },
        {
          'text': 'الْحَمْدُ لِلَّهِ',
          'reference': 'رواه البخاري',
          'count': 33,
        },
        {
          'text': 'اللَّهُ أَكْبَرُ',
          'reference': 'رواه البخاري',
          'count': 34,
        },
      ],
    },
    {
      'title': 'أذكار بعد الصلاة',
      'icon': Icons.mosque,
      'color': AppTheme.primaryGreen,
      'items': [
        {
          'text': 'أَسْتَغْفِرُ اللَّهَ',
          'reference': 'رواه مسلم',
          'count': 3,
        },
        {
          'text': 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
          'reference': 'رواه مسلم',
          'count': 1,
        },
        {
          'text': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
          'reference': 'رواه مسلم',
          'count': 1,
        },
      ],
    },
  ];

  int _selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            floating: false,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'الأذكار والأدعية',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // Category Tabs
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _azkarCategories.length,
                    itemBuilder: (context, index) {
                      final category = _azkarCategories[index];
                      final isSelected = index == _selectedCategory;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                          });
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? category['color'] as Color : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (category['color'] as Color).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                color: isSelected ? Colors.white : category['color'] as Color,
                                size: 28,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category['title'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.charcoal,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Azkar Items
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (_azkarCategories[_selectedCategory]['items'] as List).length,
                    itemBuilder: (context, index) {
                      final item = (_azkarCategories[_selectedCategory]['items'] as List)[index];
                      return _buildAzkarCard(item, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zikr Text
          Text(
            item['text'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 2.0,
              color: AppTheme.charcoal,
              fontFamily: 'Amiri',
            ),
          ),

          const SizedBox(height: 16),

          // Reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item['reference'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.gold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: AppTheme.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'التكرار: ${item['count']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.share, color: AppTheme.primaryGreen),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppTheme.primaryGreen),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
