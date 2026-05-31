import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:hijri/hijri_calendar.dart';
import '../theme/app_theme.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  double _latitude = 31.7683;
  double _longitude = 35.2137;
  String _locationName = 'default_location'.tr; // 🌟 مفتاح فلسطين أو الموقع الافتراضي
  bool _isLoading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAdhanPlaying = false;
  StreamSubscription? _accelerometerSubscription;
  Timer? _countdownTimer;
  List<Map<String, dynamic>> _prayerTimes = [];
  String _nextPrayerKey = ''; // 🌟 حفظ مفتاح الترجمة بدلاً من الاسم العربي الثابت
  String _timeLeftToNextPrayer = '--:--:--';

  @override
  void initState() {
    super.initState();
    _getUserLocationAndCalculate();
    _initFlipToMute();
  }

  void _initFlipToMute() {
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.z < -9 && _isAdhanPlaying) {
        _stopAdhan();
      }
    });
  }

  Future<void> _stopAdhan() async {
    await _audioPlayer.stop();
    setState(() {
      _isAdhanPlaying = false;
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _playAdhan() async {
    if (!_isAdhanPlaying) {
      _isAdhanPlaying = true;
      await _audioPlayer.play(AssetSource('audio/adhan.mp3'));
    }
  }

  Future<void> _getUserLocationAndCalculate() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationName = 'current_location'.tr; // 🌟 ترجمة موقعي الحالي
        });
      }
    } catch (e) {
      debugPrint('Error fetching location: $e');
    } finally {
      _calculatePrayers();
      _startCountdown();
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _calculatePrayers();
    });
  }

  void _calculatePrayers() {
    final coordinates = Coordinates(_latitude, _longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final now = DateTime.now();
    final prayerTimesData = PrayerTimes(coordinates, DateComponents.from(now), params);

    // 🌟 جعل تنسيق الوقت يتبع لغة التطبيق الحالية (تلقائياً AM/PM أو ص/م)
    final String currentLangCode = Get.locale?.languageCode ?? 'ar';
    final timeFormat = DateFormat.jm(currentLangCode);
    final nextPrayer = prayerTimesData.nextPrayer();

    setState(() {
      _prayerTimes = [
        {'key': 'fajr', 'time': timeFormat.format(prayerTimesData.fajr.toLocal()), 'icon': Icons.wb_twilight, 'isNext': nextPrayer == Prayer.fajr},
        {'key': 'sunrise', 'time': timeFormat.format(prayerTimesData.sunrise.toLocal()), 'icon': Icons.wb_sunny, 'isNext': nextPrayer == Prayer.sunrise},
        {'key': 'dhuhr', 'time': timeFormat.format(prayerTimesData.dhuhr.toLocal()), 'icon': Icons.wb_sunny_outlined, 'isNext': nextPrayer == Prayer.dhuhr},
        {'key': 'asr', 'time': timeFormat.format(prayerTimesData.asr.toLocal()), 'icon': Icons.wb_cloudy, 'isNext': nextPrayer == Prayer.asr},
        {'key': 'maghrib', 'time': timeFormat.format(prayerTimesData.maghrib.toLocal()), 'icon': Icons.nights_stay, 'isNext': nextPrayer == Prayer.maghrib},
        {'key': 'isha', 'time': timeFormat.format(prayerTimesData.isha.toLocal()), 'icon': Icons.bedtime, 'isNext': nextPrayer == Prayer.isha},
      ];

      if (nextPrayer != Prayer.none) {
        _nextPrayerKey = _getPrayerNameKey(nextPrayer);
        final nextPrayerTime = prayerTimesData.timeForPrayer(nextPrayer)!.toLocal();
        final diff = nextPrayerTime.difference(now);
        if (diff.inSeconds <= 0 && diff.inSeconds > -5) { _playAdhan(); }
        else if (diff.inSeconds > 5) { _isAdhanPlaying = false; }
        _timeLeftToNextPrayer = '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      } else {
        _nextPrayerKey = 'fajr';
        _timeLeftToNextPrayer = '00:00:00';
      }
      _isLoading = false;
    });
  }

  // 🌟 دالة تعيد مفتاح الترجمة الخاص بكل صلاة من حزمة adhan
  String _getPrayerNameKey(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'fajr';
      case Prayer.sunrise: return 'sunrise';
      case Prayer.dhuhr: return 'dhuhr';
      case Prayer.asr: return 'asr';
      case Prayer.maghrib: return 'maghrib';
      case Prayer.isha: return 'isha';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isRtl = Get.locale?.languageCode == 'ar';
    final String currentLangCode = Get.locale?.languageCode ?? 'ar';

    // تهيئة التاريخ الهجري
    final hijriDateData = HijriCalendar.now();
    final hijriDate = "${hijriDateData.hDay} ${hijriDateData.longMonthName} ${hijriDateData.hYear} ${'hijri_symbol'.tr}";
    final gregorianDate = DateFormat('EEEE, d MMMM yyyy', currentLangCode).format(now);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text('prayer_times'.tr, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Text(hijriDate, style: const TextStyle(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(gregorianDate, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(_locationName, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.access_time, color: AppTheme.gold, size: 20),
                                  const SizedBox(width: 8),
                                  Text('${'next_prayer_title'.tr}: ${_nextPrayerKey.tr}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16))
                                ]
                            ),
                            const SizedBox(height: 16),
                            Text(_timeLeftToNextPrayer, style: const TextStyle(color: AppTheme.gold, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            // 🌟 دمج الترجمة المتداخلة (متبقي على صلاة ...)
                            Text('${'time_left_for'.tr} ${_nextPrayerKey.tr}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _prayerTimes.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 12),
                          itemBuilder: (c, i) => _buildPrayerCard(_prayerTimes[i], isRtl)
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer, bool isRtl) {
    final isNext = prayer['isNext'] as bool;
    final String prayerKey = prayer['key'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isNext ? AppTheme.primaryGreen : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: isNext ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isNext ? AppTheme.gold.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(prayer['icon'] as IconData, color: isNext ? AppTheme.gold : AppTheme.primaryGreen, size: 24)),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                // 🌟 جعل المحاذاة مرنة تتبع اتجاه لغة الواجهة لمنع الأخطاء البصرية
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prayerKey.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isNext ? Colors.white : AppTheme.charcoal)),
                    if (isNext) Text('next_prayer'.tr, style: const TextStyle(fontSize: 12, color: AppTheme.gold))
                  ]
              )
          ),
          Text(prayer['time'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isNext ? AppTheme.gold : AppTheme.primaryGreen)),
          if (isNext) Padding(padding: EdgeInsets.only(left: isRtl ? 0 : 8, right: isRtl ? 8 : 0), child: const Icon(Icons.notifications_active, color: AppTheme.gold, size: 20)),
        ],
      ),
    );
  }
}