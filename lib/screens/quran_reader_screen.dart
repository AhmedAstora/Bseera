import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _isInitialized = false;

  // المصحف الشريف يتكون من 604 صفحة ثابتة
  final int _totalQuranPages = 604;

  // 🗺️ خريطة ذكية لربط السور بالصفحات (مصحف المدينة المنورة الحقيقي)
  final Map<int, int> _surahToPageMap = {
    1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
    11: 221, 12: 235, 13: 249, 14: 255, 15: 262, 16: 267, 17: 282, 18: 293, 19: 305, 20: 312,
    21: 322, 22: 332, 23: 342, 24: 350, 25: 359, 26: 367, 27: 377, 28: 385, 29: 396, 30: 404,
    31: 411, 32: 415, 33: 418, 34: 428, 35: 434, 36: 440, 37: 446, 38: 453, 39: 458, 40: 467,
    41: 477, 42: 483, 43: 489, 44: 496, 45: 499, 46: 502, 47: 507, 48: 511, 49: 515, 50: 518,
    51: 520, 52: 523, 53: 526, 54: 528, 55: 531, 56: 534, 57: 537, 58: 542, 59: 545, 60: 549,
    61: 551, 62: 553, 63: 554, 64: 556, 65: 558, 66: 560, 67: 562, 68: 564, 69: 566, 70: 568,
    71: 570, 72: 572, 73: 574, 74: 575, 75: 577, 76: 578, 77: 580, 78: 582, 79: 583, 80: 585,
    81: 586, 82: 587, 83: 587, 84: 589, 85: 590, 86: 591, 87: 591, 88: 592, 89: 593, 90: 594,
    91: 595, 92: 595, 93: 596, 94: 596, 95: 597, 96: 597, 97: 598, 98: 598, 99: 599, 100: 599,
    101: 600, 102: 600, 103: 601, 104: 601, 105: 601, 106: 602, 107: 602, 108: 602, 109: 603, 110: 603,
    111: 603, 112: 604, 113: 604, 114: 604
  };

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    final Map<String, dynamic> args = Get.arguments ?? {};

    // استقبال معرف السورة القادم من شاشتك الحالية (QuranScreen)
    dynamic rawSurahId = args['surah_id'] ?? args['id'] ?? args['number'] ?? 1;
    int surahId = 1;

    if (rawSurahId is int) {
      surahId = rawSurahId;
    } else if (rawSurahId is String) {
      surahId = int.tryParse(rawSurahId) ?? 1;
    }

    dynamic rawPageNumber = args['page_number'];
    int targetPage = 1;

    if (rawPageNumber != null) {
      if (rawPageNumber is int) targetPage = rawPageNumber;
      if (rawPageNumber is String) targetPage = int.tryParse(rawPageNumber) ?? 1;
    } else {
      // مطابقة رقم السورة بصفحتها الصحيحة في المصحف
      targetPage = _surahToPageMap[surahId] ?? 1;
    }

    if (targetPage < 1) targetPage = 1;
    if (targetPage > _totalQuranPages) targetPage = _totalQuranPages;

    _currentPage = targetPage;
    _pageController = PageController(initialPage: _currentPage - 1);

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 🚀 السيرفر الجديد المعدل: خادم فائق السرعة وبجودة عالية جداً لصفحات المصحف الشريف كاملة
  String _getQuranPageUrl(int pageNumber) {
    return "https://everyayah.com/data/quranpages_800/%03d.png".replaceFirst('%03d', pageNumber.toString().padLeft(3, '0'));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFFFBF9F4),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0F4C3A))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      body: Stack(
        children: [
          // 1. عارض الصفحات المصورة بكامل الشاشة وبدون تمرير عمودي
          Positioned.fill(
            child: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl, // التصفح يميناً ويساراً كالمصحف الشريف
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _totalQuranPages,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index + 1;
                    });
                  },
                  itemBuilder: (context, index) {
                    final int pageNum = index + 1;

                    return InteractiveViewer(
                      maxScale: 4.0, // يتيح تكبير الكلمات بالأصابع
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: _getQuranPageUrl(pageNum),
                          fit: BoxFit.contain, // احتواء كامل وعمودي بدون سكرول
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F4C3A),
                              strokeWidth: 3,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.wifi_off, size: 44, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  "يرجى التحقق من اتصال الإنترنت",
                                  style: TextStyle(fontFamily: 'Amiri', fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 2. زر العودة الشفاف في أعلى الزاوية لترك مساحة القراءة ناصعة
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Opacity(
              opacity: 0.5,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF0F4C3A)),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}