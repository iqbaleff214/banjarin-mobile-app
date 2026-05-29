import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/dictionary/presentation/bloc/search_bloc.dart';
import 'features/dictionary/presentation/bloc/word_detail_bloc.dart';
import 'features/dictionary/presentation/bloc/word_list_bloc.dart';
import 'features/dictionary/presentation/bloc/word_list_event.dart';
import 'features/identity/presentation/bloc/auth_bloc.dart';
import 'features/identity/presentation/bloc/auth_event.dart';
import 'features/identity/presentation/bloc/profile_bloc.dart';
import 'injection/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await initDependencies();
  runApp(const BanjarinApp());
}

class BanjarinApp extends StatelessWidget {
  const BanjarinApp({super.key});

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
      ],
      child: MaterialApp.router(
        title: 'Banjarin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: createRouter(),
      ),
    );
  }
}
