import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/connectivity_checker.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/storage/onboarding_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/network_banner.dart';
import 'features/admin/presentation/bloc/ai_request_bloc.dart';
import 'features/admin/presentation/bloc/admin_word_bloc.dart';
import 'features/admin/presentation/bloc/moderation_bloc.dart';
import 'features/admin/presentation/bloc/user_mgmt_bloc.dart';
import 'features/ai/presentation/bloc/translate_bloc.dart';
import 'features/community/presentation/bloc/bookmark_bloc.dart';
import 'features/community/presentation/bloc/contribution_bloc.dart';
import 'features/dictionary/presentation/bloc/search_bloc.dart';
import 'features/dictionary/presentation/bloc/word_detail_bloc.dart';
import 'features/dictionary/presentation/bloc/word_list_bloc.dart';
import 'features/dictionary/presentation/bloc/word_list_event.dart';
import 'features/identity/presentation/bloc/auth_bloc.dart';
import 'features/identity/presentation/bloc/auth_event.dart';
import 'features/identity/presentation/bloc/auth_state.dart';
import 'features/identity/presentation/bloc/profile_bloc.dart';
import 'injection/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await initDependencies();

  final showOnboarding = !(await sl<OnboardingStorage>().hasSeenOnboarding());

  runApp(BanjarinApp(showOnboarding: showOnboarding));
}

class BanjarinApp extends StatelessWidget {
  final bool showOnboarding;

  const BanjarinApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const CheckSession()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
        ),
        BlocProvider<WordListBloc>(
          create: (_) => sl<WordListBloc>()..add(const LoadWords()),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => sl<SearchBloc>(),
        ),
        BlocProvider<WordDetailBloc>(
          create: (_) => sl<WordDetailBloc>(),
        ),
        BlocProvider<BookmarkBloc>(
          create: (_) => sl<BookmarkBloc>(),
        ),
        BlocProvider<TranslateBloc>(
          create: (_) => sl<TranslateBloc>(),
        ),
        BlocProvider<ContributionBloc>(
          create: (_) => sl<ContributionBloc>(),
        ),
        BlocProvider<AdminWordBloc>(
          create: (_) => sl<AdminWordBloc>(),
        ),
        BlocProvider<UserMgmtBloc>(
          create: (_) => sl<UserMgmtBloc>(),
        ),
        BlocProvider<ModerationBloc>(
          create: (_) => sl<ModerationBloc>(),
        ),
        BlocProvider<AIRequestBloc>(
          create: (_) => sl<AIRequestBloc>(),
        ),
      ],
      child: _AppWithListeners(showOnboarding: showOnboarding),
    );
  }
}

class _AppWithListeners extends StatelessWidget {
  final bool showOnboarding;

  const _AppWithListeners({required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    // Global 401 handler: redirect to login when session expires
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          curr is Unauthenticated && prev is! Unauthenticated,
      listener: (context, state) {
        // Navigate to login only from protected routes
        final router = GoRouter.of(context);
        final currentUri = router.routerDelegate.currentConfiguration.uri.toString();
        final publicRoutes = [Routes.login, Routes.register, Routes.home, '/'];
        final isProtected =
            !publicRoutes.any((r) => currentUri.startsWith(r));
        if (isProtected) {
          context.go(Routes.login);
        }
      },
      child: NetworkBanner(
        connectivityChecker: sl<ConnectivityChecker>(),
        child: MaterialApp.router(
          title: 'Banjarin',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          routerConfig:
              createRouter(initialLocation: showOnboarding ? Routes.onboarding : Routes.home),
        ),
      ),
    );
  }
}
