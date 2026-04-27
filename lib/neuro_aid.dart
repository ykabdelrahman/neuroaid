import 'package:flutter/material.dart';
import 'package:neuroaid/src/core/routes/app_router.dart';
import 'package:neuroaid/src/core/theme/app_theme.dart';

import 'package:device_preview/device_preview.dart';

class NeuroAid extends StatelessWidget {
  const NeuroAid({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'NeuroAid',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
