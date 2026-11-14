import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/nfc_provider.dart';
import 'services/ad_service.dart';
import 'services/review_service.dart';
import 'services/tracking_service.dart';
import 'core/platform_support.dart';
import 'ui/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/onboarding_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge is an Android 10+ concept; iOS manages the status bar and home
  // indicator itself, so the call is skipped there to avoid fighting the system.
  if (AppPlatform.isAndroid) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // iOS: ATT izni reklam SDK'sı başlamadan önce istenmek zorunda.
    await TrackingService.requestIfNeeded();
    // Initialize Unity LevelPlay / Unity Ads
    await AdService.instance.init(testMode: false);

    final prefs = await SharedPreferences.getInstance();

    // Track app opens and decide whether to show the rating prompt.
    await ReviewService.instance.registerAppOpen();

    // Check Splash Screen (Once per day)
    final lastSplashDate = prefs.getString('last_splash_date') ?? '';
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    if (lastSplashDate == today) {
      _showSplash = false;
    } else {
      await prefs.setString('last_splash_date', today);
    }

    // Check Onboarding
    final seen = prefs.getBool('onboarding_seen') ?? false;

    setState(() {
      _showOnboarding = !seen;
      _loading = false;
    });
  }

  void _finishSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => NfcProvider())],
      child: Consumer<NfcProvider>(
        builder: (context, nfcProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NFC Manager',
            scrollBehavior: const AppScrollBehavior(),
            theme: AppTheme.lightTheme(nfcProvider.themeColor),
            darkTheme: AppTheme.darkTheme(nfcProvider.themeColor),
            themeMode: nfcProvider.themeMode,
            locale: nfcProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: _showSplash
                ? SplashScreen(onFinish: _finishSplash)
                : (_showOnboarding
                      ? OnboardingScreen(onFinish: _finishOnboarding)
                      : const HomeScreen()),
          );
        },
      ),
    );
  }
}
