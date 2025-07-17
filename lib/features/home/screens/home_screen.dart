// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/widgets/youtube_thumbnail_widget.dart';
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/home/viewmodels/home_view_model.dart';
import 'package:ray_club_app/features/home/widgets/youtube_player_widget.dart';

import 'package:ray_club_app/shared/bottom_navigation_bar.dart';
import 'package:ray_club_app/features/profile/providers/profile_providers.dart';
import 'package:ray_club_app/features/subscription/widgets/premium_feature_gate.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';
import 'package:ray_club_app/features/home/providers/home_workout_provider.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/providers/user_access_provider.dart';
import 'package:ray_club_app/features/workout/screens/workout_video_detail_screen.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart' as profile_providers;
import 'package:ray_club_app/core/services/user_verification_service.dart';
import 'package:ray_club_app/features/workout/screens/workout_video_detail_screen.dart';

/**
 * HomeScreen - Tela principal do aplicativo
 * 
 * NOVA ESTRUTURA DE PARCEIROS:
 * =============================
 * 
 * Esta tela foi atualizada para incluir uma nova estrutura de parceiros organizados
 * na seguinte ordem específica:
 * 
 * 1. Treinos de Musculação
 *    - Conheça nossa personal
 *    - Semana 1, 2, 3
 *    - Categoria: 'musculação'
 * 
 * 2. Goya Health Club  
 *    - Apresentação Pilates
 *    - Comece por aqui
 *    - Mat pilates, Pilates com mini band, Pilates com peso
 *    - Categoria: 'pilates'
 * 
 * 3. Fight Fit
 *    - Apresentação Fight Fit
 *    - Comece por aqui
 *    - Fullbody, Inferiores, Superiores, Abdominal
 *    - Categoria: 'funcional'
 * 
 * 4. Bora Assessoria
 *    - Apresentação
 *    - Dicas, Planilhas
 *    - Categoria: 'corrida'
 * 
 * 5. The Unit
 *    - Apresentação
 *    - Testes, Mobilidade, Fortalecimento
 *    - Categoria: 'fisioterapia'
 * 
 * FUNCIONALIDADES:
 * ================
 * 
 * - Cada conteúdo possui link do YouTube (youtubeUrl)
 * - Cards têm ícone do YouTube quando possuem vídeo
 * - Clique no card abre player do YouTube em modal
 * - Botão "Ver Todos" navega para treinos com filtro da categoria
 * - Consistência visual mantida com resto do app
 * - Descrições para filtragem por categoria, tempo e nível
 * 
 * NAVEGAÇÃO:
 * ==========
 * 
 * - Parceiros redirecionam para tela de treinos (/workouts)
 * - Filtro automático aplicado conforme categoria do parceiro
 * - Novas categorias adicionadas ao sistema: musculação, fisioterapia
 * - Sistema de filtros integrado com as categorias existentes
 */





