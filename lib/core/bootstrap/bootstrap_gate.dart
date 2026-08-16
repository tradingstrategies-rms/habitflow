import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/app/habit_flow_app.dart';
import 'package:habitflow/core/bootstrap/bootstrap.dart';
import 'package:habitflow/shared/widgets/widgets.dart';

/// [BootstrapGate] is a widget that manages the asynchronous initialization
/// of the application before mounting the main [HabitFlowApp].
class BootstrapGate extends StatefulWidget {
  /// Creates a [BootstrapGate].
  const BootstrapGate({super.key});

  @override
  State<BootstrapGate> createState() => _BootstrapGateState();
}

class _BootstrapGateState extends State<BootstrapGate> {
  ProviderContainer? _container;
  Object? _error;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (_isInitializing) return;
    
    setState(() {
      _isInitializing = true;
      _error = null;
    });

    try {
      debugPrint('BootstrapGate: Starting initialization...');
      final container = await Bootstrap.initialize();
      if (mounted) {
        setState(() {
          _container = container;
          _isInitializing = false;
        });
        debugPrint('BootstrapGate: Initialization successful');
      }
    } catch (e, st) {
      debugPrint('BootstrapGate: Initialization FAILED');
      debugPrint('Error: $e');
      debugPrint('Stacktrace: $st');
      if (mounted) {
        setState(() {
          _error = e;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If initialization is complete and we have a container, mount the app
    if (_container != null) {
      return UncontrolledProviderScope(
        container: _container!,
        child: const HabitFlowApp(),
      );
    }

    // Show error state if initialization failed
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF10B981)),
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
                    const SizedBox(height: 24),
                    const Text(
                      'Startup Failed',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'HabitFlow encountered an error while starting up. This might be due to a connection issue or a configuration error.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _error.toString(),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _init,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry Startup'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Default loading state (Bootstrap UI)
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF10B981)),
      home: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Placeholder (matches SplashScreen branding)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(51), // ~0.2 opacity
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'HabitFlow',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 48),
              const HFLoadingIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Initializing services...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
