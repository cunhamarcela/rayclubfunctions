// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AnimatedSplashScreen]
class AnimatedSplashRoute extends PageRouteInfo<void> {
  const AnimatedSplashRoute({List<PageRouteInfo>? children})
      : super(
          AnimatedSplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'AnimatedSplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnimatedSplashScreen();
    },
  );
}

/// generated route for
/// [BasicUserDebugScreen]
class BasicUserDebugRoute extends PageRouteInfo<void> {
  const BasicUserDebugRoute({List<PageRouteInfo>? children})
      : super(
          BasicUserDebugRoute.name,
          initialChildren: children,
        );

  static const String name = 'BasicUserDebugRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BasicUserDebugScreen();
    },
  );
}

/// generated route for
/// [BenefitAdminScreen]
class BenefitAdminRoute extends PageRouteInfo<void> {
  const BenefitAdminRoute({List<PageRouteInfo>? children})
      : super(
          BenefitAdminRoute.name,
          initialChildren: children,
        );

  static const String name = 'BenefitAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BenefitAdminScreen();
    },
  );
}

/// generated route for
/// [BenefitDetailScreen]
class BenefitDetailRoute extends PageRouteInfo<BenefitDetailRouteArgs> {
  BenefitDetailRoute({
    Key? key,
    required String benefitId,
    List<PageRouteInfo>? children,
  }) : super(
          BenefitDetailRoute.name,
          args: BenefitDetailRouteArgs(
            key: key,
            benefitId: benefitId,
          ),
          rawPathParams: {'id': benefitId},
          initialChildren: children,
        );

  static const String name = 'BenefitDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<BenefitDetailRouteArgs>(
          orElse: () =>
              BenefitDetailRouteArgs(benefitId: pathParams.getString('id')));
      return BenefitDetailScreen(
        key: args.key,
        benefitId: args.benefitId,
      );
    },
  );
}

class BenefitDetailRouteArgs {
  const BenefitDetailRouteArgs({
    this.key,
    required this.benefitId,
  });

  final Key? key;

  final String benefitId;

  @override
  String toString() {
    return 'BenefitDetailRouteArgs{key: $key, benefitId: $benefitId}';
  }
}

/// generated route for
/// [BenefitFormScreen]
class BenefitFormRoute extends PageRouteInfo<BenefitFormRouteArgs> {
  BenefitFormRoute({
    Key? key,
    String? benefitId,
    List<PageRouteInfo>? children,
  }) : super(
          BenefitFormRoute.name,
          args: BenefitFormRouteArgs(
            key: key,
            benefitId: benefitId,
          ),
          rawQueryParams: {'benefitId': benefitId},
          initialChildren: children,
        );

  static const String name = 'BenefitFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<BenefitFormRouteArgs>(
          orElse: () => BenefitFormRouteArgs(
              benefitId: queryParams.optString('benefitId')));
      return BenefitFormScreen(
        key: args.key,
        benefitId: args.benefitId,
      );
    },
  );
}

class BenefitFormRouteArgs {
  const BenefitFormRouteArgs({
    this.key,
    this.benefitId,
  });

  final Key? key;

  final String? benefitId;

  @override
  String toString() {
    return 'BenefitFormRouteArgs{key: $key, benefitId: $benefitId}';
  }
}

/// generated route for
/// [BenefitsListScreen]
class BenefitsListRoute extends PageRouteInfo<void> {
  const BenefitsListRoute({List<PageRouteInfo>? children})
      : super(
          BenefitsListRoute.name,
          initialChildren: children,
        );

  static const String name = 'BenefitsListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BenefitsListScreen();
    },
  );
}

/// generated route for
/// [BenefitsScreen]
class BenefitsRoute extends PageRouteInfo<void> {
  const BenefitsRoute({List<PageRouteInfo>? children})
      : super(
          BenefitsRoute.name,
          initialChildren: children,
        );

  static const String name = 'BenefitsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BenefitsScreen();
    },
  );
}

/// generated route for
/// [ChallengeCompletedScreen]
class ChallengeCompletedRoute extends PageRouteInfo<void> {
  const ChallengeCompletedRoute({List<PageRouteInfo>? children})
      : super(
          ChallengeCompletedRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChallengeCompletedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChallengeCompletedScreen();
    },
  );
}

/// generated route for
/// [ChallengeDetailScreen]
class ChallengeDetailRoute extends PageRouteInfo<ChallengeDetailRouteArgs> {
  ChallengeDetailRoute({
    Key? key,
    required String challengeId,
    List<PageRouteInfo>? children,
  }) : super(
          ChallengeDetailRoute.name,
          args: ChallengeDetailRouteArgs(
            key: key,
            challengeId: challengeId,
          ),
          rawPathParams: {'challengeId': challengeId},
          initialChildren: children,
        );

  static const String name = 'ChallengeDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChallengeDetailRouteArgs>(
          orElse: () => ChallengeDetailRouteArgs(
              challengeId: pathParams.getString('challengeId')));
      return ChallengeDetailScreen(
        key: args.key,
        challengeId: args.challengeId,
      );
    },
  );
}

