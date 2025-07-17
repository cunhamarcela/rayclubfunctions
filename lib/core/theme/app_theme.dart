// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'app_colors.dart';
import 'app_typography.dart';

/// Classe que gerencia o tema do aplicativo
class AppTheme {
  /// Cor primária do tema
  static const Color primaryColor = AppColors.primary;
  
  /// Retorna o tema claro do aplicativo
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Century Gothic',
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.orange,
        onPrimary: Colors.white,
        primaryContainer: AppColors.backgroundLight,
        onPrimaryContainer: AppColors.darkGray,
        secondary: AppColors.purple,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.purple.withOpacity(0.1),
        onSecondaryContainer: AppColors.darkGray,
        tertiary: AppColors.softPink,
        onTertiary: AppColors.darkGray,
        tertiaryContainer: AppColors.softPink.withOpacity(0.1),
        onTertiaryContainer: AppColors.darkGray,
        error: AppColors.orangeDark,
        onError: Colors.white,
        errorContainer: AppColors.orangeDark.withOpacity(0.1),
        onErrorContainer: AppColors.darkGray,
        background: AppColors.backgroundLight,
        onBackground: AppColors.darkGray,
        surface: Colors.white,
        onSurface: AppColors.darkGray,
        surfaceVariant: AppColors.backgroundLight.withOpacity(0.7),
        onSurfaceVariant: AppColors.darkGray.withOpacity(0.7),
        outline: AppColors.lightGray,
        outlineVariant: AppColors.lightGray.withOpacity(0.5),
        shadow: AppColors.darkGray.withOpacity(0.2),
        scrim: AppColors.darkGray.withOpacity(0.5),
        inverseSurface: AppColors.darkGray,
        onInverseSurface: Colors.white,
        inversePrimary: AppColors.backgroundLight,
        surfaceTint: AppColors.orange.withOpacity(0.05),
      ),
      
      // Configurações de texto
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGray,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.darkGray,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.darkGray,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.darkGray,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
      ),
      
      // Configurações dos componentes
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkGray,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple,
          side: const BorderSide(color: AppColors.purple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
      ),
      
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: AppColors.shadow,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkGray.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.orangeDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.orangeDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppColors.darkGray.withOpacity(0.5),
          fontWeight: FontWeight.normal,
        ),
        errorStyle: const TextStyle(
          color: AppColors.orangeDark,
          fontSize: 12,
        ),
        helperStyle: TextStyle(
          color: AppColors.darkGray.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.darkGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.orange,
        unselectedLabelColor: AppColors.darkGray.withOpacity(0.7),
        indicatorColor: AppColors.orange,
        labelStyle: const TextStyle(
          fontFamily: 'Century Gothic',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Century Gothic',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      
      // Tema para ícones
      iconTheme: const IconThemeData(
        color: AppColors.darkGray, 
        size: 24,
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.orange,
        linearTrackColor: AppColors.backgroundLight,
        circularTrackColor: AppColors.backgroundLight,
        refreshBackgroundColor: AppColors.backgroundLight,
      ),
      
      dividerTheme: const DividerThemeData(
        color: AppColors.lightGray,
        thickness: 1,
        space: 1,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.backgroundLight,
        disabledColor: AppColors.lightGray,
        selectedColor: AppColors.purple,
        secondarySelectedColor: AppColors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.darkGray,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightGray),
        ),
      ),
      
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 16,
          color: AppColors.darkGray,
        ),
      ),
      
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkGray,
        contentTextStyle: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          color: Colors.white,
        ),
        actionTextColor: AppColors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange;
          }
          return AppColors.lightGray;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(color: AppColors.lightGray, width: 1.5),
      ),
      
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange;
          }
          return AppColors.darkGray.withOpacity(0.5);
        }),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange.withOpacity(0.5);
          }
          return AppColors.lightGray;
        }),
      ),
    );
  }
  
  /// Retorna o tema escuro do aplicativo
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Century Gothic',
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.orange,
        onPrimary: Colors.white,
        primaryContainer: AppColors.darkGray,
        onPrimaryContainer: AppColors.backgroundLight,
        secondary: AppColors.purple,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.purple.withOpacity(0.3),
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.softPink,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.softPink.withOpacity(0.3),
        onTertiaryContainer: Colors.white,
        error: AppColors.orangeDark,
        onError: Colors.white,
        errorContainer: AppColors.orangeDark.withOpacity(0.3),
        onErrorContainer: Colors.white,
        background: AppColors.darkGray,
        onBackground: AppColors.backgroundLight,
        surface: Colors.black,
        onSurface: AppColors.backgroundLight,
        surfaceVariant: Colors.black54,
        onSurfaceVariant: AppColors.backgroundLight,
        outline: AppColors.lightGray,
        outlineVariant: AppColors.lightGray.withOpacity(0.3),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColors.backgroundLight,
        onInverseSurface: AppColors.darkGray,
        inversePrimary: AppColors.orange,
        surfaceTint: AppColors.orange.withOpacity(0.1),
      ),
      
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Century Gothic',
        bodyColor: AppColors.backgroundLight,
        displayColor: AppColors.backgroundLight,
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.backgroundLight,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.backgroundLight,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.purple,
          side: const BorderSide(color: AppColors.purple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Century Gothic',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        color: Colors.black12,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black45,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.backgroundLight.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.orange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.orangeDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.orangeDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          color: AppColors.backgroundLight.withOpacity(0.5),
          fontWeight: FontWeight.normal,
        ),
        errorStyle: const TextStyle(
          color: AppColors.orangeDark,
          fontSize: 12,
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.backgroundLight.withOpacity(0.7),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      iconTheme: IconThemeData(
        color: AppColors.backgroundLight, 
        size: 24,
      ),
      
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.orange,
        linearTrackColor: Colors.black54,
        circularTrackColor: Colors.black54,
        refreshBackgroundColor: Colors.black,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange.withOpacity(0.5);
          }
          return Colors.grey.shade800;
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.orange;
          }
          return Colors.grey.shade800;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
      ),
      
      dividerTheme: DividerThemeData(
        color: AppColors.backgroundLight.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade900,
        contentTextStyle: TextStyle(
          fontFamily: 'Century Gothic',
          fontSize: 14,
          color: AppColors.backgroundLight,
        ),
        actionTextColor: AppColors.orange,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 