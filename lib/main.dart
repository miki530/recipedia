import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/recipes_provider.dart';
import 'providers/categories_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'main_navigation.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_colors.dart';
import 'utils/import_export_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const RecipediaApp());
}

class RecipediaApp extends StatelessWidget {
  const RecipediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipesProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
      ],
      child: MaterialApp(
        title: 'Recipedia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: kOrange,
            primary: kOrange,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: kBgLight,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: kTextDark),
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const AppStartup(),
      ),
    );
  }
}

class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool? _showWelcome;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('recipedia_welcome_seen') ?? false;
    if (mounted) setState(() => _showWelcome = !seen);
  }

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('recipedia_welcome_seen', true);
    if (mounted) setState(() => _showWelcome = false);
  }

  Future<void> _handleImport() async {
    final recipesProvider = context.read<RecipesProvider>();
    final categoriesProvider = context.read<CategoriesProvider>();

    // Czekaj aż oba providery załadują dane z dysku
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 50));
      return !recipesProvider.initialized || !categoriesProvider.initialized;
    });

    final result = await ImportExportService.importData();
    if (!mounted) return;

    if (result == null) {
      await _markSeen();
      return;
    }

    if (result.categories.isNotEmpty) {
      await categoriesProvider.bulkImport(result.categories);
    }

    final imported = await recipesProvider.bulkImport(result.recipes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(imported == 0
              ? 'Wszystkie przepisy już istniały'
              : 'Zaimportowano $imported przepisów'),
        ),
      );
    }

    await _markSeen();
  }

  @override
  Widget build(BuildContext context) {
    if (_showWelcome == null) {
      // Splash minimalny żeby nie migało
      return const Scaffold(
        backgroundColor: kBgLight,
        body: Center(
          child: CircularProgressIndicator(color: kOrange),
        ),
      );
    }
    if (_showWelcome!) {
      return WelcomeScreen(
        onGetStarted: _markSeen,
        onImport: _handleImport,
      );
    }
    return const MainNavigation();
  }
}
