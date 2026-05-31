import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<dynamic> _surahs = [];
  List<dynamic> _filteredSurahs = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _errorMessage = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocalSurahsData();
  }

  Future<void> _loadLocalSurahsData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/surah.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        _surahs = data;
        _filteredSurahs = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "error_quran".tr;
        _isLoading = false;
      });
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = _surahs;
      } else {
        _filteredSurahs = _surahs.where((surah) {
          final nameAr = (surah['title'] ?? surah['name'] ?? '').toString().toLowerCase();
          final nameEn = (surah['english_name'] ?? '').toString().toLowerCase();
          return nameAr.contains(query.toLowerCase()) || nameEn.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Get.locale?.languageCode == 'ar';

    // 🌟 لوحة ألوان فخمة مخصصة بالكامل للوضع المظلم (Dark Mode)
    const Color darkBackground = Color(0xFF121212);     // خلفية الشاشة الداكنة
    const Color darkSurface = Color(0xFF1E1E1E);        // خلفية الكروت والبطاقات
    const Color darkSecondaryField = Color(0xFFFFFFFF); // خلفية حقل البحث المظلم
    const Color textMuted = Color(0xFFA0A0A0);          // النصوص الفرعية الرمادية

    return Scaffold(
      body: Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 🌟 SliverAppBar المتفاعل والمتناسق مع الوضع المظلم
            SliverAppBar(
              expandedHeight: _isSearching ? 130 : 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.primaryGreen,
              automaticallyImplyLeading: false,

              // 🌟 إضافة متحرك ذكي وسلس للغاية لتبديل الهيدر بدون وميض أو قفز
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
                    onChanged: _filterSurahs,
                    autofocus: true,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'search_surah'.tr,
                      hintStyle: TextStyle(color: Colors.black, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.gold, size: 20),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                        onPressed: () {
                          setState(() {
                            _isSearching = false;
                            _searchController.clear();
                            _filterSurahs('');
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

              // الأزرار العلوية المقابلة
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
                    // 🌟 بطاقة "آخر قراءة" بأسلوب نيون مظلم فخم (Dark Glassmorphism)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.25),
                            darkSurface,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
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
                              color: AppTheme.primaryGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: AppTheme.gold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'last_read'.tr.toUpperCase(),
                                  style: TextStyle(
                                    color: textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isRtl ? 'سورة البقرة • آية ٢٠٥' : 'Surah Al-Baqarah • Ayah 205',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => Get.toNamed('/quran-reader', arguments: {'surah_id': 2}),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'continue_reading'.tr,
                                        style: const TextStyle(
                                          color: AppTheme.gold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
                                        color: AppTheme.gold,
                                        size: 11,
                                      ),
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

                    // عنوان قسم السور متناسق مع الوضع المظلم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppTheme.gold,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'quran_surahs'.tr,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          ],
                        ),
                        if (!_isLoading)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: darkSurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_filteredSurahs.length} ${'surah'.tr}',
                              style: const TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.gold)),
                      )
                    else if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 15),
                          ),
                        ),
                      )
                    else if (_filteredSurahs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Center(
                            child: Text(
                              'no_results'.tr,
                              style: const TextStyle(color: textMuted, fontSize: 15),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredSurahs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildSurahCard(Map<String, dynamic>.from(_filteredSurahs[index]), index, darkSurface, textMuted);
                          },
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

  // 🌟 كارت السورة المطور والمعدل بالكامل للوضع المظلم
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
        border: Border.all(color: Colors.white.withOpacity(0.03)), // حدود خفيفة جداً لتمييز الكارت بالظلام
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
              // رقم السورة بالنجمة الثمانية المتوهجة بالظلام
              Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: const AlwaysStoppedAnimation(45 / 360),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1.5),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3), width: 1.5),
                    ),
                  ),
                  Text(
                    currentSurahNumber.toString(),
                    style: const TextStyle(
                      color: AppTheme.gold, // تغيير الرقم للذهبي لتباين ممتاز في الظلام
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
                        color: Colors.white, // نص أبيض ناصع
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

              // شارة نوع السورة بتناسق مع الـ Dark mode
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: (place == 'Mecca' || place == 'Makkah')
                        ? AppTheme.gold.withOpacity(0.1)
                        : AppTheme.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: (place == 'Mecca' || place == 'Makkah') ? AppTheme.gold.withOpacity(0.2) : AppTheme.teal.withOpacity(0.2)
                    )
                ),
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
                icon: Icon(Icons.play_arrow_rounded, color: Colors.grey.shade500, size: 26),
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