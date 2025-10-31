import 'dart:io';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/theme.dart';
import 'package:smeta_maker/service/excel_service.dart';
import 'package:smeta_maker/service/works_parser.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/ui/views/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<Category> lastCategory = ValueNotifier(Category.complex);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Отключаем ограничения производительности для профильного режима
  if (kDebugMode || kProfileMode) {
    // Включаем более высокий FPS для профильного режима
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  AppState appState = AppState();
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString(AppConstants.lastCategoryKey) == null) {
    await prefs.setString(AppConstants.lastCategoryKey, Category.complex.name);
  }
  final file = await rootBundle.loadString('assets/db/works.txt');
  final parsed = await compute(WorksParser.parse, file);
  appState.initParsedRows(parsed);
  if (Platform.isAndroid || Platform.isIOS) {
    await FlutterDownloader.initialize(debug: true);
  }
  try {
    runApp(MyApp(appState));
  } catch (e) {
    print('Failed to initialize app: $e');
    runApp(ErrorApp(e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp(this.mainAppState, {super.key});
  final AppState mainAppState;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => mainAppState,
      child: Consumer<AppState>(
        builder: (context, appState, _) => Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                SaveIntent(),
          },
          child: Actions(
            actions: {
              SaveIntent: CallbackAction<SaveIntent>(
                onInvoke: (intent) =>
                    appState.rows.length > 0 ? intent.save(appState) : null,
              ),
            },
            child: MaterialApp(
              initialRoute: '/',
              navigatorKey: navigatorKey,
              theme: AppTheme.dark,
              debugShowCheckedModeBanner: false,
              // Настройки для повышения производительности
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    // Отключаем ограничение FPS
                    disableAnimations: false,
                  ),
                  child: child!,
                );
              },
              home: const HomePage(),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp(this.errorMessage, {super.key});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smeta Maker - Error',
      theme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Ошибка инициализации приложения',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
