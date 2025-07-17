// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/localization/app_strings.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/accessible_widget.dart';
import 'package:ray_club_app/core/widgets/app_error_widget.dart';
import 'package:ray_club_app/core/widgets/app_loading.dart';
import 'package:ray_club_app/features/settings/viewmodels/settings_view_model.dart';
import 'package:ray_club_app/features/settings/models/settings_state.dart';

/// Tela de configurações gerais do aplicativo
@RoutePage()
class SettingsScreen extends ConsumerWidget {
  /// Construtor padrão
  const SettingsScreen({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: settingsState.isLoading
          ? const AppLoading()
          : settingsState.errorMessage != null
              ? AppErrorWidget(
                  message: settingsState.errorMessage!,
                  onRetry: () => ref.read(settingsViewModelProvider.notifier).loadSettings(),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGeneralSection(context, ref, settingsState),
                        const SizedBox(height: 24),
                        _buildAccountSection(context),
                        const SizedBox(height: 24),
                        _buildNotificationsSection(context),
                        const SizedBox(height: 24),
                        _buildPrivacySection(context),
                        
                        // Seção de desenvolvedor, visível apenas para administradores
                        if (settingsState.isAdmin) ...[
                          const SizedBox(height: 24),
                          _buildDeveloperSection(context),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
  
  Widget _buildGeneralSection(BuildContext context, WidgetRef ref, SettingsState state) {
    return _buildSection(
      title: 'Geral',
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_outlined,
          title: 'Modo escuro',
          subtitle: 'Mudar entre tema claro e escuro',
          value: state.isDarkMode,
          onChanged: (value) {
            ref.read(settingsViewModelProvider.notifier).toggleDarkMode();
          },
        ),
        _buildLanguageTile(context, ref, state),
      ],
    );
  }
  
  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      title: 'Conta',
      children: [
        _buildListTile(
          icon: Icons.person,
          title: 'Editar Perfil',
          subtitle: 'Atualizar suas informações pessoais',
          onTap: () => context.router.pushNamed('/profile/edit'),
        ),
        const Divider(),
        _buildListTile(
          icon: Icons.lock_outline,
          title: 'Alterar senha',
          subtitle: 'Atualizar senha da conta',
          onTap: () {
            // Implementar quando a tela estiver disponível
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppStrings.comingSoon)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return _buildSection(
      title: 'Notificações',
      children: [
        _buildListTile(
          icon: Icons.notifications_outlined,
          title: 'Configurações de Notificações',
          subtitle: 'Gerencie as notificações do aplicativo',
          onTap: () => context.router.pushNamed('/notification-settings'),
        ),
      ],
    );
  }
  
  Widget _buildPrivacySection(BuildContext context) {
    return _buildSection(
      title: 'Privacidade e Segurança',
      children: [
        _buildListTile(
          icon: Icons.security_outlined,
          title: 'Política de Privacidade',
          subtitle: 'Como seus dados são utilizados',
          onTap: () => context.router.pushNamed('/privacy-policy'),
        ),
        _buildListTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Gerenciar Consentimentos',
          subtitle: 'Controle suas preferências de privacidade',
          onTap: () => context.router.pushNamed('/consent-management'),
        ),
        _buildListTile(
          icon: Icons.description_outlined,
          title: 'Termos de Uso',
          subtitle: 'Termos e condições de uso do aplicativo',
          onTap: () => context.router.pushNamed('/terms'),
        ),
      ],
    );
  }
  
  Widget _buildLanguageTile(BuildContext context, WidgetRef ref, SettingsState state) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.language_outlined,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: const Text('Idioma'),
      subtitle: Text(state.selectedLanguage),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Selecione o idioma'),
            children: [
              _buildLanguageOption(context, ref, 'Português', state),
              _buildLanguageOption(context, ref, 'English', state),
              _buildLanguageOption(context, ref, 'Español', state),
            ],
          ),
        );
      },
    ).withAccessibility(
      label: 'Configuração de idioma',
      hint: 'Toque para alterar o idioma do aplicativo',
    );
  }
  
  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String language, SettingsState state) {
    final isSelected = state.selectedLanguage == language;
    
    return SimpleDialogOption(
      onPressed: () {
        ref.read(settingsViewModelProvider.notifier).setLanguage(language);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            isSelected
                ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor)
                : const Icon(Icons.radio_button_unchecked),
            const SizedBox(width: 16),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ).withAccessibility(
          label: 'Título da seção $title',
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF4285F4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4285F4),
          size: 24,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ).withAccessibility(
      label: title,
      hint: subtitle,
    );
  }
  
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF4285F4).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4285F4),
          size: 24,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    ).withAccessibility(
      label: title,
      hint: subtitle,
    );
  }
  
  /// Cria a seção de ferramentas de desenvolvedor (apenas visível para administradores)
  Widget _buildDeveloperSection(BuildContext context) {
    return _buildSection(
      title: 'Ferramentas de Desenvolvedor',
      children: [
        _buildListTile(
          icon: Icons.storage,
          title: 'Diagnóstico do Banco de Dados',
          subtitle: 'Verificar a integridade das tabelas do Supabase',
          onTap: () => context.router.pushNamed('/db-validator'),
        ),
        _buildListTile(
          icon: Icons.security,
          title: 'Verificar Acesso Expert',
          subtitle: 'Testar se usuário expert tem acesso completo',
                            onTap: () => context.router.pushNamed('/dev/verificar-acesso-expert'),
                ),
                
                // Diagnóstico completo de perfil
                ListTile(
                  leading: const Icon(Icons.psychology, color: Colors.blue),
                  title: const Text('🔍 Diagnóstico Profile Expert/Basic'),
                  subtitle: const Text('Diagnóstico completo dos providers'),
                  onTap: () => context.router.pushNamed('/dev/profile-diagnose'),
                ),
        _buildListTile(
          icon: Icons.integration_instructions,
          title: 'API Explorer',
          subtitle: 'Testar chamadas de API',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Função em desenvolvimento')),
            );
          },
        ),
        _buildListTile(
          icon: Icons.bug_report_outlined,
          title: 'Logs de Depuração',
          subtitle: 'Visualizar logs do aplicativo',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Função em desenvolvimento')),
            );
          },
        ),
      ],
    );
  }
} 