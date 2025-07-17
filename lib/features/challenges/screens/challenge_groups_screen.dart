import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:ray_club_app/core/extensions/context_extensions.dart';
import 'package:ray_club_app/core/services/auth_service.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/core/widgets/app_loading.dart';
import 'package:ray_club_app/core/widgets/ray_button.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';
import 'package:ray_club_app/features/challenges/widgets/create_join_group_modal.dart';

@RoutePage()
class ChallengeGroupsScreen extends ConsumerStatefulWidget {
  const ChallengeGroupsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChallengeGroupsScreen> createState() => _ChallengeGroupsScreenState();
}

class _ChallengeGroupsScreenState extends ConsumerState<ChallengeGroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGroups();
    });
  }

  Future<void> _loadGroups() async {
    await ref.read(challengeGroupViewModelProvider.notifier).loadUserGroups();
  }

  void _navigateToGroupDetails(String groupId) {
    context.router.push(ChallengeGroupDetailRoute(groupId: groupId));
  }

  void _navigateToCreateGroup() {
    context.router.push(const CreateChallengeGroupRoute());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeGroupViewModelProvider);
    final currentUserId = ref.watch(authServiceProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBarWidget(
        title: 'Meus Grupos',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateGroup,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroups,
        child: state.isLoading
            ? const Center(child: AppLoading())
            : state.groups.isEmpty
                ? _buildEmptyState()
                : _buildGroupsList(state.groups),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Você ainda não participa de nenhum grupo',
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          RayButton(
            label: 'Criar Grupo',
            onPressed: _navigateToCreateGroup,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(List<ChallengeGroup> groups) {
    return ListView.builder(
      itemCount: groups.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              group.name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: group.description.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(group.description),
                  )
                : null,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToGroupDetails(group.id),
          ),
        );
      },
    );
  }
} 