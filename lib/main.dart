import 'package:al_rabwa_restaurant/core/di/dependency_injection.dart';
import 'package:al_rabwa_restaurant/core/routes/app_router.dart';
import 'package:al_rabwa_restaurant/core/theme/app_theme.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:al_rabwa_restaurant/features/settings/presentation/cubit/settings_state.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_cubit.dart';
import 'package:al_rabwa_restaurant/features/home/presentation/cubit/store_config_state.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) => getIt<SettingsCubit>(),
        ),
        BlocProvider<StoreConfigCubit>(
          create: (context) => getIt<StoreConfigCubit>(),
        ),
      ],
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            previous.locale.languageCode != current.locale.languageCode,
        listener: (context, state) {
          // The backend localizes names and menu content, so reload the
          // storefront configuration in the newly selected language.
          context.read<StoreConfigCubit>().load(
            lang: state.locale.languageCode,
          );
        },
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return BlocBuilder<StoreConfigCubit, StoreConfigState>(
              builder: (context, storeState) {
                final brand = storeState.settings?.theme;
                final bool isDark = settingsState.darkModeEnabled;

                return ScreenUtilInit(
                  designSize: const Size(375, 812),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  child: MaterialApp.router(
                    onGenerateTitle: (context) =>
                        AppLocalizations.of(context)!.appTitle,
                    debugShowCheckedModeBanner: false,
                    locale: settingsState.locale,
                    theme: AppTheme.light(
                      primaryHex: brand?.primaryColor,
                      accentHex: brand?.accentColor,
                      backgroundHex: brand?.backgroundColor,
                      textHex: brand?.textColor,
                      titleHex: brand?.titleColor,
                      fontFamily: brand?.fontFamily,
                    ),
                    darkTheme: AppTheme.dark(),
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    routerConfig: AppRouter.router,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
