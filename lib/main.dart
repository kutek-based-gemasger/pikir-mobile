import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const ChatHeadApp());
}

class ChatHeadApp extends StatelessWidget {
  const ChatHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Head Notifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // We start at the Gatekeeper
      home: const GatekeeperScreen(),
    );
  }
}

class GatekeeperScreen extends StatefulWidget {
  const GatekeeperScreen({super.key});

  @override
  State<GatekeeperScreen> createState() => _GatekeeperScreenState();
}

class _GatekeeperScreenState extends State<GatekeeperScreen>
    with WidgetsBindingObserver {
  static const platform = MethodChannel(
    'com.yourdomain.chat_head_app/overlay',
  ); // Make sure this channel name matches yours

  bool _isLoading = true;
  bool _hasOverlayPermission = false;
  bool _hasNotificationPermission = false;
  bool _hasPostNotificationPermission = false; // NEW STATE

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);

    try {
      final bool overlay = await platform.invokeMethod(
        'checkOverlayPermission',
      );
      final bool notification = await platform.invokeMethod(
        'checkNotificationPermission',
      );
      final bool postNotif = await platform.invokeMethod(
        'checkPostNotificationPermission',
      ); // NEW CHECK

      if (overlay && notification && postNotif) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
        return;
      }

      setState(() {
        _hasOverlayPermission = overlay;
        _hasNotificationPermission = notification;
        _hasPostNotificationPermission = postNotif; // UPDATE STATE
        _isLoading = false;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to check permissions: '${e.message}'.");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestOverlayPermission() async {
    await platform.invokeMethod('requestOverlayPermission');
  }

  Future<void> _requestNotificationPermission() async {
    await platform.invokeMethod('requestNotificationPermission');
  }

  Future<void> _requestPostNotificationPermission() async {
    await platform.invokeMethod('requestPostNotificationPermission');
    // For standard permission dialogs, we need a slight delay before re-checking
    await Future.delayed(const Duration(seconds: 2));
    _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setup Required')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'We need a few permissions to make the chat head work correctly.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            if (!_hasOverlayPermission) ...[
              ElevatedButton.icon(
                onPressed: _requestOverlayPermission,
                icon: const Icon(Icons.layers),
                label: const Text('Allow Display Over Other Apps'),
              ),
              const SizedBox(height: 16),
            ],

            if (!_hasNotificationPermission) ...[
              ElevatedButton.icon(
                onPressed: _requestNotificationPermission,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Allow Notification Access'),
              ),
              const SizedBox(height: 16),
            ],

            // NEW BUTTON
            if (!_hasPostNotificationPermission) ...[
              ElevatedButton.icon(
                onPressed: _requestPostNotificationPermission,
                icon: const Icon(Icons.message),
                label: const Text('Allow App to Send Notifications'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- THIS IS YOUR MAIN APP SCREEN ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const platform = MethodChannel('com.yourdomain.chat_head_app/overlay');
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _checkInitialServiceState();
  }

  // Queries the native Kotlin layer to see if the Foreground Service is alive
  Future<void> _checkInitialServiceState() async {
    try {
      final bool isRunning = await platform.invokeMethod('isServiceRunning');
      setState(() {
        _isServiceRunning = isRunning;
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to check service state: '${e.message}'.");
    }
  }

  Future<void> _toggleService() async {
    if (_isServiceRunning) {
      await platform.invokeMethod('stopFloatingService');
      setState(() => _isServiceRunning = false);
    } else {
      await platform.invokeMethod('startFloatingService');
      setState(() => _isServiceRunning = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Head Active'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _toggleService,
          icon: Icon(_isServiceRunning ? Icons.stop : Icons.play_arrow),
          label: Text(_isServiceRunning ? 'Stop Chat Head' : 'Start Chat Head'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isServiceRunning ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),
    );
  }
}
