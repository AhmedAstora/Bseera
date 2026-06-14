import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quran/quran.dart' as quran;

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  final box = GetStorage();
  final Color goldColor = const Color(0xFFE8C87A);
  late final ValueNotifier<bool> _showSystemUI = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _initializePage();
  }
  @override
  void dispose() {
    _pageController.dispose();
    _showSystemUI.dispose(); // إضافة هذا السطر
    super.dispose();
  }

  void _initializePage() {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    int targetPage = 1;

    // 1. الأولوية للـ arguments إذا جاءت من القائمة
    if (args != null && args.containsKey('surah_id')) {
      targetPage = quran.getSurahPages(args['surah_id']).first;
    }
    // 2. إذا لم توجد arguments، نحصل عليها من box (وهذا يحفظ مكاننا عند تغيير الثيم)
    else {
      targetPage = box.read('last_page') ?? 1;
    }

    _currentPage = targetPage;

    // تأكد من تهيئة الـ Controller بالصفحة الصحيحة
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: () => _showSystemUI.value = !_showSystemUI.value,
          child: Stack(
            children: [
              PageView.builder(
                key: const PageStorageKey('quran_page_view'),
                controller: _pageController,
                itemCount: 604,
                onPageChanged: (index) {
                  setState(() => _currentPage = index + 1);
                  box.write('last_page', _currentPage);
                },
                itemBuilder: (context, index) => Container( // تأكد أن الخلفية معرفة هنا
                  color: Get.isDarkMode ? Colors.black : const Color(0xFFF9F4E8),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: SingleChildScrollView(child: _buildPageContent(index + 1)),
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _showSystemUI,
                builder: (context, show, child) {
                  return show ? child! : const SizedBox();
                },
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _buildHeader(),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomBar(),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    bool isAr = Get.locale?.languageCode == 'ar';
    String surahName = quran.getSurahNameArabic(
      quran.getPageData(_currentPage).first['surah'],
    );
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 35, 20, 10),
        decoration: BoxDecoration(
          color: (Get.isDarkMode ? Colors.black : Colors.white).withOpacity(
            0.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
         IconButton(
        icon: Icon(
        // اختيار الأيقونة المناسبة للغة
        isAr ?Icons.arrow_forward  :Icons.arrow_back ,
            color: goldColor
        ),
        onPressed: () => Get.back(),
      ),
         Column(
           children: [
             Text(
               "الجزء : ${((_currentPage - 1) ~/ 20) + 1}",
               style: TextStyle(color: goldColor, fontSize: 18,fontWeight: FontWeight.bold),
             ),
             Text(
               "الصفحة : $_currentPage",
               style: TextStyle(
                 color: goldColor,
                 fontSize: 18,
                 fontWeight: FontWeight.bold,
               ),
             ),
           ],
         ),
            Text(surahName, style: TextStyle(color: goldColor, fontSize: 20,fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: (Get.isDarkMode ? Colors.black : Colors.white).withOpacity(
            0.6,
          ),
          border: Border(top: BorderSide(color: goldColor.withOpacity(0.9))),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBtn(Icons.list, "الفهرس", () => Get.back()),
                  _buildBtn(Icons.layers_outlined, "الأجزاء", () {}),
                  _buildBtn(
                    Icons.picture_in_picture_outlined,
                    "الصفحات",
                    () {},
                  ),
                  // 1. احذف الـ Obx تماماً من أمام الدالة
                  _buildBtn(
                    Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                    Get.isDarkMode ? "نهار" : "ليل",
                        () {
                      // 2. تغيير الثيم
                      Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);

                      // 3. إجبار الشاشة على إعادة البناء لتظهر الأيقونة الجديدة فوراً
                      setState(() {});
                    },
                  ),
                  _buildBtn(Icons.search, "بحث", () {}),
                ],
              ),
            ),
            Divider(height: 1, color: goldColor.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBtn(
                    Icons.bookmark_add_outlined,
                    "حفظ",
                    () => box.write('bookmark', _currentPage),
                  ),
                  _buildBtn(Icons.bookmark_border, "انتقال", () {
                    int saved = box.read('bookmark') ?? 1;
                    _pageController.jumpToPage(saved - 1);
                  }),
                  _buildBtn(Icons.people_outline, "أعمالنا", () {}),
                  _buildBtn(Icons.share_outlined, "مشاركة", () {}),
                  _buildBtn(Icons.more_horiz, "المزيد", () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: goldColor, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: goldColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int page) {
    String fullPageText = "";
    for (var s in quran.getPageData(page)) {
      fullPageText += _getTextForPage(s['surah'], s['start'], s['end']);
    }
    double fontSize = fullPageText.length < 500 ? 28 : 23;

    return Column(
      children: quran
          .getPageData(page)
          .map(
            (s) => Column(
              children: [
                if (s['start'] == 1) _buildSurahBanner(s['surah']),
                Text(
                  _getTextForPage(s['surah'], s['start'], s['end']),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 23,
                    height: 2,
                    fontFamily: 'Amiri',
                    color: Get.isDarkMode ? Colors.white70 : Colors.black,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  String _getTextForPage(int surah, int start, int end) {
    String text = "";
    for (int i = start; i <= end; i++)
      text += "${quran.getVerse(surah, i, verseEndSymbol: true)} ";
    return text;
  }

  Widget _buildSurahBanner(int surah) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      child: Text(
        "سُورَةُ ${quran.getSurahNameArabic(surah)}",
        style: TextStyle(color: goldColor, fontSize: 28, fontFamily: 'Amiri'),
      ),
    );
  }
}