class ChallengeDetailRouteArgs {
  const ChallengeDetailRouteArgs({
    this.key,
    required this.challengeId,
  });

  final Key? key;

  final String challengeId;

  @override
  String toString() {
    return 'ChallengeDetailRouteArgs{key: $key, challengeId: $challengeId}';
  }
}

/// generated route for
/// [ChallengeFormScreen]
class ChallengeFormRoute extends PageRouteInfo<ChallengeFormRouteArgs> {
  ChallengeFormRoute({
    String? challengeId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ChallengeFormRoute.name,
          args: ChallengeFormRouteArgs(
            challengeId: challengeId,
            key: key,
          ),
          rawPathParams: {'id': challengeId},
          initialChildren: children,
        );

  static const String name = 'ChallengeFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChallengeFormRouteArgs>(
          orElse: () =>
              ChallengeFormRouteArgs(challengeId: pathParams.optString('id')));
      return ChallengeFormScreen(
        challengeId: args.challengeId,
        key: args.key,
      );
    },
  );
}

class ChallengeFormRouteArgs {
  const ChallengeFormRouteArgs({
    this.challengeId,
    this.key,
  });

  final String? challengeId;

  final Key? key;

  @override
  String toString() {
    return 'ChallengeFormRouteArgs{challengeId: $challengeId, key: $key}';
  }
}

/// generated route for
/// [ChallengeGroupDetailScreen]
class ChallengeGroupDetailRoute
    extends PageRouteInfo<ChallengeGroupDetailRouteArgs> {
  ChallengeGroupDetailRoute({
    Key? key,
    required String groupId,
    List<PageRouteInfo>? children,
  }) : super(
          ChallengeGroupDetailRoute.name,
          args: ChallengeGroupDetailRouteArgs(
            key: key,
            groupId: groupId,
          ),
          rawPathParams: {'groupId': groupId},
          initialChildren: children,
        );

  static const String name = 'ChallengeGroupDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChallengeGroupDetailRouteArgs>(
          orElse: () => ChallengeGroupDetailRouteArgs(
              groupId: pathParams.getString('groupId')));
      return ChallengeGroupDetailScreen(
        key: args.key,
        groupId: args.groupId,
      );
    },
  );
}

class ChallengeGroupDetailRouteArgs {
  const ChallengeGroupDetailRouteArgs({
    this.key,
    required this.groupId,
  });

  final Key? key;

  final String groupId;

  @override
  String toString() {
    return 'ChallengeGroupDetailRouteArgs{key: $key, groupId: $groupId}';
  }
}

/// generated route for
/// [ChallengeGroupInvitesScreen]
class ChallengeGroupInvitesRoute extends PageRouteInfo<void> {
  const ChallengeGroupInvitesRoute({List<PageRouteInfo>? children})
      : super(
          ChallengeGroupInvitesRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChallengeGroupInvitesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChallengeGroupInvitesScreen();
    },
  );
}

/// generated route for
/// [ChallengeGroupsScreen]
class ChallengeGroupsRoute extends PageRouteInfo<void> {
  const ChallengeGroupsRoute({List<PageRouteInfo>? children})
      : super(
          ChallengeGroupsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChallengeGroupsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChallengeGroupsScreen();
    },
  );
}

/// generated route for
/// [ChallengeInvitesScreen]
class ChallengeInvitesRoute extends PageRouteInfo<ChallengeInvitesRouteArgs> {
  ChallengeInvitesRoute({
    Key? key,
    required String userId,
    List<PageRouteInfo>? children,
  }) : super(
          ChallengeInvitesRoute.name,
          args: ChallengeInvitesRouteArgs(
            key: key,
            userId: userId,
          ),
          rawPathParams: {'userId': userId},
          initialChildren: children,
        );

  static const String name = 'ChallengeInvitesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChallengeInvitesRouteArgs>(
          orElse: () => ChallengeInvitesRouteArgs(
              userId: pathParams.getString('userId')));
      return ChallengeInvitesScreen(
        key: args.key,
        userId: args.userId,
      );
    },
  );
}

class ChallengeInvitesRouteArgs {
  const ChallengeInvitesRouteArgs({
    this.key,
    required this.userId,
  });

  final Key? key;

  final String userId;

  @override
  String toString() {
    return 'ChallengeInvitesRouteArgs{key: $key, userId: $userId}';
  }
}

/// generated route for
/// [ChallengeRankingScreen]
class ChallengeRankingRoute extends PageRouteInfo<ChallengeRankingRouteArgs> {
  ChallengeRankingRoute({
    Key? key,
    required String challengeId,
    List<PageRouteInfo>? children,
  }) : super(
          ChallengeRankingRoute.name,
          args: ChallengeRankingRouteArgs(
            key: key,
            challengeId: challengeId,
          ),
          rawPathParams: {'challengeId': challengeId},
          initialChildren: children,
        );

