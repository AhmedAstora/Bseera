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
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.warmWhite, AppTheme.cream],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl, // 🌟 تأكيد الاتجاه العربي للواجهة بالكامل
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
                      )
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      )
                          .animate(key: ValueKey(_isLogin)) // إعادة تشغيل الحركة عند التبديل
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 8),

                      Text(
                        _isLogin
                            ? 'مرحباً بعودتك! سجل دخولك للمتابعة'
                            : 'أنشئ حساباً جديداً للبدء',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Form Fields
                      if (!_isLogin) ...[
                        _buildTextField(
                          key: const ValueKey('name_field'),
                          controller: _nameController,
                          hint: 'الاسم الكامل',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          key: const ValueKey('phone_field'),
                          controller: _phoneController,
                          hint: 'رقم الهاتف',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildTextField(
                        key: const ValueKey('email_field'),
                        controller: _emailController,
                        hint: 'البريد الإلكتروني',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        key: const ValueKey('password_field'),
                        controller: _passwordController,
                        hint: 'كلمة المرور',
                        icon: Icons.lock_outline,
                        isPassword: true,
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
                                  activeColor: AppTheme.primaryGreen,
                                ),
                                Text(
                                  'تذكرني',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showForgotPasswordDialog(),
                              child: Text(
                                'نسيت كلمة المرور؟',
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
                          _isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
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
                          Expanded(child: Divider(color: AppTheme.sand)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'أو استمر باستخدام',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Expanded(child: Divider(color: AppTheme.sand)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Social Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(Icons.g_mobiledata, 'Google', Colors.red),
                          const SizedBox(width: 16),
                          _buildSocialButton(Icons.facebook, 'Facebook', Colors.blue),
                          const SizedBox(width: 16),
                          _buildSocialButton(Icons.apple, 'Apple', Colors.black),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Toggle Login/Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin ? 'سجل الآن' : 'تسجيل الدخول',
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
        )
    );
    }

  Widget _buildTextField({
    required Key key, // 🌟 إضافة مفتاح لمنع تداخل قيم الحقول عند التبديل
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      key: key,
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        // 🌟 جعل أيقونة التوضيح في اليمين (suffix) بدلاً من اليمين المعكوس لتناسب الـ RTL العربي
        suffixIcon: Icon(icon, color: AppTheme.primaryGreen.withOpacity(0.6)),
        prefixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.primaryGreen.withOpacity(0.6),
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
    )
        .animate(key: key)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
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

  void _showForgotPasswordDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'استعادة كلمة المرور',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        content: Directionality(
          textDirection: TextDirection.rtl, // 🌟 ضبط اتجاه نافذة الحوار للعربية
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل بريدك الإلكتروني لإرسال رمز التحقق',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'البريد الإلكتروني',
                  suffixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryGreen.withOpacity(0.6)),
                ),
              ),
              const SizedBox(height: 20),
              // Verification Code Label
              Text(
                'رمز التحقق الافتراضي',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              // Verification Code Visual Placeholders
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
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            child: const Text('إرسال', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}