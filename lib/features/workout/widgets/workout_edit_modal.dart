import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../models/workout_record.dart';
import '../providers/workout_providers.dart';
import '../viewmodels/workout_history_view_model.dart';
import '../../../core/providers/supabase_providers.dart';

/// Modal para edição ou exclusão de um registro de treino
class WorkoutEditModal extends ConsumerStatefulWidget {
  /// Registro de treino a ser editado
  final WorkoutRecord workoutRecord;
  
  /// Callback executado após edição com sucesso
  final VoidCallback onUpdateSuccess;
  
  /// Callback executado após exclusão com sucesso
  final VoidCallback onDeleteSuccess;
  
  /// ID do desafio associado (para recalcular o progresso)
  final String? challengeId;

  const WorkoutEditModal({
    Key? key,
    required this.workoutRecord,
    required this.onUpdateSuccess,
    required this.onDeleteSuccess,
    this.challengeId,
  }) : super(key: key);

  @override
  ConsumerState<WorkoutEditModal> createState() => _WorkoutEditModalState();
}

class _WorkoutEditModalState extends ConsumerState<WorkoutEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _durationController;
  late TextEditingController _dateController;
  late String _selectedType;
  bool _isLoading = false;
  bool _isDeleteConfirmVisible = false;
  
  // Lista de tipos de treino disponíveis
  final workoutTypes = [
    'Musculação',
    'Funcional',
    'Força',
    'Pilates',
    'Corrida',
    'Fisioterapia',
    'Alongamento',
    'Flexibilidade',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.workoutRecord.workoutName);
    _durationController = TextEditingController(text: widget.workoutRecord.durationMinutes.toString());
    _dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(widget.workoutRecord.date),
    );
    
    // Obter o tipo do treino e verificar se está na lista de tipos disponíveis
    final workoutType = widget.workoutRecord.workoutType;
    debugPrint('🔍 Tipo de treino original: $workoutType');
    
    if (workoutTypes.contains(workoutType)) {
      _selectedType = workoutType;
    } else {
      debugPrint('⚠️ Tipo de treino não encontrado na lista: $workoutType');
      _selectedType = workoutTypes.last; // 'Alongamento' como fallback
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Salva as alterações feitas no registro de treino
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Obter o repositório
      final repository = ref.read(workoutRecordRepositoryProvider);
      
      // Usar a nova função updateWorkout que chama a RPC update_workout_and_refresh
      await repository.updateWorkout(
        workoutId: widget.workoutRecord.id,
        userId: widget.workoutRecord.userId,
        challengeId: widget.challengeId ?? '',
        workoutName: _nameController.text.trim(),
        workoutType: _selectedType,
        duration: int.tryParse(_durationController.text) ?? widget.workoutRecord.durationMinutes,
        date: widget.workoutRecord.date,
        notes: widget.workoutRecord.notes,
      );
      
      // Invalidar providers para forçar atualização
      ref.invalidate(userWorkoutsProvider);
      ref.invalidate(workoutHistoryViewModelProvider);
      
      // Notificar sucesso
      if (mounted) {
        SnackbarHelper.showSuccess(
          context: context, 
          message: 'Treino atualizado com sucesso!',
        );
        
        Navigator.of(context).pop();
        widget.onUpdateSuccess();
      }
    } catch (e) {
      // Tratar erro
      if (mounted) {
        SnackbarHelper.showError(
          context: context, 
          message: 'Erro ao atualizar treino: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Exclui o registro de treino
  Future<void> _deleteWorkout() async {
    setState(() => _isLoading = true);
    
    try {
      // Obter o repositório
      final repository = ref.read(workoutRecordRepositoryProvider);
      final workoutId = widget.workoutRecord.id;
      
      debugPrint('🔍 Tentando excluir treino: id=$workoutId, userId=${widget.workoutRecord.userId}');
      
      // Usar a nova função que chama a RPC delete_workout_and_refresh
      await repository.deleteWorkout(
        workoutId: workoutId,
        userId: widget.workoutRecord.userId,
        challengeId: widget.challengeId ?? '',
      );
      
      // Invalidar providers para forçar atualização
      ref.invalidate(userWorkoutsProvider);
      ref.invalidate(workoutHistoryViewModelProvider);
      
      // Notificar sucesso
      if (mounted) {
        debugPrint('✅ Treino excluído com sucesso no modal: $workoutId');
        
        SnackbarHelper.showSuccess(
          context: context, 
          message: 'Treino excluído com sucesso!',
        );
        Navigator.of(context).pop();
        widget.onDeleteSuccess();
      }
    } catch (e) {
      // Tratar erro com log detalhado
      debugPrint('❌ ERRO AO EXCLUIR TREINO: ${e.toString()}');
      debugPrint('❌ Tipo de erro: ${e.runtimeType}');
      
      // Tratar erro
      if (mounted) {
        SnackbarHelper.showError(
          context: context, 
          message: 'Erro ao excluir treino: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  /// Recalcula o progresso do desafio via função RPC
  Future<void> _recalculateChallengeProgress(String userId, String challengeId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.rpc('recalculate_challenge_progress', params: {
        'p_user_id': userId,
        'p_challenge_id': challengeId,
      });
      debugPrint('✅ Progresso do desafio recalculado com sucesso');
    } catch (e) {
      debugPrint('⚠️ Erro ao recalcular progresso do desafio: $e');
      // Não propagar o erro - o usuário já verá o treino atualizado/excluído
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  'Editar Treino',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textDark,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Nome do treino
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do treino',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome do treino é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Tipo de treino
                Builder(
                  builder: (context) {
                    // Verificação adicional para garantir que o valor selecionado está na lista
                    if (!workoutTypes.contains(_selectedType)) {
                      debugPrint('⚠️ [BUILD] Correção: tipo $_selectedType não encontrado na lista');
                      _selectedType = workoutTypes.last; // 'Flexibilidade'
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de treino',
                        border: OutlineInputBorder(),
                      ),
                      items: workoutTypes.map((type) => 
                        DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tipo de treino é obrigatório';
                        }
                        return null;
                      },
                    );
                  }
                ),
                const SizedBox(height: 12),
                
                // Duração
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duração (minutos)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Duração é obrigatória';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Informe um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                // Data (somente visualização)
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Data e hora (não editável)',
                    border: OutlineInputBorder(),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 24),
                
                // Botões de ação
                if (!_isDeleteConfirmVisible) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão de excluir
                      TextButton.icon(
                                                    onPressed: _isLoading 
                                ? null 
                                : () => setState(() => _isDeleteConfirmVisible = true),
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              'Excluir',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: const ButtonStyle(
                              padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                            ),
                      ),
                      
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botão de cancelar
                            TextButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                              style: const ButtonStyle(
                                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                              ),
                            ),
                            
                            const SizedBox(width: 4),
                            
                            // Botão de salvar
                            Flexible(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveChanges,
                                                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Color(0xFFF38638)), // Orange color
                                foregroundColor: MaterialStatePropertyAll(Colors.white),
                                padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                              ),
                                child: _isLoading 
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Salvar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Confirmação de exclusão
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(244, 67, 54, 0.1), // Use direct RGBA color instead
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color.fromRGBO(244, 67, 54, 0.3)), // Use direct RGBA color instead
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                                  const Text(
                          'Tem certeza que deseja excluir este treino?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Esta ação não pode ser desfeita e atualizará o ranking do desafio.',
                          style: TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                                      onPressed: _isLoading 
                                  ? null 
                                  : () => setState(() => _isDeleteConfirmVisible = false),
                                child: const Text('Cancelar'),
                                style: const ButtonStyle(
                                  padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                                ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _deleteWorkout,
                                style: const ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(Colors.red),
                                  foregroundColor: MaterialStatePropertyAll(Colors.white),
                                  padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                                ),
                                icon: _isLoading 
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.delete, size: 18),
                                label: const Text('Confirmar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Função auxiliar para exibir o modal de edição
Future<void> showWorkoutEditModal({
  required BuildContext context,
  required WorkoutRecord workoutRecord,
  required VoidCallback onUpdateSuccess,
  required VoidCallback onDeleteSuccess,
  String? challengeId,
}) async {
  await showDialog(
    context: context,
    builder: (context) => WorkoutEditModal(
      workoutRecord: workoutRecord,
      onUpdateSuccess: onUpdateSuccess,
      onDeleteSuccess: onDeleteSuccess,
      challengeId: challengeId,
    ),
  );
} 