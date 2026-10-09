import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/home/screens/main_navigation_shell.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // F-Droid compliance: prevent runtime HTTP downloading of non-free assets/fonts
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Firebase with fallback tolerance (runs gracefully in offline/FOSS mode)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice (running in offline/FOSS mode): $e');
  }

  runApp(
    const ProviderScope(
      child: HeadsUpApp(),
    ),
  );
}

class HeadsUpApp extends StatelessWidget {
  const HeadsUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AppRootRouter(),
    );
  }
}

class AppRootRouter extends ConsumerStatefulWidget {
  const AppRootRouter({super.key});

  @override
  ConsumerState<AppRootRouter> createState() => _AppRootRouterState();
}

class _AppRootRouterState extends ConsumerState<AppRootRouter> {
  bool _hasSeenOnboarding = false;

  @override
  Widget build(BuildContext context) {
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(
        onFinish: () {
          setState(() {
            _hasSeenOnboarding = true;
          });
        },
      );
    }

    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigationShell();
        }
        return const AuthScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      ),
      error: (err, stack) => const AuthScreen(),
    );
  }
}