  static const String name = 'ChallengeRankingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChallengeRankingRouteArgs>(
          orElse: () => ChallengeRankingRouteArgs(
              challengeId: pathParams.getString('challengeId')));
      return ChallengeRankingScreen(
        key: args.key,
        challengeId: args.challengeId,
      );
    },
  );
}

class ChallengeRankingRouteArgs {
  const ChallengeRankingRouteArgs({
    this.key,
    required this.challengeId,
  });

  final Key? key;

  final String challengeId;

  @override
  String toString() {
    return 'ChallengeRankingRouteArgs{key: $key, challengeId: $challengeId}';
  }
}

/// generated route for
/// [ChallengeWorkoutsScreen]
class ChallengeWorkoutsRoute extends PageRouteInfo<ChallengeWorkoutsRouteArgs> {
  ChallengeWorkoutsRoute({
    required String challengeId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ChallengeWorkoutsRoute.name,
          args: ChallengeWorkoutsRouteArgs(
            challengeId: challengeId,
            key: key,
          ),
          rawPathParams: {'challengeId': challengeId},
          initialChildren: children,
        );

  static const String name = 'ChallengeWorkoutsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ChallengeWorkoutsRouteArgs>(
          orElse: () => ChallengeWorkoutsRouteArgs(
              challengeId: pathParams.getString('challengeId')));
      return ChallengeWorkoutsScreen(
        challengeId: args.challengeId,
        key: args.key,
      );
    },
  );
}

class ChallengeWorkoutsRouteArgs {
  const ChallengeWorkoutsRouteArgs({
    required this.challengeId,
    this.key,
  });

  final String challengeId;

  final Key? key;

  @override
  String toString() {
    return 'ChallengeWorkoutsRouteArgs{challengeId: $challengeId, key: $key}';
  }
}

/// generated route for
/// [ChallengesAdminScreen]
class ChallengesAdminRoute extends PageRouteInfo<void> {
  const ChallengesAdminRoute({List<PageRouteInfo>? children})
      : super(
          ChallengesAdminRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChallengesAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChallengesAdminScreen();
    },
  );
}

/// generated route for
/// [ChallengesListScreen]
class ChallengesListRoute extends PageRouteInfo<void> {
  const ChallengesListRoute({List<PageRouteInfo>? children})
      : super(
          ChallengesListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChallengesListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChallengesListScreen();
    },
  );
}

/// generated route for
/// [ChallengesScreen]
class ChallengesRoute extends PageRouteInfo<void> {
  const ChallengesRoute({List<PageRouteInfo>? children})
      : super(
          ChallengesRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChallengesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChallengesScreen();
    },
  );
}

/// generated route for
/// [ConsentManagementScreen]
class ConsentManagementRoute extends PageRouteInfo<void> {
  const ConsentManagementRoute({List<PageRouteInfo>? children})
      : super(
          ConsentManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'ConsentManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ConsentManagementScreen();
    },
  );
}

/// generated route for
/// [CreateChallengeGroupScreen]
class CreateChallengeGroupRoute extends PageRouteInfo<void> {
  const CreateChallengeGroupRoute({List<PageRouteInfo>? children})
      : super(
          CreateChallengeGroupRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateChallengeGroupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateChallengeGroupScreen();
    },
  );
}

/// generated route for
/// [CreateChallengeScreen]
class CreateChallengeRoute extends PageRouteInfo<void> {
  const CreateChallengeRoute({List<PageRouteInfo>? children})
      : super(
          CreateChallengeRoute.name,
          initialChildren: children,
        );

  static const String name = 'CreateChallengeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CreateChallengeScreen();
    },
  );
}

/// generated route for
/// [CuponsScreen]
class CuponsRoute extends PageRouteInfo<void> {
  const CuponsRoute({List<PageRouteInfo>? children})
      : super(
          CuponsRoute.name,
          initialChildren: children,
        );

  static const String name = 'CuponsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CuponsScreen();
    },
  );
}

/// generated route for
/// [DashboardEnhancedScreen]
class DashboardEnhancedRoute extends PageRouteInfo<void> {
  const DashboardEnhancedRoute({List<PageRouteInfo>? children})
      : super(
          DashboardEnhancedRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardEnhancedRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardEnhancedScreen();
    },
  );
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DashboardScreen();
    },
  );
}

/// generated route for
/// [DbValidatorScreen]
class DbValidatorRoute extends PageRouteInfo<void> {
  const DbValidatorRoute({List<PageRouteInfo>? children})
      : super(
          DbValidatorRoute.name,
          initialChildren: children,
        );

  static const String name = 'DbValidatorRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DbValidatorScreen();
    },
  );
}

/// generated route for
/// [DebugProfileDiagnoseScreen]
class DebugProfileDiagnoseRoute extends PageRouteInfo<void> {
  const DebugProfileDiagnoseRoute({List<PageRouteInfo>? children})
      : super(
          DebugProfileDiagnoseRoute.name,
          initialChildren: children,
        );

  static const String name = 'DebugProfileDiagnoseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DebugProfileDiagnoseScreen();
    },
  );
}

