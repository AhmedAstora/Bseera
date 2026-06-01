import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _isInitialized = false;
  bool _showSystemUI = true;
  final int _totalQuranPages = 604;

  final Color goldColor = const Color(0xFFC5A059);
  final Color paperColor = const Color(0xFFFFFFFF);
  final Color darkBgColor = const Color(0xFF000000);
  final Color darkTextColor = const Color(0xFFD1CCC0);
  final Color lightTextColor = const Color(0xFF2C2C2C);

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  void _initializePage() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    int targetPage = 1;
    if (args['page_number'] != null) {
      targetPage = int.tryParse(args['page_number'].toString()) ?? 1;
    } else if (args['surah_id'] != null) {
      targetPage = quran.getSurahPages(int.tryParse(args['surah_id'].toString()) ?? 1).first;
    }
    _currentPage = targetPage;
    _pageController = PageController(initialPage: _currentPage - 1);
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final bool isDark = Get.isDarkMode;
    final Color bgColor = isDark ? darkBgColor : paperColor;
    final Color textColor = isDark ? darkTextColor : lightTextColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: () => setState(() => _showSystemUI = !_showSystemUI),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: _totalQuranPages,
                onPageChanged: (index) => setState(() => _currentPage = index + 1),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: SingleChildScrollView(child: _buildPageContent(index + 1, textColor)),
                ),
              ),
              if (_showSystemUI) ...[
                _buildHeader(),
                _buildFooter(), // إضافة التذييل في الأسفل
              ],
            ],
          ),
        ),
      ),
    );
  }

  // تذييل رقم الصفحة في المنتصف بالأسفل
  Widget _buildFooter() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: goldColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$_currentPage",
            style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    bool isAr = Get.locale?.languageCode == 'ar';

    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Stack(
        alignment: Alignment.center, // يجعل النص دائماً في المنتصف
        children: [
          // 1. السهم: يتحرك مكانه واتجاهه حسب اللغة
          Positioned(
            // إذا كانت عربي: السهم في اليمين. إذا إنجليزي: السهم في اليسار
            right: isAr ? 0 : null,
            left: isAr ? null : 0,
            child: IconButton(
              icon: Icon(
                // اختيار الأيقونة المناسبة للغة
                  isAr ?Icons.arrow_back  :Icons.arrow_forward ,
                  color: goldColor
              ),
              onPressed: () => Get.back(),
            ),
          ),

          // 2. النص: ثابت في المنتصف دائماً
          Text(
            "${isAr ? "الصفحة" : "Page"} $_currentPage",
            style: TextStyle(
                color: goldColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Amiri'
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int page, Color textColor) {
    List<dynamic> pageData = quran.getPageData(page);
    return Column(
      children: pageData.map((s) {
        return Column(
          children: [
            if (s['start'] == 1) _buildSurahBanner(s['surah']),
            Text(
              _getTextForPage(s['surah'], s['start'], s['end']),
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 23, height: 2.2, fontFamily: 'Amiri', color: textColor,),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getTextForPage(int surah, int start, int end) {
    String text = "";
    for (int i = start; i <= end; i++) text += "${quran.getVerse(surah, i, verseEndSymbol: true)} ";
    return text;
  }

  Widget _buildSurahBanner(int surah) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 30),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFC5A059), width: 2),
          bottom: BorderSide(color: Color(0xFFC5A059), width: 2),
        ),
      ),
      child: Column(
        children: [
          Text("سُورَةُ ${quran.getSurahNameArabic(surah)}",
              style: const TextStyle(color: Color(0xFFC5A059), fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Amiri')),
          Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
              style: TextStyle(color: const Color(0xFFC5A059).withOpacity(0.8), fontSize: 16, fontFamily: 'Amiri')),
        ],
      ),
    );
  }
}