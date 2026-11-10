import 'dart:io';
import 'dart:ui' as ui;

import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_loading_shimmer.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _capture(
  WidgetTester tester, {
  required ThemeData theme,
  required String path,
}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('capture'),
      child: MaterialApp(
        locale: const Locale('ar'),
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SafeArea(child: HomeLoadingShimmer())),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 700));

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('capture')),
  );
  final image = await boundary.toImage(pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('capture light shimmer', (tester) async {
    await _capture(
      tester,
      theme: AppTheme.light(),
      path: r'C:\Users\3M.T\AppData\Local\Temp\opencode\shimmer_light.png',
    );
  });

  testWidgets('capture dark shimmer', (tester) async {
    await _capture(
      tester,
      theme: AppTheme.dark(),
      path: r'C:\Users\3M.T\AppData\Local\Temp\opencode\shimmer_dark.png',
    );
  });
}