/// generated route for
/// [EmailVerificationScreen]
class EmailVerificationRoute extends PageRouteInfo<EmailVerificationRouteArgs> {
  EmailVerificationRoute({
    Key? key,
    required String email,
    String? userId,
    List<PageRouteInfo>? children,
  }) : super(
          EmailVerificationRoute.name,
          args: EmailVerificationRouteArgs(
            key: key,
            email: email,
            userId: userId,
          ),
          initialChildren: children,
        );

  static const String name = 'EmailVerificationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EmailVerificationRouteArgs>();
      return EmailVerificationScreen(
        key: args.key,
        email: args.email,
        userId: args.userId,
      );
    },
  );
}

class EmailVerificationRouteArgs {
  const EmailVerificationRouteArgs({
    this.key,
    required this.email,
    this.userId,
  });

  final Key? key;

  final String email;

  final String? userId;

  @override
  String toString() {
    return 'EmailVerificationRouteArgs{key: $key, email: $email, userId: $userId}';
  }
}

/// generated route for
/// [ErrorAdminScreen]
class ErrorAdminRoute extends PageRouteInfo<void> {
  const ErrorAdminRoute({List<PageRouteInfo>? children})
      : super(
          ErrorAdminRoute.name,
          initialChildren: children,
        );

  static const String name = 'ErrorAdminRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ErrorAdminScreen();
    },
  );
}

/// generated route for
/// [EventDetailScreen]
class EventDetailRoute extends PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    Key? key,
    required String eventId,
    List<PageRouteInfo>? children,
  }) : super(
          EventDetailRoute.name,
          args: EventDetailRouteArgs(
            key: key,
            eventId: eventId,
          ),
          rawPathParams: {'eventId': eventId},
          initialChildren: children,
        );

  static const String name = 'EventDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EventDetailRouteArgs>(
          orElse: () =>
              EventDetailRouteArgs(eventId: pathParams.getString('eventId')));
      return EventDetailScreen(
        key: args.key,
        eventId: args.eventId,
      );
    },
  );
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({
    this.key,
    required this.eventId,
  });

  final Key? key;

  final String eventId;

  @override
  String toString() {
    return 'EventDetailRouteArgs{key: $key, eventId: $eventId}';
  }
}

/// generated route for
/// [EventsScreen]
class EventsRoute extends PageRouteInfo<void> {
  const EventsRoute({List<PageRouteInfo>? children})
      : super(
          EventsRoute.name,
          initialChildren: children,
        );

  static const String name = 'EventsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EventsScreen();
    },
  );
}

/// generated route for
/// [FavoriteRecipesScreen]
class FavoriteRecipesRoute extends PageRouteInfo<void> {
  const FavoriteRecipesRoute({List<PageRouteInfo>? children})
      : super(
          FavoriteRecipesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoriteRecipesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavoriteRecipesScreen();
    },
  );
}

/// generated route for
/// [FeaturedContentDetailScreen]
class FeaturedContentDetailRoute
    extends PageRouteInfo<FeaturedContentDetailRouteArgs> {
  FeaturedContentDetailRoute({
    Key? key,
    required String contentId,
    List<PageRouteInfo>? children,
  }) : super(
          FeaturedContentDetailRoute.name,
          args: FeaturedContentDetailRouteArgs(
            key: key,
            contentId: contentId,
          ),
          rawPathParams: {'id': contentId},
          initialChildren: children,
        );

  static const String name = 'FeaturedContentDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<FeaturedContentDetailRouteArgs>(
          orElse: () => FeaturedContentDetailRouteArgs(
              contentId: pathParams.getString('id')));
      return FeaturedContentDetailScreen(
        key: args.key,
        contentId: args.contentId,
      );
    },
  );
}

class FeaturedContentDetailRouteArgs {
  const FeaturedContentDetailRouteArgs({
    this.key,
    required this.contentId,
  });

  final Key? key;

  final String contentId;

  @override
  String toString() {
    return 'FeaturedContentDetailRouteArgs{key: $key, contentId: $contentId}';
  }
}

/// generated route for
/// [FitnessDashboardScreen]
class FitnessDashboardRoute extends PageRouteInfo<void> {
  const FitnessDashboardRoute({List<PageRouteInfo>? children})
      : super(
          FitnessDashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'FitnessDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FitnessDashboardScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ForgotPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [GoalFormScreen]
class GoalFormRoute extends PageRouteInfo<GoalFormRouteArgs> {
  GoalFormRoute({
    Key? key,
    GoalData? existingGoal,
    List<PageRouteInfo>? children,
  }) : super(
          GoalFormRoute.name,
          args: GoalFormRouteArgs(
            key: key,
            existingGoal: existingGoal,
          ),
          initialChildren: children,
        );

  static const String name = 'GoalFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GoalFormRouteArgs>(
          orElse: () => const GoalFormRouteArgs());
      return GoalFormScreen(
        key: args.key,
        existingGoal: args.existingGoal,
      );
    },
  );
}

