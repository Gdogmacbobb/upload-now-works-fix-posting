import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../config/supabase_config.dart';

void main() async {
  print('DEBUG: main() started');
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: WidgetsFlutterBinding initialized');

  // 🚨 CRITICAL: Global error handler for uncaught errors
  FlutterError.onError = (FlutterErrorDetails details) {
    print('DEBUG: FlutterError caught:');
    print('  Error: ${details.exception}');
    print('  Stack: ${details.stack}');
    FlutterError.presentError(details);
  };

  // Clear stale tokens once on startup
  try {
    // Clear cached Supabase tokens
    const projectRef = 'oemeugiejcjfbpmsftot';
    final script = '''
      localStorage.removeItem('sb-$projectRef-auth-token');
      localStorage.removeItem('sb-$projectRef-auth-token-code-verifier');
    ''';
    // Note: This runs in web context automatically
  } catch (e) {
    debugPrint('Token cleanup warning: $e');
  }

  // Initialize Supabase (single source)
  print('DEBUG: Supabase initializing...');
  try {
    await Supabase.initialize(
      url: AppSupabase.url, 
      anonKey: AppSupabase.anonKey
    );
    
    print('DEBUG: Supabase initialized successfully');
    
    // Safe logging (host only, never key)
    final uri = Uri.parse(AppSupabase.url);
    print('[SUPABASE] URL in use: ${uri.host}');
  } catch (e) {
    print('DEBUG: Supabase failed to initialize - ${e.toString()}');
=======
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    SupabaseService();
  } catch (e) {
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    debugPrint('Failed to initialize Supabase: $e');
  }

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
<<<<<<< HEAD
    print('DEBUG: ErrorWidget.builder triggered');
=======
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
<<<<<<< HEAD
  
  print('DEBUG: Setting device orientation');
  // 🚨 CRITICAL: Device orientation lock (web-safe)
  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    print('DEBUG: Orientation lock successful');
  } catch (e) {
    print('DEBUG: Orientation lock not supported (web) - $e');
  }
  
  print('DEBUG: Running MyApp');
  runApp(MyApp());
=======
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    print('DEBUG: Building MyApp');
    return ResponsiveWrapper(
      child: MaterialApp(
        title: 'ynfny',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
=======
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'ynfny',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
        // Add navigation error handling
        onUnknownRoute: (settings) {
          debugPrint('Unknown route: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Page Not Found'),
                backgroundColor: AppTheme.primaryOrange,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.accentRed,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Page Not Found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The requested page could not be found.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.initial,
                        (route) => false,
                      ),
                      child: Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
<<<<<<< HEAD
      ),
    );
=======
      );
    });
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5
  }
}
