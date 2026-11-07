import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/restaurant_settings.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/settings_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/screens/home_screen.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/settings_fixtures.dart';

class _FakeRepository implements SettingsRepository {
  _FakeRepository({this.result, this.error});

  RestaurantSettings? result;
  Object? error;

  @override
  Future<RestaurantSettings> fetchSettings({String lang = 'ar'}) async {
    final failure = error;
    if (failure != null) throw failure;
    return result!;
  }
}

Future<StoreConfigCubit> _pumpHome(
  WidgetTester tester, {
  required _FakeRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = StoreConfigCubit(repository);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: BlocProvider.value(value: cubit, child: const HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  testWidgets('renders the restaurant content from the settings payload', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettings()),
    );

    expect(find.text('مطعم الربوة'), findsOneWidget);
    expect(find.text('مشاوي على الفحم'), findsOneWidget);
    expect(find.text('نكهة تستاهل التجربة'), findsOneWidget);
    expect(find.text('توصيل'), findsOneWidget);
    expect(find.text('استلام من المطعم'), findsOneWidget);
    expect(find.text('داخل المطعم'), findsOneWidget);
    expect(find.text('مفتوح الآن — نستقبل طلباتك'), findsOneWidget);
    expect(find.text('نقدًا'), findsOneWidget);
    expect(find.text('ر.ق · QAR'), findsOneWidget);
    expect(find.text('تصفح المنيو'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the failure state and recovers on retry', (tester) async {
    final repository = _FakeRepository(error: Exception('offline'));
    await _pumpHome(tester, repository: repository);

    expect(
      find.text('تعذر تحميل بيانات المطعم، تحقق من اتصالك وحاول مرة أخرى.'),
      findsOneWidget,
    );
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    repository.error = null;
    repository.result = sampleSettingsWithoutImages();
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.text('مشاوي على الفحم'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsNothing);
  });

  testWidgets('fits a small phone at 2x text scale without overflow', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettingsWithoutImages()),
      size: const Size(320, 640),
      textScale: 2,
    );

    expect(find.text('مشاوي على الفحم'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('تصفح المنيو'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('تصفح المنيو'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('centers the content on wide screens', (tester) async {
    await _pumpHome(
      tester,
      repository: _FakeRepository(result: sampleSettingsWithoutImages()),
      size: const Size(1280, 900),
    );

    final bannerWidth = tester
        .getSize(find.bySemanticsLabel('مشاوي على الفحم'))
        .width;
    expect(bannerWidth, lessThanOrEqualTo(760));
    expect(tester.takeException(), isNull);
  });
}
