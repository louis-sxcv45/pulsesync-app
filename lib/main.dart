import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulsesync/data/services/telemetry_service.dart';
import 'package:pulsesync/presentation/providers/telemetry_provider.dart';
import 'package:pulsesync/presentation/resources/colors_manager.dart';
import 'package:pulsesync/presentation/routes/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => TelemetryProvider(TelemetryService())..start(),
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


