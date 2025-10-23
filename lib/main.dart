import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smeta_maker/data/app_constants.dart';
import 'package:smeta_maker/data/models/rows_model.dart';
import 'package:smeta_maker/data/theme.dart';
import 'package:smeta_maker/service/excel_service.dart';
import 'package:smeta_maker/service/project_manager.dart';
import 'package:smeta_maker/state/app_state.dart';
import 'package:smeta_maker/ui/views/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ValueNotifier<Category> lastCategory = ValueNotifier(Category.complex);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    await ProjectManager.create();
    if (prefs.getString(AppConstants.lastCategoryKey) == null) {
      await prefs.setString(
        AppConstants.lastCategoryKey,
        Category.complex.name,
      );
    }

    runApp(MyApp());
  } catch (e) {
    // Handle initialization errors
    print('Failed to initialize app: $e');
    runApp(ErrorApp(e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) => Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
                SaveIntent(),
          },
          child: Actions(
            actions: {
              SaveIntent: CallbackAction<SaveIntent>(
                onInvoke: (intent) => appState.rows.length > 0
                    ? intent.save(appState.rows, appState.settings.name)
                    : null,
              ),
            },
            child: MaterialApp(
              initialRoute: '/',
              navigatorKey: navigatorKey,
              theme: AppTheme.dark,
              debugShowCheckedModeBanner: false,
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
