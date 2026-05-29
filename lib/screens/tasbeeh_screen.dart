import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _target = 33;
  String _selectedZikr = 'سُبْحَانَ اللَّهِ';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _azkarList = [
    {'text': 'سُبْحَانَ اللَّهِ', 'target': 33, 'color': AppTheme.primaryGreen},
    {'text': 'الْحَمْدُ لِلَّهِ', 'target': 33, 'color': AppTheme.teal},
    {'text': 'اللَّهُ أَكْبَرُ', 'target': 34, 'color': AppTheme.gold},
    {'text': 'لَا إِلَهَ إِلَّا اللَّهُ', 'target': 100, 'color': AppTheme.navy},
    {'text': 'أَسْتَغْفِرُ اللَّهَ', 'target': 100, 'color': AppTheme.primaryGreenLight},
    {'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ', 'target': 100, 'color': AppTheme.goldDark},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    _animationController.forward().then((_) => _animationController.reverse());
    setState(() {
      _counter++;
      if (_counter >= _target) {
        _counter = 0;
        _showCompletionDialog();
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _showCompletionDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withOpacity(0.2),
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.gold, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              'أحسنت!',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'لقد أكملت $_target تسبيحة',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('استمرار'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _counter / _target;

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
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      'المسبحة الإلكترونية',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: AppTheme.primaryGreen),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // Azkar Selector
              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _azkarList.length,
                  itemBuilder: (context, index) {
                    final zikr = _azkarList[index];
                    final isSelected = _selectedZikr == zikr['text'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedZikr = zikr['text'] as String;
                          _target = zikr['target'] as int;
                          _counter = 0;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? zikr['color'] as Color : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: (zikr['color'] as Color).withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            zikr['text'] as String,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.charcoal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Counter Circle
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _incrementCounter,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen,
                                  AppTheme.primaryGreenLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withOpacity(0.3),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Progress Ring
                                SizedBox(
                                  width: 260,
                                  height: 260,
                                  child: CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    backgroundColor: Colors.white.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.gold),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$_counter',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 72,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '/ $_target',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'اضغط للتسبيح',
                                      style: TextStyle(
                                        color: AppTheme.gold,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Selected Zikr Display
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  _selectedZikr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                    fontFamily: 'Amiri',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Control Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.restart_alt,
                      label: 'إعادة',
                      onTap: _resetCounter,
                      color: AppTheme.error,
                    ),
                    _buildControlButton(
                      icon: Icons.remove,
                      label: 'تراجع',
                      onTap: () {
                        if (_counter > 0) {
                          setState(() {
                            _counter--;
                          });
                        }
                      },
                      color: AppTheme.warning,
                    ),
                    _buildControlButton(
                      icon: Icons.vibration,
                      label: 'اهتزاز',
                      onTap: () {},
                      color: AppTheme.info,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
