import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const HidayahApp());
}

class HidayahApp extends StatelessWidget {
  const HidayahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          // Update system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: appProvider.isDarkMode 
                  ? Brightness.light 
                  : Brightness.dark,
              systemNavigationBarColor: appProvider.isDarkMode 
                  ? Colors.black 
                  : Colors.white,
              systemNavigationBarIconBrightness: appProvider.isDarkMode 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
          );
          
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(
              appProvider.themeMode, 
              appProvider.glassStyle,
              baseFontSize: appProvider.baseFontSize,
            ),
            home: child,
          );
        },
        // Cache SplashScreen widget to prevent rebuilds
        child: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final appProvider = context.read<AppProvider>();
    await appProvider.initialize();
    
    if (mounted) {
      // Navigate to appropriate screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => appProvider.isFirstLaunch
              ? const WelcomeScreen()
              : const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    
    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appProvider.accentColor,
                      appProvider.accentColor.withOpacity(0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: appProvider.accentColor.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.book_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // App Name
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Your Companion for Learning',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 48),
              
              // Loading Indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  appProvider.accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
