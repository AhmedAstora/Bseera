import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _target = 33;
  int _lapCount = 0;
  String _selectedZikr = 'subhan_allah'.tr;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> _azkarList = [
    {'text': 'subhan_allah', 'target': 33, 'color': AppTheme.primaryGreen},
    {'text': 'alhamdulillah', 'target': 33, 'color': AppTheme.teal},
    {'text': 'allahu_akbar', 'target': 34, 'color': AppTheme.gold},
    {'text': 'la_ilaha_illallah', 'target': 100, 'color': AppTheme.navy},
    {
      'text': 'astaghfirullah',
      'target': 100,
      'color': AppTheme.primaryGreenLight,
    },
    {'text': 'allahumma_salli', 'target': 100, 'color': AppTheme.goldDark},
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
        _lapCount++;
        _counter = 0;
        _showCompletionDialog();
      }
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _lapCount = 0;
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
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.gold,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'well_done'.tr,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${'completed_lap'.tr} $_lapCount',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('continue'.tr),
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.primaryGreen,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      'tasbeeh_app'.tr,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: AppTheme.primaryGreen,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _azkarList.length,
                  itemBuilder: (context, index) {
                    final zikr = _azkarList[index];
                    final isSelected =
                        _selectedZikr == zikr['text'].toString().tr;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedZikr = zikr['text'].toString().tr;
                        _target = zikr['target'];
                        _counter = 0;
                        _lapCount = 0;
                      }),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? zikr['color'] : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            zikr['text'].toString().tr,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.charcoal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _incrementCounter,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryGreen,
                                      AppTheme.primaryGreen.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 25,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 260,
                                      height: 260,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.1),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              AppTheme.gold,
                                            ),
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '$_counter',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 72,
                                            fontWeight: FontWeight.bold,
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          '/ $_target',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 20,
                                right:
                                    Directionality.of(context) ==
                                        TextDirection.rtl
                                    ? -30
                                    : null,
                                left:
                                    Directionality.of(context) ==
                                        TextDirection.ltr
                                    ? -30
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gold,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '$_lapCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedZikr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: Icons.restart_alt,
                      label: 'restart'.tr,
                      onTap: _resetCounter,
                      color: AppTheme.error,
                    ),
                    _buildControlButton(
                      icon: Icons.remove,
                      label: 'undo'.tr,
                      onTap: () {
                        setState(() {
                          if (_counter > 0)
                            _counter--;
                          else if (_lapCount > 0) {
                            _lapCount--;
                            _counter = _target - 1;
                          }
                        });
                      },
                      color: AppTheme.warning,
                    ),
                  ],
                ),
              ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
