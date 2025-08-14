// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/bottom_navigation_bar.dart';
import '../providers/challenge_providers.dart';
import '../providers/challenge_provider.dart';
import '../models/challenge_progress.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/empty_state.dart';

@RoutePage()
class ChallengeCompletedScreen extends ConsumerStatefulWidget {
  const ChallengeCompletedScreen({super.key});

  @override
  ConsumerState<ChallengeCompletedScreen> createState() => _ChallengeCompletedScreenState();
}

class _ChallengeCompletedScreenState extends ConsumerState<ChallengeCompletedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Banner superior como SliverAppBar que desaparece ao rolar
          SliverAppBar(
            expandedHeight: screenHeight * 0.25,
            floating: true,
            pinned: false,
            snap: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.orange,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.orange,
                      AppColors.orange.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Imagem de fundo do banner
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/logos/app/headerdesafio.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // Overlay gradiente para melhor legibilidade
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Removido o texto "Desafio" - apenas a imagem de fundo
                  ],
                ),
              ),
            ),
          ),
          
          // Conteúdo principal como SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  
                  // Título de parabéns
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.orange.withOpacity(0.1),
                          AppColors.purple.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '🎉 Desafio concluído!',
                      style: TextStyle(
                        fontFamily: 'StingerTrial',
                        color: AppColors.textDark,
                        fontSize: 26,
                        fontWeight: FontWeight.w200,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Parabéns por ter chegado até o fim!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Card de informação principal
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.purple.withOpacity(0.08),
                          AppColors.orange.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.purple.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                color: AppColors.orange,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aguardando Resultado',
                                    style: TextStyle(
                                      fontFamily: 'StingerTrial',
                                      color: AppColors.textDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Agora é só aguardar enquanto conferimos todos os exercícios enviados para divulgar os vencedores e o ranking oficial 🏆✨',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: AppColors.darkGray,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Lista de participantes
                  _buildParticipantsList(context, ref),
                  
                  const SizedBox(height: 32),
                  
                  // Botão de suporte
                  _buildSupportButton(),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: -1),
    );
  }
  
  /// Constrói a lista de participantes do desafio Ray 21
  Widget _buildParticipantsList(BuildContext context, WidgetRef ref) {
    // ID do desafio Ray 21
    const challengeId = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';
    
    final challengeProgressAsync = ref.watch(challengeProgressProvider(challengeId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          'Participantes do Desafio',
          style: TextStyle(
            fontFamily: 'StingerTrial',
            color: Color(0xFFF38638),
            fontSize: 22,
            fontWeight: FontWeight.w200,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        
        // Barra de pesquisa
        _buildSearchBar(),
        const SizedBox(height: 16),
        
        // Lista de participantes
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: challengeProgressAsync.when(
            data: (participants) {
              if (participants.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: EmptyState(
                    icon: Icons.people_outline,
                    message: 'Nenhum participante encontrado',
                  ),
                );
              }
              
              // Filtrar participantes por pesquisa
              var filteredParticipants = participants.where((participant) {
                return participant.userName.toLowerCase().contains(_searchQuery);
              }).toList();
              
              // Ordenar participantes alfabeticamente
              final sortedParticipants = List<ChallengeProgress>.from(filteredParticipants)
                ..sort((a, b) => a.userName.toLowerCase().compareTo(b.userName.toLowerCase()));
              
              // Se não há participantes após a filtragem, mostrar estado vazio específico para pesquisa
              if (sortedParticipants.isEmpty && _searchQuery.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum participante encontrado para "$_searchQuery"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        child: const Text('Limpar pesquisa'),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedParticipants.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final participant = sortedParticipants[index];
                  return _buildParticipantTile(context, participant);
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32.0),
              child: LoadingIndicator(),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: EmptyState(
                icon: Icons.error_outline,
                message: 'Erro ao carregar participantes: $error',
                actionLabel: 'Tentar novamente',
                onAction: () => ref.refresh(challengeProgressProvider(challengeId)),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Constrói um tile para cada participante
  Widget _buildParticipantTile(BuildContext context, ChallengeProgress participant) {
    return InkWell(
      onTap: () {
        // Navegar para tela de treinos do usuário específico no desafio
        context.router.push(UserChallengeWorkoutsRoute(
          challengeId: participant.challengeId,
          userId: participant.userId,
          userName: participant.userName,
        ));
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar do usuário
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.orange.withOpacity(0.1),
              backgroundImage: participant.userPhotoUrl != null 
                  ? NetworkImage(participant.userPhotoUrl!)
                  : null,
              child: participant.userPhotoUrl == null
                  ? Text(
                      participant.userName.isNotEmpty 
                          ? participant.userName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Informações do participante
            Expanded(
              child: Center(
                child: Text(
                  participant.userName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textDark,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            
            // Ícone de seta
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a barra de pesquisa
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar participante...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Constrói o botão de suporte
  Widget _buildSupportButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _openWhatsAppSupport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366), // Cor oficial do WhatsApp
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Suporte - Problemas com treinos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre o WhatsApp para suporte
  Future<void> _openWhatsAppSupport() async {
    const url = 'https://wa.me/5531997940477?text=Ol%C3%A1%21%20Estou%20enfrentando%20dificuldades%20com%20meus%20treinos%20no%20app%20e%20preciso%20de%20ajuda%2C%20por%20favor.';
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir suporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 