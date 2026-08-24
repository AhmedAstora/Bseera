import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// خدمة مركزية واحدة لكل ما يخص أوقات الصلاة والأذان:
/// - تخزّن الإعدادات بشكل دائم (GetStorage) فما بتنمسح مع الريستارت.
/// - تجدول إشعارات حقيقية (zonedSchedule) تشتغل حتى لو التطبيق مقفول.
/// - مصدر واحد للحقيقة لأوقات الصلاة تستخدمه كل الشاشات (Home + PrayerTimes)
///   بدل ما كل شاشة تجيب الموقع وتحسب لحالها.
class AzanService {
  AzanService._internal();
  static final AzanService instance = AzanService._internal();

  final GetStorage _box = GetStorage();
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _kLat = 'azan_lat';
  static const String _kLng = 'azan_lng';
  static const String _kLocationName = 'azan_location_name';
  static const String _kCountryCode = 'azan_country_code';
  static const String _kNotificationsEnabled = 'notifications';
  static const String _kLocationEnabled = 'location';
  static const String _kLastScheduleDay = 'azan_last_schedule_day';
  static const String _kHasRequestedExactAlarm = 'azan_has_requested_exact_alarm';

  double latitude = 31.7683;
  double longitude = 35.2137;
  String locationName = 'default_location';
  String? countryCode;
  bool isInitialized = false;

  PrayerTimes? todayPrayerTimes;

  bool get notificationsEnabled => _box.read(_kNotificationsEnabled) ?? true;
  bool get locationEnabled => _box.read(_kLocationEnabled) ?? true;

  /// يُستدعى مرة واحدة فقط عند إقلاع التطبيق (main.dart).
  Future<void> init() async {
    if (isInitialized) return;

    // 1) تهيئة قواعد المناطق الزمنية - ضرورية لـ zonedSchedule
    tz_data.initializeTimeZones();
    try {
      final String currentTimeZone =
          (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('AzanService: timezone fallback -> $e');
      tz.setLocalLocation(tz.getLocation('Asia/Amman'));
    }

    // 2) تهيئة الإشعارات - flutter_local_notifications ما إله دعم لمنصة الويب
    // إطلاقاً (بيرمي LateInitializationError لأي استدعاء)، فبنتجاوزه هناك
    // ومنكمل حساب مواقيت الصلاة عادي بدون جدولة إشعارات.
    if (!kIsWeb) {
      const AndroidInitializationSettings androidInit =
          AndroidInitializationSettings('ic_notification');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidInit);
      await notificationsPlugin.initialize(initSettings);

      await _requestPermissions();
    }

    // 3) قراءة آخر موقع محفوظ (حتى لو نرجع نفتح التطبيق بدون نت/جي بي اس بسرعة)
    _loadCachedLocation();

    // 4) إذا الموقع مفعّل بالإعدادات، حدّثه بالخلفية (ما بمنع تحميل الشاشة)
    if (locationEnabled) {
      await refreshLocation();
    }

    _computeTodayPrayerTimes();
    isInitialized = true;

    // 5) جدولة حقيقية للإشعارات إذا كانت مفعّلة
    if (notificationsEnabled) {
      await scheduleUpcomingPrayers();
    }
  }

  Future<void> _requestPermissions() async {
    final androidImpl = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    // إذن الإشعارات (أندرويد 13+)
    await androidImpl?.requestNotificationsPermission();

    // إذن الـ Exact Alarm (أندرويد 12+) - ضروري عشان الأذان يدق بوقته بالضبط.
    // بنطلبه مرة وحدة بس مدى حياة التطبيق (مش كل مرة يفتح فيها)، لأنه بيفتح
    // شاشة إعدادات النظام كاملة وبيقاطع واجهة التطبيق في كل إقلاع لو ضل يتكرر.
    final bool hasAskedBefore = _box.read(_kHasRequestedExactAlarm) ?? false;
    if (!hasAskedBefore) {
      await androidImpl?.requestExactAlarmsPermission();
      await _box.write(_kHasRequestedExactAlarm, true);
    }
  }

  void _loadCachedLocation() {
    latitude = _box.read(_kLat) ?? latitude;
    longitude = _box.read(_kLng) ?? longitude;
    locationName = _box.read(_kLocationName) ?? locationName;
    countryCode = _box.read(_kCountryCode) ?? countryCode;
  }

