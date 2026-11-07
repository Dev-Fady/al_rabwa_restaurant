import 'package:al_rabwa_restaurant/core/widget/app_bottom_nav_bar.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const arabicLabels = ['الرئيسية', 'المنيو', 'السلة', 'طلباتي', 'المتجر'];

  Future<void> pumpBar(
    WidgetTester tester, {
    int currentIndex = 0,
    int cartBadgeCount = 0,
    Size size = const Size(390, 844),
    ValueChanged<int>? onTap,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: AppBottomNavBar(
            currentIndex: currentIndex,
            onTap: onTap ?? (_) {},
            cartBadgeCount: cartBadgeCount,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the five restaurant tabs', (tester) async {
    await pumpBar(tester);

    for (final label in arabicLabels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.getSize(find.byType(AppBottomNavBar)).height, lessThan(120));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected tab is highlighted against inactive ones', (
    tester,
  ) async {
    await pumpBar(tester);

    final homeIcon = tester.widget<Icon>(find.byIcon(Icons.home_outlined));
    final menuIcon = tester.widget<Icon>(
      find.byIcon(Icons.restaurant_outlined),
    );

    expect(homeIcon.color, isNotNull);
    expect(menuIcon.color, isNotNull);
    expect(homeIcon.color, isNot(menuIcon.color));
  });

  testWidgets('home is the right-most tab in RTL', (tester) async {
    await pumpBar(tester);

    final homeX = tester.getCenter(find.text(arabicLabels[0])).dx;
    final menuX = tester.getCenter(find.text(arabicLabels[1])).dx;
    final storeX = tester.getCenter(find.text(arabicLabels[4])).dx;

    expect(homeX, greaterThan(menuX));
    expect(menuX, greaterThan(storeX));
  });

  testWidgets('tapping a tab forwards its index', (tester) async {
    int? tappedIndex;
    await pumpBar(tester, onTap: (index) => tappedIndex = index);

    await tester.tap(find.text('السلة'));
    await tester.pump();

    expect(tappedIndex, AppBottomNavBar.cartIndex);
  });

  testWidgets('cart badge renders the count', (tester) async {
    await pumpBar(tester, cartBadgeCount: 3);

    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('fits a small phone without overflow', (tester) async {
    await pumpBar(tester, size: const Size(320, 640));

    for (final label in arabicLabels) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
