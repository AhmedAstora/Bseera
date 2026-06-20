import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../theme/app_theme.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  static double _latitude = 31.7683;
  static double _longitude = 35.2137;
  static String _locationName = 'default_location'.tr;
  static bool _isInitialized = false;

  bool _isLoading = !_isInitialized;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isAdhanPlaying = false;
  StreamSubscription? _accelerometerSubscription;
  Timer? _countdownTimer;
  List<Map<String, dynamic>> _prayerTimes = [];
  String _nextPrayerKey = '';
  String _timeLeftToNextPrayer = '--:--:--';

  @override
  void initState() {
    super.initState();
    _initNotifications();
    if (!_isInitialized) {
      _getUserLocationAndCalculate();
    } else {
      _calculatePrayers();
      _startCountdown();
    }
    _initFlipToMute();
  }

  Future<void> _initNotifications() async {
    // هنا نحدد اسم الأيقونة التي وضعناها في مجلد drawable (بدون امتداد .png)
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('ic_notification');

    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _showPrayerNotification(String prayerName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_channel_id',
      'تنبيهات الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      // هنا نحدد أيقونة اللوجو الخاص بنا
      icon: 'ic_notification',
      // يمكنك تلوين اللوجو في شريط التنبيهات إذا أردت
      color: AppTheme.primaryGreenDark,
      colorized: true,
    );

    await _notificationsPlugin.show(
      0,
      '🕌 ${'prayer_time'.tr}',
      '${'time_left_for'.tr} ${prayerName.tr}',
      const NotificationDetails(android: androidDetails),
    );
  }

  void _initFlipToMute() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (event.z < -9 && _isAdhanPlaying) _stopAdhan();
    });
  }

  Future<void> _stopAdhan() async {
    await _audioPlayer.stop();
    setState(() => _isAdhanPlaying = false);
  }

  Future<void> _playAdhan() async {
    if (_isAdhanPlaying) return;
    _isAdhanPlaying = true;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('audio/adhan.mp3'));
  }

  Future<void> _getUserLocationAndCalculate() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = 'current_location'.tr;
      }
    } catch (e) { debugPrint('GPS Error: $e'); }
    finally {
      _isInitialized = true;
      if (mounted) setState(() { _isLoading = false; _calculatePrayers(); _startCountdown(); });
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
    final String currentLangCode = Get.locale?.languageCode ?? 'ar';
    final timeFormat = DateFormat.jm(currentLangCode);

    Prayer? nextPrayer = prayerTimesData.nextPrayer() ?? Prayer.fajr;
    if (nextPrayer == Prayer.none) nextPrayer = Prayer.fajr;

    DateTime prayerTime = prayerTimesData.timeForPrayer(nextPrayer!)!.toLocal();
    if (prayerTime.isBefore(now)) prayerTime = prayerTime.add(const Duration(days: 1));
    final diff = prayerTime.difference(now);

    // منطق التنبيه قبل 15 دقيقة (900 ثانية)
    if (diff.inSeconds >= 898 && diff.inSeconds <= 902) {
      _showPrayerNotification(_getPrayerNameKey(nextPrayer));
    }

    // منطق الأذان
    if (diff.inSeconds >= 0 && diff.inSeconds <= 1) _playAdhan();
    else if (diff.inSeconds > 5) _isAdhanPlaying = false;

    setState(() {
      _prayerTimes = [
        {'key': 'fajr', 'time': timeFormat.format(prayerTimesData.fajr.toLocal()), 'icon': Icons.wb_twilight, 'isNext': nextPrayer == Prayer.fajr},
        {'key': 'sunrise', 'time': timeFormat.format(prayerTimesData.sunrise.toLocal()), 'icon': Icons.wb_sunny, 'isNext': nextPrayer == Prayer.sunrise},
        {'key': 'dhuhr', 'time': timeFormat.format(prayerTimesData.dhuhr.toLocal()), 'icon': Icons.wb_sunny_outlined, 'isNext': nextPrayer == Prayer.dhuhr},
        {'key': 'asr', 'time': timeFormat.format(prayerTimesData.asr.toLocal()), 'icon': Icons.wb_cloudy, 'isNext': nextPrayer == Prayer.asr},
        {'key': 'maghrib', 'time': timeFormat.format(prayerTimesData.maghrib.toLocal()), 'icon': Icons.nights_stay, 'isNext': nextPrayer == Prayer.maghrib},
        {'key': 'isha', 'time': timeFormat.format(prayerTimesData.isha.toLocal()), 'icon': Icons.bedtime, 'isNext': nextPrayer == Prayer.isha},
      ];
      _nextPrayerKey = _getPrayerNameKey(nextPrayer!);
      _timeLeftToNextPrayer = '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      _isLoading = false;
    });
  }

  String _getPrayerNameKey(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'fajr';
      case Prayer.sunrise: return 'sunrise';
      case Prayer.dhuhr: return 'dhuhr';
      case Prayer.asr: return 'asr';
      case Prayer.maghrib: return 'maghrib';
      case Prayer.isha: return 'isha';
      default: return 'fajr';
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _audioPlayer.dispose();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isRtl = Get.locale?.languageCode == 'ar';
    final String currentLangCode = Get.locale?.languageCode ?? 'ar';
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
                    decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.goldDark), boxShadow: [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.access_time, color: AppTheme.gold, size: 20), const SizedBox(width: 8), Text('${'next_prayer_title'.tr}: ${_nextPrayerKey.tr}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16))]),
                        const SizedBox(height: 16),
                        Text(_timeLeftToNextPrayer, style: const TextStyle(color: AppTheme.gold, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        const SizedBox(height: 8),
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
                    itemBuilder: (c, i) => _buildPrayerCard(_prayerTimes[i], isRtl),
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
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark, width: 1.5),
        boxShadow: [BoxShadow(color: isNext ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isNext ? AppTheme.gold.withOpacity(0.2) : AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(prayer['icon'] as IconData, color: isNext ? AppTheme.gold : AppTheme.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prayerKey.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isNext ? Colors.white : AppTheme.charcoal)),
              if (isNext) Text('next_prayer'.tr, style: const TextStyle(fontSize: 12, color: AppTheme.gold)),
            ]),
          ),
          Text(prayer['time'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isNext ? AppTheme.gold : AppTheme.primaryGreen)),
          if (isNext) Padding(padding: EdgeInsets.only(left: isRtl ? 0 : 8, right: isRtl ? 8 : 0), child: const Icon(Icons.notifications_active, color: AppTheme.gold, size: 20)),
        ],
      ),
    );
  }
}