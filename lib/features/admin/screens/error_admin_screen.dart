// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/features/admin/repositories/admin_repository.dart';
import 'package:ray_club_app/features/workout/models/check_in_error_log.dart';

/// Tela administrativa para diagnóstico de erros no processamento de treinos
@RoutePage()
class ErrorAdminScreen extends ConsumerStatefulWidget {
  const ErrorAdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ErrorAdminScreen> createState() => _ErrorAdminScreenState();
}

class _ErrorAdminScreenState extends ConsumerState<ErrorAdminScreen> with SingleTickerProviderStateMixin {
  /// Controlador das abas
  late TabController _tabController;
  
  /// ID do usuário selecionado para filtrar
  String? _selectedUserId;
  
  /// Status de filtro selecionado
  String? _selectedStatus;
  
  /// Formatador de data
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Adicionar listener para ressetar filtro quando mudar para a aba de resumo
    _tabController.addListener(() {
      if (_tabController.index == 0 && _selectedUserId != null) {
        setState(() {
          _selectedUserId = null;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico de Erros'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumo por Usuário'),
            Tab(text: 'Logs Detalhados'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // Força refresh dos dados
            tooltip: 'Atualizar dados',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserSummaryTab(),
          _buildDetailedLogsTab(),
        ],
      ),
      bottomNavigationBar: _buildDiagnosticTools(),
    );
  }
  
  /// Constrói a tab de resumo por usuário
  Widget _buildUserSummaryTab() {
    final adminRepo = ref.watch(adminRepositoryProvider);
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: adminRepo.getErrorSummaryByUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum erro registrado'));
        }
        
        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user['user_name'] ?? 'Usuário ${user['user_id']}'),
              subtitle: Text('${user['error_count']} erros • Último: ${_formatDate(user['last_error'])}'),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                setState(() {
                  _selectedUserId = user['user_id'];
                  _tabController.animateTo(1); // Mudar para a tab de logs detalhados
                });
              },
            );
          },
        );
      },
    );
  }
  
  /// Constrói a tab de logs detalhados
  Widget _buildDetailedLogsTab() {
    final adminRepo = ref.watch(adminRepositoryProvider);
    
    return Column(
      children: [
        // Área de filtros
        _buildFilterChips(),
        
        // Lista de logs
        Expanded(
          child: FutureBuilder<List<CheckInErrorLog>>(
            future: adminRepo.getErrorLogs(
              userId: _selectedUserId,
              status: _selectedStatus,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhum log de erro encontrado'));
              }
              
              final logs = snapshot.data!;
              return ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return _buildErrorLogCard(log);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// Constrói chips de filtro
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            if (_selectedUserId != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: const Text('Filtro: ID do usuário'),
                  onDeleted: () {
                    setState(() {
                      _selectedUserId = null;
                    });
                  },
                ),
              ),
              
            if (_selectedStatus != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Chip(
                  label: Text('Status: $_selectedStatus'),
                  onDeleted: () {
                    setState(() {
                      _selectedStatus = null;
                    });
                  },
                ),
              ),
              
            // Filtros de status
            if (_selectedStatus == null)
              Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('Erros'),
                    selected: _selectedStatus == 'error',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? 'error' : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Duplicados'),
                    selected: _selectedStatus == 'duplicate',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? 'duplicate' : null;
                      });
                    },
                  ),
                  FilterChip(
                    label: const Text('Ignorados'),
                    selected: _selectedStatus == 'skipped',
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? 'skipped' : null;
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói o card para um log de erro
  Widget _buildErrorLogCard(CheckInErrorLog log) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(log.statusFormatted),
                  backgroundColor: log.statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: log.statusColor),
                ),
                Text(
                  _formatDate(log.createdAt.toString()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              log.errorMessage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (log.errorDetail != null) ...[
              const SizedBox(height: 4),
              Text(
                log.errorDetail!,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (log.workoutId != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Mostrar diálogo de confirmação
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Reprocessamento'),
                          content: const Text('Deseja tentar reprocessar este treino?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Reprocessar'),
                            ),
                          ],
                        ),
                      );
                      
                      // Se confirmado, tenta reprocessar
                      if (confirmed == true) {
                        final success = await adminRepo.retryProcessingForWorkout(log.workoutId!);
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success 
                                ? 'Processamento reiniciado com sucesso!' 
                                : 'Falha ao tentar reprocessar'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          
                          // Atualizar a lista após reprocessamento
                          setState(() {});
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Reprocessar'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Mostrar detalhes do erro em um diálogo
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Detalhes do Erro'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailItem('ID', log.id),
                                _buildDetailItem('Usuário', log.userId),
                                if (log.challengeId != null)
                                  _buildDetailItem('Desafio', log.challengeId!),
                                if (log.workoutId != null)
                                  _buildDetailItem('Treino', log.workoutId!),
                                _buildDetailItem('Mensagem', log.errorMessage),
                                if (log.errorDetail != null)
                                  _buildDetailItem('Detalhes', log.errorDetail!),
                                _buildDetailItem('Status', log.statusFormatted),
                                _buildDetailItem('Data', _dateFormat.format(log.createdAt)),
                                
                                const Divider(),
                                
                                if (log.requestData != null) ...[
                                  const Text('Dados da Requisição:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(log.requestData.toString()),
                                ],
                                
                                if (log.responseData != null) ...[
                                  const SizedBox(height: 8),
                                  const Text('Dados da Resposta:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(log.responseData.toString()),
                                ],
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Fechar'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Detalhes'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Constrói a barra de ferramentas de diagnóstico
  Widget _buildDiagnosticTools() {
    final adminRepo = ref.watch(adminRepositoryProvider);
    
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                // Mostrar diálogo de confirmação
                final daysBack = await showDialog<int>(
                  context: context,
                  builder: (context) => _buildDiagnosticDialog(),
                );
                
                // Se confirmado, executa diagnóstico
                if (daysBack != null) {
                  // Mostrar indicador de progresso
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Executando diagnóstico...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                  
                  // Executar diagnóstico
                  final result = await adminRepo.runSystemDiagnostics(daysBack: daysBack);
                  
                  // Mostrar resultado
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Resultado do Diagnóstico'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Período analisado: ${result['period']} dias'),
                            const SizedBox(height: 8),
                            Text('Registros recuperados: ${result['recovered_count']}'),
                            Text('Registros sem fila: ${result['missing_count']}'),
                            Text('Falhas na recuperação: ${result['failed_count']}'),
                            const SizedBox(height: 8),
                            Text('Timestamp: ${_formatDate(result['timestamp'])}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Atualizar a lista após diagnóstico
                              setState(() {});
                            },
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.healing),
              label: const Text('Diagnóstico e Recuperação'),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedUserId = null;
                  _selectedStatus = null;
                });
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('Limpar Filtros'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói o diálogo de diagnóstico
  Widget _buildDiagnosticDialog() {
    int days = 7;
    
    return AlertDialog(
      title: const Text('Executar Diagnóstico e Recuperação'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Este processo irá identificar e tentar recuperar registros de treino com problemas no processamento.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Text('Período para análise (dias):'),
          StatefulBuilder(
            builder: (context, setState) {
              return Slider(
                value: days.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: days.toString(),
                onChanged: (value) {
                  setState(() {
                    days = value.round();
                  });
                },
              );
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(days),
          child: const Text('Executar'),
        ),
      ],
    );
  }
  
  /// Constrói um item de detalhe para o diálogo de detalhes
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  /// Formata uma string de data
  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    
    try {
      final date = DateTime.parse(dateStr.toString());
      return _dateFormat.format(date);
    } catch (e) {
      return dateStr.toString();
    }
  }
} 