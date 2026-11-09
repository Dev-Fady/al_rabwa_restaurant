import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/splash/presentation/screens/splash_screen.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeSecureStorage extends FlutterSecureStorage {
  _FakeSecureStorage({this.token});

  final String? token;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => token;
}

Future<void> _pumpSplash(
  WidgetTester tester, {
  required FlutterSecureStorage storage,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  if (getIt.isRegistered<FlutterSecureStorage>()) {
    await getIt.unregister<FlutterSecureStorage>();
  }
  getIt.registerSingleton<FlutterSecureStorage>(storage);
  addTearDown(() async {
    if (getIt.isRegistered<FlutterSecureStorage>()) {
      await getIt.unregister<FlutterSecureStorage>();
    }
  });

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const Scaffold(body: Text('register-screen')),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('home-screen')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      locale: const Locale('ar'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          // Keeps the looping pulse from blocking test teardown.
          disableAnimations: true,
        ),
        child: child!,
      ),
    ),
  );
  await tester.pump();
}

/// Lets the splash timer fire and the async token read resolve.
Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1900));
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the branded splash while the session is checked', (
    tester,
  ) async {
    await _pumpSplash(tester, storage: _FakeSecureStorage());

    expect(find.text('مطعم الربوة'), findsOneWidget);
    expect(find.text('نكهات طازجة وكرم ضيافة'), findsOneWidget);
    expect(find.text('نجهّز طاولتك…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _finishSplash(tester);
  });

  testWidgets('opens registration when no token is stored', (tester) async {
    await _pumpSplash(tester, storage: _FakeSecureStorage());

    await _finishSplash(tester);

    expect(find.text('register-screen'), findsOneWidget);
    expect(find.text('home-screen'), findsNothing);
  });

  testWidgets('opens home when a token is already stored', (tester) async {
    await _pumpSplash(
      tester,
      storage: _FakeSecureStorage(token: 'saved-token'),
    );

    await _finishSplash(tester);

    expect(find.text('home-screen'), findsOneWidget);
    expect(find.text('register-screen'), findsNothing);
  });

  testWidgets('fits a small phone at 2x text scale', (tester) async {
    await _pumpSplash(
      tester,
      storage: _FakeSecureStorage(),
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.text('مطعم الربوة'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _finishSplash(tester);
  });
}
