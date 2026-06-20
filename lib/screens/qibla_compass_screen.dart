import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  double _direction = 0.0;
  double _qiblaAngle = 0.0;
  bool _isLoading = true;

  // ===== ألوان الهوية البصرية =====
  static const Color _bgDark = Color(0xFF0B1320);
  static const Color _dialDark = Color(0xFF111B2E);
  static const Color _gold = Color(0xFFE8B339);
  static const Color _goldLight = Color(0xFFF6D27A);
  static const Color _goldDeep = Color(0xFFB9842A);

  @override
  void initState() {
    super.initState();
    _startEverything();
  }

  // ====== المنطق البرمجي الأصلي بدون أي تغيير ======
  Future<void> _startEverything() async {
    // 1. طلب الصلاحيات
    await [Permission.location, Permission.notification].request();

    // 2. تعيين موقع افتراضي (رفح) فوراً لضمان فتح الشاشة
    _updateQiblaAngle(31.2825, 34.2415);

    // 3. جلب الموقع الحقيقي في الخلفية
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
        .then((pos) => _updateQiblaAngle(pos.latitude, pos.longitude))
        .catchError((e) => print("GPS غير متاح: $e"));

    // 4. تشغيل البوصلة
    FlutterCompass.events?.listen((event) {
      if (mounted) setState(() => _direction = event.heading ?? 0.0);
    });

    // 5. إغلاق شاشة التحميل
    if (mounted) setState(() => _isLoading = false);
  }

  void _updateQiblaAngle(double lat, double lon) {
    double angle = _calculateQibla(lat, lon);
    if (mounted) setState(() => _qiblaAngle = angle);
  }

  double _calculateQibla(double lat, double lon) {
    double phiM = 21.4225 * math.pi / 180;
    double lambdaM = 39.8262 * math.pi / 180;
    double phi = lat * math.pi / 180;
    double lambda = lon * math.pi / 180;
    double y = math.sin(lambdaM - lambda);
    double x = math.cos(phi) * math.tan(phiM) - math.sin(phi) * math.cos(lambdaM - lambda);
    return math.atan2(y, x) * 180 / math.pi;
  }
  // ====== نهاية المنطق البرمجي الأصلي ======

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgDark,
        body: const Center(
          child: CircularProgressIndicator(color: _gold, strokeWidth: 3),
        ),
      );
    }

    double rotation = (_direction - _qiblaAngle) * (math.pi / 180) * -1;
    final bool isAligned = _angleDiff(_direction, _qiblaAngle) < 5;

    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusChip(isAligned),
                    const SizedBox(height: 28),
                    _buildCompassDial(rotation),
                    const SizedBox(height: 36),
                    Text(
                      isAligned ? "أنت متجه الآن نحو القبلة" : "أدر الهاتف حتى يشير السهم للأعلى",
                      style: TextStyle(
                        fontSize: 15,
                        color: isAligned ? _goldLight : Colors.white60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _angleDiff(double a, double b) {
    double diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Column(
            children: const [
              Text(
                "بوصلة القبلة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Qibla Finder",
                style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isAligned) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isAligned ? _gold.withOpacity(0.15) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAligned ? _gold : Colors.white24,
          width: 1,
        ),
      ),
      child: Text(
        "${_qiblaAngle.toStringAsFixed(0)}° عن الشمال",
        style: TextStyle(
          color: isAligned ? _goldLight : Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCompassDial(double rotation) {
    const double size = 300;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_goldLight, _goldDeep, _gold],
        ),
        boxShadow: [
          BoxShadow(color: _gold.withOpacity(0.35), blurRadius: 30, spreadRadius: 2),
          const BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [_dialDark, _bgDark],
            radius: 0.9,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // درجات وعلامات البوصلة
            CustomPaint(
              size: const Size(size - 20, size - 20),
              painter: _CompassDialPainter(),
            ),
            // مؤشر القبلة الدوار
            Transform.rotate(
              angle: rotation,
              child: CustomPaint(
                size: const Size(size - 20, size - 20),
                painter: _NeedlePainter(),
              ),
            ),
            // المحور المركزي
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_goldLight, _goldDeep]),
                border: Border.all(color: _bgDark, width: 2),
                boxShadow: [BoxShadow(color: _gold.withOpacity(0.6), blurRadius: 8)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== رسم وجه البوصلة: التدرجات والأرقام والاتجاهات =====
class _CompassDialPainter extends CustomPainter {
  static const Color gold = Color(0xFFE8B339);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.2;
    final majorTickPaint = Paint()
      ..color = gold.withOpacity(0.9)
      ..strokeWidth = 2;

    for (int deg = 0; deg < 360; deg += 6) {
      final isMajor = deg % 30 == 0;
      final rad = deg * math.pi / 180;
      final outer = Offset(
        center.dx + radius * 0.94 * math.sin(rad),
        center.dy - radius * 0.94 * math.cos(rad),
      );
      final innerLen = isMajor ? radius * 0.82 : radius * 0.88;
      final inner = Offset(
        center.dx + innerLen * math.sin(rad),
        center.dy - innerLen * math.cos(rad),
      );
      canvas.drawLine(inner, outer, isMajor ? majorTickPaint : tickPaint);
    }

    // أرقام كل 30 درجة
    for (int deg = 0; deg < 360; deg += 30) {
      final rad = deg * math.pi / 180;
      final pos = Offset(
        center.dx + radius * 0.7 * math.sin(rad),
        center.dy - radius * 0.7 * math.cos(rad),
      );
      _drawText(canvas, "$deg", pos, Colors.white54, 10);
    }

    // الاتجاهات الأساسية N E S W
    _drawCardinal(canvas, center, radius, 0, "N", gold, 16);
    _drawCardinal(canvas, center, radius, 90, "E", Colors.white70, 14);
    _drawCardinal(canvas, center, radius, 180, "S", Colors.white70, 14);
    _drawCardinal(canvas, center, radius, 270, "W", Colors.white70, 14);
  }

  void _drawCardinal(Canvas canvas, Offset center, double radius, int deg, String label, Color color, double fontSize) {
    final rad = deg * math.pi / 180;
    final pos = Offset(
      center.dx + radius * 0.55 * math.sin(rad),
      center.dy - radius * 0.55 * math.cos(rad),
    );
    _drawText(canvas, label, pos, color, fontSize, bold: true);
  }

  void _drawText(Canvas canvas, String text, Offset center, Color color, double fontSize, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ===== رسم مؤشر القبلة (إبرة ذهبية مع رمز الكعبة) =====
class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // الجزء الشمالي (المؤشر باتجاه القبلة) - تدرج ذهبي
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.78)
      ..lineTo(center.dx - 9, center.dy - radius * 0.18)
      ..lineTo(center.dx + 9, center.dy - radius * 0.18)
      ..close();

    final northPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF6D27A), Color(0xFFB9842A)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.8));
    canvas.drawPath(northPath, northPaint);

    // الجزء الجنوبي (الذيل) - رمادي داكن
    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius * 0.45)
      ..lineTo(center.dx - 7, center.dy - radius * 0.05)
      ..lineTo(center.dx + 7, center.dy - radius * 0.05)
      ..close();
    final southPaint = Paint()..color = const Color(0xFF3A4456);
    canvas.drawPath(southPath, southPaint);

    // رمز الكعبة عند رأس المؤشر
    final kaabaCenter = Offset(center.dx, center.dy - radius * 0.78 + 14);
    final kaabaRect = Rect.fromCenter(center: kaabaCenter, width: 18, height: 16);
    final kaabaPaint = Paint()..color = const Color(0xFF161616);
    final kaabaBorder = Paint()
      ..color = const Color(0xFFE8B339)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final kaabaRrect = RRect.fromRectAndRadius(kaabaRect, const Radius.circular(2));
    canvas.drawRRect(kaabaRrect, kaabaPaint);
    canvas.drawRRect(kaabaRrect, kaabaBorder);
    // الحزام الذهبي العلوي لتمثيل كسوة الكعبة
    final beltPaint = Paint()..color = const Color(0xFFE8B339);
    canvas.drawRect(
      Rect.fromLTWH(kaabaRect.left, kaabaRect.top + 3, kaabaRect.width, 2.2),
      beltPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}