// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit.dart';
import '../viewmodels/benefit_view_model.dart';
import '../widgets/custom_date_picker.dart';
import 'package:ray_club_app/core/widgets/app_loading_indicator.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';

/// Tela de administração de benefícios
@RoutePage()
class BenefitAdminScreen extends ConsumerStatefulWidget {
  const BenefitAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BenefitAdminScreen> createState() => _BenefitAdminScreenState();
}

class _BenefitAdminScreenState extends ConsumerState<BenefitAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAdmin = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAdminStatus();
    _loadData();
  }
  
  /// Verifica se o usuário é admin
  Future<void> _checkAdminStatus() async {
    final isAdmin = await ref.read(benefitViewModelProvider.notifier).isAdmin();
    if (mounted) {
      setState(() {
        _isAdmin = isAdmin;
      });
    }
  }
  
  /// Carrega os dados iniciais
  Future<void> _loadData() async {
    ref.read(benefitViewModelProvider.notifier).loadBenefits();
    ref.read(benefitViewModelProvider.notifier).loadAllRedeemedBenefits();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(benefitViewModelProvider);
    
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Administração'),
        ),
        body: const Center(
          child: Text('Você não tem permissão para acessar esta área.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração de Benefícios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Benefícios'),
            Tab(text: 'Resgates'),
          ],
        ),
        actions: [
          // Botão para alternar status de admin (para teste)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: 'Alternar status de admin',
            onPressed: () async {
              await ref.read(benefitViewModelProvider.notifier).toggleAdminStatus();
              await _checkAdminStatus();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Status de admin: ${_isAdmin ? 'Ativado' : 'Desativado'}'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadData,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBenefitsTab(state.benefits),
                _buildRedeemedBenefitsTab(state.redeemedBenefits),
              ],
            ),
    );
  }
  
  /// Constrói a tab de benefícios
  Widget _buildBenefitsTab(List<Benefit> benefits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  benefit.description,
                  style: AppTypography.body2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Parceiro: ${benefit.partner}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Expiração: ${benefit.expirationDate != null ? DateFormat('dd/MM/yyyy').format(benefit.expirationDate!) : 'Não expira'}',
                      style: AppTypography.body2,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showEditExpirationDialog(benefit),
                      child: const Text('Editar Expiração'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Constrói a tab de benefícios resgatados
  Widget _buildRedeemedBenefitsTab(List<RedeemedBenefit> redeemedBenefits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: redeemedBenefits.length,
      itemBuilder: (context, index) {
        final redeemedBenefit = redeemedBenefits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        redeemedBenefit.benefitTitle ?? 'Benefício Desconhecido',
                        style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _getStatusChip(redeemedBenefit.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Usuário: ${redeemedBenefit.userId}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 8),
                Text(
                  'Código: ${redeemedBenefit.redemptionCode}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 8),
                if (redeemedBenefit.redeemedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Resgatado em: ${DateFormat('dd/MM/yyyy').format(redeemedBenefit.redeemedAt!)}',
                    style: AppTypography.caption,
                  ),
                ],
                if (redeemedBenefit.expiresAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Expira em: ${DateFormat('dd/MM/yyyy').format(redeemedBenefit.expiresAt!)}',
                    style: AppTypography.caption,
                  ),
                ],
                if (redeemedBenefit.usedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Utilizado em: ${DateFormat('dd/MM/yyyy').format(redeemedBenefit.usedAt!)}',
                    style: AppTypography.caption,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: redeemedBenefit.status == BenefitStatus.active ||
                               redeemedBenefit.status == BenefitStatus.expired
                          ? () => _showExtendExpirationDialog(context, redeemedBenefit)
                          : null,
                      child: const Text('Editar Expiração'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Retorna um chip com o status do benefício
  Widget _getStatusChip(BenefitStatus status) {
    switch (status) {
      case BenefitStatus.active:
        return _buildStatusChip('Ativo', Colors.green);
      case BenefitStatus.used:
        return _buildStatusChip('Utilizado', Colors.blue);
      case BenefitStatus.expired:
        return _buildStatusChip('Expirado', Colors.red);
      case BenefitStatus.cancelled:
        return _buildStatusChip('Cancelado', Colors.grey);
    }
  }
  
  /// Exibe diálogo para editar data de expiração do benefício
  void _showEditExpirationDialog(Benefit benefit) {
    DateTime? selectedDate = benefit.expirationDate;
    bool removeExpiration = benefit.expirationDate == null;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Data de Expiração'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Benefício: ${benefit.title}'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Remover data de expiração'),
                value: removeExpiration,
                onChanged: (value) {
                  setState(() {
                    removeExpiration = value ?? false;
                  });
                },
              ),
              if (!removeExpiration) ...[
                const SizedBox(height: 16),
                const Text('Nova data de expiração:'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showCustomDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)), 
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Selecione uma data',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = await ref.read(benefitViewModelProvider.notifier).updateBenefitExpiration(
                  benefit.id,
                  removeExpiration ? null : selectedDate,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Data de expiração atualizada com sucesso'
                            : 'Erro ao atualizar data de expiração',
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Exibe diálogo para editar data de expiração do benefício resgatado
  void _showExtendExpirationDialog(BuildContext context, RedeemedBenefit redeemedBenefit) {
    DateTime? selectedDate = redeemedBenefit.expiresAt;
    bool removeExpiration = redeemedBenefit.expiresAt == null;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Estender Validade'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Benefício: ${redeemedBenefit.benefitTitle ?? "Desconhecido"}',
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: 8),
              Text(
                'Status atual: ${_getStatusText(redeemedBenefit.status)}',
                style: AppTypography.body2,
              ),
              if (redeemedBenefit.expiresAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Expiração atual: ${DateFormat('dd/MM/yyyy').format(redeemedBenefit.expiresAt!)}',
                  style: AppTypography.body2,
                ),
              ],
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Remover data de expiração'),
                value: removeExpiration,
                onChanged: (value) {
                  setState(() {
                    removeExpiration = value ?? false;
                  });
                },
              ),
              if (!removeExpiration) ...[
                const SizedBox(height: 16),
                const Text('Nova data de expiração:'),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showCustomDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 8),
                        Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Selecione uma data',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final success = await ref.read(benefitViewModelProvider.notifier).extendRedeemedBenefitExpiration(
                  redeemedBenefit.id,
                  removeExpiration ? null : selectedDate,
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Validade atualizada com sucesso'
                            : 'Erro ao atualizar validade',
                      ),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Retorna texto representando o status
  String _getStatusText(BenefitStatus status) {
    switch (status) {
      case BenefitStatus.active:
        return 'Ativo';
      case BenefitStatus.used:
        return 'Utilizado';
      case BenefitStatus.expired:
        return 'Expirado';
      case BenefitStatus.cancelled:
        return 'Cancelado';
    }
  }

  Widget _buildStatusChip(String label, Color color) {
    return Chip(
      backgroundColor: color.withOpacity(0.1),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
} 