  /// يجيب الموقع الحالي، يخزنه بشكل دائم، ويحدّث أوقات اليوم.
  Future<void> refreshLocation() async {
    try {
      // فحص منفصل عن الإذن: ممكن الإذن يكون ممنوح بس خدمة الموقع (GPS) نفسها
      // مطفية من إعدادات الجهاز - هاي أكتر سبب شائع لبقاء الموقع على القيمة
      // الافتراضية دايماً حتى لو المستخدم وافق على الإذن سابقاً.
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('AzanService: location services are disabled on the device');
        _computeTodayPrayerTimes();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 5),
        );
        latitude = position.latitude;
        longitude = position.longitude;
        locationName = 'current_location';

        // نحاول نحول الإحداثيات لاسم مكان حقيقي (مثل "خان يونس" أو "غزة")
        // بدل ما يضل النص العام "موقعي الحالي". إذا فشل الاتصال أو ما رجع
        // نتيجة، منحافظ على القيمة الافتراضية فوق.
        try {
          final placemarks = await placemarkFromCoordinates(latitude, longitude);
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final resolvedName = [
              placemark.locality,
              placemark.subAdministrativeArea,
              placemark.administrativeArea,
            ].firstWhere(
              (name) => name != null && name.trim().isNotEmpty,
              orElse: () => null,
            );
            if (resolvedName != null) {
              locationName = resolvedName;
            }
            if (placemark.isoCountryCode != null &&
                placemark.isoCountryCode!.trim().isNotEmpty) {
              countryCode = placemark.isoCountryCode;
            }
          }
        } catch (e) {
          debugPrint('AzanService geocoding error: $e');
        }

        await _box.write(_kLat, latitude);
        await _box.write(_kLng, longitude);
        await _box.write(_kLocationName, locationName);
        await _box.write(_kCountryCode, countryCode);
      } else {
        debugPrint('AzanService: location permission not granted ($permission)');
      }
    } catch (e) {
      debugPrint('AzanService location error: $e');
    }
    _computeTodayPrayerTimes();
  }

  /// يحدد طريقة الحساب والمذهب المناسبين حسب دولة المستخدم (لو معروفة من
  /// آخر تحديد موقع)، بدل ما يضل التطبيق يستخدم رابطة العالم الإسلامي
  /// كطريقة وحيدة لكل الدول. القيمة الافتراضية (رابطة العالم الإسلامي +
  /// شافعي) بتضل مناسبة لفلسطين والأردن ومعظم بلاد الشام لو الدولة مش معروفة.
  CalculationMethod _resolveCalculationMethod() {
    switch (countryCode) {
      case 'SA':
        return CalculationMethod.umm_al_qura;
      case 'EG':
        return CalculationMethod.egyptian;
      case 'PK':
      case 'IN':
      case 'BD':
      case 'AF':
        return CalculationMethod.karachi;
      case 'AE':
      case 'OM':
      case 'BH':
        return CalculationMethod.dubai;
      case 'KW':
        return CalculationMethod.kuwait;
      case 'QA':
        return CalculationMethod.qatar;
      case 'SG':
      case 'MY':
      case 'BN':
      case 'ID':
        return CalculationMethod.singapore;
      case 'TR':
        return CalculationMethod.turkey;
      case 'IR':
        return CalculationMethod.tehran;
      case 'US':
      case 'CA':
        return CalculationMethod.north_america;
      default:
        return CalculationMethod.muslim_world_league;
    }
  }

  Madhab _resolveMadhab() {
    switch (countryCode) {
      case 'PK':
      case 'IN':
      case 'BD':
      case 'AF':
      case 'TR':
        return Madhab.hanafi;
      default:
        return Madhab.shafi;
    }
  }

  CalculationParameters _buildParams() {
    final params = _resolveCalculationMethod().getParameters();
    params.madhab = _resolveMadhab();
    return params;
  }

  void _computeTodayPrayerTimes() {
    final coordinates = Coordinates(latitude, longitude);
    todayPrayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(DateTime.now()),
      _buildParams(),
    );
  }

  PrayerTimes prayerTimesFor(DateTime date) {
    final coordinates = Coordinates(latitude, longitude);
    return PrayerTimes(coordinates, DateComponents.from(date), _buildParams());
  }

  /// اسم الصلاة القادمة (fajr/dhuhr/asr/maghrib/isha) حسب مفاتيح الترجمة الموجودة بالمشروع
  String get nextPrayerKey {
    final p = todayPrayerTimes;
    if (p == null) return 'fajr';
    Prayer next = p.nextPrayer();
    if (next == Prayer.none) next = Prayer.fajr;
    return _prayerKey(next);
  }

  DateTime? get nextPrayerTime {
    final p = todayPrayerTimes;
    if (p == null) return null;
    Prayer next = p.nextPrayer();
    if (next == Prayer.none) next = Prayer.fajr;
    DateTime time = p.timeForPrayer(next)!.toLocal();
    if (time.isBefore(DateTime.now())) {
      time = time.add(const Duration(days: 1));
    }
    return time;
  }

  String _prayerKey(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'fajr';
      case Prayer.sunrise:
        return 'sunrise';
      case Prayer.dhuhr:
        return 'dhuhr';
      case Prayer.asr:
        return 'asr';
      case Prayer.maghrib:
        return 'maghrib';
      case Prayer.isha:
        return 'isha';
      default:
        return 'fajr';
    }
  }

  String _prayerArabicName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return 'الفجر';
      case Prayer.dhuhr:
        return 'الظهر';
      case Prayer.asr:
        return 'العصر';
      case Prayer.maghrib:
        return 'المغرب';
      case Prayer.isha:
        return 'العشاء';
      default:
        return '';
    }
  }

  Map<Prayer, DateTime> _prayerMap(PrayerTimes p) => {
        Prayer.fajr: p.fajr,
        Prayer.dhuhr: p.dhuhr,
        Prayer.asr: p.asr,
        Prayer.maghrib: p.maghrib,
        Prayer.isha: p.isha,
      };

  /// أهم دالة: تجدول إشعارات حقيقية (مو فورية) لكل صلاة في الأيام القادمة.
  /// هاد اللي بيخلي الأذان يشتغل حتى لو التطبيق مسكر تماماً.
  Future<void> scheduleUpcomingPrayers({int days = 7}) async {
    // ما في دعم لـ flutter_local_notifications على الويب إطلاقاً.
    if (kIsWeb) return;
    await notificationsPlugin.cancelAll();
    if (!notificationsEnabled) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_channel_id',
      'تنبيهات الصلاة',
      channelDescription: 'إشعار دخول وقت الصلاة',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification',
      playSound: true,
      // يضمن ظهور اسم الصلاة كامل على شاشة القفل مباشرة، مش مخفي كإشعار حساس.
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.alarm,
      // ملاحظة: ضروري تحط ملف الصوت باسم adhan.mp3 داخل
      // android/app/src/main/res/raw/adhan.mp3 (بدون نقاط، أحرف صغيرة)
      sound: RawResourceAndroidNotificationSound('adhan'),
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // إذا المستخدم ما وافق على إذن الـ Exact Alarm، بنستخدم جدولة غير دقيقة
    // (inexact) بدل ما نخلي zonedSchedule يرمي PlatformException ويوقف الجدولة كلها.
    final androidImpl = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final bool canScheduleExact =
        await androidImpl?.canScheduleExactNotifications() ?? false;
    final AndroidScheduleMode scheduleMode = canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    int id = 0;
    final DateTime now = DateTime.now();

    for (int d = 0; d < days; d++) {
      final DateTime date = now.add(Duration(days: d));
      final Map<Prayer, DateTime> times = _prayerMap(prayerTimesFor(date));

      for (final entry in times.entries) {
        final DateTime scheduledLocal = entry.value.toLocal();
        if (scheduledLocal.isBefore(now)) continue; // ما نجدول وقت فات

        final tz.TZDateTime scheduledTz =
            tz.TZDateTime.from(scheduledLocal, tz.local);

        await notificationsPlugin.zonedSchedule(
          id++,
          '🕌 حان وقت الصلاة',
          'حان الآن وقت صلاة ${_prayerArabicName(entry.key)}',
          scheduledTz,
          notificationDetails,
          androidScheduleMode: scheduleMode,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }

    await _box.write(_kLastScheduleDay, now.day);
  }

  /// نادِ هاي كل ما ينفتح التطبيق (Home initState مثلاً) عشان نحافظ
  /// على وجود جدولة كافية قدام دايماً (rolling window).
  Future<void> ensureScheduleIsFresh() async {
    if (!notificationsEnabled) return;
    final int? lastDay = _box.read(_kLastScheduleDay);
    if (lastDay != DateTime.now().day) {
      await scheduleUpcomingPrayers();
    }
  }

  /// يُستدعى من شاشة الإعدادات عند تبديل مفتاح إشعارات الصلاة
  Future<void> setNotificationsEnabled(bool value) async {
    await _box.write(_kNotificationsEnabled, value);
    if (kIsWeb) return;
    if (value) {
      await scheduleUpcomingPrayers();
    } else {
      await notificationsPlugin.cancelAll();
    }
  }

  /// يُستدعى من شاشة الإعدادات عند تبديل مفتاح الموقع
  Future<void> setLocationEnabled(bool value) async {
    await _box.write(_kLocationEnabled, value);
    if (value) {
      await refreshLocation();
      if (notificationsEnabled) {
        await scheduleUpcomingPrayers();
      }
    }
  }
}
