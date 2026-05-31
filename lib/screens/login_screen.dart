import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 فحص اتجاه اللغة الحالية ديناميكياً للتطبيق بالكامل
    final bool isRtl = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.warmWhite, AppTheme.cream],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Directionality(
            // 🌟 استبدال الاتجاه الثابت باتجاه مرن يتغير بتغير اللغة
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mosque,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      _isLogin ? 'login'.tr : 'register'.tr, // 🌟 ترجمة العنوان
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayMedium,
                    )
                        .animate(key: ValueKey(_isLogin))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      _isLogin
                          ? 'welcome_back'.tr // 🌟 ترجمة نص الترحيب بالدخول
                          : 'create_account_start'.tr, // 🌟 ترجمة نص البدء لإنشاء الحساب
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black),
                    ),

                    const SizedBox(height: 32),

                    // Form Fields
                    if (!_isLogin) ...[
                      _buildTextField(
                        key: const ValueKey('name_field'),
                        controller: _nameController,
                        hint: 'full_name'.tr, // 🌟 ترجمة الاسم الكامل
                        icon: Icons.person_outline,
                        isRtl: isRtl,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        key: const ValueKey('phone_field'),
                        controller: _phoneController,
                        hint: 'phone_number'.tr, // 🌟 ترجمة رقم الهاتف
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        isRtl: isRtl,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildTextField(
                      key: const ValueKey('email_field'),
                      controller: _emailController,
                      hint: 'email'.tr, // 🌟 ترجمة البريد الإلكتروني
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isRtl: isRtl,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      key: const ValueKey('password_field'),
                      controller: _passwordController,
                      hint: 'password'.tr, // 🌟 ترجمة كلمة المرور
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isRtl: isRtl,
                    ),

                    const SizedBox(height: 16),

                    // Remember Me & Forgot Password
                    if (_isLogin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: Colors.black,
                                checkColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              Text(
                                'remember_me'.tr, // 🌟 ترجمة تذكرني
                                style: const TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () => _showForgotPasswordDialog(isRtl),
                            child: Text(
                              'forgot_password_q'.tr, // 🌟 ترجمة نسيت كلمة المرور؟
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Main Button
                    ElevatedButton(
                      onPressed: () => Get.offNamed('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isLogin ? 'login'.tr : 'register'.tr, // 🌟 ترجمة نص الزر الرئيسي
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppTheme.sand)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or_continue_with'.tr, // 🌟 ترجمة أو استمر باستخدام
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppTheme.sand)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          Icons.g_mobiledata,
                          'Google',
                          Colors.red,
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(
                          Icons.facebook,
                          'Facebook',
                          Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _buildSocialButton(Icons.apple, 'Apple', Colors.black),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Toggle Login/Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? 'dont_have_account'.tr : 'already_have_account'.tr, // 🌟 ترجمة نصوص التحويل الفرعية
                          style: const TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? 'register_now'.tr : 'login'.tr, // 🌟 ترجمة أزرار التحويل
                            style: const TextStyle(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required Key key,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    required bool isRtl, // مررنا حالة اتجاه اللغة للحقل
  }) {
    return TextField(
      key: key,
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      // 🌟 محاذاة النص تتغير تلقائياً حسب لغة الواجهة الحالية لإصلاح المظهر الإنجليزي والعربي
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black),
        // 🌟 نستخدم prefixIcon للأيقونة الأساسية و suffixIcon لأيقونة الرؤية لكي يتناسب الانقلاب البصري مع الـ LTR والـ RTL تلقائياً
        prefixIcon: Icon(icon, color: Colors.black),
        fillColor: const Color(0x158B9EE0),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
    ).animate(key: key).fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }

  void _showForgotPasswordDialog(bool isRtl) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'reset_password'.tr, // 🌟 ترجمة استعادة كلمة المرور
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        content: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr, // 🌟 ضبط مرن لاتجاه الحوار
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'enter_email_reset_desc'.tr, // 🌟 ترجمة أدخل بريدك الإلكتروني...
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText: 'email'.tr, // 🌟 ترجمة حقل الإيميل داخل الديالوج
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'default_verification_code'.tr, // 🌟 ترجمة رمز التحقق الافتراضي
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.sand),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: const Center(
                      child: Text(
                        '5',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('cancel'.tr, style: const TextStyle(color: AppTheme.primaryGreen)) // 🌟 ترجمة إلغاء
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text('send'.tr, style: const TextStyle(color: Colors.white)), // 🌟 ترجمة إرسال
          ),
        ],
      ),
    );
  }
}