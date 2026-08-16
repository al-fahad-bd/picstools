import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/service_locator.dart';
import 'core/theme/neo_theme.dart';
import 'core/routing/app_router.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  await initServiceLocator();
  runApp(const PicsToolsApp());
}

class PicsToolsApp extends StatelessWidget {
  const PicsToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsBloc>()..add(LoadSettingsEvent()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          final themeMode = state is SettingsLoadedState
              ? state.themeMode
              : ThemeMode.system;

          return MaterialApp.router(
            title: 'PicsTools',
            debugShowCheckedModeBanner: false,
            theme: NeoTheme.lightTheme,
            darkTheme: NeoTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
