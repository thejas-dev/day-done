import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/providers/notification_providers.dart';
import 'routing/app_router.dart';

part 'app.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return createAppRouter(ref);
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Initialize the notification reschedule trigger so it starts
    // watching settings + today summary and scheduling notifications.
    ref.watch(notificationRescheduleTriggerProvider);
    ref.watch(notificationPermissionBootstrapTriggerProvider);

    return MaterialApp.router(
      title: 'DayDone',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode:
          ThemeMode.system, // Week 6: replace with ref.watch(themeModeProvider)
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
