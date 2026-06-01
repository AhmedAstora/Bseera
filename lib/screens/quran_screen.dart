import 'package:bseera/Controller/quran_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  // استدعاء أو إيجاد الـ Controller الجاهز والمحمل مسبقاً بالبيانات
  final QuranController _controller = Get.put(QuranController());
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Get.locale?.languageCode == 'ar';


    const Color darkSurface = Color(0xFFFFFFFF);
    const Color darkSecondaryField = Color(0xFF000000);
    const Color textMuted = Color(0xFF000000);

    return Scaffold(
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: _isSearching ? 130 : 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.primaryGreen,

              automaticallyImplyLeading: false,
              title: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
                      child: child,
                    ),
                  );
                },
                child: _isSearching
                    ? Container(
                  key: const ValueKey('searchField'),
                  height: 44,
                  decoration: BoxDecoration(
                    color: darkSecondaryField,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _controller.filterSurahs,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'search_surah'.tr,
                      hintStyle: const TextStyle(color: Colors.black, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.gold, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                            _controller.filterSurahs('');
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                )
                    : Text(
                  'quran_kareem'.tr,
                  key: const ValueKey('appTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              centerTitle: !_isSearching,
              leading: IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 26),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              actions: [
                if (!_isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 26),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                ]
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                    ),
                    Positioned(
                      top: -40,
                      right: isRtl ? -30 : null,
                      left: isRtl ? null : -30,
                      child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.03)),
                    ),
                    Positioned(
                      bottom: 20,
                      left: isRtl ? -20 : null,
                      right: isRtl ? null : -20,
                      child: CircleAvatar(radius: 70, backgroundColor: AppTheme.gold.withOpacity(0.04)),
                    ),
                    if (!_isSearching)
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'reading_judging'.tr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface, // استدعاء من الثيم
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:AppTheme.goldDark,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.auto_stories_rounded, color: AppTheme.gold, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'last_read'.tr.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isRtl ? 'سورة البقرة • آية ٢٠٥' : 'Surah Al-Baqarah • Ayah 205',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface, // لون النص التلقائي
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => Get.toNamed('/quran-reader', arguments: {'surah_id': 2}),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('continue_reading'.tr, style: const TextStyle(color: AppTheme.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Icon(isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios, color: AppTheme.gold, size: 11),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 4, height: 20,
                  decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 10),
                Text('quran_surahs'.tr, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            if (!_controller.isLoading.value)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Text(
                  '${_controller.filteredSurahs.length} ${'surah'.tr}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        )),
        const SizedBox(height: 16),
      ],
    ),
  ),
),
            // 🌟 مراقبة وعرض القائمة فوراً بواسطة Obx الذكي واللحظي
            Obx(() {
              if (_controller.isLoading.value) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
                  ),
                );
              }

              if (_controller.errorMessage.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        _controller.errorMessage.value,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                      ),
                    ),
                  ),
                );
              }

              if (_controller.filteredSurahs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: Center(
                      child: Text(
                        'no_results'.tr,
                        style: const TextStyle(color: textMuted, fontSize: 15),
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList.builder(
                  itemCount: _controller.filteredSurahs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildSurahCard(
                        Map<String, dynamic>.from(_controller.filteredSurahs[index]),
                        index,
                        darkSurface,
                        textMuted,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah, int index, Color surfaceColor, Color mutedTextColor) {
    int currentSurahNumber = surah['number'] ?? (index + 1);

    final String surahName = Get.locale?.languageCode == 'en'
        ? (surah['english_name'] ?? surah['title'] ?? '').toString()
        : (surah['title'] ?? surah['name'] ?? '').toString();

    final String versesCount = surah['count']?.toString() ?? '0';
    final String place = surah['place']?.toString() ?? 'Mecca';
    final String surahTypeDisplay = (place == 'Mecca' || place == 'Makkah') ? 'mecca'.tr : 'madinah'.tr;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed('/quran-reader', arguments: {
            'surah_id': currentSurahNumber,
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: const AlwaysStoppedAnimation(45 / 360),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.8), width: 1.5),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.8), width: 1.5),
                    ),
                  ),
                  Text(
                    currentSurahNumber.toString(),
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$versesCount ${'ayah'.tr}',
                      style: TextStyle(
                        color: mutedTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: (place == 'Mecca' || place == 'Makkah')
                        ? AppTheme.gold.withOpacity(0.1)
                        : AppTheme.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (place == 'Mecca' || place == 'Makkah') ? AppTheme.gold.withOpacity(0.2) : AppTheme.teal.withOpacity(0.2)
                    )),
                child: Text(
                  surahTypeDisplay,
                  style: TextStyle(
                    color: (place == 'Mecca' || place == 'Makkah') ? AppTheme.gold : AppTheme.teal,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.play_arrow_rounded, color: Colors.black, size: 26),
                onPressed: () {},
                splashRadius: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}