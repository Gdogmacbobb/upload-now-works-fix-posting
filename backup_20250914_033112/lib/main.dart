import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ynfny/core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/connection_error_widget.dart';
import '../widgets/startup_error_screen.dart';
import './services/supabase_service.dart';
import './config/supabase_config.dart';

// BULLETPROOF: Helper function to run startup error screen safely
void _runStartupErrorApp(String title, String details) {
  try {
    runApp(StartupErrorScreen(
      errorMessage: title,
      errorDetails: details,
      onRetry: () {
        // Full app restart - call main() again after delay
        Future.delayed(Duration(milliseconds: 500), () {
          main();
        });
      },
    ));
  } catch (e) {
    // ULTIMATE FALLBACK: If even startup error screen fails
    debugPrint('Startup error screen failed to load: $e');
    try {
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Critical Error: App Cannot Start',
                      style: TextStyle(
                        color: Colors.red, 
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please close and reopen the application.',
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ));
    } catch (finalError) {
      // ABSOLUTE LAST RESORT
      debugPrint('All error handling failed: $finalError');
    }
  }
}

void main() async {
  // GLOBAL ERROR HANDLING: Catch ALL uncaught async errors globally
  runZonedGuarded<void>(
    () async {
      // BULLETPROOF: Catch ALL possible errors during app initialization
      try {
        WidgetsFlutterBinding.ensureInitialized();

        // Set up global Flutter error handling FIRST
        FlutterError.onError = (FlutterErrorDetails details) {
          debugPrint('Flutter Error: ${details.exception}');
          debugPrint('Stack trace: ${details.stack}');
          
          // Try to show startup error screen for Flutter errors
          try {
            _runStartupErrorApp(
              'Flutter Error', 
              '${details.exception}\n\nStack: ${details.stack}',
            );
          } catch (e) {
            debugPrint('Failed to show Flutter error screen: $e');
          }
        };

    // HARDENED: Initialize Supabase with guaranteed single instance pattern and timeout
    try {
      if (!SupabaseConfig.isValid) {
        throw Exception(SupabaseConfig.configErrorMessage);
      }
      
      // Protect against duplicate initialization with timeout
      try {
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          anonKey: SupabaseConfig.supabaseAnonKey,
        ).timeout(
          Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Supabase initialization timeout after 10 seconds', Duration(seconds: 10));
          },
        );
        debugPrint('Supabase initialized successfully');
      } catch (initError) {
        // If already initialized, that's fine - just log and continue
        if (initError.toString().contains('already initialized') || 
            initError.toString().contains('Supabase has already been initialized')) {
          debugPrint('Supabase already initialized - using existing instance');
        } else if (initError is TimeoutException) {
          debugPrint('Supabase initialization timed out');
          throw Exception('Supabase initialization timed out. Please check your connection.');
        } else {
          // Re-throw other initialization errors
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize Supabase: $e');
      // Show clean connection error screen with safe fallback
      _runStartupErrorApp('Supabase connection failed', e.toString());
      return;
    }
  } catch (e) {
    // ULTIMATE FALLBACK: If even basic initialization fails
    debugPrint('Critical initialization error: $e');
    _runStartupErrorApp('App initialization failed', e.toString());
    return;
  }

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  try {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return CustomErrorWidget(
        errorDetails: details,
      );
    };
  } catch (e) {
    debugPrint('Error widget setup failed: $e');
    // Continue anyway - not critical for app function
  }
  
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(MyApp());
  } catch (e) {
    debugPrint('Orientation setup failed: $e');
    // Try to run app anyway without orientation lock
    try {
      runApp(MyApp());
    } catch (e2) {
      debugPrint('App startup failed: $e2');
      _runStartupErrorApp('App startup failed', e2.toString());
    }
  }
    },
    (Object error, StackTrace stack) {
      // ZONE ERROR HANDLER: Catch ALL uncaught async errors
      debugPrint('Uncaught async error: $error');
      debugPrint('Stack trace: $stack');
      
      // Show startup error screen for async errors
      try {
        _runStartupErrorApp(
          'Uncaught Async Error', 
          '$error\n\nStack: $stack',
        );
      } catch (e) {
        debugPrint('Failed to show async error screen: $e');
        // Last resort: try basic error screen
        try {
          runApp(MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Fatal Error: App Has Crashed',
                          style: TextStyle(
                            color: Colors.red, 
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please close and reopen the application.',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
        } catch (finalError) {
          debugPrint('All async error handling failed: $finalError');
        }
      }
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ynfny',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
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
    );
  }
}
