import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/theme/app_theme.dart';

/// The root of the PIKIR app.
class PikirApp extends StatelessWidget {
  const PikirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIKIR',
      debugShowCheckedModeBanner: false,

      // One theme, always light. No darkTheme is supplied on purpose, so a
      // device in dark mode still gets the palette the contrast ratios were
      // checked against.
      theme: PikirTheme.light,
      themeMode: ThemeMode.light,

      initialRoute: Routes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,

      // System text scaling is deliberately left alone. The users this is
      // built for often run their phones at a larger text size, and clamping
      // it would trade their legibility for our layout's convenience.
    );
  }
}
