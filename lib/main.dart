import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(
    const ProviderScope(
      child: MyBandApp(),
    ),
  );
}

class MyBandApp extends ConsumerWidget {
  const MyBandApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'MyBand',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
    );
  }
}
