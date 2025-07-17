// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/repositories/auth_repository.dart';
import 'package:ray_club_app/repositories/user_repository.dart';

void main() {
  group('AppRouter', () {
    late supabase.SupabaseClient mockSupabaseClient;
    late IAuthRepository mockAuthRepository;
    late IUserRepository mockUserRepository;
    late SharedPreferences mockPrefs;

    setUpAll(() async {
      mockPrefs = await SharedPreferences.getInstance();
    });

    setUp(() {
      mockSupabaseClient = supabase.SupabaseClient('url', 'key');
      mockAuthRepository = AuthRepository(mockSupabaseClient);
      mockUserRepository = UserRepository(
        supabaseClient: mockSupabaseClient,
        prefs: mockPrefs,
      );
    });

    test('should generate correct routes', () {
      final routes = [
        AppRouter.splash,
        AppRouter.login,
        AppRouter.signup,
        AppRouter.home,
      ];

      for (final route in routes) {
        final generatedRoute = AppRouter.generateRoute(
          RouteSettings(name: route),
        );
        expect(generatedRoute, isA<MaterialPageRoute>());
      }
    });

    test('should handle unknown routes', () {
      final route = AppRouter.generateRoute(
        const RouteSettings(name: '/unknown'),
      );
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('navigateTo should use Navigator.pushNamed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () =>
                      AppRouter.navigateTo(context, AppRouter.login),
                  child: const Text('Navigate'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('replaceWith should use Navigator.pushReplacementNamed',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () =>
                      AppRouter.replaceWith(context, AppRouter.login),
                  child: const Text('Replace'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('replaceAllWith should use Navigator.pushNamedAndRemoveUntil',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            userRepositoryProvider.overrideWithValue(mockUserRepository),
            sharedPreferencesProvider.overrideWithValue(mockPrefs),
          ],
          child: MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () =>
                      AppRouter.replaceAllWith(context, AppRouter.login),
                  child: const Text('Replace All'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Replace All'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);
    });
  });
}
