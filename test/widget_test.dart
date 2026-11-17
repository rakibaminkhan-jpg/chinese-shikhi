import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'package:chinese_shikhi/main.dart';

// ------------------------------------------------------------
// Fake Firebase Core
// ------------------------------------------------------------

class FakeFirebaseCore extends FirebasePlatform {
  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;

    return _apps.putIfAbsent(
      appName,
      () => FirebaseAppPlatform(
        appName,
        options ??
            const FirebaseOptions(
              apiKey: 'test-api-key',
              appId: '1:1234567890:android:test',
              messagingSenderId: '1234567890',
              projectId: 'chinese-shikhi-test',
            ),
      ),
    );
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    final result = _apps[name];
    if (result == null) {
      throw FirebaseException(
        plugin: 'firebase_core',
        code: 'no-app',
        message: 'No Firebase App $name has been created.',
      );
    }
    return result;
  }
}

// ------------------------------------------------------------
// Fake Firebase Auth — signed-out user
// ------------------------------------------------------------

class FakeFirebaseAuth extends FirebaseAuthPlatform {
  FakeFirebaseAuth(FirebaseApp app) : super(appInstance: app);

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return FakeFirebaseAuth(app);
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }

  @override
  UserPlatform? get currentUser => null;

  @override
  Stream<UserPlatform?> authStateChanges() {
    return Stream<UserPlatform?>.value(null);
  }

  @override
  Stream<UserPlatform?> idTokenChanges() {
    return Stream<UserPlatform?>.value(null);
  }

  @override
  Stream<UserPlatform?> userChanges() {
    return Stream<UserPlatform?>.value(null);
  }
}

// ------------------------------------------------------------
// Fake Firestore — app is signed out, so no database reads
// ------------------------------------------------------------

class FakeFirebaseFirestore extends FirebaseFirestorePlatform {
  FakeFirebaseFirestore(FirebaseApp app) : super(appInstance: app);

  @override
  FirebaseFirestorePlatform delegateFor({
    required FirebaseApp app,
    required String databaseId,
  }) {
    return FakeFirebaseFirestore(app);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    // প্রথমে Firebase Core mock ইনস্টল করি।
    FirebasePlatform.instance = FakeFirebaseCore();

    // এরপর Firebase-এর default app initialize করি।
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: '1:1234567890:android:test',
        messagingSenderId: '1234567890',
        projectId: 'chinese-shikhi-test',
      ),
    );

    // App তৈরি হওয়ার পর Auth ও Firestore mock ইনস্টল করি।
    final app = Firebase.app();
    FirebaseAuthPlatform.instance = FakeFirebaseAuth(app);
    FirebaseFirestorePlatform.instance = FakeFirebaseFirestore(app);
  });

  testWidgets(
    'ChineseShikhiApp loads and welcome dialog opens',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(const ChineseShikhiApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('চীনা শিখি অ্যাপে স্বাগতম!'), findsOneWidget);
      expect(find.text('শেখা শুরু করুন'), findsOneWidget);
    },
  );

  testWidgets(
    'Welcome dialog closes and home navigation appears',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(const ChineseShikhiApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('শেখা শুরু করুন'), findsOneWidget);

      await tester.tap(find.text('শেখা শুরু করুন'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('শেখা শুরু করুন'), findsNothing);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('হোম'), findsOneWidget);
    },
  );
}