class GoalFormRouteArgs {
  const GoalFormRouteArgs({
    this.key,
    this.existingGoal,
  });

  final Key? key;

  final GoalData? existingGoal;

  @override
  String toString() {
    return 'GoalFormRouteArgs{key: $key, existingGoal: $existingGoal}';
  }
}

/// generated route for
/// [GoalsScreen]
class GoalsRoute extends PageRouteInfo<void> {
  const GoalsRoute({List<PageRouteInfo>? children})
      : super(
          GoalsRoute.name,
          initialChildren: children,
        );

  static const String name = 'GoalsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const GoalsScreen();
    },
  );
}

/// generated route for
/// [HelpScreen]
class HelpRoute extends PageRouteInfo<void> {
  const HelpRoute({List<PageRouteInfo>? children})
      : super(
          HelpRoute.name,
          initialChildren: children,
        );

  static const String name = 'HelpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HelpScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [IntroScreen]
class IntroRoute extends PageRouteInfo<void> {
  const IntroRoute({List<PageRouteInfo>? children})
      : super(
          IntroRoute.name,
          initialChildren: children,
        );

  static const String name = 'IntroRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IntroScreen();
    },
  );
}

/// generated route for
/// [InviteUsersScreen]
class InviteUsersRoute extends PageRouteInfo<InviteUsersRouteArgs> {
  InviteUsersRoute({
    Key? key,
    String challengeId = 'temp-id',
    String challengeTitle = 'Novo Desafio',
    String? currentUserId,
    String? currentUserName,
    List<PageRouteInfo>? children,
  }) : super(
          InviteUsersRoute.name,
          args: InviteUsersRouteArgs(
            key: key,
            challengeId: challengeId,
            challengeTitle: challengeTitle,
            currentUserId: currentUserId,
            currentUserName: currentUserName,
          ),
          initialChildren: children,
        );

  static const String name = 'InviteUsersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InviteUsersRouteArgs>(
          orElse: () => const InviteUsersRouteArgs());
      return InviteUsersScreen(
        key: args.key,
        challengeId: args.challengeId,
        challengeTitle: args.challengeTitle,
        currentUserId: args.currentUserId,
        currentUserName: args.currentUserName,
      );
    },
  );
}

class InviteUsersRouteArgs {
  const InviteUsersRouteArgs({
    this.key,
    this.challengeId = 'temp-id',
    this.challengeTitle = 'Novo Desafio',
    this.currentUserId,
    this.currentUserName,
  });

  final Key? key;

  final String challengeId;

  final String challengeTitle;

  final String? currentUserId;

  final String? currentUserName;

  @override
  String toString() {
    return 'InviteUsersRouteArgs{key: $key, challengeId: $challengeId, challengeTitle: $challengeTitle, currentUserId: $currentUserId, currentUserName: $currentUserName}';
  }
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MealDetailScreen]
class MealDetailRoute extends PageRouteInfo<MealDetailRouteArgs> {
  MealDetailRoute({
    Key? key,
    required String mealId,
    List<PageRouteInfo>? children,
  }) : super(
          MealDetailRoute.name,
          args: MealDetailRouteArgs(
            key: key,
            mealId: mealId,
          ),
          rawPathParams: {'id': mealId},
          initialChildren: children,
        );

  static const String name = 'MealDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MealDetailRouteArgs>(
          orElse: () =>
              MealDetailRouteArgs(mealId: pathParams.getString('id')));
      return MealDetailScreen(
        key: args.key,
        mealId: args.mealId,
      );
    },
  );
}

class MealDetailRouteArgs {
  const MealDetailRouteArgs({
    this.key,
    required this.mealId,
  });

  final Key? key;

  final String mealId;

  @override
  String toString() {
    return 'MealDetailRouteArgs{key: $key, mealId: $mealId}';
  }
}

/// generated route for
/// [NotificationSettingsScreen]
class NotificationSettingsRoute extends PageRouteInfo<void> {
  const NotificationSettingsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationSettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationSettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationSettingsScreen();
    },
  );
}

/// generated route for
/// [NotificationSettingsScreenRefactored]
class NotificationSettingsRouteRefactored extends PageRouteInfo<void> {
  const NotificationSettingsRouteRefactored({List<PageRouteInfo>? children})
      : super(
          NotificationSettingsRouteRefactored.name,
          initialChildren: children,
        );

  static const String name = 'NotificationSettingsRouteRefactored';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotificationSettingsScreenRefactored();
    },
  );
}

/// generated route for
/// [NutritionScreen]
class NutritionRoute extends PageRouteInfo<void> {
  const NutritionRoute({List<PageRouteInfo>? children})
      : super(
          NutritionRoute.name,
          initialChildren: children,
        );

  static const String name = 'NutritionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NutritionScreen();
    },
  );
}

