import 'package:al_rabwa_restaurant/core/error/failure.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/home/data/models/menu_categories_response.dart';
import 'package:al_rabwa_restaurant/features/home/domain/entities/menu_category.dart';
import 'package:al_rabwa_restaurant/features/home/domain/repositories/menu_categories_repository.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/home_categories_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/widgets/home_categories_section.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/categories_fixtures.dart';

class _FakeCategoriesRepository implements MenuCategoriesRepository {
  _FakeCategoriesRepository({this.result = const [], this.error});

  List<MenuCategory> result;
  Object? error;
  int calls = 0;
  String? lastLang;

  @override
  Future<Either<Failure, List<MenuCategory>>> fetchCategories({
    String lang = 'ar',
  }) async {
    calls++;
    lastLang = lang;
    final failure = error;
    if (failure != null) {
      if (failure is Failure) return Left(failure);
      throw failure;
    }
    return Right(result);
  }
}

Future<HomeCategoriesCubit> _pumpSection(
  WidgetTester tester, {
  required _FakeCategoriesRepository repository,
  Size size = const Size(390, 844),
  double textScale = 1,
  ValueChanged<MenuCategory>? onCategoryTap,
  VoidCallback? onViewAll,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final cubit = HomeCategoriesCubit(repository);
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
      home: BlocProvider.value(
        value: cubit,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: HomeCategoriesSection(
              onViewAll: onViewAll ?? () {},
              onCategoryTap: onCategoryTap ?? (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  // The marquee scrolls continuously, so `pumpAndSettle` would never settle.
  await tester.pump();
  await tester.pump();
  await tester.pump();
  return cubit;
}

void main() {
  group('MenuCategoriesResponse', () {
    test('maps the categories payload with its display styles', () {
      final categories = MenuCategoriesResponse.fromJson(
        categoriesPayload(),
      ).toEntities();

      expect(categories, hasLength(13));
      expect(categories.first.id, 11);
      expect(categories.first.name, 'مشاوي علي الفحم');
      expect(categories.first.image, '');
      expect(categories.first.hasImage, isFalse);
      expect(categories.first.displayStyle, CategoryDisplayStyle.large);
      expect(categories.first.isLarge, isTrue);
      expect(categories.first.itemsCount, 12);

      expect(categories[1].displayStyle, CategoryDisplayStyle.list);
      expect(categories[1].isLarge, isFalse);
      expect(categories.last.name, 'العصائر والمشروبات');
      expect(categories.last.itemsCount, 15);
    });

    test('falls back to safe defaults for malformed categories', () {
      final category = const MenuCategoryModel(
        name: '  ',
        itemsCount: -3,
      ).toEntity();

      expect(category.id, isNull);
      expect(category.name, '');
      expect(category.image, '');
      expect(category.hasImage, isFalse);
      expect(category.displayStyle, CategoryDisplayStyle.list);
      expect(category.itemsCount, 0);
    });
  });

  group('HomeCategoriesCubit', () {
    test('loads the categories in the selected language', () async {
      final repository = _FakeCategoriesRepository(result: sampleCategories());
      final cubit = HomeCategoriesCubit(repository, lang: 'en');

      expect(cubit.state.isLoading, isTrue);
      await pumpEventQueue();

      expect(cubit.state.status, HomeCategoriesStatus.success);
      expect(cubit.state.categories, hasLength(13));
      expect(repository.lastLang, 'en');
      await cubit.close();
    });

    test('keeps the loaded categories when a refresh fails', () async {
      final repository = _FakeCategoriesRepository(result: sampleCategories());
      final cubit = HomeCategoriesCubit(repository);

      await pumpEventQueue();
      expect(cubit.state.hasCategories, isTrue);

      repository.error = ServerFailure('انقطع الاتصال');
      await cubit.refresh();

      expect(cubit.state.status, HomeCategoriesStatus.failure);
      expect(cubit.state.errorMessage, 'انقطع الاتصال');
      expect(cubit.state.categories, hasLength(13));
      await cubit.close();
    });
  });

  group('HomeCategoriesSection', () {
    testWidgets('renders the header, categories and swipe hint', (
      tester,
    ) async {
      await _pumpSection(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
      );

      expect(find.text('اكتشف المنيو'), findsOneWidget);
      expect(find.text('عرض الكل'), findsOneWidget);
      expect(find.text('مشاوي علي الفحم'), findsOneWidget);
      expect(find.text('أطباق ساخنة'), findsOneWidget);
      expect(
        find.text('اسحب الأقسام يمينًا ويسارًا أو اضغط على قسم لفتحه'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('renders every category at the same size', (tester) async {
      await _pumpSection(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
      );

      final firstWidth = tester
          .getSize(find.bySemanticsLabel('مشاوي علي الفحم'))
          .width;
      final middleWidth = tester
          .getSize(find.bySemanticsLabel('أطباق ساخنة'))
          .width;

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      final lastWidth = tester
          .getSize(find.bySemanticsLabel('العصائر والمشروبات'))
          .width;

      expect(firstWidth, middleWidth);
      expect(middleWidth, lastWidth);
    });

    testWidgets('scrolls horizontally and opens a tapped category', (
      tester,
    ) async {
      MenuCategory? tapped;
      await _pumpSection(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
        onCategoryTap: (category) => tapped = category,
      );

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.maxScrollExtent, greaterThan(0));

      await tester.tap(find.text('مشاوي علي الفحم'));
      await tester.pump();

      expect(tapped?.id, 11);
    });

    testWidgets('scrolls the categories automatically back and forth', (
      tester,
    ) async {
      await _pumpSection(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
      );

      final position = tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position;
      expect(position.pixels, 0);

      await tester.pump(const Duration(seconds: 1));
      final afterFirstSecond = position.pixels;
      expect(afterFirstSecond, greaterThan(0));

      await tester.pump(const Duration(seconds: 1));
      expect(position.pixels, greaterThan(afterFirstSecond));

      // At the far edge the carousel reverses instead of jumping back.
      await tester.pump(const Duration(seconds: 60));
      expect(position.pixels, position.maxScrollExtent);
      await tester.pump(const Duration(seconds: 1));
      expect(position.pixels, lessThan(position.maxScrollExtent));
    });

    testWidgets('forwards the view-all action', (tester) async {
      var viewAllTapped = false;
      await _pumpSection(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
        onViewAll: () => viewAllTapped = true,
      );

      await tester.tap(find.text('عرض الكل'));
      await tester.pump();

      expect(viewAllTapped, isTrue);
    });

    testWidgets('shows an error state and recovers on retry', (tester) async {
      final repository = _FakeCategoriesRepository(
        error: ServerFailure('تعذر الاتصال بالخادم'),
      );
      await _pumpSection(tester, repository: repository);

      expect(find.text('تعذر تحميل أقسام المنيو.'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);

      repository.error = null;
      repository.result = sampleCategories();
      await tester.tap(find.text('إعادة المحاولة'));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.text('مشاوي علي الفحم'), findsOneWidget);
      expect(find.text('تعذر تحميل أقسام المنيو.'), findsNothing);
    });

    testWidgets('fits a small phone at 2x text scale without overflow', (
      tester,
    ) async {
      await _pumpSection(
        tester,
        repository: _FakeCategoriesRepository(result: sampleCategories()),
        size: const Size(320, 640),
        textScale: 2,
      );

      expect(find.text('اكتشف المنيو'), findsOneWidget);
      expect(find.text('عرض الكل'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
