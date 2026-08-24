import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:hijri/hijri_calendar.dart';
import '../services/azan_service.dart';
import '../theme/app_theme.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final AzanService _azan = AzanService.instance;

  bool _isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isAdhanPlaying = false;
  StreamSubscription? _accelerometerSubscription;
  Timer? _countdownTimer;
  List<Map<String, dynamic>> _prayerTimes = [];
  String _nextPrayerKey = '';
  String _timeLeftToNextPrayer = '--:--:--';

  @override
  void initState() {
    super.initState();
    _load();
    _initFlipToMute();
  }

  Future<void> _load() async {
    if (!_azan.isInitialized) {
      await _azan.init();
    } else {
      // نحدث الجدولة إذا اليوم تغيّر ولسا ما انجدولت أوقات جديدة
      await _azan.ensureScheduleIsFresh();
    }
    setState(() => _isLoading = false);
    _tick(); // أول حساب فوري
    _startCountdown();
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

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) _tick();
    });
  }

  /// يقرأ أوقات الصلاة المحسوبة مسبقاً من AzanService (مش بيحسب موقع من جديد)
  /// وبس يحدث العد التنازلي وتشغيل صوت الأذان أثناء فتح الشاشة (المؤثر الصوتي
  /// أثناء الاستخدام الفعلي؛ الإشعار بالخلفية مجدول أصلاً من AzanService).
  void _tick() {
    final prayerTimesData = _azan.todayPrayerTimes;
    if (prayerTimesData == null) return;

    final now = DateTime.now();
    final timeFormat = DateFormat.jm('ar');

    Prayer nextPrayer = prayerTimesData.nextPrayer();
    if (nextPrayer == Prayer.none) nextPrayer = Prayer.fajr;

    DateTime prayerTime = prayerTimesData.timeForPrayer(nextPrayer)!.toLocal();
    if (prayerTime.isBefore(now)) {
      prayerTime = prayerTime.add(const Duration(days: 1));
    }
    final diff = prayerTime.difference(now);

    // تشغيل صوت الأذان محليًا إذا الشاشة مفتوحة فعليًا وقت الأذان بالضبط
    if (diff.inSeconds >= 0 && diff.inSeconds <= 1) {
      _playAdhan();
    } else if (diff.inSeconds > 5) {
      _isAdhanPlaying = false;
    }

    setState(() {
      _prayerTimes = [
        {
          'key': 'fajr',
          'time': timeFormat.format(prayerTimesData.fajr.toLocal()),
          'icon': Icons.wb_twilight,
          'isNext': nextPrayer == Prayer.fajr
        },
        {
          'key': 'sunrise',
          'time': timeFormat.format(prayerTimesData.sunrise.toLocal()),
          'icon': Icons.wb_sunny,
          'isNext': nextPrayer == Prayer.sunrise
        },
        {
          'key': 'dhuhr',
          'time': timeFormat.format(prayerTimesData.dhuhr.toLocal()),
          'icon': Icons.wb_sunny_outlined,
          'isNext': nextPrayer == Prayer.dhuhr
        },
        {
          'key': 'asr',
          'time': timeFormat.format(prayerTimesData.asr.toLocal()),
          'icon': Icons.wb_cloudy,
          'isNext': nextPrayer == Prayer.asr
        },
        {
          'key': 'maghrib',
          'time': timeFormat.format(prayerTimesData.maghrib.toLocal()),
          'icon': Icons.nights_stay,
          'isNext': nextPrayer == Prayer.maghrib
        },
        {
          'key': 'isha',
          'time': timeFormat.format(prayerTimesData.isha.toLocal()),
          'icon': Icons.bedtime,
          'isNext': nextPrayer == Prayer.isha
        },
      ];
      _nextPrayerKey = _azan.nextPrayerKey;
      _timeLeftToNextPrayer =
      '${diff.inHours.toString().padLeft(2, '0')}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
    });
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
    final hijriDateData = HijriCalendar.now();
    final hijriDate = "${hijriDateData.hDay} ${hijriDateData
        .longMonthName} ${hijriDateData.hYear} ${'hijri_symbol'.tr}";
    final gregorianDate = DateFormat('EEEE, d MMMM yyyy', 'ar')
        .format(now);

    return Scaffold(
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text('prayer_times'.tr, style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
              background: Container(
                decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Text(hijriDate, style: const TextStyle(
                            color: AppTheme.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(gregorianDate, style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                            (_azan.locationName == 'default_location' ||
                                    _azan.locationName == 'current_location')
                                ? _azan.locationName.tr
                                : _azan.locationName,
                            style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12)),
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
                    decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldDark),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primaryGreen.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ]),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [const Icon(
                                Icons.access_time, color: AppTheme.gold,
                                size: 20), const SizedBox(width: 8), Text(
                                '${'next_prayer_title'.tr}: ${_nextPrayerKey
                                    .tr}', style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16))
                            ]),
                        const SizedBox(height: 16),
                        Text(_timeLeftToNextPrayer,
                            style: const TextStyle(color: AppTheme.gold,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text('${'time_left_for'.tr} ${_nextPrayerKey.tr}',
                            style: TextStyle(color: Colors.white.withOpacity(
                                0.7), fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _prayerTimes.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 12),
                    itemBuilder: (c, i) =>
                        _buildPrayerCard(_prayerTimes[i]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer) {
    final isNext = prayer['isNext'] as bool;
    final String prayerKey = prayer['key'] as String;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldDark, width: 1.5),
        boxShadow: [
          BoxShadow(
              color: isNext ? AppTheme.primaryGreen.withOpacity(0.2) : Colors
                  .black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: isNext ? AppTheme.gold.withOpacity(0.2) : AppTheme
                    .primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(prayer['icon'] as IconData,
                color: isNext ? AppTheme.gold : AppTheme.primaryGreen,
                size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prayerKey.tr, style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isNext ? Colors.white : AppTheme.charcoal)),
              if (isNext) Text('next_prayer'.tr,
                  style: const TextStyle(fontSize: 12, color: AppTheme.gold)),
            ]),
          ),
          Text(prayer['time'] as String, style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isNext ? AppTheme.gold : AppTheme.primaryGreen)),
          if (isNext) const Padding(padding: EdgeInsets.only(right: 8),
              child: Icon(
                  Icons.notifications_active, color: AppTheme.gold, size: 20)),
        ],
      ),
    );
  }
}