@RoutePage()
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Key for the scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    
    // Verificar usuário assim que a tela carrega
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserVerificationService.verifyUserOnAppStart(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final profileState = ref.watch(currentProfileProvider);

    // Variável removida: isGuest (não utilizada)
    
    // Nome do usuário (para personalização) - preferir dados do perfil
    final String username = profileState.when(
      data: (profile) => profile?.name?.split(' ')[0] ?? "Raymember",
      loading: () => authState.maybeWhen(
        authenticated: (user) => user.name?.split(' ')[0] ?? "Raymember",
        orElse: () => "Raymember"
      ),
      error: (_, __) => authState.maybeWhen(
        authenticated: (user) => user.name?.split(' ')[0] ?? "Raymember",
        orElse: () => "Raymember"
      ),
    );

    // URL da foto do usuário (usar dados do perfil que são mais atualizados)
    final String? photoUrl = profileState.when(
      data: (profile) => profile?.photoUrl,
      loading: () => authState.maybeWhen(
        authenticated: (user) => user.photoUrl,
        orElse: () => null
      ),
      error: (_, __) => authState.maybeWhen(
        authenticated: (user) => user.photoUrl,
        orElse: () => null
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F7),
      extendBodyBehindAppBar: true,
      drawer: _buildDrawer(context, username, photoUrl, ref),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.data != null
              ? _buildHomeContent(context, username, photoUrl, homeState.data!)
              : _buildErrorView(context, homeState.error ?? 'Sem dados disponíveis', ref),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildDrawer(BuildContext context, String username, String? photoUrl, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFFAA9182), // Tom marrom conforme imagem de referência
      child: SafeArea(
        child: Column(
          children: [
            // Header com botão de fechar, perfil do usuário e botão de edição
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  // Botão de fechar no canto superior direito
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white, size: 28),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Foto de perfil e nome do usuário
                  Row(
                    children: [
                      // Foto de perfil
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: photoUrl != null 
                            ? NetworkImage(photoUrl) 
                            : null,
                        child: photoUrl == null
                            ? Text(
                                username.isNotEmpty ? username[0].toUpperCase() : "R",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Nome do usuário e botão de editar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi $username',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                context.router.pushNamed('/profile');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
            
            // Linha de separação
            const Divider(height: 1, color: Colors.white24),
            
            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const DashboardRoute());
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.fitness_center,
                    title: 'Dashboard Fitness',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.router.push(const FitnessDashboardRoute());
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.fitness_center_outlined,
                    title: 'Treinos',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateTo(context, AppRoutes.workout);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Nutrição',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateTo(context, AppRoutes.nutrition);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Desafio Ray 21'),
                    onTap: () {
                      Navigator.pop(context);
                      AppNavigator.navigateToChallenges(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.card_giftcard_outlined,
                    title: 'Benefícios',
                    onTap: () {
                      // Verificar acesso antes de navegar
                      final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
                      if (hasAccess) {
                        context.router.replaceNamed('/benefits');
                      } else {
                        // Mostrar tela de bloqueio
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: ProgressGate(
                              featureKey: 'detailed_reports',
                              progressTitle: 'Benefícios Exclusivos',
                              progressDescription: 'Continue evoluindo para desbloquear acesso aos benefícios exclusivos dos nossos parceiros.',
                              child: const SizedBox.shrink(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.event_outlined,
                    title: 'Eventos',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateToEvents(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Configurações',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateToSettings(context);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ajuda',
                    onTap: () {
                      Navigator.of(context).pop();
                      AppNavigator.navigateToHelp(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Botão de logout no rodapé
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();
                  
                  // Mostrar indicador de carregamento
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saindo...'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                  
                  // Fazer logout usando o AuthViewModel
                  await ref.read(authViewModelProvider.notifier).signOut();
                  
                  // Navegar para tela de login
                  context.router.replaceNamed('/login');
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }

  // Conteúdo principal da tela
  Widget _buildHomeContent(BuildContext context, String username, String? photoUrl, HomeData data) {
    // Determinar posição exata da linha divisória
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerHeight = 80.0; // Altura do header (sem incluir a statusbar)
    final double dividerPosition = statusBarHeight + headerHeight;
    
    return Stack(
      children: [
        // Conteúdo principal com rolagem
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header dinâmico que desaparece com a rolagem
            SliverAppBar(
              expandedHeight: headerHeight,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.transparent,
              elevation: 0, 
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logos/app/novaheader.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Linha superior com menu e notificações
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.menu, color: Color(0xFFF8F1E7), size: 28),
                                onPressed: () {
                                  if (_scaffoldKey.currentState != null) {
                                    _scaffoldKey.currentState!.openDrawer();
                                  }
                                },
                              ),
                              // Espaço central
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Color(0xFFF8F1E7), size: 28),
                                onPressed: () {
                                  // Navegar para notificações
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Conteúdo principal
            SliverList(
              delegate: SliverChildListDelegate([
                // Título e subtítulo movidos para cá
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Row(
                    children: [
                      // Foto do usuário
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null || photoUrl.isEmpty
                            ? Text(
                                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Saudação e subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, $username',
                              style: const TextStyle(
                                fontFamily: 'Stinger',
                                color: Color(0xFF333333),
                                fontSize: 24,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Pronto(a) pra se desafiar hoje?',
                              style: TextStyle(
                                fontFamily: 'CenturyGothic',
                                color: Color(0xFF666666),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // NOVO: Grid de acesso rápido
                _buildQuickAccessGrid(context, ref),
                
                // NOVO: Widget de Onboarding
                _buildOnboardingWidget(context),
                

                
                // NOVO: Seções completas de treinos por categoria
                _buildCompleteWorkoutSections(context, ref),
                
                const SizedBox(height: 24),
              ]),
            ),
          ],
        ),
        
        // Efeito de blur fixo e linha divisória - ficam por cima do conteúdo mas não rolam
        Consumer(
          builder: (context, ref, _) {
            // Usar o NotificationListener para detectar a rolagem
            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                // Atualize o estado de scrollOffset em um provider, se necessário
                // (pode ser implementado em uma versão futura)
                return false;
              },
              child: Builder(
                builder: (context) {
                  // Controlar a opacidade com base na posição do scroll
                  return Positioned(
                    top: dividerPosition,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.0, // Alterado para 0.0 para ficar totalmente transparente
                      child: Stack(
                        children: [
                          // Efeito de blur
                          Container(
                            height: 2, // Reduzido para uma linha mais fina
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          
                          // Linha divisória bem fina com gradiente
                          Container(
                            height: 0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFFE78639).withOpacity(0.1),
                                  const Color(0xFFCDA8F0).withOpacity(0.2),
                                  const Color(0xFFE78639).withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // NOVO: Grid de acesso rápido
  Widget _buildQuickAccessGrid(BuildContext context, WidgetRef ref) {
    // Definição das ações rápidas e cores
    final quickActions = [
      {
        'title': 'Treinos',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFF38638), // Nova cor laranja
        'route': () => context.router.replaceNamed('/workouts'),
      },
      {
        'title': 'Meu Perfil',
        'icon': Icons.person_rounded,
        'color': const Color(0xFFFEDC94), // Nova cor amarelo claro
        'route': () => context.router.pushNamed('/profile'),
      },
      {
        'title': 'Desafios',
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFFEFB9B7), // Nova cor lilás
        'route': () => context.router.push(const ChallengesListRoute()),
      },
      {
        'title': 'Nutrição',
        'icon': Icons.restaurant_menu_rounded,
        'color': const Color(0xFFCDA8F0), // Nova cor rosa
        'route': () => context.router.replaceNamed('/nutrition'),
      },
      {
        'title': 'Benefícios',
        'icon': Icons.card_giftcard_rounded,
        'color': const Color(0xFFF38638), // Repetição da primeira cor
        'route': () {
          // Verificar acesso antes de navegar
          final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
          if (hasAccess) {
            context.router.replaceNamed('/benefits');
          } else {
            // Mostrar diálogo de evolução
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (dialogContext) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header com botão de fechar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFE78639),
                              const Color(0xFFCDA8F0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Benefícios Especiais',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      // Conteúdo
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Ilustração
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE78639).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.card_giftcard,
                                size: 60,
                                color: Color(0xFFE78639),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Descrição
                            const Text(
                              'Continue evoluindo em sua jornada para desbloquear benefícios especiais dos nossos parceiros.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Botão
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE78639),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Entendi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      },
      {
        'title': 'Eventos',
        'icon': Icons.event_rounded,
        'color': const Color(0xFFFEDC94), // Repetição da segunda cor
        'route': () => AppNavigator.navigateToEvents(context),
      },
      {
        'title': 'Cupons',
        'icon': Icons.local_offer_rounded,
        'color': const Color(0xFFEFB9B7), // Cor rosa para cupons
        'route': () => context.router.pushNamed('/cupons'),
      },
    ];

    return Container(
      margin: const EdgeInsets.only(top: 20), // Reduced top margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(
              'Explorar',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF333333),
                fontFamily: 'CenturyGothic',
              ),
            ),
          ),
          SizedBox(
            height: 90, // Reduced height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return Container(
                  width: 75,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == quickActions.length - 1 ? 0 : 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ícone circular com cor sólida (sem imagem)
                      InkWell(
                        onTap: action['route'] as Function(),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: action['color'] as Color,
                          ),
                          child: Center(
                            child: Icon(
                              action['icon'] as IconData,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced spacing
                      // Título da ação com proteção contra overflow
                      SizedBox(
                        width: 75,
                        child: Text(
                          action['title'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4D4D4D),
                            fontFamily: 'CenturyGothic',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // NOVO: Widget de Onboarding
  Widget _buildOnboardingWidget(BuildContext context) {
    // Lista de imagens do banner do projeto 7 dias
    final bannerImages = [
      'assets/images/logos/app/projeto 7 dias.png',
      'assets/images/logos/app/projeto 7 dias 2.png',
      'assets/images/logos/app/projeto 7 dias 3.png',
    ];

    // Lista de itens de onboarding focados no Desafio Ray de 21 dias
    final onboardingItems = [
      {
        'title': 'Regras',
        'description': 'Conheça as regras do desafio',
        'icon': Icons.rule_folder,
        'color': const Color(0xFFFF8A80),
        'bgColor': const Color(0xFFFFEBEE),
        'action': 'Ver regras',
        'type': 'image',
        'imageAsset': 'assets/Imagem.jpeg',
        'onTap': () => _showImageDialog(context, 'assets/Imagem.jpeg'),
      },
      {
        'title': 'Pontuação',
        'description': 'Veja a pontuação do desafio',
        'icon': Icons.leaderboard,
        'color': const Color(0xFFFFC069),
        'bgColor': const Color(0xFFFFF8E1),
        'action': 'Ver pontuação',
        'type': 'link',
        'url': 'https://docs.google.com/spreadsheets/d/1-WGqc7WNi_9ojN9n4EINMK90AYPdYnonMZnMwXwHHkA/edit?usp=sharing',
        'onTap': () => _launchURL('https://docs.google.com/spreadsheets/d/1-WGqc7WNi_9ojN9n4EINMK90AYPdYnonMZnMwXwHHkA/edit?usp=sharing'),
      },
      {
        'title': 'Comunidade',
        'description': 'Entre no grupo do WhatsApp',
        'icon': Icons.group,
        'color': const Color(0xFF25D366),
        'bgColor': const Color(0xFFE8F5E9),
        'action': 'Entrar no grupo',
        'type': 'link',
        'url': 'https://chat.whatsapp.com/JC7jjgxPV5O9MhA6Abzil8',
        'onTap': () => _launchURL('https://chat.whatsapp.com/JC7jjgxPV5O9MhA6Abzil8'),
      },
    ];

    // Controller para PageView
    final PageController pageController = PageController(viewportFraction: 0.93);
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
        
        // Carrossel unificado com banner principal e cards informativos
        SizedBox(
          height: 260, // Reduzido ainda mais o tamanho do carrossel de desafio
          child: PageView.builder(
            controller: pageController,
            itemCount: bannerImages.length + onboardingItems.length, // 3 banners + cards informativos
            padEnds: false,
              itemBuilder: (context, index) {
                              // Primeiros itens são as imagens do banner
              if (index < bannerImages.length) {
                return Container(
                  margin: EdgeInsets.fromLTRB(
                    index == 0 ? 24 : 12, // Primeira imagem tem margin maior à esquerda
                    0, 
                    index == bannerImages.length - 1 ? 12 : 12, // Última imagem do banner
                    0
                  ),
                  height: 260, // Tamanho reduzido para o banner
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.router.push(const ChallengesListRoute()),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Imagem de fundo
                            Image.asset(
                              bannerImages[index],
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              
              // Restante dos itens são os cards informativos
              final itemIndex = index - bannerImages.length; // Ajustar índice para os cards informativos
              final item = onboardingItems[itemIndex];
              return Container(
                margin: index == bannerImages.length + onboardingItems.length - 1
                  ? const EdgeInsets.fromLTRB(0, 0, 24, 0) // Último item
                  : const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: item['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logos/app/Ray Club-25.png'),
                    fit: BoxFit.cover,
                    opacity: 0.15,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Ícone lado esquerdo
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Conteúdo lado direito
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['description'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF666666),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: item['onTap'] as Function(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: item['color'] as Color,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  minimumSize: const Size(100, 36),
                                ),
                                child: Text(
                                  item['action'] as String,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Indicador de página
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Center(
            child: SmoothPageIndicator(
              controller: pageController,
              count: bannerImages.length + onboardingItems.length, // 3 banners + cards informativos
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
                radius: 4,
                dotColor: Colors.grey.shade300,
                activeDotColor: const Color(0xFFBF8F5C),
              ),
            ),
          ),
        ),
      ],
    )
    );
  }

  // NOVO: Seção de parceiros RayClub
  Widget _buildPartnersSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção com proteção contra overflow
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Row(
              children: [
                const Text(
                  '🤝 ',
                  style: TextStyle(fontSize: 24),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Parceiros ',
                          style: TextStyle(
                            fontFamily: 'Stinger',
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            color: Color(0xFF333333),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Flexible(
                        child: Text(
                          'RayClub',
                          style: TextStyle(
                            fontFamily: 'Stinger',
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                            color: Color(0xFFE78639),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Card simples dos parceiros
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE78639).withOpacity(0.1),
                  const Color(0xFFCDA8F0).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE78639).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE78639).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group,
                        color: Color(0xFFE78639),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nossos Parceiros',
                            style: TextStyle(
                              fontFamily: 'Stinger',
                              fontSize: 18,
                              fontWeight: FontWeight.w100,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Especialistas em cada modalidade',
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 14,
                              color: Color(0xFF777777),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cada treino é desenvolvido por profissionais especializados em suas áreas, garantindo qualidade e resultados.',
                  style: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // NOVO: Seções completas de treinos por categoria
  Widget _buildCompleteWorkoutSections(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final homeWorkoutVideosAsync = ref.watch(homeWorkoutVideosProvider);
        
        return homeWorkoutVideosAsync.when(
          data: (studios) {
            if (studios.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seções por categoria conforme a estrutura solicitada
                ...studios.map((studio) => _buildCategorySection(context, ref, studio)),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Carregando treinos...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
        );
      },
    );
  }

  // Método para construir cada seção de categoria com design minimalista
  Widget _buildCategorySection(BuildContext context, WidgetRef ref, HomePartnerStudio studio) {
    // Organizar vídeos em grupos de 3
    final allVideos = studio.videos;
    final videosPerPage = 3;
    final totalPages = (allVideos.length / videosPerPage).ceil();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da categoria - design mais clean com proteção contra overflow
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    studio.name,
                    style: const TextStyle(
                      fontFamily: 'CenturyGothic',
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                      color: Color(0xFF1F1F1F),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Botão "Ver Todos" mais sutil com proteção
                Flexible(
                  child: GestureDetector(
                    onTap: () => _navigateToCategory(context, ref, studio.workoutCategory),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            'Ver todos',
                            style: TextStyle(
                              fontFamily: 'CenturyGothic',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[600],
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Se tem mais de 3 vídeos, usar PageView horizontal; senão, lista vertical simples
          if (allVideos.length <= 3)
            // Lista vertical simples para 3 ou menos vídeos
            ...allVideos.asMap().entries.map((entry) {
              final index = entry.key;
              final video = entry.value;
              return _buildMinimalistVideoCard(context, ref, video, studio, index);
            })
          else
            // Column para PageView + indicador
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // PageView horizontal para mais de 3 vídeos
                SizedBox(
                  height: 376, // Altura ajustada: 3 cards de 120px + 2 margins de 8px + padding extra = 376px
                  child: PageView.builder(
                    itemCount: totalPages,
                    padEnds: false,
                    pageSnapping: true,
                    controller: PageController(viewportFraction: 0.92), // Mostrar um pouco da próxima página
                    itemBuilder: (context, pageIndex) {
                      final startIndex = pageIndex * videosPerPage;
                      final endIndex = (startIndex + videosPerPage).clamp(0, allVideos.length);
                      final pageVideos = allVideos.sublist(startIndex, endIndex);
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: pageVideos.asMap().entries.map((entry) {
                            final index = entry.key + startIndex;
                            final video = entry.value;
                            final isLastInPage = entry.key == pageVideos.length - 1;
                            return _buildMinimalistVideoCardWithMargin(context, ref, video, studio, index, isLastInPage);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ),
                
                // Indicador de treinos total
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_left,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${allVideos.length} treinos disponíveis',
                          style: TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.swipe_right,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // Método para obter imagem de fundo baseada no ID do estúdio
  String? _getStudioBackgroundImage(String studioId) {
    switch (studioId) {
      case 'musculacao':
        return 'assets/images/categories/IMG_1469.jpg';
      case 'pilates':
        return 'assets/images/categories/IMG_1472.jpg';
      case 'funcional':
        return 'assets/images/categories/IMG_1488.jpg';
      case 'corrida':
        return 'assets/images/categories/IMG_1516.jpg';
      case 'fisioterapia':
        return 'assets/images/categories/IMG_1536.jpg';
      default:
        return null;
    }
  }

  // MÉTODO COMENTADO TEMPORARIAMENTE - Usando thumbnails do YouTube
  // Método para obter imagem de fundo variável para cada vídeo do estúdio
  /*String? _getVideoBackgroundImage(String studioId, int videoIndex) {
    final images = _getStudioBackgroundImages(studioId);
    if (images.isEmpty) return null;
    return images[videoIndex % images.length];
  }

  // Método para obter lista de imagens por estúdio (várias imagens por categoria)
  List<String> _getStudioBackgroundImages(String studioId) {
    switch (studioId) {
      case 'musculacao':
        return [
          'assets/images/categories/IMG_1469.jpg',
          'assets/images/categories/IMG_1472.jpg',
          'assets/images/categories/IMG_1488.jpg',
        ];
      case 'pilates':
        return [
          'assets/images/categories/IMG_1516.jpg',
          'assets/images/categories/IMG_1536.jpg',
          'assets/images/categories/IMG_1637.jpg',
        ];
      case 'funcional':
        return [
          'assets/images/categories/IMG_1660.jpg',
          'assets/images/categories/IMG_1613.jpg',
          'assets/images/categories/IMG_1707.jpg',
        ];
      case 'corrida':
        return [
          'assets/images/categories/IMG_1710.jpg',
          'assets/images/categories/IMG_1718.jpg',
          'assets/images/categories/IMG_1752.jpg',
        ];
      case 'fisioterapia':
        return [
          'assets/images/categories/IMG_7008.jpg',
        ];
      default:
        return [];
    }
  }*/

  // Método para construir card de vídeo minimalista com controle de margin
  Widget _buildMinimalistVideoCardWithMargin(BuildContext context, WidgetRef ref, dynamic video, HomePartnerStudio studio, int videoIndex, bool isLastInPage) {
    // ✅ Verificação instantânea com novo provider
    final canAccess = _checkVideoAccess(ref, video.id);
        
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // ✅ Garantir que toda a área seja clicável
          onTap: () async {
            try {
              debugPrint('🎬 [DEBUG] ========== CLIQUE DETECTADO ==========');
              debugPrint('🎬 [DEBUG] Vídeo: ${video.title}');
              debugPrint('🎬 [DEBUG] YouTube URL: ${video.youtubeUrl}');
              debugPrint('🎬 [DEBUG] Tem PDF: ${video.hasPdfMaterials}');
              
              // ✨ NOVA LÓGICA: Se tem PDF, navegar para WorkoutVideoDetailScreen
              if (video.hasPdfMaterials == true) {
                debugPrint('🎬 [DEBUG] Navegando para WorkoutVideoDetailScreen (tem PDF)...');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutVideoDetailScreen(video: video),
                  ),
                );
              } else {
                debugPrint('🎬 [DEBUG] Chamando ExpertVideoGuard.handleVideoTap (sem PDF)...');
                // Usar verificação expert rigorosa para vídeos sem PDF
                await ExpertVideoGuard.handleVideoTap(
                  context,
                  ref,
                  video.youtubeUrl ?? 'unknown',  // ✅ CORRIGIDO: usar apenas youtubeUrl
                  () => _openVideoPlayer(context, video),
                );
              }
              
              debugPrint('🎬 [DEBUG] ========== FIM DO CLIQUE ==========');
            } catch (e, stackTrace) {
              debugPrint('🚨 [ERROR] Erro no clique do vídeo: $e');
              debugPrint('🚨 [ERROR] Stack trace: $stackTrace');
              debugPrint('🚨 [ERROR] Video data: ${video.toString()}');
            }
          },
          child: Container(
            height: 120,
            margin: EdgeInsets.fromLTRB(20, 0, 20, isLastInPage ? 0 : 8), // Remove margin bottom do último card e reduz margins
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Usar thumbnail do YouTube se disponível, senão gradiente
                  if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
                    Image.network(
                      video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              studio.logoColor.withOpacity(0.8),
                              studio.logoColor.withOpacity(0.6),
                              studio.logoColor.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Fallback gradiente se não houver thumbnail
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            studio.logoColor.withOpacity(0.8),
                            studio.logoColor.withOpacity(0.6),
                            studio.logoColor.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  
                  // Overlay escuro para legibilidade do texto
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(canAccess ? 0.1 : 0.4),
                          Colors.black.withOpacity(canAccess ? 0.4 : 0.6),
                        ],
                      ),
                    ),
                  ),
                  
                  // Conteúdo do card com proteção contra overflow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Ícone do YouTube e duração no topo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Ícone do YouTube no canto superior esquerdo
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: canAccess 
                                    ? const Color(0xFFFF0000).withOpacity(0.9) 
                                    : Colors.grey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                canAccess ? Icons.play_arrow : Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            
                            // ✨ NOVO: Indicador de PDF no meio
                            if (video.hasPdfMaterials == true)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Color(0xFFE74C3C),
                                  size: 16,
                                ),
                              ),
                            
                            // Duração no canto superior direito
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                video.duration ?? '0 min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CenturyGothic',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Título centralizado verticalmente
                        Expanded(
                          child: Center(
                            child: Text(
                              video.title ?? 'Sem título',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'CenturyGothic',
                                letterSpacing: -0.2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Badge de acesso Expert para vídeos bloqueados
                        if (!canAccess)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE78639),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'EXPERT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Ícones do canto superior direito
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✨ NOVO: Indicador de PDF
                        if (video.hasPdfMaterials == true)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.picture_as_pdf,
                              color: Color(0xFFE74C3C),
                              size: 16,
                            ),
                          ),
                        
                        // Ícone do YouTube
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  // Método para construir card de vídeo minimalista com proteção contra overflow
  Widget _buildMinimalistVideoCard(BuildContext context, WidgetRef ref, dynamic video, HomePartnerStudio studio, int videoIndex) {
    // Comentado temporariamente o uso das imagens locais para usar thumbnails do YouTube
    // final backgroundImage = _getVideoBackgroundImage(studio.id, videoIndex);
    
    // ✅ Verificação instantânea com novo provider
    final canAccess = _checkVideoAccess(ref, video.id);
        
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // ✅ Garantir que toda a área seja clicável
          onTap: () async {
            try {
              debugPrint('🎬 [DEBUG] ========== CLIQUE DETECTADO ==========');
              debugPrint('🎬 [DEBUG] Vídeo: ${video.title}');
              debugPrint('🎬 [DEBUG] YouTube URL: ${video.youtubeUrl}');
              
              // 🎯 NOVA LÓGICA: Se o vídeo tem PDF, navegar para tela de detalhes
              // Se não tem PDF, abrir player direto (comportamento antigo)
              if (video.hasPdfMaterials == true) {
                debugPrint('🎬 [DEBUG] Vídeo tem PDF - navegando para tela de detalhes');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutVideoDetailScreen(video: video),
                  ),
                );
              } else {
                debugPrint('🎬 [DEBUG] Vídeo sem PDF - abrindo player direto');
                // Usar verificação expert rigorosa
                await ExpertVideoGuard.handleVideoTap(
                  context,
                  ref,
                  video.youtubeUrl ?? 'unknown',
                  () => _openVideoPlayer(context, video),
                );
              }
              
              debugPrint('🎬 [DEBUG] ========== FIM DO CLIQUE ==========');
            } catch (e, stackTrace) {
              debugPrint('🚨 [ERROR] Erro no clique do vídeo: $e');
              debugPrint('🚨 [ERROR] Stack trace: $stackTrace');
              debugPrint('🚨 [ERROR] Video data: ${video.toString()}');
            }
          },
          child: Container(
            height: 120,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Usar thumbnail do YouTube se disponível, senão gradiente
                  if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
                    Image.network(
                      video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              studio.logoColor.withOpacity(0.8),
                              studio.logoColor.withOpacity(0.6),
                              studio.logoColor.withOpacity(0.9),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Fallback gradiente se não houver thumbnail
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            studio.logoColor.withOpacity(0.8),
                            studio.logoColor.withOpacity(0.6),
                            studio.logoColor.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  
                  // Overlay escuro para legibilidade do texto
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(canAccess ? 0.1 : 0.4),
                          Colors.black.withOpacity(canAccess ? 0.4 : 0.6),
                        ],
                      ),
                    ),
                  ),
                  
                  // Conteúdo do card com proteção contra overflow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Ícone do YouTube e duração no topo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Ícone do YouTube no canto superior esquerdo
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: canAccess 
                                    ? const Color(0xFFFF0000).withOpacity(0.9) 
                                    : Colors.grey.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                canAccess ? Icons.play_arrow : Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            
                            // ✨ NOVO: Indicador de PDF no meio
                            if (video.hasPdfMaterials == true)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf,
                                  color: Color(0xFFE74C3C),
                                  size: 16,
                                ),
                              ),
                            
                            // Duração no canto superior direito
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                video.duration ?? '0 min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CenturyGothic',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 6),
                        
                        // Título centralizado verticalmente
                        Expanded(
                          child: Center(
                            child: Text(
                              video.title ?? 'Sem título',
                              style: TextStyle(
                                color: canAccess ? Colors.white : Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'CenturyGothic',
                                letterSpacing: -0.2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Badge de acesso Expert para vídeos bloqueados
                        if (!canAccess)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE78639),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'EXPERT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }



  // Método para navegar para categoria específica
  void _navigateToCategory(BuildContext context, WidgetRef ref, String category) {
    context.router.pushNamed('/workouts?category=$category');
  }

  // Método para abrir player de vídeo - SEM DUPLA VERIFICAÇÃO
  // ✅ Este método já é chamado APENAS após verificação expert em handleVideoTap
  void _openVideoPlayer(BuildContext context, dynamic video) {
    debugPrint('🎬 [_openVideoPlayer] Abrindo player para: ${video.title}');
    debugPrint('🎬 [_openVideoPlayer] YouTube URL: ${video.youtubeUrl}');
    
    if (video.youtubeUrl != null && video.youtubeUrl!.isNotEmpty) {
      try {
        // ✅ Abrir player diretamente - verificação expert já foi feita
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => YouTubePlayerWidget(
              videoUrl: video.youtubeUrl!,
              title: video.title ?? 'Vídeo de Treino',
              description: video.description ?? video.instructorName,
              onClose: () => Navigator.pop(context),
            ),
          ),
        );
      } catch (e) {
        debugPrint('Erro ao abrir player do YouTube: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o vídeo. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Fallback caso não tenha URL do YouTube
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vídeo não disponível no momento'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Método auxiliar para mapear categoria para nome amigável
  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'musculação':
        return '💪 Treinos de Musculação';
      case 'pilates':
        return '🧘 Goya Pilates';
      case 'funcional':
        return '🥊 Fight Fit';
      case 'corrida':
        return '🏃 Bora Running';
      case 'fisioterapia':
        return '🏥 The Unit - Fisioterapia';
      case 'flexibilidade':
        return '🤸 Flexibilidade';
      default:
        return category.toUpperCase();
    }
  }

  // Método para navegar para vídeos de uma seção específica
  void _navigateToSectionVideos(BuildContext context, WidgetRef ref, WorkoutSection section) {
    // Por enquanto, navegar para a tela de treinos com filtro
    // Futuramente pode ser uma tela específica da seção
    context.router.pushNamed('/workouts');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navegando para ${section.name} - ${section.videos.length} vídeos'),
        backgroundColor: const Color(0xFFE78639),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método auxiliar para navegação para treinos com filtro da categoria do estúdio
  void _navigateToWorkoutsByCategory(BuildContext context, WidgetRef ref, String category) async {
    try {
      // Mapear categoria para nome amigável
      String categoryName = _getCategoryDisplayName(category);
      
      // Navegar para a tela específica de vídeos da categoria usando o caminho
      final path = '/workouts/videos/$category';
      context.router.pushNamed(path);
      
      // Mostrar mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navegando para $categoryName'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      debugPrint('Erro ao navegar para treinos de $category: $e');
      // Fallback para navegação simples
      context.router.pushNamed('/workouts');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar $category. Navegando para treinos...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Método auxiliar para abrir player do YouTube com verificação de evolução
  void _openYouTubePlayerFromVideo(BuildContext context, WorkoutVideo video, WidgetRef ref) {
    if (video.youtubeUrl == null || video.youtubeUrl!.isEmpty) return;
    
    // Verificar se usuário evoluiu o suficiente para interagir
    final hasEvolved = ref.read(hasEvolvedEnoughProvider);
    
    if (hasEvolved) {
      // Usuário evoluiu o suficiente - abrir player normalmente
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => YouTubePlayerWidget(
            videoUrl: video.youtubeUrl!,
            title: video.title,
            description: video.description,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      // Usuário ainda não evoluiu o suficiente - mostrar mensagem motivacional
      _showEvolutionDialogFromVideo(context, video);
    }
  }
  
  void _showEvolutionDialogFromVideo(BuildContext context, WorkoutVideo video) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE78639).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                color: Color(0xFFE78639),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Continue Evoluindo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O vídeo "${video.title}" estará disponível conforme você progride em sua jornada.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você pode visualizar todos os conteúdos disponíveis. Para interagir com eles, continue evoluindo!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE78639).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE78639).withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFE78639),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Continue sua evolução para desbloquear ainda mais conteúdos incríveis!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFE78639),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendi',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visite rayclub.com.br para evoluir ainda mais'),
                  backgroundColor: Color(0xFFE78639),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE78639),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Saiba Mais',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card de vídeo compacto para seções
  Widget _buildCompactVideoCard(BuildContext context, WidgetRef ref, WorkoutVideo video, Color accentColor) {
    // ✅ Verificação instantânea com novo provider
    final canAccess = _checkVideoAccess(ref, video.id);
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (canAccess && video.youtubeUrl != null && video.youtubeUrl!.isNotEmpty) {
                  _openYouTubePlayerFromVideo(context, video, ref);
                } else if (!canAccess) {
                  _showAccessDeniedDialog(context, video);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: YouTubeThumbnailWidget(
                            youtubeUrl: video.youtubeUrl,
                            fallbackImageUrl: video.thumbnailUrl,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            showPlayIcon: false,
                          ),
                        ),
                        // Ícone do YouTube
                        if (video.youtubeUrl != null && video.youtubeUrl!.isNotEmpty)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF0000),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Informações
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            fontFamily: 'CenturyGothic',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: accentColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                video.duration,
                                style: TextStyle(
                                  fontFamily: 'CenturyGothic',
                                  fontSize: 11,
                                  color: accentColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  // Método para exibir erro
  Widget _buildErrorView(BuildContext context, String error, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Algo deu errado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Tentar recarregar os dados
                    ref.refresh(homeViewModelProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE78639),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tentar Novamente',
                    style: TextStyle(
                      color: Colors.white,
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

  // Item de estatística de progresso para o novo dashboard
  Widget _buildProgressStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Exibe a imagem das regras em um diálogo
  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com título e botão fechar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF38638),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Regras do Desafio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // Imagem
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder<bool>(
                      future: _checkImageExists(imagePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFF38638),
                            ),
                          );
                        }
                        
                        if (snapshot.data == true) {
                          return Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Erro ao carregar imagem: $error');
                              return _buildImageErrorWidget();
                            },
                          );
                        } else {
                          return _buildImageErrorWidget();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Abre uma URL externa
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Verifica se a imagem existe
  Future<bool> _checkImageExists(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      debugPrint('Imagem não encontrada: $imagePath - Erro: $e');
      return false;
    }
  }

  /// Widget de erro para imagem
  Widget _buildImageErrorWidget() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Imagem não disponível',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'Tente fazer um hot restart do app',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Funções auxiliares para controle de acesso Expert/Basic

  /// Verifica se o usuário tem acesso ao vídeo
  /// ✅ Otimizado com novo provider global - resposta instantânea
  bool _checkVideoAccess(WidgetRef ref, String videoId) {
    // Usar nova implementação simples e direta
    final isExpertAsync = ref.watch(profile_providers.isExpertUserProfileProvider);
    return isExpertAsync.maybeWhen(
      data: (isExpert) => isExpert,
      orElse: () => false, // Durante loading ou erro, negar acesso
    );
  }

  /// Mostra dialog de acesso negado para usuários Basic
  void _showAccessDeniedDialog(BuildContext context, dynamic video) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header com botão de fechar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE78639),
                      const Color(0xFFCDA8F0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Treinos Especiais',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Conteúdo
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Ilustração
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE78639).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: Color(0xFFE78639),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Descrição
                    const Text(
                      'Continue evoluindo em sua jornada para desbloquear os treinos especiais dos nossos parceiros.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Botão
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE78639),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Entendi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mostra dialog de upgrade para usuários Basic
  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('🚀 Upgrade para Expert'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Com o plano Expert você terá:'),
            SizedBox(height: 12),
            Text('✅ Acesso a todos os vídeos de parceiros'),
            Text('✅ Treinos exclusivos de Fight Fit'),
            Text('✅ Conteúdo de Goya Health Club'),
            Text('✅ Vídeos de Bora Assessoria'),
            Text('✅ Fisioterapia com The Unit'),
            Text('✅ E muito mais!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mais tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Aqui você pode navegar para a tela de upgrade/subscription
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de upgrade em desenvolvimento!'),
                  backgroundColor: Color(0xFFE78639),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE78639),
            ),
            child: const Text(
              'Quero Upgrade!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


}
