import 'package:bseera/Controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isDarkMode = false;
  bool isCurrentlyDark = Get.isDarkMode;
  bool _notifications = true;
  bool _location = true;
  final ProfileController controller = Get.find();
  String _selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    if (Get.locale?.languageCode == 'en') {
      _selectedLanguage = 'English';
    } else {
      _selectedLanguage = 'العربية';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        controller.updateImage(pickedFile.path);

        setState(() {
          _profileImage = File(pickedFile.path);
        });

        Get.snackbar(
          'success_title'.tr,
          'image_updated_success'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error_title'.tr,
        '${'image_error'.tr}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: // هذا الكود يوضع داخل الـ Row في دالة _buildActionItem
                Directionality(
                  // هنا السحر: إذا كان التطبيق عربي، اجعل الاتجاه RTL فيقلب الأيقونات تلقائياً
                  textDirection: Get.locale?.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white),
                    ],
                  ),
                ),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'settings'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _buildSectionHeader('my_account'.tr),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldDark,width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProfileItem(
                            icon: Icons.person_outline,
                            title: 'username'.tr,
                            subtitleWidget: Obx(
                              () => Text(
                                controller.name.value,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.black),
                              ),
                            ),
                            onTap: () => _showEditDialog(
                              'username',
                              controller.name.value,
                            ),
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildProfileItem(
                            icon: Icons.email_outlined,
                            title: 'email'.tr,
                            subtitleWidget: Obx(
                              () => Text(
                                controller.email.value,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.black),
                              ),
                            ),
                            onTap: () => _showEditDialog(
                              'email',
                              controller.email.value,
                            ),
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildProfileItem(
                            icon: Icons.camera_alt_outlined,
                            title: 'profile_image'.tr,
                            subtitle: 'tap_to_edit'.tr,
                            onTap: () => _showEditImageDialog(),
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildProfileItem(
                            icon: Icons.phone_outlined,
                            title: 'phone_number'.tr,
                            subtitle: '+970598358225',
                            onTap: () => _showEditDialog(
                              'phone_number',
                              '+970598358225',
                            ),
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildProfileItem(
                            icon: Icons.lock_outline,
                            title: 'change_password'.tr,
                            subtitle: '12345678',
                            onTap: () => _showPasswordDialog(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Appearance Section
                    _buildSectionHeader('appearance'.tr),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldDark,width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSwitchItem(
                            icon: Icons.dark_mode_outlined,
                            title: 'dark_mode'.tr,
                            subtitle: 'dark_mode_sub'.tr,
                            value: isCurrentlyDark,
                            // نستخدم القيمة القادمة من GetX مباشرة
                            onChanged: (value) {
                              setState(() {
                                // لتحديث الواجهة فوراً عند النقر
                                isCurrentlyDark = value;
                              });

                              // تغيير الوضع في التطبيق بالكامل
                              if (value) {
                                Get.changeThemeMode(ThemeMode.dark);
                              } else {
                                Get.changeThemeMode(ThemeMode.light);
                              }
                            },
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildDropdownItem(
                            icon: Icons.language,
                            title: 'language'.tr,
                            value: _selectedLanguage,
                            items: const ['العربية', 'English'],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedLanguage = value;
                                });

                                if (value == 'العربية') {
                                  Get.updateLocale(const Locale('ar', 'AE'));
                                } else if (value == 'English') {
                                  Get.updateLocale(const Locale('en', 'US'));
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Notifications Section
                    _buildSectionHeader('notifications_section'.tr),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldDark,width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSwitchItem(
                            icon: Icons.notifications_outlined,
                            title: 'prayer_notifications'.tr,
                            subtitle: 'prayer_notifications_sub'.tr,
                            value: _notifications,
                            onChanged: (value) {
                              setState(() {
                                _notifications = value;
                              });
                            },
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildSwitchItem(
                            icon: Icons.location_on_outlined,
                            title: 'location_title'.tr,
                            subtitle: 'location_sub'.tr,
                            value: _location,
                            onChanged: (value) {
                              setState(() {
                                _location = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Support Section
                    _buildSectionHeader('help_support'.tr),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldDark,width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildActionItem(
                            icon: Icons.help_outline,
                            title: 'faq'.tr,
                            isRtl: isRtl,
                            onTap: () {},
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildActionItem(
                            icon: Icons.contact_support_outlined,
                            title: 'contact_us'.tr,
                            isRtl: isRtl,
                            onTap: () {},
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildActionItem(
                            icon: Icons.info_outline,
                            title: 'about_us'.tr,
                            isRtl: isRtl,
                            onTap: () {},
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildActionItem(
                            icon: Icons.share_outlined,
                            title: 'share_app'.tr,
                            isRtl: isRtl,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Danger Zone
                    _buildSectionHeader('account_management'.tr),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldDark,width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDangerItem(
                            icon: Icons.logout,
                            title: 'logout'.tr,
                            color: AppTheme.warning,
                            onTap: () => _showLogoutDialog(),
                          ),
                          const Divider(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.goldDark,width: 0.5),
                            ),
                          ),
                          const Divider(height: 12),
                          _buildDangerItem(
                            icon: Icons.delete_forever,
                            title: 'delete_account'.tr,
                            color: AppTheme.error,
                            onTap: () => _showDeleteAccountDialog(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Version Info
                    Center(
                      child: Text(
                        'app_name'.tr + ' v1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.gold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  subtitleWidget ??
                      Text(
                        subtitle ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.black, fontSize: 12),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryGreen,
          activeTrackColor: AppTheme.primaryGreen.withOpacity(0.6),
        ),
      ],
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required bool isRtl,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Directionality(
              // هنا السحر: إذا كان التطبيق عربي، اجعل الاتجاه RTL فيقلب الأيقونات تلقائياً
              textDirection: Get.locale?.languageCode == 'ar'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Row(
                children: [
                  Icon(Icons.arrow_forward_ios, color: Colors.black,size: 15,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String keyKey, String currentValue) {
    final TextEditingController textEditingController = TextEditingController(
      text: currentValue,
    );

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${'edit'.tr} ${keyKey.tr}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        content: TextField(
          controller: textEditingController,
          decoration: InputDecoration(
            hintText: '${'enter_new'.tr} ${keyKey.tr}',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              if (keyKey == 'username') {
                controller.updateName(textEditingController.text);
              } else if (keyKey == 'email') {
                controller.updateEmail(textEditingController.text);
              }
              Get.back();
              Get.snackbar(
                'success_title'.tr,
                '${keyKey.tr} ${'updated_success'.tr}',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditImageDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'change_profile_image'.tr,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'camera'.tr,
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'gallery'.tr,
                  onTap: () {
                    Get.back();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showPasswordDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'change_password'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'current_password'.tr),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'new_password'.tr),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'confirm_new_password'.tr),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'success_title'.tr,
                'password_changed_success'.tr,
                backgroundColor: AppTheme.success,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'logout'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        content: Text(
          'logout_confirm_msg'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning),
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'delete_account'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(color: AppTheme.error),
        ),
        content: Text(
          'delete_account_confirm_msg'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('delete_account'.tr),
          ),
        ],
      ),
    );
  }
}
