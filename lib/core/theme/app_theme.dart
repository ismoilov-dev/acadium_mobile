import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ilovaning barcha ranglari. Boshqa hech qayerda hex rang yozilmaydi.
class AppColors {
  const AppColors._();

  // Asosiy brend ranglari (ko'k-binafsha gradient)
  static const Color primary = Color(0xFF5B5BF7);
  static const Color primaryDark = Color(0xFF3F3AD6);
  static const Color primaryLight = Color(0xFFEDECFE);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF38BDF8);

  // Gradient uchun
  static const Color gradientStart = Color(0xFF4F6CF7);
  static const Color gradientEnd = Color(0xFF9061F9);

  // Holat (status) ranglari
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Neytral ranglar
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8EAF2);
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textTertiary = Color(0xFF98A2B3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x145B5BF7);
  static const Color shimmerBase = Color(0xFFE9ECF3);
  static const Color shimmerHighlight = Color(0xFFF7F8FC);

  // Fanlar uchun avatar ranglari (aylanib ishlatiladi)
  static const List<Color> subjectPalette = <Color>[
    Color(0xFF5B5BF7),
    Color(0xFF8B5CF6),
    Color(0xFF0EA5E9),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
  ];

  /// Fan nomiga qarab barqaror rang tanlaydi.
  static Color forSubject(String subject) =>
      subjectPalette[subject.hashCode.abs() % subjectPalette.length];

  // Gradientlar
  static const LinearGradient primaryGradient = LinearGradient(
    colors: <Color>[gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: <Color>[gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Bo'sh joy (padding / margin) o'lchamlari.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 40;

  /// Ekranlarning gorizontal standart chetlanishi.
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: lg);
}

/// Burchak yumaloqliklari.
class AppRadius {
  const AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(pill);
}

/// Yumshoq soyalar.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F101828),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A101828),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glow = <BoxShadow>[
    BoxShadow(
      color: Color(0x4D5B5BF7),
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
  ];
}

/// Matn stillari (Poppins).
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get display => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMuted =>
      body.copyWith(color: AppColors.textSecondary);

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.onPrimary,
      );

  static TextStyle get numeric => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
}

/// Butun ilova uchun yagona ThemeData.
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ThemeData base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: AppColors.onPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTextStyles.h2,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.button,
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        labelStyle: AppTextStyles.caption,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.onPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryLight,
      ),
    );
  }
}
