import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/phone_login_screen.dart';
import 'presentation/screens/auth/pin_login_screen.dart';
import 'presentation/screens/auth/pin_setup_screen.dart';
import 'presentation/screens/notifications/notifications_screen.dart';
import 'presentation/screens/shell/main_shell.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar ilovaning och foniga moslashsin.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // ProviderScope — Riverpod'ning ildizi. Testlarda yoki real API'ga
  // o'tishda provider'larni shu yerda override qilish mumkin.
  runApp(const ProviderScope(child: AcadiumApp()));
}

/// Ilovaning ildiz vidjeti.
class AcadiumApp extends StatelessWidget {
  const AcadiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: <String, WidgetBuilder>{
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.phoneLogin: (_) => const PhoneLoginScreen(),
        AppRoutes.pinSetup: (_) => const PinSetupScreen(),
        AppRoutes.pinLogin: (_) => const PinLoginScreen(),
        AppRoutes.shell: (_) => const MainShell(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
      },
      // Matn o'lchamini qurilma sozlamalaridan qat'i nazar cheklab qo'yamiz,
      // aks holda dizayn buzilishi mumkin.
      builder: (BuildContext context, Widget? child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaler: TextScaler.linear(
              data.textScaler.scale(1).clamp(0.9, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
