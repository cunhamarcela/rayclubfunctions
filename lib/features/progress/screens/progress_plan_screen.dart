// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/widgets/app_loading_indicator.dart';
import 'package:ray_club_app/core/widgets/app_error_widget.dart';
import 'package:ray_club_app/shared/bottom_navigation_bar.dart';
import 'package:ray_club_app/features/goals/models/user_goal_model.dart';
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/features/goals/repositories/goal_repository.dart';
import 'package:ray_club_app/features/goals/repositories/water_intake_repository.dart';
import 'package:ray_club_app/features/goals/models/water_intake_mapper.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';

@RoutePage()
class ProgressPlanScreen extends ConsumerStatefulWidget {
  const ProgressPlanScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressPlanScreen> createState() => _ProgressPlanScreenState();
}

class _ProgressPlanScreenState extends ConsumerState<ProgressPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Activity',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout statistics with chart
            _buildWorkoutStatistics(),
            
            // Challenge participation section
            _buildChallengeParticipation(),
            
            // Redeemed coupons section
            _buildRedeemedCoupons(),
            
            // Calendar showing workout days
            _buildWorkoutCalendar(),
          ],
        ),
      ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildWorkoutStatistics() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  // Navegue para a tela de histórico de treinos
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.fitness_center,
                      size: 20,
                      color: Color(0xFF333333),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Meus Treinos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegue para a tela de histórico de treinos
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                title: 'Treinos Completados',
                value: '28',
                subtitle: 'Este mês',
                iconData: Icons.fitness_center,
                color: Colors.orange,
              ),
              _buildStatCard(
                title: 'Tempo Total',
                value: '14.5h',
                subtitle: 'Este mês',
                iconData: Icons.timer,
                color: Colors.green,
              ),
              _buildStatCard(
                title: 'Frequência',
                value: '86%',
                subtitle: 'Meta atingida',
                iconData: Icons.trending_up,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Progresso de Tempo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _buildWorkoutChart(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData iconData,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconData,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildWorkoutChart() {
    // Mock data for the workout time chart
    final weekData = [
      {'day': 'S', 'minutes': 30, 'color': Colors.orange},
      {'day': 'M', 'minutes': 45, 'color': Colors.orange},
      {'day': 'T', 'minutes': 0, 'color': Colors.grey.withOpacity(0.3)},
      {'day': 'W', 'minutes': 60, 'color': Colors.orange},
      {'day': 'T', 'minutes': 40, 'color': Colors.orange},
      {'day': 'F', 'minutes': 50, 'color': Colors.orange},
      {'day': 'S', 'minutes': 75, 'color': Colors.orange},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weekData.map((data) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              (data['minutes'] as int) > 0 ? '${data['minutes']}m' : '',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: (data['minutes'] as int) > 0 ? (data['minutes'] as int) * 1.2 : 0,
              decoration: BoxDecoration(
                color: data['color'] as Color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['day'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildChallengeParticipation() {
    // Mock data for challenges
    final activeChallenges = [
      {
        'name': 'Desafio de Verão 2025',
        'progress': 0.45,
        'position': 12,
        'participants': 230,
        'daysLeft': 18,
        'color': Colors.orange,
      }
    ];
    
    final pastChallenges = [
      {
        'name': 'Maratona Fitness',
        'finalPosition': 8,
        'participants': 186,
        'completionDate': '10/04/2025',
        'color': Colors.green,
      },
      {
        'name': 'Desafio 30 Dias',
        'finalPosition': 3,
        'participants': 145,
        'completionDate': '15/03/2025',
        'color': Colors.blue,
      },
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desafios',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navegue para a tela de desafios
                  context.router.push(const ChallengesListRoute());
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Desafios ativos
          if (activeChallenges.isNotEmpty) ...[
            const Text(
              'Desafio Atual',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            ...activeChallenges.map((challenge) => 
              GestureDetector(
                onTap: () {
                  // Navegue para o detalhe do desafio
                  context.router.push(ChallengeDetailRoute(challengeId: '123'));
                },
                child: _buildActiveChallenge(challenge),
              )
            ).toList(),
            const SizedBox(height: 24),
          ],
          
          // Desafios passados
          if (pastChallenges.isNotEmpty) ...[
            const Text(
              'Desafios Concluídos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            ...pastChallenges.map((challenge) => 
              GestureDetector(
                onTap: () {
                  // Navegue para o detalhe do desafio
                  context.router.push(ChallengeDetailRoute(challengeId: '456'));
                },
                child: _buildPastChallenge(challenge),
              )
            ).toList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildActiveChallenge(Map<String, dynamic> challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: challenge['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Faltam ${challenge['daysLeft']} dias',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: challenge['color'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: challenge['progress'],
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(challenge['color']),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(challenge['progress'] * 100).toInt()}% concluído',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${challenge['position']}º lugar de ${challenge['participants']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPastChallenge(Map<String, dynamic> challenge) {
    final position = challenge['finalPosition'] as int;
    final medal = position <= 3
        ? Icon(
            Icons.emoji_events,
            color: position == 1
                ? Colors.amber
                : position == 2
                    ? Colors.grey[400]
                    : Colors.brown[300],
            size: 20,
          )
        : const SizedBox.shrink();
        
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: challenge['color'],
            margin: const EdgeInsets.only(right: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Concluído em ${challenge['completionDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              medal,
              const SizedBox(width: 4),
              Text(
                '${challenge['finalPosition']}º lugar',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' / ${challenge['participants']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemedCoupons() {
    // Mock data for redeemed coupons
    final coupons = [
      {
        'title': 'Desconto Smart Fit',
        'description': 'Desconto mensal de 15%',
        'expirationDate': '30/05/2025',
        'logoUrl': 'assets/images/gym_logo.png', // Substitua pelo caminho correto
        'status': 'Ativo',
        'color': Colors.green,
      },
      {
        'title': 'Protein Shop',
        'description': '10% OFF na primeira compra',
        'expirationDate': '10/04/2025',
        'logoUrl': 'assets/images/shop_logo.png', // Substitua pelo caminho correto
        'status': 'Expirado',
        'color': Colors.grey,
      },
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Benefícios Resgatados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Verificar acesso antes de navegar para benefícios
                  final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
                  if (hasAccess) {
                    context.router.pushNamed(AppRoutes.redeemedBenefits);
                  } else {
                    // Mostrar diálogo de bloqueio profissional
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (dialogContext) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6A5ACD),
                                Color(0xFF9370DB),
                                Color(0xFFBA55D3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.workspace_premium,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Benefícios Exclusivos',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Continue evoluindo para desbloquear acesso aos benefícios exclusivos dos nossos parceiros.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF6A5ACD),
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: const Text(
                                    'Entendi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (coupons.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum benefício resgatado ainda',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Verificar acesso antes de navegar para benefícios
                      final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
                      if (hasAccess) {
                        context.router.pushNamed(AppRoutes.benefits);
                      } else {
                        // Mostrar diálogo de bloqueio profissional
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (dialogContext) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 400),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF6A5ACD),
                                    Color(0xFF9370DB),
                                    Color(0xFFBA55D3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Benefícios Exclusivos',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Continue evoluindo para desbloquear acesso aos benefícios exclusivos dos nossos parceiros.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(0xFF6A5ACD),
                                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: const Text(
                                        'Entendi',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Explorar Benefícios'),
                  ),
                ],
              ),
            )
          else
            ...coupons.map((coupon) => 
              GestureDetector(
                onTap: () {
                  // Navegue para o detalhe do benefício
                  context.router.pushNamed(AppRoutes.redeemedBenefitDetail);
                },
                child: _buildCouponItem(coupon),
              )
            ).toList(),
        ],
      ),
    );
  }
  
  Widget _buildCouponItem(Map<String, dynamic> coupon) {
    final isActive = coupon['status'] == 'Ativo';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? coupon['color'].withOpacity(0.3) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Logo placeholder - replace with actual image loading
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? coupon['color'].withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.storefront,
              color: isActive ? coupon['color'] : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coupon['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive ? Colors.black54 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Válido até ${coupon['expirationDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.black45 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? coupon['color'].withOpacity(0.1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              coupon['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? coupon['color'] : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCalendar() {
    // Mock data for workout days
    final workoutDays = {
      DateTime(2025, 4, 1): ['Treino de Pernas'],
      DateTime(2025, 4, 3): ['Treino de Peito', 'Cardio HIIT'],
      DateTime(2025, 4, 5): ['Treino Completo'],
      DateTime(2025, 4, 8): ['Treino de Costas e Bíceps'],
      DateTime(2025, 4, 11): ['Yoga Flow'],
      DateTime(2025, 4, 12): ['Cardio Moderado'],
      DateTime(2025, 4, 15): ['Treino de Ombros'],
      DateTime(2025, 4, 18): ['Treino de Pernas'],
      DateTime(2025, 4, 21): ['Treino de Peito e Tríceps'],
      DateTime(2025, 4, 23): ['Yoga Restaurativo'],
      DateTime(2025, 4, 25): ['HIIT Intenso'],
      DateTime(2025, 4, 26): ['Treino de Core'],
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendário de Treinos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  // Navegue para o calendário completo (histórico de treinos)
                  context.router.pushNamed(AppRoutes.workoutHistory);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Colors.red),
              holidayTextStyle: const TextStyle(color: Colors.blue),
              todayDecoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
            ),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black54),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black54),
              titleTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            eventLoader: (day) {
              // Retorna os eventos para este dia
              return workoutDays[DateTime(day.year, day.month, day.day)] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              
              // Mostrar detalhes do treino se houver algum neste dia
              final workouts = workoutDays[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];
              if (workouts != null && workouts.isNotEmpty) {
                _showWorkoutDetails(context, selectedDay, workouts);
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          
          // Se um dia com treinos for selecionado, mostre informações resumidas
          if (_selectedDay != null) ...[
            const SizedBox(height: 16),
            _buildSelectedDayWorkouts(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSelectedDayWorkouts() {
    // Mock data para os treinos do dia selecionado
    final workoutDetails = {
      DateTime(2025, 4, 3): [
        {
          'name': 'Treino de Peito',
          'duration': '45 min',
          'calories': 320,
          'exercises': ['Supino', 'Crucifixo', 'Pullover', 'Flexões'],
          'time': '07:30',
        },
        {
          'name': 'Cardio HIIT',
          'duration': '25 min',
          'calories': 280,
          'exercises': ['Burpees', 'Mountain Climbers', 'Jumping Jacks', 'Sprints'],
          'time': '18:15',
        },
      ],
    };
    
    // Verifique se há detalhes para o dia selecionado
    final dayKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final workouts = workoutDetails[dayKey] ?? [];
    
    if (workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Nenhum detalhe disponível para ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Treinos em ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...workouts.map((workout) {
          return _buildWorkoutListItem(workout);
        }).toList(),
      ],
    );
  }
  
  Widget _buildWorkoutListItem(Map<String, dynamic> workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${workout['time']} • ${workout['duration']} • ${workout['calories']} kcal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Exercícios: ${(workout['exercises'] as List).join(', ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
  
  void _showWorkoutDetails(BuildContext context, DateTime day, List<dynamic> workouts) {
    // Aqui você mostraria um bottom sheet ou diálogo com detalhes completos
    // dos treinos realizados naquele dia
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Treinos em ${DateFormat('dd/MM/yyyy').format(day)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...workouts.map((workoutName) {
                return ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.orange),
                  title: Text(workoutName),
                  subtitle: const Text('Toque para ver detalhes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navegue para os detalhes do treino específico
                    Navigator.pop(context);
                    // Adicione aqui a navegação para a tela de detalhes do treino
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// Painter personalizado para o gráfico
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.deepOrange.withOpacity(0.3),
          Colors.deepOrange.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    const double baseHeight = 90; // Altura base do gráfico
    
    // Pontos do gráfico (simulados)
    final List<double> points = [
      baseHeight - 30, // 3.0 (escala de intensidade)
      baseHeight - 60, // 6.0
      baseHeight - 45, // 4.5
      baseHeight - 80, // 8.0
      baseHeight - 60, // 6.0
      baseHeight - 90, // 9.0
      baseHeight - 105, // 10.5
    ];
    
    // Calcular o espaçamento horizontal
    final double dx = size.width / (points.length - 1);
    
    // Criar o path para a linha
    final Path linePath = Path();
    linePath.moveTo(0, points[0]);
    
    // Adicionar pontos ao path
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(dx * i, points[i]);
    }
    
    // Criar o path para o preenchimento
    final Path fillPath = Path()..addPath(linePath, Offset.zero);
    fillPath.lineTo(size.width, baseHeight);
    fillPath.lineTo(0, baseHeight);
    fillPath.close();
    
    // Desenhar o preenchimento e a linha
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Desenhar pontos no gráfico
    final Paint dotPaint = Paint()
      ..color = Colors.deepOrange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final Paint dotFillPaint = Paint()
      ..color = Colors.white;
    
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(Offset(dx * i, points[i]), 3, dotFillPaint);
      canvas.drawCircle(Offset(dx * i, points[i]), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Provider para fornecer as metas do usuário
final userGoalsProvider = FutureProvider<List<UserGoal>>((ref) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getUserGoals();
});

/// ViewModel para gerenciar o consumo de água
class WaterIntakeViewModel extends StateNotifier<AsyncValue<WaterIntake>> {
  final WaterIntakeRepository _repository;
  AsyncValue<List<WaterIntake>> _history = const AsyncValue.loading();
  AsyncValue<WaterIntakeStats> _stats = const AsyncValue.loading();
  DateTime _selectedDate = DateTime.now();
  
  WaterIntakeViewModel(this._repository) : super(const AsyncValue.loading()) {
    // Carrega os dados iniciais
    loadTodayWaterIntake();
  }
  
  /// Carrega os dados de hoje
  Future<void> loadTodayWaterIntake() async {
    state = const AsyncValue.loading();
    try {
      final waterIntake = await _repository.getTodayWaterIntake();
      state = AsyncValue.data(waterIntake);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Adiciona um copo de água
  Future<void> addGlass() async {
    try {
      // Otimismo da UI: atualiza primeiro para feedback imediato
      final currentIntake = state.value;
      if (currentIntake != null) {
        // Atualiza a UI imediatamente (otimisticamente)
        state = AsyncValue.data(
          currentIntake.copyWith(
            currentGlasses: currentIntake.currentGlasses + 1,
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Faz a chamada real ao repositório
      final updatedIntake = await _repository.addGlass();
      
      // Atualiza com os dados reais do servidor
      state = AsyncValue.data(updatedIntake);
      
      // Atualiza estatísticas se estiverem carregadas
      _refreshStatsIfNeeded();
    } catch (e, stack) {
      // Em caso de erro, reverte para o estado anterior ou mostra erro
      state = AsyncValue.error(e, stack);
      
      // Recarrega os dados corretos
      loadTodayWaterIntake();
    }
  }
  
  /// Remove um copo de água
  Future<void> removeGlass() async {
    try {
      // Otimismo da UI: atualiza primeiro para feedback imediato
      final currentIntake = state.value;
      if (currentIntake != null && currentIntake.currentGlasses > 0) {
        // Atualiza a UI imediatamente (otimisticamente)
        state = AsyncValue.data(
          currentIntake.copyWith(
            currentGlasses: currentIntake.currentGlasses - 1,
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Faz a chamada real ao repositório
      final updatedIntake = await _repository.removeGlass();
      
      // Atualiza com os dados reais do servidor
      state = AsyncValue.data(updatedIntake);
      
      // Atualiza estatísticas se estiverem carregadas
      _refreshStatsIfNeeded();
    } catch (e, stack) {
      // Em caso de erro, reverte para o estado anterior ou mostra erro
      state = AsyncValue.error(e, stack);
      
      // Recarrega os dados corretos
      loadTodayWaterIntake();
    }
  }
  
  /// Atualiza a meta diária
  Future<void> updateDailyGoal(int newGoal) async {
    try {
      // Validação rápida
      if (newGoal <= 0) return;
      
      // Otimismo da UI: atualiza primeiro para feedback imediato
      final currentIntake = state.value;
      if (currentIntake != null) {
        // Atualiza a UI imediatamente (otimisticamente)
        state = AsyncValue.data(
          currentIntake.copyWith(
            dailyGoal: newGoal,
            updatedAt: DateTime.now(),
          ),
        );
      }
      
      // Faz a chamada real ao repositório
      final updatedIntake = await _repository.updateDailyGoal(newGoal);
      
      // Atualiza com os dados reais do servidor
      state = AsyncValue.data(updatedIntake);
      
      // Atualiza estatísticas se estiverem carregadas
      _refreshStatsIfNeeded();
    } catch (e, stack) {
      // Em caso de erro, reverte para o estado anterior ou mostra erro
      state = AsyncValue.error(e, stack);
      
      // Recarrega os dados corretos
      loadTodayWaterIntake();
    }
  }
  
  /// Obtém o histórico de consumo de água
  Future<void> loadHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _history = const AsyncValue.loading();
      
      // Usar datas fornecidas ou padrão (últimos 7 dias)
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 6));
      
      // Carregar histórico
      final history = await _repository.getWaterIntakeHistory(
        startDate: start,
        endDate: end,
      );
      
      _history = AsyncValue.data(history);
    } catch (e, stack) {
      _history = AsyncValue.error(e, stack);
    }
  }
  
  /// Carrega consumo para uma data específica
  Future<void> loadWaterIntakeForDate(DateTime date) async {
    try {
      _selectedDate = date;
      
      // Verificar se é hoje
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      if (isToday) {
        await loadTodayWaterIntake();
        return;
      }
      
      // Definir estado de carregamento
      state = const AsyncValue.loading();
      
      // Buscar dados para a data selecionada
      final intake = await _repository.getWaterIntakeByDate(date);
      
      if (intake != null) {
        state = AsyncValue.data(intake);
      } else {
        // Criar um objeto vazio para a data
        state = AsyncValue.data(WaterIntake(
          id: 'empty-${date.millisecondsSinceEpoch}',
          userId: 'user', // Será substituído pelo ID real
          date: date,
          currentGlasses: 0,
          dailyGoal: 8,
          createdAt: date,
        ));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  /// Carrega estatísticas de consumo
  Future<void> loadStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _stats = const AsyncValue.loading();
      
      // Usar datas fornecidas ou padrão (últimos 30 dias)
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 29));
      
      // Carregar estatísticas
      final stats = await _repository.getWaterIntakeStats(
        startDate: start,
        endDate: end,
      );
      
      _stats = AsyncValue.data(stats);
    } catch (e, stack) {
      _stats = AsyncValue.error(e, stack);
    }
  }
  
  /// Atualiza estatísticas se já tiverem sido carregadas previamente
  void _refreshStatsIfNeeded() {
    if (_stats is! AsyncLoading && _history is! AsyncLoading) {
      loadStats();
      loadHistory();
    }
  }
  
  /// Getter para histórico
  AsyncValue<List<WaterIntake>> get history => _history;
  
  /// Getter para estatísticas
  AsyncValue<WaterIntakeStats> get stats => _stats;
  
  /// Getter para data selecionada
  DateTime get selectedDate => _selectedDate;
}

/// Provider para o ViewModel de consumo de água
final waterIntakeViewModelProvider = StateNotifierProvider<WaterIntakeViewModel, AsyncValue<WaterIntake>>((ref) {
  final repository = ref.watch(waterIntakeRepositoryProvider);
  return WaterIntakeViewModel(repository);
});

/// Provider para acessar diretamente o estado atual de consumo de água
final waterIntakeProvider = Provider<AsyncValue<WaterIntake>>((ref) {
  return ref.watch(waterIntakeViewModelProvider);
});

/// Provider para acessar o histórico de consumo de água
final waterIntakeHistoryProvider = Provider<AsyncValue<List<WaterIntake>>>((ref) {
  return ref.watch(waterIntakeViewModelProvider.notifier).history;
});

/// Provider para acessar estatísticas de consumo de água
final waterIntakeStatsProvider = Provider<AsyncValue<WaterIntakeStats>>((ref) {
  return ref.watch(waterIntakeViewModelProvider.notifier).stats;
}); 