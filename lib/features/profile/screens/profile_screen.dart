// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/widgets/accessible_widget.dart';

// Project imports:
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/bottom_navigation_bar.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/core/constants/privacy_policy.dart';
import 'package:ray_club_app/features/profile/screens/privacy_policy_screen.dart';
import 'package:ray_club_app/features/profile/screens/consent_management_screen.dart';
import 'package:ray_club_app/core/viewmodels/base_view_model.dart';
import '../../../core/widgets/user_avatar.dart';

@RoutePage()
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileViewModelProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: profileState is BaseStateLoading<Profile>
          ? const Center(child: CircularProgressIndicator())
          : profileState is BaseStateError<Profile>
              ? Center(child: Text('Erro: ${(profileState as BaseStateError<Profile>).message}'))
              : profileState is BaseStateData<Profile>
                  ? _buildProfileContent(context, (profileState as BaseStateData<Profile>).data)
                  : const Center(child: Text('Perfil não encontrado')),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildProfileContent(BuildContext context, Profile profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header com foto e informações básicas
          _buildProfileHeader(context, profile),
          
          // Configurações e Privacidade
          _buildSettingsSection(context),
          
          // Botão Logout
          _buildLogoutButton(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Profile profile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/logos/app/padronagem_3.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
          child: Column(
            children: [
              const SizedBox(height: 5),
              UserAvatar(
                photoUrl: profile.photoUrl,
                name: profile.name,
                size: 110,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              const SizedBox(height: 16),
              // Nome
              Text(
                profile.name ?? 'Usuário',
                style: const TextStyle(
                  fontFamily: 'Century',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                profile.email ?? '',
                style: const TextStyle(
                  fontFamily: 'Century',
                  fontSize: 16,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 20),
              // Botão editar perfil
              ElevatedButton(
                onPressed: () {
                  // Navegação para edição de perfil
                  context.router.pushNamed('/profile/edit');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    fontFamily: 'Century',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).withAccessibility(
                label: 'Botão para editar perfil',
                isButton: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações e Privacidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Política de Privacidade
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.purple),
            title: const Text('Política de Privacidade'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              context.router.pushNamed('/privacy-policy');
            },
          ).withAccessibility(
            label: 'Link para Política de Privacidade',
            hint: 'Toque para ver a política de privacidade completa',
            isButton: true,
          ),
          
          const Divider(),
          
          // Gerenciamento de Consentimentos GDPR/LGPD
          ListTile(
            leading: const Icon(Icons.security_outlined, color: AppColors.purple),
            title: const Text('Gerenciar Consentimentos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              context.router.pushNamed('/consent-management');
            },
          ).withAccessibility(
            label: 'Link para Gerenciamento de Consentimentos',
            hint: 'Toque para gerenciar suas permissões e consentimentos de privacidade',
            isButton: true,
          ),
          
          const Divider(),
          
          // Termos de Uso
          ListTile(
            leading: const Icon(Icons.description_outlined, color: AppColors.purple),
            title: const Text('Termos de Uso'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              context.router.pushNamed('/terms');
            },
          ).withAccessibility(
            label: 'Link para Termos de Uso',
            hint: 'Toque para ver os termos de uso completos',
            isButton: true,
          ),
          
          const Divider(),
          
          // Notificações
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: AppColors.purple),
            title: const Text('Configurar Notificações'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              context.router.pushNamed('/notification-settings');
            },
          ).withAccessibility(
            label: 'Link para Configurações de Notificações',
            hint: 'Toque para gerenciar suas preferências de notificações',
            isButton: true,
          ),
          
          const Divider(),
          
          // Excluir conta
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Excluir Conta',
              style: TextStyle(
                fontFamily: 'Century',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            contentPadding: EdgeInsets.zero,
            onTap: () => _showDeleteAccountDialog(context),
          ).withAccessibility(
            label: 'Botão para excluir a conta',
            hint: 'Toque para iniciar o processo de exclusão da sua conta',
            isButton: true,
          ),
          
          const Divider(),
          
          // Validação do Banco de Dados (apenas para desenvolvimento)
          ListTile(
            leading: const Icon(Icons.data_usage, color: AppColors.purple),
            title: const Text('Validar Banco de Dados'),
            subtitle: const Text('Verificar a estrutura das tabelas do Supabase'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              context.router.pushNamed('/db-validator');
            },
          ).withAccessibility(
            label: 'Link para Validação de Banco de Dados',
            hint: 'Toque para verificar a estrutura do banco de dados',
            isButton: true,
          ),
        ],
      ),
    );
  }

  // Mostrar diálogo de confirmação para excluir a conta
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Excluir Conta',
          style: TextStyle(
            fontFamily: 'StingerTrial',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Esta ação é irreversível. Todos os seus dados serão excluídos permanentemente.\n\nDeseja realmente excluir sua conta?',
          style: TextStyle(fontFamily: 'StingerFitTrial'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'StingerFitTrial',
                color: Color(0xFF29B6F6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _deleteAccount(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Excluir',
              style: TextStyle(
                fontFamily: 'StingerTrial',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para excluir a conta
  Future<void> _deleteAccount(BuildContext context) async {
    // Fechar o diálogo de confirmação
    Navigator.of(context).pop();
    
    // Mostrar indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Excluindo conta...',
              style: TextStyle(fontFamily: 'Century'),
            ),
          ],
        ),
      ),
    );
    
    try {
      // Chamar o método de exclusão no ViewModel
      await ref.read(profileViewModelProvider.notifier).deleteAccount();
      
      // Fechar o diálogo de carregamento
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar mensagem de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Navegar para a tela de login
      if (mounted) {
        context.router.replaceNamed('/login');
      }
    } catch (e) {
      // Fechar o diálogo de carregamento
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar mensagem de erro
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: OutlinedButton(
        onPressed: () {
          _showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.orangeDark,
          side: const BorderSide(color: AppColors.orangeDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Sair da Conta',
          style: TextStyle(
            fontFamily: 'Century',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).withAccessibility(
        label: 'Botão para sair da conta',
        isButton: true,
      ),
    );
  }

  // Diálogo de confirmação para o logout
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Sair da Conta?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Century',
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          content: const Text(
            'Você tem certeza que deseja desconectar da sua conta?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Century',
              color: AppColors.darkGray,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.darkGray,
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica de logout
                      ref.read(authViewModelProvider.notifier).signOut();
                      Navigator.of(context).pop();
                      context.router.replaceNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangeDark,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sair'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileMenuItem({
    required BuildContext context,
    required IconData iconData,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(iconData, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF29B6F6),
      ),
    ).withAccessibility(
      label: 'Link para $label',
      hint: 'Toque para $label',
      isButton: true,
    );
  }
} 
