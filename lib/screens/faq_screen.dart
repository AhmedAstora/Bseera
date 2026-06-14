import 'package:bseera/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqScreen extends StatelessWidget {
  FaqScreen({super.key});

  final List<Map<String, String>> _faqList = [
    {
      'question': 'كيف يمكنني إعادة تعيين العداد؟',
      'answer':
          'يمكنك الضغط على زر "إعادة" الموجود في الأسفل لتصفير العداد والدورات.',
    },
    {
      'question': 'هل التطبيق يعمل بدون إنترنت؟',
      'answer':
          'نعم، التطبيق يعمل بالكامل دون الحاجة لاتصال بالإنترنت، مما يجعله مثالياً للاستخدام في أي وقت.',
    },
    {
      'question': 'كيف يمكنني تغيير اللغة؟',
      'answer':
          'يمكنك تغيير لغة التطبيق من خلال الدخول إلى قائمة الإعدادات واختيار اللغة المفضلة لديك.',
    },
    {
      'question': 'هل يتم حفظ العداد عند إغلاق التطبيق؟',
      'answer':
          'نعم، يتم حفظ تقدمك تلقائياً عند الخروج من التطبيق لضمان عدم ضياع تسبيحك.',
    },
    {
      'question': 'كيف يمكنني التراجع عن ضغطة خاطئة؟',
      'answer':
          'يمكنك الضغط على زر "تراجع" في واجهة المسبحة لنقصان العداد بمقدار رقم واحد في كل ضغطة.',
    },
    {
      'question': 'هل يمكنني إضافة أذكار مخصصة؟',
      'answer':
          'في التحديث الحالي، قمنا بتوفير الأذكار الأساسية، ونعمل على إضافة ميزة الأذكار المخصصة في التحديثات القادمة.',
    },
    {
      'question': 'كيف يمكنني مشاركة التطبيق مع أصدقائي؟',
      'answer':
          'يمكنك الضغط على خيار "مشاركة التطبيق" من القائمة الجانبية وإرسال الرابط لأصدقائك عبر مختلف وسائل التواصل.',
    },
    {
      'question': 'هل التطبيق يدعم الوضع الليلي؟',
      'answer':
          'نعم، التطبيق يدعم الوضع الليلي تلقائياً ليوفر راحة أكبر للعين أثناء الاستخدام في الإضاءة الخافتة.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('faq'.tr)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppTheme.goldDark.withOpacity(0.3)),
            ),
            child: ExpansionTile(
              initiallyExpanded: true, // 🌟 هذه الخاصية تجعل السؤال مفتوحاً عند الدخول
              title: Text(
                _faqList[index]['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _faqList[index]['answer']!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
