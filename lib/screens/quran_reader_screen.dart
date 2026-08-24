import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';

/// التطبيق عربي فقط، فاسم السورة دايماً بالعربي.
String quranSurahName(int surah) => quran.getSurahNameArabic(surah);

class QuranReaderScreen extends StatefulWidget {
  const QuranReaderScreen({super.key});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  final box = GetStorage();
  final Color goldLightColor = const Color(0xFFE8C87A);
  final Color goldDarkColor = const Color(0xFFB8943F);
  late final ValueNotifier<bool> _showSystemUI = ValueNotifier<bool>(true);
  late double _fontSize = (box.read('quran_font_size') as num?)?.toDouble() ?? 26;
  bool _hifzMode = false;
  final Set<String> _revealedAyahs = {};

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

  // ارتفاعات ثابتة تُستخدم لحجز مساحة للهيدر والشريط السفلي داخل الصفحة
  // حتى ما يصير تراكب بين نص السورة وشريط التنقل لما يكونوا ظاهرين.
  static const double _headerContentHeight = 92;
  static const double _bottomBarContentHeight = 176;

  @override
  Widget build(BuildContext context) {
    final Color bg = Theme.of(context).scaffoldBackgroundColor;
    final double topInset = MediaQuery.of(context).padding.top;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final Color frameColor = Get.isDarkMode
        ? goldLightColor.withOpacity(0.55)
        : goldDarkColor.withOpacity(0.65);

    return Scaffold(
      backgroundColor: bg,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          onTap: () => _showSystemUI.value = !_showSystemUI.value,
          child: Stack(
            children: [
              // لما نخفي الهيدر والشريط السفلي (بالضغط على الشاشة)، لازم مساحة
              // النص تتمدد فعليًا وتاخد الشاشة كاملة، مو تضل محجوزة فاضية.
              ValueListenableBuilder<bool>(
                valueListenable: _showSystemUI,
                builder: (context, showChrome, child) {
                  final double topPad = (showChrome ? topInset + _headerContentHeight : topInset) + 6;
                  final double bottomPad = (showChrome ? bottomInset + _bottomBarContentHeight : bottomInset) + 6;
                  return PageView.builder(
                    key: const PageStorageKey('quran_page_view'),
                    controller: _pageController,
                    itemCount: 604,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index + 1;
                        _revealedAyahs.clear();
                      });
                      box.write('last_page', _currentPage);
                    },
                    itemBuilder: (context, index) => Container(
                      color: bg,
                      padding: EdgeInsets.fromLTRB(6, topPad, 6, bottomPad),
                      child: SingleChildScrollView(
                        // إطار المصحف الزخرفي: خط خارجي سميك وخط داخلي رفيع،
                        // بنفس روح إطارات صفحات المصحف الشريف التقليدية، وبأقل هوامش
                        // ممكنة حتى تاخد الآيات أكبر مساحة من الشاشة.
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(border: Border.all(color: frameColor, width: 2)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            decoration: BoxDecoration(border: Border.all(color: frameColor.withOpacity(0.6), width: 1)),
                            child: _buildPageContent(index + 1),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _showSystemUI,
                builder: (context, show, child) {
                  return show ? child! : const SizedBox();
                },
                child: Stack( // هذا هو الـ Stack الوحيد المسؤول عن التموضع
                  // _buildHeader() و _buildBottomBar() بيرجعوا Positioned جاهز
                  // من جوا (شوف تعريفهم تحت)، فما بلزم نلفهم بـ Positioned كمان
                  // هون - هيك كان في تعارض بين Positioned مزدوج على نفس
                  // الـ RenderObject وبيكرش الشاشة (Incorrect use of
                  // ParentDataWidget).
                  children: [
                    _buildHeader(),
                    _buildBottomBar(),
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
    String surahName = quranSurahName(
      quran.getPageData(_currentPage).first['surah'],
    );
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 12,
          20,
          14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(bottom: BorderSide(color: accent.withOpacity(0.25), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Get.isDarkMode ? 0.35 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              // التطبيق عربي فقط والشاشة RTL دايماً، فالأيقونة المعاكسة
              // (arrow_back) هي يلي بتنعكس تلقائياً (matchTextDirection)
              // لتعطي شكل "رجوع" الصحيح بالعربي.
              icon: Icon(Icons.arrow_back, color: accent),
              onPressed: () => Get.back(),
            ),
            Column(
              children: [
                Text(
                  "${'juz'.tr} ${((_currentPage - 1) ~/ 20) + 1}",
                  style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "${'page'.tr} $_currentPage",
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              surahName,
              style: TextStyle(
                color: accent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSearch() async {
    final result = await Get.to<Map<String, int>>(() => const _QuranSearchView());
    if (result != null) {
      final int page = quran.getPageNumber(result['surah']!, result['ayah']!);
      _pageController.jumpToPage(page - 1);
    }
  }

  void _showJuzListDialog() {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    final Color textColor = Get.isDarkMode ? const Color(0xFFEDE6D6) : const Color(0xFF241C10);
    final int currentJuz = ((_currentPage - 1) ~/ 20) + 1;
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('juz_tab'.tr, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: quran.totalJuzCount,
                separatorBuilder: (_, __) => Divider(color: accent.withOpacity(0.12)),
                itemBuilder: (context, index) {
                  final int juzNumber = index + 1;
                  final MapEntry<int, List<int>> entry =
                      quran.getSurahAndVersesFromJuz(juzNumber).entries.first;
                  final int startSurah = entry.key;
                  final int startVerse = entry.value[0];
                  final bool isCurrent = juzNumber == currentJuz;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: accent.withOpacity(isCurrent ? 0.25 : 0.08),
                      child: Text('$juzNumber', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      '${'juz'.tr} $juzNumber',
                      style: TextStyle(color: textColor, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
                    ),
                    subtitle: Text(quranSurahName(startSurah), style: TextStyle(color: textColor.withOpacity(0.55), fontSize: 12)),
                    onTap: () {
                      final int page = quran.getPageNumber(startSurah, startVerse);
                      _pageController.jumpToPage(page - 1);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sharePage() {
    final String text = quran
        .getPageData(_currentPage)
        .map((s) => _getTextForPage(s['surah'], s['start'], s['end']))
        .join(' ');
    Share.share('$text\n\n(${'page'.tr} $_currentPage)');
  }

  void _showJumpToPageDialog() {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    final controller = TextEditingController(text: _currentPage.toString());
    Get.dialog(
      AlertDialog(
        title: Text('go_to_page'.tr),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(hintText: 'page_number_hint'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final int? target = int.tryParse(controller.text);
              if (target != null && target >= 1 && target <= 604) {
                _pageController.jumpToPage(target - 1);
                Get.back();
              }
            },
            child: Text('go'.tr, style: TextStyle(color: accent)),
          ),
        ],
      ),
    );
  }

  // ===== العلامات المرجعية المتعددة (كل علامة: صفحة + ملاحظة اختيارية) =====
  static const String _kBookmarksKey = 'quran_bookmarks_v2';

  List<Map<String, dynamic>> _readBookmarks() {
    final List<dynamic>? raw = box.read(_kBookmarksKey);
    if (raw == null) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  void _writeBookmarks(List<Map<String, dynamic>> bookmarks) {
    box.write(_kBookmarksKey, bookmarks);
  }

  void _showAddBookmarkDialog() {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    final noteController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text('${'save_page_as_bookmark'.tr} $_currentPage ${'as_bookmark_suffix'.tr}'),
        content: TextField(
          controller: noteController,
          maxLines: 2,
          decoration: InputDecoration(hintText: 'note_optional_hint'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
            onPressed: () {
              final surah = quran.getPageData(_currentPage).first['surah'] as int;
              final bookmarks = _readBookmarks();
              bookmarks.insert(0, {
                'page': _currentPage,
                'surahName': quranSurahName(surah),
                'note': noteController.text.trim(),
                'savedAt': DateTime.now().millisecondsSinceEpoch,
              });
              _writeBookmarks(bookmarks);
              Get.back();
              Get.snackbar('bookmark_saved_title'.tr, 'bookmark_saved_msg'.tr, snackPosition: SnackPosition.BOTTOM);
            },
            child: Text('save'.tr, style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBookmarksList() {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    final Color textColor = Get.isDarkMode ? const Color(0xFFEDE6D6) : const Color(0xFF241C10);
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final bookmarks = _readBookmarks();
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: accent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('my_bookmarks_title'.tr, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (bookmarks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('no_bookmarks_yet'.tr, style: TextStyle(color: textColor.withOpacity(0.5))),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: bookmarks.length,
                      separatorBuilder: (_, __) => Divider(color: accent.withOpacity(0.15)),
                      itemBuilder: (context, index) {
                        final b = bookmarks[index];
                        final String note = (b['note'] as String?) ?? '';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.bookmark, color: accent),
                          title: Text('${b['surahName']} • ${'page'.tr} ${b['page']}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          subtitle: note.isNotEmpty ? Text(note, style: TextStyle(color: textColor.withOpacity(0.6))) : null,
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: textColor.withOpacity(0.5)),
                            onPressed: () {
                              bookmarks.removeAt(index);
                              _writeBookmarks(bookmarks);
                              setSheetState(() {});
                            },
                          ),
                          onTap: () {
                            _pageController.jumpToPage((b['page'] as int) - 1);
                            Get.back();
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: accent.withOpacity(0.25), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(Get.isDarkMode ? 0.35 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBtn(Icons.list, 'index'.tr, () => Get.back(), accent),
                  _buildBtn(Icons.layers_outlined, 'juz_tab'.tr, _showJuzListDialog, accent),
                  _buildBtn(
                    Icons.picture_in_picture_outlined,
                    'pages_tab'.tr,
                    _showJumpToPageDialog,
                    accent,
                  ),
                  _buildBtn(Icons.search, 'search'.tr, _openSearch, accent),
                ],
              ),
            ),
            Divider(height: 1, color: accent.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBtn(
                    Icons.bookmark_add_outlined,
                    'save'.tr,
                    _showAddBookmarkDialog,
                    accent,
                  ),
                  _buildBtn(Icons.bookmark_border, 'bookmarks_tab'.tr, _showBookmarksList, accent),
                  _buildBtn(Icons.share_outlined, 'share'.tr, _sharePage, accent),
                  _buildBtn(Icons.more_horiz, 'more'.tr, _showFontSizeSheet, accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(IconData icon, String label, VoidCallback onTap, Color accent) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // نمط "المصحف الشريف": كل آية = نص عادي + شارة دائرية ذهبية برقم الآية،
  // ولفظ الجلالة "الله" يُميَّز بلون خاص، وكل هذا يتدفق كفقرة واحدة مُبررة
  // (justified) بنفس أسلوب صفحات المصحف الحقيقية.
  static final RegExp _diacritics = RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]');

  List<InlineSpan> _buildAyahSpans(
    int surah,
    int start,
    int end,
    Color textColor,
    Color lafzColor,
    Color badgeColor,
  ) {
    final List<InlineSpan> spans = [];
    for (int ayah = start; ayah <= end; ayah++) {
      final String verseText = quran.getVerse(surah, ayah);
      final List<String> words = verseText.split(' ').where((w) => w.isNotEmpty).toList();
      for (int w = 0; w < words.length; w++) {
        final String word = words[w];
        // ٱ (ألف الوصل، U+0671) بتنكتب بشكل مختلف عن الألف العادية (ا) بالرسم
        // العثماني، فلازم نوحّدها قبل فحص لفظ الجلالة وإلا "ٱللَّه" ما بتنطابق
        // مع "الله".
        final String bare = word.replaceAll(_diacritics, '').replaceAll('ٱ', 'ا');
        final bool isLafz = bare.contains('الله') || bare == 'لله' || bare == 'لِلَّه';
        spans.add(TextSpan(
          text: w == words.length - 1 ? word : '$word ',
          style: TextStyle(
            color: isLafz ? lafzColor : textColor,
            fontWeight: isLafz ? FontWeight.w700 : FontWeight.normal,
          ),
        ));
      }
      spans.add(const TextSpan(text: '  '));
      spans.add(_ayahBadge(surah, ayah, badgeColor));
      spans.add(const TextSpan(text: '  '));
    }
    return spans;
  }

  // شارة رقم الآية: بلمسة وحدة (tap) بتفتح شاشة الترجمة والتفسير لنفس الآية.
  // شارة فخمة على شكل وردة زخرفية (rosette) بدل الدائرة البسيطة، بنفس روح
  // رمز نهاية الآية ۝ التقليدي بالمصحف الشريف.
  InlineSpan _ayahBadge(int surah, int ayahNumber, Color accent) {
    final String numeral = quran.getVerseEndSymbol(ayahNumber).replaceFirst('۝', '');
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () => _showTranslationSheet(surah, ayahNumber),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CustomPaint(
            painter: _AyahMedallionPainter(color: accent),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  numeral,
                  style: TextStyle(fontSize: 10.5, fontFamily: 'Amiri', fontWeight: FontWeight.bold, color: accent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTranslationSheet(int surah, int ayah) {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    final Color textColor = Get.isDarkMode ? const Color(0xFFEDE6D6) : const Color(0xFF241C10);
    final String arabicText = quran.getVerse(surah, ayah);
    final String translation = quran.getVerseTranslation(surah, ayah);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.translate_rounded, color: accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${quranSurahName(surah)} • ${'ayah'.tr} $ayah',
                  style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              arabicText,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: textColor, fontFamily: 'Amiri', fontSize: 22, height: 1.8),
            ),
            const SizedBox(height: 14),
            Divider(color: accent.withOpacity(0.2)),
            const SizedBox(height: 10),
            Text(
              translation,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
              style: TextStyle(color: textColor.withOpacity(0.85), fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  // ===== وضع الحفظ (Hifz): كل آية تظهر مخفية خلف بطاقة، وبالضغط عليها تنكشف
  // للاختبار الذاتي. يُعاد إخفاء كل الآيات تلقائيًا عند الانتقال لصفحة جديدة. =====
  Widget _buildHifzPageContent(int page) {
    final Color textColor = Get.isDarkMode ? const Color(0xFFEDE6D6) : const Color(0xFF241C10);
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;

    final List<Widget> widgets = [];
    for (final s in quran.getPageData(page)) {
      final int surah = s['surah'] as int;
      if (s['start'] == 1) widgets.add(_buildSurahBanner(surah));
      for (int ayah = s['start'] as int; ayah <= (s['end'] as int); ayah++) {
        final String key = '$surah:$ayah';
        final bool revealed = _revealedAyahs.contains(key);
        widgets.add(
          GestureDetector(
            onTap: () => setState(() {
              revealed ? _revealedAyahs.remove(key) : _revealedAyahs.add(key);
            }),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(revealed ? 0.55 : 0.25)),
                color: accent.withOpacity(revealed ? 0.05 : 0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(left: 10, top: 2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent, width: 1.1)),
                    child: Text(
                      quran.getVerseEndSymbol(ayah).replaceFirst('۝', ''),
                      style: TextStyle(fontFamily: 'Amiri', color: accent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: revealed
                        ? Text(
                            quran.getVerse(surah, ayah),
                            textAlign: TextAlign.right,
                            style: TextStyle(fontFamily: 'Amiri', fontSize: _fontSize, height: 1.9, color: textColor),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.visibility_off_outlined, color: accent.withOpacity(0.55), size: 18),
                                const SizedBox(width: 8),
                                Text('tap_to_reveal'.tr, style: TextStyle(color: accent.withOpacity(0.55), fontSize: 12)),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return Column(children: widgets);
  }

  Widget _buildPageContent(int page) {
    if (_hifzMode) return _buildHifzPageContent(page);

    final Color ayahColor = Get.isDarkMode ? const Color(0xFFEDE6D6) : const Color(0xFF241C10);
    final Color lafzColor = Get.isDarkMode ? const Color(0xFF6FD6C8) : const Color(0xFFA6321E);
    final Color badgeColor = Get.isDarkMode ? goldLightColor : goldDarkColor;

    return Column(
      children: quran
          .getPageData(page)
          .map(
            (s) => Column(
              children: [
                if (s['start'] == 1) _buildSurahBanner(s['surah']),
                Text.rich(
                  TextSpan(
                    children: _buildAyahSpans(s['surah'], s['start'], s['end'], ayahColor, lafzColor, badgeColor),
                  ),
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 2.15,
                    fontFamily: 'Amiri',
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  void _showFontSizeSheet() {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('font_size'.tr, style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.text_decrease, color: accent, size: 18),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      min: 18,
                      max: 34,
                      divisions: 8,
                      activeColor: accent,
                      onChanged: (value) {
                        setSheetState(() {});
                        setState(() => _fontSize = value);
                        box.write('quran_font_size', value);
                      },
                    ),
                  ),
                  Icon(Icons.text_increase, color: accent, size: 22),
                ],
              ),
              const Divider(height: 28),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: accent,
                value: _hifzMode,
                title: Text('hifz_mode'.tr, style: TextStyle(color: accent, fontSize: 15, fontWeight: FontWeight.bold)),
                subtitle: Text('hifz_mode_desc'.tr, style: const TextStyle(fontSize: 12)),
                onChanged: (value) {
                  setSheetState(() {});
                  setState(() {
                    _hifzMode = value;
                    _revealedAyahs.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTextForPage(int surah, int start, int end) {
    String text = "";
    for (int i = start; i <= end; i++) {
      text += "${quran.getVerse(surah, i, verseEndSymbol: true)} ";
    }
    return text;
  }

  Widget _buildSurahBanner(int surah) {
    final Color accent = Get.isDarkMode ? goldLightColor : goldDarkColor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withOpacity(0.5), width: 1.2),
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.08), accent.withOpacity(0.02)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: accent.withOpacity(0.6), size: 14),
          const SizedBox(height: 6),
          Text(
            "${'surah_prefix'.tr} ${quranSurahName(surah)}",
            textAlign: TextAlign.center,
            style: TextStyle(color: accent, fontSize: 26, fontFamily: 'Amiri', fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// شاشة البحث عن الآيات — تابعة لشاشة قراءة القرآن فقط (نفس الملف)،
/// بترجع {surah, ayah} للنتيجة المختارة عشان شاشة القراءة تنتقل لصفحتها.
class _QuranSearchView extends StatefulWidget {
  const _QuranSearchView();

  @override
  State<_QuranSearchView> createState() => _QuranSearchViewState();
}

class _QuranSearchViewState extends State<_QuranSearchView> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  List<int> _matchingSurahs = [];
  static const int _maxResults = 80;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ملاحظة: كتابة رموز التشكيل العربية حرفيًا جوا الـ RegExp كانت بتسبب مشكلة
  // (ترتيب مدى غير صحيح) لأنها رموز تركيبية (combining marks) بطبيعتها.
  // استخدام أكواد \uXXXX الصريحة بيضمن ترتيب صحيح ونتيجة موثوقة دايمًا.
  static final RegExp _diacritics = RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]');

  // بنشيل التشكيل وبنوحّد الألف/الياء قبل المقارنة، لأن آيات القرآن مُشكّلة
  // بالكامل بينما المستخدم بيكتب بدون تشكيل عادةً من لوحة المفاتيح العادية.
  String _normalize(String text) {
    return text
        .replaceAll(_diacritics, '')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ٱ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
  }

  void _search(String query) {
    final String q = _normalize(query.trim());
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _matchingSurahs = [];
      });
      return;
    }

    // نطابق أسماء السور أولاً (عربي وإنجليزي) عشان لو المستخدم عم يدوّر
    // على سورة بالاسم مباشرة يوصلها بسرعة.
    final List<int> matchedSurahs = [];
    for (int surah = 1; surah <= quran.totalSurahCount; surah++) {
      final String arabicName = _normalize(quran.getSurahNameArabic(surah));
      final String englishName = quran.getSurahNameEnglish(surah).toLowerCase();
      if (arabicName.contains(q) || englishName.contains(query.trim().toLowerCase())) {
        matchedSurahs.add(surah);
      }
    }

    final List<Map<String, dynamic>> found = [];
    for (int surah = 1; surah <= quran.totalSurahCount && found.length < _maxResults; surah++) {
      final int verseCount = quran.getVerseCount(surah);
      for (int ayah = 1; ayah <= verseCount; ayah++) {
        final String text = quran.getVerse(surah, ayah);
        if (_normalize(text).contains(q)) {
          found.add({'surah': surah, 'ayah': ayah, 'text': text});
          if (found.length >= _maxResults) break;
        }
      }
    }
    setState(() {
      _matchingSurahs = matchedSurahs;
      _results = found;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Color accent = isDark ? const Color(0xFFE8C87A) : const Color(0xFFB8943F);
    final Color bg = Theme.of(context).scaffoldBackgroundColor;
    final Color textColor = isDark ? const Color(0xFFEDE6D6) : const Color(0xFF241C10);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      // نفس منطق الهيدر: الشاشة RTL دايماً.
                      icon: Icon(Icons.arrow_back, color: accent),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accent.withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onChanged: _search,
                          style: TextStyle(fontFamily: 'Amiri', fontSize: 17, color: textColor),
                          decoration: InputDecoration(
                            hintText: 'search_quran_hint'.tr,
                            hintStyle: TextStyle(color: textColor.withOpacity(0.4), fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: accent, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _controller.text.trim().isEmpty
                    ? Center(
                        child: Text(
                          'search_min_chars'.tr,
                          style: TextStyle(color: textColor.withOpacity(0.45), fontSize: 14),
                        ),
                      )
                    : (_results.isEmpty && _matchingSurahs.isEmpty)
                        ? Center(
                            child: Text('no_results'.tr, style: TextStyle(color: textColor.withOpacity(0.45), fontSize: 14)),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            children: [
                              if (_matchingSurahs.isNotEmpty) ...[
                                Text('quran_surahs'.tr, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                ..._matchingSurahs.map((surah) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(Icons.menu_book_rounded, color: accent, size: 20),
                                      title: Text(quranSurahName(surah), style: TextStyle(color: textColor, fontFamily: 'Amiri', fontSize: 18)),
                                      onTap: () => Get.back(result: {'surah': surah, 'ayah': 1}),
                                    )),
                                if (_results.isNotEmpty) Divider(color: accent.withOpacity(0.25), height: 24),
                              ],
                              if (_results.isNotEmpty)
                                Text('${'ayah'.tr} - ${'quran_kareem'.tr}', style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold)),
                              ...List.generate(_results.length, (index) {
                                final r = _results[index];
                                return InkWell(
                                  onTap: () => Get.back(result: {'surah': r['surah'] as int, 'ayah': r['ayah'] as int}),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${quranSurahName(r['surah'] as int)} • ${'ayah'.tr} ${r['ayah']}',
                                          style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          r['text'] as String,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(color: textColor, fontFamily: 'Amiri', fontSize: 18, height: 1.7),
                                        ),
                                        if (index != _results.length - 1) Divider(color: accent.withOpacity(0.15), height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// يرسم وردة زخرفية (rosette) بثماني بتلات حول رقم الآية، بنفس روح رمز
/// نهاية الآية ۝ التقليدي بالمصحف الشريف — بدل الدائرة البسيطة.
class _AyahMedallionPainter extends CustomPainter {
  final Color color;
  const _AyahMedallionPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.width / 2;

    // قرص داخلي بتدرج شعاعي خفيف يعطي عمق للشارة
    final Paint fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.18), color.withOpacity(0.02)],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.62));
    canvas.drawCircle(center, r * 0.62, fillPaint);

    // ثماني بتلات صغيرة حوالين المحيط
    final Paint petalPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const int petals = 8;
    for (int i = 0; i < petals; i++) {
      final double angle = (2 * math.pi / petals) * i;
      final Offset petalCenter = Offset(
        center.dx + r * 0.82 * math.cos(angle),
        center.dy + r * 0.82 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, r * 0.2, petalPaint);
    }

    // الحلقة الداخلية المحيطة بالرقم
    final Paint ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(center, r * 0.62, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _AyahMedallionPainter oldDelegate) => oldDelegate.color != color;
}
