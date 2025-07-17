// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/exceptions/error_handler.dart';
import 'package:ray_club_app/core/widgets/accessible_widget.dart';
import 'package:ray_club_app/core/widgets/error_widget.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/profile/models/notification_type.dart';
import 'package:ray_club_app/features/profile/viewmodels/notification_settings_view_model.dart';

/// Tela para configuração de notificações refatorada para usar MVVM
@RoutePage()
class NotificationSettingsScreenRefactored extends HookConsumerWidget {
  /// Construtor padrão
  const NotificationSettingsScreenRefactored({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/notification-settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o estado do ViewModel
    final state = ref.watch(notificationSettingsViewModelProvider);
    final viewModel = ref.read(notificationSettingsViewModelProvider.notifier);
    
    // Hook para mostrar snackbar quando as alterações forem salvas
    useEffect(() {
      if (state.changesSaved) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configurações salvas com sucesso!')),
          );
        });
      }
      return null;
    }, [state.changesSaved]);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Notificações').withAccessibility(
          label: 'Tela de configuração de notificações',
        ),
        centerTitle: true,
      ),
      body: _buildBody(context, ref, state, viewModel),
    );
  }
  
  Widget _buildBody(
    BuildContext context, 
    WidgetRef ref, 
    state, 
    NotificationSettingsViewModel viewModel
  ) {
    // Mostrar indicador de carregamento
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Mostrar mensagem de erro se houver
    if (state.errorMessage != null) {
      return Center(
        child: AppErrorWidget(
          error: AppError(message: state.errorMessage!),
          onRetry: viewModel.loadSettings,
        ),
      );
    }
    
    // Conteúdo principal
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interruptor mestre para todas as notificações
          _buildMasterSwitch(context, state, viewModel),
          
          const Divider(height: 32),
          
          // Lista de configurações de notificação
          if (state.masterSwitchEnabled) ...[
            const Text(
              'Configurações de Notificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            
            // Configurações para cada tipo de notificação
            ...NotificationType.values.map(
              (type) => _buildNotificationSetting(context, type, state, viewModel),
            ),
            
            const SizedBox(height: 24),
            
            // Configuração de horário de lembretes diários
            _buildReminderTimeSelector(context, state, viewModel),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMasterSwitch(
    BuildContext context, 
    state, 
    NotificationSettingsViewModel viewModel
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_active,
              size: 28,
              color: AppColors.orange,
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ativar Notificações',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Controla todas as notificações do app',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: state.masterSwitchEnabled,
              onChanged: viewModel.updateMasterSwitch,
              activeColor: AppColors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNotificationSetting(
    BuildContext context, 
    NotificationType type, 
    state, 
    NotificationSettingsViewModel viewModel
  ) {
    final isEnabled = state.notificationSettings[type] ?? true;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(
          type.icon,
          color: AppColors.purple.withOpacity(isEnabled ? 1.0 : 0.5),
        ),
        title: Text(
          type.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isEnabled ? AppColors.darkGray : AppColors.darkGray.withOpacity(0.6),
          ),
        ),
        subtitle: Text(
          type.description,
          style: TextStyle(
            fontSize: 12,
            color: isEnabled ? AppColors.darkGray.withOpacity(0.7) : AppColors.darkGray.withOpacity(0.4),
          ),
        ),
        trailing: Switch(
          value: isEnabled,
          onChanged: (value) => viewModel.updateNotificationSetting(type, value),
          activeColor: AppColors.orange,
        ),
      ),
    );
  }
  
  Widget _buildReminderTimeSelector(
    BuildContext context, 
    state, 
    NotificationSettingsViewModel viewModel
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horário de Lembretes Diários',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha o melhor horário para receber lembretes diários',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: state.reminderTime,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor: Colors.white,
                          hourMinuteTextColor: AppColors.orange,
                          dialHandColor: AppColors.orange,
                          dialBackgroundColor: AppColors.orange.withOpacity(0.1),
                        ),
                        colorScheme: ColorScheme.light(
                          primary: AppColors.orange,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: AppColors.darkGray,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                
                if (pickedTime != null) {
                  viewModel.updateReminderTime(pickedTime);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.reminderTime.hour.toString().padLeft(2, '0')}:${state.reminderTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.access_time,
                      color: AppColors.purple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 