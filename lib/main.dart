import 'package:flutter/material.dart';
import 'core/services/service_locator.dart';
import 'core/theme/neo_theme.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const PicsToolsApp());
}

class PicsToolsApp extends StatelessWidget {
  const PicsToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PicsTools',
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      darkTheme: NeoTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
