// اختبار دخان (smoke test) حقيقي للتطبيق: يتأكد إنه شجرة الواجهة بتبني بدون
// استثناءات وإنه شاشة البداية بتعرض صح، بدون الاعتماد على أي plugin يحتاج
// منصة حقيقية (geolocator/notifications) - هدول مغطاة بمحاولة/معالجة أخطاء
// داخل AzanService نفسها ومش لازم لاختبار الواجهة.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:bseera/main.dart';
import 'package:bseera/screens/quran_reader_screen.dart';
import 'package:bseera/utils/translate.dart';

void main() {
  testWidgets('IslamicApp builds and shows the splash screen', (
    WidgetTester tester,
  ) async {
    // main.dart بينتظر GetStorage.init() قبل runApp - لازم نعمل نفس الشي هون
    // وإلا GetStorage() بتحاول تتهيأ لحالها جوا الـ widget tree وبتسيب Timer معلّق.
    await GetStorage.init();

    await tester.pumpWidget(const IslamicApp(initialRoute: '/splash'));
    await tester.pump();

    // اسم التطبيق ووصفه لازم يبينوا فوراً بشاشة البداية.
    expect(find.text('app_name'.tr), findsOneWidget);
    expect(find.text('app_description'.tr), findsOneWidget);
  });

  testWidgets(
    'QuranReaderScreen renders header/bottom bar without a duplicate Positioned crash',
    (WidgetTester tester) async {
      // هاد الاختبار بيثبّت رجعة مشكلة "Incorrect use of ParentDataWidget":
      // _buildHeader()/_buildBottomBar() بيرجعوا Positioned جاهز من جوا، وإذا
      // حدا لفهم بـ Positioned إضافي عند نقطة الاستدعاء بيرجع يطلع نفس الخطأ.
      await GetStorage.init();

      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('ar', 'AE'),
          home: const QuranReaderScreen(),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