/// generated route for
/// [PartnerContentDetailScreen]
class PartnerContentDetailRoute
    extends PageRouteInfo<PartnerContentDetailRouteArgs> {
  PartnerContentDetailRoute({
    Key? key,
    required PartnerContent content,
    required String studioName,
    List<PageRouteInfo>? children,
  }) : super(
          PartnerContentDetailRoute.name,
          args: PartnerContentDetailRouteArgs(
            key: key,
            content: content,
            studioName: studioName,
          ),
          initialChildren: children,
        );

  static const String name = 'PartnerContentDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PartnerContentDetailRouteArgs>();
      return PartnerContentDetailScreen(
        key: args.key,
        content: args.content,
        studioName: args.studioName,
      );
    },
  );
}

class PartnerContentDetailRouteArgs {
  const PartnerContentDetailRouteArgs({
    this.key,
    required this.content,
    required this.studioName,
  });

  final Key? key;

  final PartnerContent content;

  final String studioName;

  @override
  String toString() {
    return 'PartnerContentDetailRouteArgs{key: $key, content: $content, studioName: $studioName}';
  }
}

/// generated route for
/// [PrivacyPolicyScreen]
class PrivacyPolicyRoute extends PageRouteInfo<void> {
  const PrivacyPolicyRoute({List<PageRouteInfo>? children})
      : super(
          PrivacyPolicyRoute.name,
          initialChildren: children,
        );

  static const String name = 'PrivacyPolicyRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PrivacyPolicyScreen();
    },
  );
}

/// generated route for
/// [ProfileEditScreen]
class ProfileEditRoute extends PageRouteInfo<void> {
  const ProfileEditRoute({List<PageRouteInfo>? children})
      : super(
          ProfileEditRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileEditRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileEditScreen();
    },
  );
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [ProgressDayScreen]
class ProgressDayRoute extends PageRouteInfo<ProgressDayRouteArgs> {
  ProgressDayRoute({
    required int day,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ProgressDayRoute.name,
          args: ProgressDayRouteArgs(
            day: day,
            key: key,
          ),
          rawPathParams: {'day': day},
          initialChildren: children,
        );

  static const String name = 'ProgressDayRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<ProgressDayRouteArgs>(
          orElse: () => ProgressDayRouteArgs(day: pathParams.getInt('day')));
      return ProgressDayScreen(
        day: args.day,
        key: args.key,
      );
    },
  );
}

class ProgressDayRouteArgs {
  const ProgressDayRouteArgs({
    required this.day,
    this.key,
  });

  final int day;

  final Key? key;

  @override
  String toString() {
    return 'ProgressDayRouteArgs{day: $day, key: $key}';
  }
}

/// generated route for
/// [ProgressPlanScreen]
class ProgressPlanRoute extends PageRouteInfo<void> {
  const ProgressPlanRoute({List<PageRouteInfo>? children})
      : super(
          ProgressPlanRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProgressPlanRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProgressPlanScreen();
    },
  );
}

/// generated route for
/// [RecipeDetailScreen]
class RecipeDetailRoute extends PageRouteInfo<RecipeDetailRouteArgs> {
  RecipeDetailRoute({
    Key? key,
    required String recipeId,
    List<PageRouteInfo>? children,
  }) : super(
          RecipeDetailRoute.name,
          args: RecipeDetailRouteArgs(
            key: key,
            recipeId: recipeId,
          ),
          rawPathParams: {'id': recipeId},
          initialChildren: children,
        );

  static const String name = 'RecipeDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RecipeDetailRouteArgs>(
          orElse: () =>
              RecipeDetailRouteArgs(recipeId: pathParams.getString('id')));
      return RecipeDetailScreen(
        key: args.key,
        recipeId: args.recipeId,
      );
    },
  );
}

class RecipeDetailRouteArgs {
  const RecipeDetailRouteArgs({
    this.key,
    required this.recipeId,
  });

  final Key? key;

  final String recipeId;

  @override
  String toString() {
    return 'RecipeDetailRouteArgs{key: $key, recipeId: $recipeId}';
  }
}

/// generated route for
/// [RedeemedBenefitDetailScreen]
class RedeemedBenefitDetailRoute extends PageRouteInfo<void> {
  const RedeemedBenefitDetailRoute({List<PageRouteInfo>? children})
      : super(
          RedeemedBenefitDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'RedeemedBenefitDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RedeemedBenefitDetailScreen();
    },
  );
}

/// generated route for
/// [RedeemedBenefitsScreen]
class RedeemedBenefitsRoute extends PageRouteInfo<void> {
  const RedeemedBenefitsRoute({List<PageRouteInfo>? children})
      : super(
          RedeemedBenefitsRoute.name,
          initialChildren: children,
        );

  static const String name = 'RedeemedBenefitsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RedeemedBenefitsScreen();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<void> {
  const ResetPasswordRoute({List<PageRouteInfo>? children})
      : super(
          ResetPasswordRoute.name,
          initialChildren: children,
        );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ResetPasswordScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [SignupScreen]
class SignupRoute extends PageRouteInfo<void> {
  const SignupRoute({List<PageRouteInfo>? children})
      : super(
          SignupRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignupRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignupScreen();
    },
  );
}

