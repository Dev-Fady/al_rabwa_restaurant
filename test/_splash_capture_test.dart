import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/splash/presentation/screens/splash_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFont() async {
  final bytes = await File('C:/Windows/Fonts/tahoma.ttf').readAsBytes();
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required Locale locale,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  final boundaryKey = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: boundaryKey,
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 1000));

  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 2);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('build/visual_check/$name.png');
  await file.parent.create(recursive: true);
  await file.writeAsBytes(data!.buffer.asUint8List());

  // Drain the splash timer so the test ends cleanly.
  await tester.pump(const Duration(milliseconds: 1900));
  await tester.pumpAndSettle();
  await tester.binding.setSurfaceSize(null);
}

void main() {
  setUpAll(_loadFont);

  testWidgets('capture splash ar', (tester) async {
    await _capture(
      tester,
      name: 'splash_ar_phone',
      locale: const Locale('ar'),
    );
  });

  testWidgets('capture splash en', (tester) async {
    await _capture(
      tester,
      name: 'splash_en_phone',
      locale: const Locale('en'),
    );
  });

  testWidgets('capture splash small 2x', (tester) async {
    await _capture(
      tester,
      name: 'splash_ar_small_2x',
      locale: const Locale('ar'),
      size: const Size(320, 640),
      textScale: 2,
    );
  });

  testWidgets('capture splash wide', (tester) async {
    await _capture(
      tester,
      name: 'splash_ar_wide',
      locale: const Locale('ar'),
      size: const Size(1280, 900),
    );
  });
}
