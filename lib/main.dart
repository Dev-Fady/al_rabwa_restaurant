import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/features/presentation/cubit/settings_state.dart';
import 'package:al_rabwa_restaurant/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await setupGetIt();
  } catch (error) {
    // Startup must still render the UI (e.g. storage unavailable in tests).
    debugPrint('setupGetIt failed (non-fatal): $error');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (context) => getIt<SettingsCubit>(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            final bool isDark = state.darkModeEnabled;
            return MaterialApp.router(
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)!.appTitle,
              debugShowCheckedModeBanner: false,
              locale: state.locale,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
