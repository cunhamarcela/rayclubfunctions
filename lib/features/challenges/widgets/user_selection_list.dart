// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../features/profile/models/profile_model.dart';
import '../../../features/profile/repositories/profile_repository.dart';
import '../../../features/profile/viewmodels/profile_view_model.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';

@RoutePage()
class UserSelectionScreen extends ConsumerStatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  ConsumerState<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends ConsumerState<UserSelectionScreen> {
  List<Profile>? _users;
  bool _isLoading = true;
  String? _errorMessage;
  
  final Set<String> _selectedUsers = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    // Carregar a lista de usuários
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final profileRepository = ref.read(profileRepositoryProvider);
      final users = await profileRepository.getAllProfiles();
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Profile> get _filteredUsers {
    if (_users == null) return [];
    
    if (_searchQuery.isEmpty) {
      return _users!;
    }
    
    return _users!.where((user) => 
      user.name?.toLowerCase().contains(_searchQuery) == true ||
      user.email?.toLowerCase().contains(_searchQuery) == true
    ).toList();
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUsers.contains(userId)) {
        _selectedUsers.remove(userId);
      } else {
        _selectedUsers.add(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convidar Usuários'),
        actions: [
          TextButton(
            onPressed: _selectedUsers.isEmpty 
                ? null 
                : () {
                    Navigator.of(context).pop(_selectedUsers.toList());
                  },
            child: Text(
              'CONFIRMAR (${_selectedUsers.length})',
              style: TextStyle(
                color: _selectedUsers.isEmpty ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar usuários',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, 
                  horizontal: 16,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserList() {
    // Mostrar loading durante o carregamento inicial
    if (_isLoading) {
      return const LoadingView();
    }
    
    // Mostrar erro se houver
    if (_errorMessage != null) {
      return ErrorView(
        message: 'Erro ao carregar usuários: $_errorMessage',
        onRetry: _loadUsers,
      );
    }
    
    // Mostrar mensagem se não houver usuários com o filtro atual
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum usuário encontrado',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Mostrar lista de usuários
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isSelected = _selectedUsers.contains(user.id);
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: user.photoUrl != null
                ? Image.network(user.photoUrl!)
                : Text(
                    user.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          title: Text(user.name ?? 'Usuário'),
          subtitle: user.email != null ? Text(user.email!) : null,
          trailing: Checkbox(
            value: isSelected,
            activeColor: AppColors.primary,
            onChanged: (_) => _toggleUserSelection(user.id),
          ),
          onTap: () => _toggleUserSelection(user.id),
        );
      },
    );
  }
} 