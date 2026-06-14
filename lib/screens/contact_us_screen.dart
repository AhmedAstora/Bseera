  import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
  import 'package:get/get.dart';
  import 'package:url_launcher/url_launcher.dart'; // تحتاج لإضافة هذه المكتبة في pubspec.yaml
  import '../theme/app_theme.dart';

  class ContactUsScreen extends StatelessWidget {
    const ContactUsScreen({super.key});

    // دالة لفتح الروابط
    Future<void> _sendEmail() async {
      final Email email = Email(
        body: 'مرحباً، لدي استفسار بخصوص تطبيق المسبحة...',
        subject: 'استفسار من مستخدم تطبيق البصيرة',
        recipients: ['ghost.basha2800@gmail.com'],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(email);
      } catch (error) {
        // إذا فشل الإرسال (مثلاً لا يوجد تطبيق إيميل)، أظهر تنبيهاً
        Get.snackbar("خطأ", "لم يتم العثور على تطبيق بريد إلكتروني.");
      }
    }
    Future<void> _launchUrl() async {
      // محاولة فتح Gmail مباشرة (هذا يعمل على أغلب أجهزة أندرويد)
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'ghost.basha2800@gmail.com',
        query: 'subject=استفسار&body=مرحباً',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // إذا فشل، افتح رابطاً عادياً (كحل أخير)
        Get.snackbar("تنبيه", "يرجى إرسال رسالة إلى: ghost.basha2800@gmail.com");
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('contact_us'.tr)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.support_agent, size: 100, color: AppTheme.goldDark),
              const SizedBox(height: 20),
              Text('contact_us_desc'.tr, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),

              // بطاقة التواصل
              // داخل build method:
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'email'.tr,
                subtitle: 'ghost.basha2800@gmail.com',
                onTap: () => _launchUrl(),
              ),
              _buildContactCard(
                icon: Icons.chat_bubble_outline,
                title: 'whatsapp'.tr,
                subtitle: '+972568766673',
                onTap: () => _launchUrl(),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
      return Card(
        margin: const EdgeInsets.only(bottom: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: AppTheme.gold.withOpacity(0.1), child: Icon(icon, color: AppTheme.goldDark)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      );
    }
  }