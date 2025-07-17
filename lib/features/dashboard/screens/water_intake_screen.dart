// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/water_intake_view_model.dart';

/// Tela para registrar o consumo de água
@RoutePage()
class WaterIntakeScreen extends ConsumerStatefulWidget {
  const WaterIntakeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends ConsumerState<WaterIntakeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waterAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _waterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waterState = ref.watch(waterIntakeViewModelProvider);
    final waterViewModel = ref.read(waterIntakeViewModelProvider.notifier);
    
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      appBar: AppBarWidget(
        title: 'Hidratação',
        showBackButton: true,
      ),
      body: waterState.when(
        data: (waterIntake) => _buildContent(context, waterIntake, waterViewModel),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFF38638),
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => waterViewModel.loadWaterIntake(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContent(
    BuildContext context, 
    dynamic waterIntake,
    WaterIntakeViewModel viewModel,
  ) {
    final percentage = waterIntake.cups / waterIntake.goal;
    
    // Animar quando atualizar
    _animationController.forward();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Card principal com visualização
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Título
                Text(
                  'Consumo de Água Hoje',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'StingerTrial',
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Visualização do copo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Copo
                    Container(
                      width: 200,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF4FC3F7),
                          width: 4,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Água animada
                          AnimatedBuilder(
                            animation: _waterAnimation,
                            builder: (context, child) {
                              return Container(
                                height: 240 * percentage * _waterAnimation.value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF4FC3F7).withOpacity(0.8),
                                      const Color(0xFF29B6F6),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Ondas
                          if (percentage > 0)
                            Positioned(
                              bottom: 240 * percentage - 10,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4FC3F7).withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Texto central
                    Column(
                      children: [
                        Text(
                          '${waterIntake.cups}',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        Text(
                          'de ${waterIntake.goal} copos',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Botões de controle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão diminuir
                    IconButton(
                      onPressed: waterIntake.cups > 0 
                          ? () {
                              HapticFeedback.lightImpact();
                              viewModel.decrementWater();
                            }
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 48,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 32),
                    // Botão adicionar
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        viewModel.incrementWater();
                        
                        // Celebração ao atingir meta
                        if (waterIntake.cups + 1 == waterIntake.goal) {
                          _showGoalReachedDialog(context);
                        }
                      },
                      icon: const Icon(Icons.add_circle),
                      iconSize: 48,
                      color: const Color(0xFF4FC3F7),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progresso
                Column(
                  children: [
                    Text(
                      '${(percentage * 100).toInt()}% da meta diária',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: percentage >= 1.0 
                            ? Colors.green 
                            : const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 1.0 
                            ? Colors.green 
                            : const Color(0xFF4FC3F7),
                      ),
                      minHeight: 8,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Card de informações
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4FC3F7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4FC3F7).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF4FC3F7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dica de Hidratação',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Beba água regularmente ao longo do dia, especialmente antes, durante e após os treinos.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botão para alterar meta
          OutlinedButton.icon(
            onPressed: () => _showChangeGoalDialog(context, viewModel, waterIntake.goal),
            icon: const Icon(Icons.edit),
            label: const Text('Alterar Meta Diária'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4FC3F7),
              side: const BorderSide(
                color: Color(0xFF4FC3F7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showGoalReachedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('🎉 Parabéns!'),
        content: const Text(
          'Você atingiu sua meta de hidratação diária! Continue assim para manter seu corpo saudável.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Obrigado!'),
          ),
        ],
      ),
    );
  }
  
  void _showChangeGoalDialog(
    BuildContext context, 
    WaterIntakeViewModel viewModel,
    int currentGoal,
  ) {
    int newGoal = currentGoal;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Alterar Meta Diária'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$newGoal copos por dia',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Slider(
                  value: newGoal.toDouble(),
                  min: 4,
                  max: 20,
                  divisions: 16,
                  label: '$newGoal copos',
                  onChanged: (value) {
                    setState(() {
                      newGoal = value.toInt();
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.updateGoal(newGoal);
              Navigator.of(context).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
} 