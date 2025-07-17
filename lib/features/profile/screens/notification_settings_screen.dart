// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/accessible_widget.dart';
import 'package:ray_club_app/features/profile/models/notification_type.dart';

/// Tela para configuração de notificações
@RoutePage()
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  /// Construtor padrão
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/notification-settings';

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final Map<NotificationType, bool> _notificationSettings = {};
  bool _masterSwitch = true;
  bool _isLoading = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  
  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }
  
  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar configuração mestra
    _masterSwitch = prefs.getBool('notifications_enabled') ?? true;
    
    // Carregar configurações individuais
    for (final type in NotificationType.values) {
      _notificationSettings[type] = prefs.getBool(type.prefsKey) ?? true;
    }
    
    // Carregar horário do lembrete
    final reminderHour = prefs.getInt('notification_reminder_hour') ?? 18;
    final reminderMinute = prefs.getInt('notification_reminder_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _updateMasterSwitch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    
    setState(() {
      _masterSwitch = value;
    });
  }
  
  Future<void> _updateNotificationSetting(NotificationType type, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(type.prefsKey, value);
    
    setState(() {
      _notificationSettings[type] = value;
    });
  }
  
  Future<void> _updateReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Theme.of(context).primaryColor,
              dialHandColor: Theme.of(context).primaryColor,
              dialBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_reminder_hour', pickedTime.hour);
      await prefs.setInt('notification_reminder_minute', pickedTime.minute);
      
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }
  
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    String period = timeOfDay.hour >= 12 ? 'PM' : 'AM';
    int hour = timeOfDay.hour > 12 ? timeOfDay.hour - 12 : timeOfDay.hour;
    hour = hour == 0 ? 12 : hour;
    String minute = timeOfDay.minute < 10 ? '0${timeOfDay.minute}' : '${timeOfDay.minute}';
    return '$hour:$minute $period';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Notificações').withAccessibility(
          label: 'Tela de configuração de notificações',
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interruptor mestre
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.notifications,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ativar Notificações',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Controla todas as notificações do aplicativo',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _masterSwitch,
                              onChanged: _updateMasterSwitch,
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ).withAccessibility(
                      label: 'Interruptor mestre de notificações',
                      hint: 'Ative ou desative todas as notificações',
                    ),
                    
                    // Horário do lembrete
                    if (_masterSwitch)
                      Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Horário do Lembrete Diário',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).withAccessibility(
                                label: 'Título da seção de horário do lembrete',
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _updateReminderTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _formatTimeOfDay(_reminderTime),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Alterar',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).withAccessibility(
                                label: 'Botão para alterar horário do lembrete',
                                hint: 'Toque para alterar o horário do lembrete diário',
                                isButton: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Tipos de notificações
                    if (_masterSwitch)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tipos de Notificações',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).withAccessibility(
                                label: 'Título da seção de tipos de notificações',
                              ),
                              const SizedBox(height: 16),
                              
                              ...NotificationType.values.map((type) => _buildNotificationItem(type)).toList(),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildNotificationItem(NotificationType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              type.icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  type.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationSettings[type] ?? true,
            onChanged: (value) => _updateNotificationSetting(type, value),
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    ).withAccessibility(
      label: 'Configuração de ${type.title}',
      hint: type.description,
    );
  }
} 