import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'core/notification_service.dart';
import 'core/theme_notifier.dart';
import 'core/workmanager_callback.dart';
import 'features/home/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================
  // INICIALIZAÇÃO DAS NOTIFICAÇÕES
  // ============================
  await NotificationService.init();

  // ==========================================
  // INICIALIZAÇÃO DO WORKMANAGER (BACKGROUND)
  // ==========================================
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // 🔧 TRUE apenas durante desenvolvimento/testes
  );

  // ============================================================
  // TAREFA PERIÓDICA (PRODUÇÃO)
  // ------------------------------------------------------------
  // • Executa 1x por dia
  // • Android escolhe o horário exato
  // • Usada para verificar documentos vencendo
  // ============================================================
  await Workmanager().registerPeriodicTask(
    'document-expiry-check',
    'documentExpiryCheck',
    frequency: const Duration(hours: 24),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
    ),
  );


  runApp(const Journey2EuropeApp());
}

class Journey2EuropeApp extends StatelessWidget {
  const Journey2EuropeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Journey2Europe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
