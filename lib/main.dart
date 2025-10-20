import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ynfny/utils/responsive_scale.dart';
import 'package:ynfny/presentation/video_recording/video_recording_screen.dart';
import 'package:ynfny/presentation/video_upload/video_upload_screen.dart';
import 'package:ynfny/services/api_service.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';



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

  // Initialize API Service
  print('DEBUG: API Service initializing...');
  try {
    await ApiService().init();
    print('DEBUG: API Service initialized successfully');
  } catch (e) {
    print('DEBUG: API Service failed to initialize - ${e.toString()}');
    debugPrint('Failed to initialize API Service: $e');
  }

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    print('DEBUG: ErrorWidget.builder triggered');
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
  
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
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('DEBUG: Building MyApp');
    return ResponsiveWrapper(
      child: MaterialApp(
        title: 'ynfny',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
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
      ),
    );
  }
}
