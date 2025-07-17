// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/error_handler.dart';
import 'package:ray_club_app/features/profile/repositories/notification_settings_repository.dart';
import 'package:ray_club_app/features/profile/viewmodels/notification_settings_view_model.dart';

/// Configuração dos providers da aplicação
List<Override> get appProviders => [
  // Core
  errorHandlerProvider.overrideWithValue(ErrorHandler()),
  
  // Repositories
  notificationSettingsRepositoryProvider.overrideWithValue(
    NotificationSettingsRepository(),
  ),
  
  // Outros providers podem ser adicionados aqui
];

/// Wrap do ProviderScope com os providers da aplicação
class AppProviderScope extends StatelessWidget {
  /// Construtor
  const AppProviderScope({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// Widget filho
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: appProviders,
      child: child,
    );
  }
} 