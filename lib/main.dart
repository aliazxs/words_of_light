import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/library_screen.dart';
import 'screens/mistakes_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.kalamakum_noor.audio',
    androidNotificationChannelName: 'تشغيل الصوت',
    androidNotificationOngoing: true,
  );
  runApp(const KalamakumNoorApp());
}

class KalamakumNoorApp extends StatelessWidget {
  const KalamakumNoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp(
            title: 'كلامكم نور',
            debugShowCheckedModeBanner: false,
            themeMode: app.themeMode == 'dark'
                ? ThemeMode.dark
                : app.themeMode == 'light'
                    ? ThemeMode.light
                    : ThemeMode.system,
            theme: _buildTheme(Brightness.light),
            darkTheme: _buildTheme(Brightness.dark),
            home: const LibraryScreen(),
            routes: {
              '/settings': (_) => const SettingsScreen(),
              '/mistakes': (_) => const MistakesScreen(),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? const ColorScheme.dark(
            primary: Color(0xFF8B7355),
            secondary: Color(0xFFD4A574),
            surface: Color(0xFF1A1612),
          )
        : const ColorScheme.light(
            primary: Color(0xFF5D4E37),
            secondary: Color(0xFF8B7355),
            surface: Color(0xFFFAF8F5),
          );

    final baseTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Amiri',
      textTheme: baseTheme.apply(fontFamily: 'Amiri'),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
