import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../core/app_export.dart';

class StartupErrorScreen extends StatefulWidget {
  final String errorMessage;
  final String? errorDetails;
  final VoidCallback? onRetry;

  const StartupErrorScreen({
    Key? key,
    required this.errorMessage,
    this.errorDetails,
    this.onRetry,
  }) : super(key: key);

  @override
  State<StartupErrorScreen> createState() => _StartupErrorScreenState();
}

class _StartupErrorScreenState extends State<StartupErrorScreen> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;
    
    setState(() {
      _isRetrying = true;
    });

    try {
      // Enhanced retry logic with better error handling
      debugPrint('Attempting to reinitialize or verify Supabase...');
      
      // Try to initialize Supabase with enhanced error handling and timeout
      await () async {
        if (!SupabaseConfig.isValid) {
          throw Exception(SupabaseConfig.configErrorMessage);
        }
        
        try {
          // Try to initialize with timeout
          await Supabase.initialize(
            url: SupabaseConfig.supabaseUrl,
            anonKey: SupabaseConfig.supabaseAnonKey,
          ).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Supabase initialization timeout during retry', Duration(seconds: 10));
            },
          );
          debugPrint('Supabase initialized successfully during retry');
        } catch (initError) {
          // Handle "already initialized" gracefully
          if (initError.toString().contains('already initialized') || 
              initError.toString().contains('Supabase has already been initialized')) {
            debugPrint('Supabase already initialized - continuing with existing instance');
            
            // Verify the existing instance is working
            try {
              final client = Supabase.instance.client;
              debugPrint('Existing Supabase instance verified successfully');
            } catch (verifyError) {
              debugPrint('Existing Supabase instance verification failed: $verifyError');
              throw Exception('Existing Supabase instance is not working properly');
            }
          } else if (initError is TimeoutException) {
            debugPrint('Supabase initialization timed out during retry');
            throw Exception('Supabase initialization timed out. Please check your connection.');
          } else {
            // Re-throw other initialization errors
            rethrow;
          }
        }
      }().timeout(Duration(seconds: 15)); // Overall retry timeout

      debugPrint('Supabase verification/initialization completed successfully');
      
      // Add a brief delay before calling retry callback
      await Future.delayed(Duration(milliseconds: 300));
      
      // Call custom retry callback if provided, otherwise restart main
      if (widget.onRetry != null) {
        widget.onRetry!();
      } else {
        // Restart the entire app by calling main again
        await Future.delayed(Duration(milliseconds: 500));
        // This will be handled by the parent app restart logic
      }
    } catch (e) {
      debugPrint('Retry failed: $e');
      setState(() {
        _isRetrying = false;
      });
      
      // Enhanced error dialog with more helpful information
      if (mounted) {
        String errorMessage;
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('timeout')) {
          errorMessage = 'Connection timeout. Please check your internet connection and try again.';
        } else if (errorString.contains('network') || errorString.contains('connection')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (errorString.contains('configuration')) {
          errorMessage = 'Configuration error. Please contact support.';
        } else {
          errorMessage = 'Unable to restart the app. Please close and reopen the application.\n\nError: ${e.toString()}';
        }
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Retry Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
              if (errorString.contains('timeout') || errorString.contains('network'))
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Try again after a brief delay
                    Future.delayed(Duration(seconds: 2), () {
                      if (mounted) {
                        _handleRetry();
                      }
                    });
                  },
                  child: Text('Try Again'),
                ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error icon
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Main error message
                  Text(
                    'App Failed to Load',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Friendly explanation
                  Text(
                    'We encountered an issue while starting the app. This usually resolves itself with a quick retry.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Retry button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isRetrying ? null : _handleRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isRetrying
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Retrying...'),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 20),
                                SizedBox(width: 8),
                                Text('Try Again'),
                              ],
                            ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Error details (collapsible)
                  if (widget.errorDetails != null) ...[
                    ExpansionTile(
                      title: Text(
                        'Error Details',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.errorDetails!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  SizedBox(height: 16),
                  
                  // Additional help text
                  Text(
                    'If this problem persists, please close and reopen the app.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}