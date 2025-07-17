// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/accessible_widget.dart';

/// Tela para gerenciar consentimentos de acordo com GDPR/LGPD
@RoutePage()
class ConsentManagementScreen extends ConsumerStatefulWidget {
  /// Construtor padrão
  const ConsentManagementScreen({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/consent-management';

  @override
  ConsumerState<ConsentManagementScreen> createState() => _ConsentManagementScreenState();
}

/// Tipos de consentimento disponíveis
enum ConsentType {
  /// Consentimento para processamento de dados pessoais
  personalData,
  
  /// Consentimento para envio de emails de marketing
  marketing,
  
  /// Consentimento para análise de uso
  analytics,
  
  /// Consentimento para compartilhamento com terceiros
  thirdParty,
  
  /// Consentimento para coleta de localização
  location
}

/// Extensão para obter a chave de preferências para cada tipo de consentimento
extension ConsentTypeExtension on ConsentType {
  /// Chave para armazenar no SharedPreferences
  String get prefsKey {
    return 'consent_${toString().split('.').last}';
  }
  
  /// Título para exibição
  String get title {
    switch (this) {
      case ConsentType.personalData:
        return 'Processamento de dados pessoais';
      case ConsentType.marketing:
        return 'Comunicações de marketing';
      case ConsentType.analytics:
        return 'Análise de uso';
      case ConsentType.thirdParty:
        return 'Compartilhamento com parceiros';
      case ConsentType.location:
        return 'Coleta de localização';
    }
  }
  
  /// Descrição detalhada do consentimento
  String get description {
    switch (this) {
      case ConsentType.personalData:
        return 'Permitir o processamento dos seus dados pessoais para fornecer os serviços do aplicativo, como perfil, treinos e nutrição.';
      case ConsentType.marketing:
        return 'Receber emails e notificações sobre novidades, promoções e ofertas especiais.';
      case ConsentType.analytics:
        return 'Permitir a coleta de dados anônimos sobre como você usa o aplicativo para melhorarmos nossos serviços.';
      case ConsentType.thirdParty:
        return 'Compartilhar dados com parceiros que oferecem benefícios e descontos através do aplicativo.';
      case ConsentType.location:
        return 'Permitir acesso à sua localização para encontrar parceiros e benefícios próximos a você.';
    }
  }
  
  /// Ícone representativo
  IconData get icon {
    switch (this) {
      case ConsentType.personalData:
        return Icons.account_circle_outlined;
      case ConsentType.marketing:
        return Icons.email_outlined;
      case ConsentType.analytics:
        return Icons.analytics_outlined;
      case ConsentType.thirdParty:
        return Icons.handshake_outlined;
      case ConsentType.location:
        return Icons.location_on_outlined;
    }
  }
}

class _ConsentManagementScreenState extends ConsumerState<ConsentManagementScreen> {
  final Map<ConsentType, bool> _consents = {};
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadConsents();
  }
  
  Future<void> _loadConsents() async {
    setState(() {
      _isLoading = true;
    });
    
    final prefs = await SharedPreferences.getInstance();
    
    for (final type in ConsentType.values) {
      _consents[type] = prefs.getBool(type.prefsKey) ?? false;
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _updateConsent(ConsentType type, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(type.prefsKey, value);
    
    setState(() {
      _consents[type] = value;
    });
  }
  
  Future<void> _requestDataExport() async {
    // Simulação de solicitação de exportação de dados
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitação enviada'),
        content: const Text(
          'Sua solicitação de exportação de dados foi enviada. Você receberá seus dados no email cadastrado em até 15 dias.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _requestDataDeletion() async {
    // Confirmar antes de prosseguir
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text(
          'Tem certeza que deseja solicitar a exclusão de todos os seus dados? Esta ação não pode ser desfeita.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sim, excluir'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      // Simulação de solicitação de exclusão de dados
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Solicitação enviada'),
          content: const Text(
            'Sua solicitação de exclusão de dados foi enviada. O processo será concluído em até 30 dias e você receberá uma confirmação por email.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Consentimentos').withAccessibility(
          label: 'Tela de gerenciamento de consentimentos',
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
                    const Text(
                      'Seus direitos de privacidade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).withAccessibility(
                      label: 'Título da seção de direitos de privacidade',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Você tem o controle sobre seus dados. Gerencie abaixo como seus dados são usados e compartilhados.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ).withAccessibility(
                      hint: 'Descrição dos direitos de privacidade',
                    ),
                    const SizedBox(height: 24),
                    
                    // Seção de consentimentos
                    const Text(
                      'Consentimentos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).withAccessibility(
                      label: 'Seção de consentimentos',
                    ),
                    const SizedBox(height: 16),
                    
                    ...ConsentType.values.map((type) => _buildConsentItem(type)).toList(),
                    
                    const SizedBox(height: 32),
                    
                    // Seção de direitos GDPR/LGPD
                    const Text(
                      'Seus dados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ).withAccessibility(
                      label: 'Seção de direitos de dados',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDataRightsCard(),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildConsentItem(ConsentType type) {
    final isEnabled = _consents[type] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              type.icon,
              size: 28,
              color: Theme.of(context).primaryColor,
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
                  ).withAccessibility(
                    label: 'Consentimento para ${type.title}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ).withAccessibility(
                    hint: type.description,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Alternar consentimento para ${type.title}',
              child: Switch(
                value: isEnabled,
                onChanged: (value) => _updateConsent(type, value),
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    ).withAccessibility(
      label: 'Controle de consentimento para ${type.title}',
    );
  }
  
  Widget _buildDataRightsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exportar dados
            ListTile(
              leading: Icon(Icons.download_outlined, color: Theme.of(context).primaryColor),
              title: const Text('Solicitar meus dados'),
              subtitle: const Text('Receba uma cópia de todos os seus dados pessoais'),
              onTap: _requestDataExport,
              contentPadding: EdgeInsets.zero,
            ).withAccessibility(
              label: 'Botão para solicitar exportação de dados',
              hint: 'Toque para solicitar uma cópia de todos os seus dados pessoais',
              isButton: true,
              onTap: _requestDataExport,
            ),
            
            const Divider(),
            
            // Excluir dados
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Excluir meus dados'),
              subtitle: const Text('Solicitar a exclusão de todos os seus dados pessoais'),
              onTap: _requestDataDeletion,
              contentPadding: EdgeInsets.zero,
            ).withAccessibility(
              label: 'Botão para solicitar exclusão de dados',
              hint: 'Toque para solicitar a exclusão de todos os seus dados pessoais',
              isButton: true,
              onTap: _requestDataDeletion,
            ),
          ],
        ),
      ),
    ).withAccessibility(
      label: 'Cartão de direitos de dados',
    );
  }
} 