/// generated route for
/// [TermsOfUseScreen]
class TermsOfUseRoute extends PageRouteInfo<void> {
  const TermsOfUseRoute({List<PageRouteInfo>? children})
      : super(
          TermsOfUseRoute.name,
          initialChildren: children,
        );

  static const String name = 'TermsOfUseRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TermsOfUseScreen();
    },
  );
}

/// generated route for
/// [UserChallengeWorkoutsScreen]
class UserChallengeWorkoutsRoute
    extends PageRouteInfo<UserChallengeWorkoutsRouteArgs> {
  UserChallengeWorkoutsRoute({
    required String challengeId,
    String userId = '',
    String userName = 'Usuário',
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          UserChallengeWorkoutsRoute.name,
          args: UserChallengeWorkoutsRouteArgs(
            challengeId: challengeId,
            userId: userId,
            userName: userName,
            key: key,
          ),
          rawPathParams: {'challengeId': challengeId},
          rawQueryParams: {
            'userId': userId,
            'userName': userName,
          },
          initialChildren: children,
        );

  static const String name = 'UserChallengeWorkoutsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final queryParams = data.queryParams;
      final args = data.argsAs<UserChallengeWorkoutsRouteArgs>(
          orElse: () => UserChallengeWorkoutsRouteArgs(
                challengeId: pathParams.getString('challengeId'),
                userId: queryParams.getString(
                  'userId',
                  '',
                ),
                userName: queryParams.getString(
                  'userName',
                  'Usuário',
                ),
              ));
      return UserChallengeWorkoutsScreen(
        challengeId: args.challengeId,
        userId: args.userId,
        userName: args.userName,
        key: args.key,
      );
    },
  );
}

class UserChallengeWorkoutsRouteArgs {
  const UserChallengeWorkoutsRouteArgs({
    required this.challengeId,
    this.userId = '',
    this.userName = 'Usuário',
    this.key,
  });

  final String challengeId;

  final String userId;

  final String userName;

  final Key? key;

  @override
  String toString() {
    return 'UserChallengeWorkoutsRouteArgs{challengeId: $challengeId, userId: $userId, userName: $userName, key: $key}';
  }
}

/// generated route for
/// [UserSelectionScreen]
class UserSelectionRoute extends PageRouteInfo<void> {
  const UserSelectionRoute({List<PageRouteInfo>? children})
      : super(
          UserSelectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserSelectionScreen();
    },
  );
}

/// generated route for
/// [UserWorkoutsManagementScreen]
class UserWorkoutsManagementRoute extends PageRouteInfo<void> {
  const UserWorkoutsManagementRoute({List<PageRouteInfo>? children})
      : super(
          UserWorkoutsManagementRoute.name,
          initialChildren: children,
        );

  static const String name = 'UserWorkoutsManagementRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const UserWorkoutsManagementScreen();
    },
  );
}

/// generated route for
/// [VerificarAcessoExpertScreen]
class VerificarAcessoExpertRoute extends PageRouteInfo<void> {
  const VerificarAcessoExpertRoute({List<PageRouteInfo>? children})
      : super(
          VerificarAcessoExpertRoute.name,
          initialChildren: children,
        );

  static const String name = 'VerificarAcessoExpertRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VerificarAcessoExpertScreen();
    },
  );
}

/// generated route for
/// [WaterIntakeScreen]
class WaterIntakeRoute extends PageRouteInfo<void> {
  const WaterIntakeRoute({List<PageRouteInfo>? children})
      : super(
          WaterIntakeRoute.name,
          initialChildren: children,
        );

  static const String name = 'WaterIntakeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WaterIntakeScreen();
    },
  );
}

/// generated route for
/// [WorkoutCategoriesScreen]
class WorkoutCategoriesRoute extends PageRouteInfo<void> {
  const WorkoutCategoriesRoute({List<PageRouteInfo>? children})
      : super(
          WorkoutCategoriesRoute.name,
          initialChildren: children,
        );

  static const String name = 'WorkoutCategoriesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkoutCategoriesScreen();
    },
  );
}

/// generated route for
/// [WorkoutDetailScreen]
class WorkoutDetailRoute extends PageRouteInfo<WorkoutDetailRouteArgs> {
  WorkoutDetailRoute({
    Key? key,
    required String workoutId,
    List<PageRouteInfo>? children,
  }) : super(
          WorkoutDetailRoute.name,
          args: WorkoutDetailRouteArgs(
            key: key,
            workoutId: workoutId,
          ),
          rawPathParams: {'id': workoutId},
          initialChildren: children,
        );

  static const String name = 'WorkoutDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WorkoutDetailRouteArgs>(
          orElse: () =>
              WorkoutDetailRouteArgs(workoutId: pathParams.getString('id')));
      return WorkoutDetailScreen(
        key: args.key,
        workoutId: args.workoutId,
      );
    },
  );
}

class WorkoutDetailRouteArgs {
  const WorkoutDetailRouteArgs({
    this.key,
    required this.workoutId,
  });

  final Key? key;

  final String workoutId;

