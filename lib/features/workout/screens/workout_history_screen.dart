// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../viewmodels/workout_history_view_model.dart';
import '../models/workout_record.dart';
import '../../home/widgets/register_exercise_sheet.dart';
import 'workout_record_detail_screen.dart';

// Adiciona a enumeração para intensidade dos treinos
enum WorkoutIntensity {
  light,
  moderate,
  intense,
  unknown
}

@RoutePage()
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Abre o WhatsApp para contato com suporte sobre treinos
  Future<void> _openWhatsAppSupport() async {
    const whatsappUrl = 'https://wa.me/5531997940477?text=Ol%C3%A1%21%20Estou%20enfrentando%20dificuldades%20com%20meus%20treinos%20no%20app%20e%20preciso%20de%20ajuda%2C%20por%20favor.';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback se não conseguir abrir o WhatsApp
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Não foi possível abrir o WhatsApp. Verifique se o app está instalado.'),
              backgroundColor: AppColors.error,
              action: SnackBarAction(
                label: 'Copiar contato',
                textColor: Colors.white,
                onPressed: () async {
                  await Clipboard.setData(const ClipboardData(text: '+55 31 99794-0477'));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Número copiado para a área de transferência'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao tentar abrir o suporte'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(workoutHistoryViewModelProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF4D4D4D), // Cor escura para o fundo principal
      appBar: AppBar(
        title: const Text(
          'Calendário',
          style: TextStyle(
            fontFamily: 'Century',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4D4D4D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.router.maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
            ),
            onPressed: _openWhatsAppSupport,
            tooltip: 'Suporte - Problemas com treinos',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFCDA8F0), // Novo indicador de tab em lilás
          labelColor: const Color(0xFFCDA8F0), // Texto da tab selecionada em lilás
          unselectedLabelColor: AppColors.textLight,
          labelStyle: const TextStyle(fontFamily: 'Century', fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Century'),
          tabs: const [
            Tab(text: 'Calendário'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Opacity(
              opacity: 0.2, // Ajuste a opacidade conforme necessário
              child: Image.asset(
                'assets/images/logos/app/gradientes_9.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Conteúdo principal - usando SafeArea para evitar sobreposições
          SafeArea(
            top: false, // AppBar já fornece o padding necessário
            bottom: true, // Garante que não haja overflow na parte inferior
            child: TabBarView(
              controller: _tabController,
              children: [
                // Aba de Calendário
                _buildCalendarTab(context, historyState),
                
                // Aba de Histórico
                _buildHistoryListTab(context, historyState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Abrir o register exercise sheet
          showRegisterExerciseSheet(context);
        },
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        label: Text(
          'Adicionar Treino',
          style: AppTypography.button.copyWith(
            fontFamily: 'CenturyGothic',
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEFB9B7)), // Rosa claro para ícone de erro
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar histórico',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(workoutHistoryViewModelProvider.notifier).loadWorkoutHistory(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCDA8F0), // Botão em lilás
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Tentar novamente',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 64, color: AppColors.textLight),
          const SizedBox(height: 24),
          Text(
            'Nenhuma atividade registrada',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Registre seus treinos para acompanhar seu progresso',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectDayPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xFF555555),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            'Selecione uma data no calendário para ver suas atividades',
            style: TextStyle(
              fontFamily: 'Century',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCalendarTab(BuildContext context, WorkoutHistoryState state) {
    if (state is WorkoutHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is WorkoutHistoryError) {
      return _buildErrorView(state.message);
    } else if (state is WorkoutHistoryEmpty) {
      return _buildEmptyView();
    } else if (state is WorkoutHistoryLoaded) {
      final viewModel = ref.read(workoutHistoryViewModelProvider.notifier);
      final workoutsByDay = viewModel.getWorkoutsByDay();
      
      return SingleChildScrollView(
        child: Column(
          children: [
            // Calendário primeiro
            _buildCalendar(workoutsByDay, state.selectedDate),
            
            // Área de seleção ou exibição de treinos
            SizedBox(
              height: 200,
              child: state.selectedDate != null && state.selectedDateRecords != null
                ? state.selectedDateRecords!.isEmpty
                  ? _buildNoWorkoutsForDayView(state.selectedDate!)
                  : _buildSelectedDayWorkouts(state.selectedDateRecords!)
                : _buildSelectDayPrompt(),
            ),
            
            const Divider(color: AppColors.divider),
          ],
        ),
      );
    } else {
      return _buildEmptyView();
    }
  }
  
  Widget _buildCalendar(Map<DateTime, List<WorkoutRecord>> workoutsByDay, DateTime? selectedDay) {
    final viewModel = ref.read(workoutHistoryViewModelProvider.notifier);
    
    return TableCalendar(
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.now().add(const Duration(days: 1)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      eventLoader: (day) {
        // Normalizar a data para comparação
        final normalized = DateTime(day.year, day.month, day.day);
        return workoutsByDay[normalized] ?? [];
      },
      selectedDayPredicate: (day) {
        if (selectedDay == null) return false;
        return isSameDay(selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        viewModel.selectDate(selectedDay);
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 3,
        markerDecoration: const BoxDecoration(
          color: Color(0xFFCDA8F0), // Marcadores em lilás
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFFEFB9B7), // Dia selecionado em rosa claro
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: Color(0xFF9980C5), // Hoje em lilás mais escuro
          shape: BoxShape.circle,
        ),
        weekendTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: Colors.white,
        ),
        defaultTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14, 
          color: Colors.white,
        ),
        outsideTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: Colors.white60,
        ),
        disabledTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: Colors.white60,
        ),
        todayTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        selectedTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: Colors.white, 
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        
        // Cores de fundo para os diferentes tipos de dias - ajuste do sombreado
        defaultDecoration: BoxDecoration(
          color: const Color(0xFF555555), // Cinza médio para dias comuns
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: 0.5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        weekendDecoration: BoxDecoration(
          color: const Color(0xFF666666), // Cinza um pouco mais claro para fins de semana
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: 0.5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        outsideDecoration: BoxDecoration(
          color: const Color(0xFF444444).withOpacity(0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: 0.5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        holidayDecoration: BoxDecoration(
          color: const Color(0xFF666666),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: 0.5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        formatButtonTextStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        formatButtonDecoration: BoxDecoration(
          color: const Color(0xFFCDA8F0), // Fundo lilás para o botão de formato
          borderRadius: BorderRadius.circular(16),
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white), // Setas em branco
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        weekendStyle: TextStyle(
          fontFamily: 'Century',
          fontSize: 14,
          color: const Color(0xFFEFB9B7), // Fins de semana em rosa claro
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFF444444),
          border: Border(
            bottom: BorderSide(color: Colors.white12, width: 1),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNoWorkoutsForDayView(DateTime date) {
    final formattedDate = DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 48, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(
              'Nenhuma atividade em $formattedDate',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(workoutHistoryViewModelProvider.notifier).clearSelectedDate();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Voltar ao calendário'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectedDayWorkouts(List<WorkoutRecord> records) {
    return Container(
      color: const Color(0xFF333333), // Fundo mais escuro para a seção de treinos
      child: ListView.builder(
        itemCount: records.length,
        shrinkWrap: true, // Permite que a lista ocupe apenas o espaço necessário
        physics: const ClampingScrollPhysics(), // Evita o efeito de bounce
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final record = records[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF444444), // Cartões em cinza um pouco mais claro
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                _navigateToWorkoutDetail(record);
              },
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                record.workoutName,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getIntensityColor('normal'), // Usando valor padrão
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getIntensityText('normal'), // Usando valor padrão
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Duração: ${record.durationMinutes} minutos',
                          style: AppTypography.bodyMedium.copyWith(color: const Color(0xFFE6E6E6)), // Texto secundário em cinza claro
                        ),
                        if (record.notes != null && record.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            record.notes!,
                            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Limitando a altura das imagens em container com altura fixa
                  if (record.imageUrls.isNotEmpty)
                    Container(
                      height: 100, // Reduzindo a altura para evitar overflow
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: record.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8, left: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                record.imageUrls[index],
                                width: 100, // Reduzindo largura
                                height: 100, // Reduzindo altura
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[800],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.broken_image,
                                          color: Colors.white60,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Erro',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryListTab(BuildContext context, WorkoutHistoryState state) {
    if (state is WorkoutHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is WorkoutHistoryError) {
      return _buildErrorView(state.message);
    } else if (state is WorkoutHistoryEmpty) {
      return _buildEmptyView();
    } else if (state is WorkoutHistoryLoaded) {
      // Agrupar registros por mês
      final groupedRecords = <String, List<WorkoutRecord>>{};
      
      for (final record in state.allRecords) {
        final month = DateFormat('MMMM y', 'pt_BR').format(record.date);
        groupedRecords.putIfAbsent(month, () => []).add(record);
      }

      // Ordenar meses (mais recentes primeiro)
      final sortedMonths = groupedRecords.keys.toList()
        ..sort((a, b) {
          final dateA = DateFormat('MMMM y', 'pt_BR').parse(a);
          final dateB = DateFormat('MMMM y', 'pt_BR').parse(b);
          return dateB.compareTo(dateA);
        });
      
      return Column(
        children: [
          // Lista de treinos agrupados por mês
          Expanded(
            child: sortedMonths.isNotEmpty
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20), // Adicionar padding na parte inferior
                  itemCount: sortedMonths.length,
                  itemBuilder: (context, index) {
                    final month = sortedMonths[index];
                    final monthRecords = groupedRecords[month]!;
                    
                    return _buildMonthSection(month, monthRecords);
                  },
                )
              : _buildEmptyView(),
          ),
        ],
      );
    } else {
      return _buildEmptyView();
    }
  }

  Widget _buildMonthSection(String month, List<WorkoutRecord> records) {
    // Ordenar registros do mês (mais recentes primeiro)
    records.sort((a, b) => b.date.compareTo(a.date));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFF666666),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12, width: 1),
            ),
            child: Text(
              month,
              style: AppTypography.headingSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
        ...records.map((record) => _buildHistoryItem(context, record)),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, WorkoutRecord record) {
    // Definindo uma intensidade padrão já que não existe no modelo
    final intensityText = _getIntensityText('normal');
    final intensityColor = _getIntensityColor('normal');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF555555), // Fundo mais claro para melhor contraste
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white24, width: 1),
      ),
      child: InkWell(
        onTap: () {
          _navigateToWorkoutDetail(record);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.workoutName,
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 1,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: intensityColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: intensityColor, width: 1),
                    ),
                    child: Text(
                      intensityText,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm', 'pt_BR').format(record.date),
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    '${record.durationMinutes} min',
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              
              // Exibir imagens se disponíveis
              if (record.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: record.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            record.imageUrls[index],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[800],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.white60,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Erro ao carregar',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getIntensityColor(String intensity) {
    // Cores para os níveis de intensidade utilizando a paleta fornecida
    switch (intensity.toLowerCase()) {
      case 'light':
        return const Color(0xFFE6E6E6); // Cinza claro para leve
      case 'moderate':
        return const Color(0xFFEFB9B7); // Rosa para moderado
      case 'intense':
        return const Color(0xFFCDA8F0); // Lilás para intenso
      default:
        return const Color(0xFF777777); // Cinza médio para desconhecido
    }
  }

  String _getIntensityText(String intensity) {
    // Textos para os níveis de intensidade
    switch (intensity.toLowerCase()) {
      case 'light':
        return 'Leve';
      case 'moderate':
        return 'Moderado';
      case 'intense':
        return 'Intenso';
      default:
        return 'Desconhecido';
    }
  }

  void _navigateToWorkoutDetail(WorkoutRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WorkoutRecordDetailScreen(
          recordId: record.id,
          workoutRecord: record,
        ),
      ),
    );
  }
} 