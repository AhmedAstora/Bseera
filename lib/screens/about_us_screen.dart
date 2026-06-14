import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('about_us'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // أيقونة أو شعار التطبيق
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.gold,
              child: Icon(Icons.mosque, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 24),

            // عنوان واسم التطبيق
            Text(
              'tasbeeh_app'.tr,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
            ),
            const SizedBox(height: 16),

            // وصف التطبيق
            Text(
              'تطبيق البصيرة هو رفيقك الرقمي للتسبيح والأذكار، مصمم بعناية ليكون سهل الاستخدام ويدعمك في رحلتك الإيمانية اليومية بكل هدوء وتركيز.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[400], height: 1.5),
            ),
            const SizedBox(height: 32),

            // بطاقة المميزات
            _buildFeatureCard(Icons.favorite_outline, 'سهولة الاستخدام', 'واجهة بسيطة ومريحة للعين.'),
            _buildFeatureCard(Icons.update, 'تحديثات مستمرة', 'نضيف الأذكار والأدعية بشكل دوري.'),
            _buildFeatureCard(Icons.offline_bolt_outlined, 'بدون إنترنت', 'يعمل التطبيق في أي وقت وفي أي مكان.'),

            const SizedBox(height: 32),
            Text('الإصدار 1.0.0', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.goldDark, size: 30),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}