  @override
  String toString() {
    return 'WorkoutDetailRouteArgs{key: $key, workoutId: $workoutId}';
  }
}

/// generated route for
/// [WorkoutHistoryScreen]
class WorkoutHistoryRoute extends PageRouteInfo<void> {
  const WorkoutHistoryRoute({List<PageRouteInfo>? children})
      : super(
          WorkoutHistoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'WorkoutHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkoutHistoryScreen();
    },
  );
}

/// generated route for
/// [WorkoutListScreen]
class WorkoutListRoute extends PageRouteInfo<void> {
  const WorkoutListRoute({List<PageRouteInfo>? children})
      : super(
          WorkoutListRoute.name,
          initialChildren: children,
        );

  static const String name = 'WorkoutListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkoutListScreen();
    },
  );
}

/// generated route for
/// [WorkoutRecordDetailScreen]
class WorkoutRecordDetailRoute
    extends PageRouteInfo<WorkoutRecordDetailRouteArgs> {
  WorkoutRecordDetailRoute({
    Key? key,
    required String recordId,
    WorkoutRecord? workoutRecord,
    List<PageRouteInfo>? children,
  }) : super(
          WorkoutRecordDetailRoute.name,
          args: WorkoutRecordDetailRouteArgs(
            key: key,
            recordId: recordId,
            workoutRecord: workoutRecord,
          ),
          initialChildren: children,
        );

  static const String name = 'WorkoutRecordDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WorkoutRecordDetailRouteArgs>();
      return WorkoutRecordDetailScreen(
        key: args.key,
        recordId: args.recordId,
        workoutRecord: args.workoutRecord,
      );
    },
  );
}

class WorkoutRecordDetailRouteArgs {
  const WorkoutRecordDetailRouteArgs({
    this.key,
    required this.recordId,
    this.workoutRecord,
  });

  final Key? key;

  final String recordId;

  final WorkoutRecord? workoutRecord;

  @override
  String toString() {
    return 'WorkoutRecordDetailRouteArgs{key: $key, recordId: $recordId, workoutRecord: $workoutRecord}';
  }
}

/// generated route for
/// [WorkoutRecordFormScreen]
class WorkoutRecordFormRoute extends PageRouteInfo<void> {
  const WorkoutRecordFormRoute({List<PageRouteInfo>? children})
      : super(
          WorkoutRecordFormRoute.name,
          initialChildren: children,
        );

  static const String name = 'WorkoutRecordFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WorkoutRecordFormScreen();
    },
  );
}

/// generated route for
/// [WorkoutVideoPlayerScreen]
class WorkoutVideoPlayerRoute
    extends PageRouteInfo<WorkoutVideoPlayerRouteArgs> {
  WorkoutVideoPlayerRoute({
    Key? key,
    required String videoId,
    WorkoutVideo? video,
    List<PageRouteInfo>? children,
  }) : super(
          WorkoutVideoPlayerRoute.name,
          args: WorkoutVideoPlayerRouteArgs(
            key: key,
            videoId: videoId,
            video: video,
          ),
          rawPathParams: {'videoId': videoId},
          initialChildren: children,
        );

  static const String name = 'WorkoutVideoPlayerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<WorkoutVideoPlayerRouteArgs>(
          orElse: () => WorkoutVideoPlayerRouteArgs(
              videoId: pathParams.getString('videoId')));
      return WorkoutVideoPlayerScreen(
        key: args.key,
        videoId: args.videoId,
        video: args.video,
      );
    },
  );
}

class WorkoutVideoPlayerRouteArgs {
  const WorkoutVideoPlayerRouteArgs({
    this.key,
    required this.videoId,
    this.video,
  });

  final Key? key;

  final String videoId;

  final WorkoutVideo? video;

  @override
  String toString() {
    return 'WorkoutVideoPlayerRouteArgs{key: $key, videoId: $videoId, video: $video}';
  }
}

/// generated route for
/// [WorkoutVideosScreen]
class WorkoutVideosRoute extends PageRouteInfo<WorkoutVideosRouteArgs> {
  WorkoutVideosRoute({
    Key? key,
    required String categoryId,
    String? categoryName,
    List<PageRouteInfo>? children,
  }) : super(
          WorkoutVideosRoute.name,
          args: WorkoutVideosRouteArgs(
            key: key,
            categoryId: categoryId,
            categoryName: categoryName,
          ),
          initialChildren: children,
        );

  static const String name = 'WorkoutVideosRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WorkoutVideosRouteArgs>();
      return WorkoutVideosScreen(
        key: args.key,
        categoryId: args.categoryId,
        categoryName: args.categoryName,
      );
    },
  );
}

class WorkoutVideosRouteArgs {
  const WorkoutVideosRouteArgs({
    this.key,
    required this.categoryId,
    this.categoryName,
  });

  final Key? key;

  final String categoryId;

  final String? categoryName;

  @override
  String toString() {
    return 'WorkoutVideosRouteArgs{key: $key, categoryId: $categoryId, categoryName: $categoryName}';
  }
}
