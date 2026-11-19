import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulsesync/data/local/app_database.dart';
import 'package:pulsesync/data/repositories/queue_repository_impl.dart';
import 'package:pulsesync/data/services/sync_service.dart';
import 'package:pulsesync/data/services/telemetry_service.dart';
import 'package:pulsesync/presentation/providers/queue_provider.dart';
import 'package:pulsesync/presentation/providers/telemetry_provider.dart';
import 'package:pulsesync/presentation/resources/colors_manager.dart';
import 'package:pulsesync/presentation/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => TelemetryProvider(TelemetryService())..start(),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) =>
              QueueProvider(QueueRepositoryImpl(AppDatabase()), SyncService())
                ..init(),
        ),
      ],
      child: MaterialApp.router(
        title: 'PulseSync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: ColorsManager.bg,
          colorScheme: const ColorScheme.dark(primary: ColorsManager.primary),
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
