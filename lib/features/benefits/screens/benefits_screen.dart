// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../shared/bottom_navigation_bar.dart';
import '../../subscription/widgets/premium_feature_gate.dart';

/// Model for partner information
class Partner {
  final String name;
  final String benefits;
  final String price;
  final String instagram;
  final String phone;
  final String? experience;

  const Partner({
    required this.name,
    required this.benefits,
    required this.price,
    required this.instagram,
    required this.phone,
    this.experience,
  });
}

/// The Benefits Screen that displays Ray 21 Challenge partners
@RoutePage()
class BenefitsScreen extends ConsumerStatefulWidget {
  const BenefitsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends ConsumerState<BenefitsScreen> {
  static const List<Partner> partners = [
    Partner(
      name: 'BodyHiit',
      benefits: 'Plano de R\$149,90 por 21 dias',
      price: 'R\$ 149,90',
      instagram: '@bodyhiitbrasil',
      phone: '(31) 98364-1388',
      experience: '1ª experiência gratuita',
    ),
    Partner(
      name: 'RaceBootcamp',
      benefits: 'Plano de R\$149,90 por 21 dias',
      price: 'R\$ 149,90',
      instagram: '@racebootcamp',
      phone: '(31) 99886-8686',
      experience: '1ª experiência gratuita',
    ),
    Partner(
      name: 'Fight Fit',
      benefits: 'Plano de R\$149,90 por 21 dias',
      price: 'R\$ 149,90',
      instagram: '@fightfitbh',
      phone: '(31) 97547-2502',
      experience: '1ª experiência gratuita',
    ),
    Partner(
      name: 'Goyá Health Club',
      benefits: 'Plano de R\$149,90 por 21 dias',
      price: 'R\$ 149,90',
      instagram: '@goyahealthclub',
      phone: '(31) 98257-3742',
      experience: '1ª experiência gratuita',
    ),
    Partner(
      name: 'Big Iron',
      benefits: '1ª experiência gratuita',
      price: 'Gratuito',
      instagram: '@big_iron_raja',
      phone: '(31) 98457-4598',
    ),
    Partner(
      name: 'Single Body',
      benefits: 'Plano de R\$149,90 por 21 dias',
      price: 'R\$ 149,90',
      instagram: '@singlebodybr',
      phone: '(31) 93300-6902',
      experience: '1ª experiência gratuita',
    ),
    Partner(
      name: 'Velocity',
      benefits: '5 créditos por R\$149,90',
      price: 'R\$ 149,90',
      instagram: '@studio_velocity',
      phone: '(31) 98302-2406',
      experience: '1ª experiência gratuita',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ProgressGate(
      featureKey: 'detailed_reports',
      progressTitle: 'Benefícios Exclusivos',
      progressDescription: 'Continue evoluindo para desbloquear acesso aos benefícios exclusivos dos nossos parceiros.',
      child: Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Parceiros',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Header with challenge information
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'RayClub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pra que vocês tenham a chance de conhecer novos lugares e treinar em studios diferentes durante os dias do desafio, alguns dos nossos parceiros vão oferecer benefícios incríveis pra vocês!!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // How it works section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Como funciona?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    icon: Icons.star,
                    text: 'Se você ainda não conhece o studio, vai ganhar uma aula experimental gratuita pra viver essa primeira experiência.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    icon: Icons.calendar_month,
                    text: 'Todos os participantes terão acesso a um plano exclusivo — com validade de 26/05/2025 a 15/06/2025.',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    icon: Icons.group,
                    text: 'Vocês podem aderir a esse plano em quantos parceiros quiserem.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildWarningItem('Independente da data em que vocês começarem, o plano é válido só até o fim do desafio, dia 15/06/2025.'),
                        const SizedBox(height: 8),
                        _buildWarningItem('O plano não é válido pra quem já tem um plano ativo no studio.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // How to access section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.how_to_reg,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Como ter acesso?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'É só entrar em contato com o parceiro se identificando como participante do Desafio Ray 21. Eles terão acesso a uma lista atualizada diariamente com os assinantes do RayClub para validar o seu benefício.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Partners section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nossos Parceiros',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          
          // Partners list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final partner = partners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildPartnerCard(partner),
                );
              },
              childCount: partners.length,
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
      bottomNavigationBar: const SharedBottomNavigationBar(currentIndex: 3),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.warning_amber,
          color: Colors.orange,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerCard(Partner partner) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partner name and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      partner.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      partner.price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Experience badge (if available)
              if (partner.experience != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        partner.experience!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Benefits
              Text(
                partner.benefits,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openInstagram(partner.instagram),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(partner.instagram),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _callPartner(partner.phone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.phone, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openInstagram(String username) async {
    // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
    // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
    /*
    final instagramUrl = 'https://instagram.com/${username.replaceAll('@', '')}';
    try {
      if (await canLaunchUrl(Uri.parse(instagramUrl))) {
        await launchUrl(Uri.parse(instagramUrl), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o Instagram'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o Instagram'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
    
    // Mensagem temporária
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Instagram temporariamente indisponível. Siga: $username'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _callPartner(String phone) async {
    // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
    // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
    /*
    final phoneUrl = 'tel:${phone.replaceAll(RegExp(r'[^\d]'), '')}';
    try {
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível fazer a ligação'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao fazer a ligação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    */
    
    // Mensagem temporária
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ligação temporariamente indisponível. Telefone: $phone'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
} 
