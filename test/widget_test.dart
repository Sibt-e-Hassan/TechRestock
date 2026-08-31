import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tech_restock/app.dart';

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform(super.name, super.options);
}

class MockFirebasePlatform extends FirebasePlatform with MockPlatformInterfaceMixin {
  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final appOptions = options ?? const FirebaseOptions(
      apiKey: 'mockApiKey',
      appId: 'mockAppId',
      messagingSenderId: 'mockSenderId',
      projectId: 'mockProjectId',
    );
    final app = MockFirebaseAppPlatform(appName, appOptions);
    _apps[appName] = app;
    return app;
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    if (!_apps.containsKey(name)) {
      throw FirebaseException(
        plugin: 'core',
        code: 'no-app',
        message: "No Firebase App '$name' has been created",
      );
    }
    return _apps[name]!;
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Inject Dart-level mock Firebase platform
    FirebasePlatform.instance = MockFirebasePlatform();

    // Mock FirebaseAuth channel methods to prevent crashes during tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_auth'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Auth#registerIdTokenListener') {
          return null;
        }
        return null;
      },
    );

    // Initialize Mocked Firebase App
    await Firebase.initializeApp();
  });

  testWidgets('Log in screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ShoppandaApp());
    await tester.pumpAndSettle();

    // Verify Log In controls are displayed
    expect(find.text('Log in'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
  });
}
