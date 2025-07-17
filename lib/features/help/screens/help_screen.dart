// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/accessible_widget.dart';

/// Tela de ajuda com FAQ, tutoriais e suporte
@RoutePage()
class HelpScreen extends ConsumerStatefulWidget {
  /// Construtor padrão
  const HelpScreen({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/help';

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  // Índice da pergunta expandida, -1 significa que nenhuma está expandida
  int _expandedIndex = -1;
  bool _isLoading = false;
  
  // Lista de perguntas frequentes
  final List<Map<String, String>> _faqs = [
    {
      'question': 'Como criar um treino personalizado?',
      'answer': 'Para criar um treino personalizado, acesse a seção Treinos, toque no botão "+" no canto inferior direito e selecione "Criar treino". Escolha os exercícios, defina séries e repetições e salve seu treino.'
    },
    {
      'question': 'Como participar de um desafio?',
      'answer': 'Na seção Desafios, você encontrará desafios disponíveis. Selecione o desafio desejado e toque em "Participar". Você também pode criar seu próprio desafio tocando em "Criar desafio".'
    },
    {
      'question': 'Como acompanhar meu progresso?',
      'answer': 'Seu progresso é exibido na tela inicial e na seção Perfil. Você pode visualizar estatísticas de treinos, desafios completados e histórico de atividades.'
    },
    {
      'question': 'Como resgatar benefícios e cupons?',
      'answer': 'Acesse a seção Benefícios, escolha o benefício desejado e toque em "Resgatar". Um QR code será gerado para você apresentar no estabelecimento parceiro.'
    },
    {
      'question': 'Posso usar o app sem internet?',
      'answer': 'Sim, o Ray Club funciona offline para a maioria das funcionalidades. Treinos baixados previamente, seu perfil e estatísticas ficam disponíveis. A sincronização ocorre automaticamente quando você se reconectar.'
    },
    {
      'question': 'Como alterar minhas configurações de privacidade?',
      'answer': 'Acesse seu Perfil, toque em "Configurações e Privacidade" e selecione "Gerenciar Consentimentos". Lá você pode ajustar todas as permissões relacionadas aos seus dados.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
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
                    _buildSupportSection(),
                    const SizedBox(height: 24),
                    _buildFaqSection(),
                    const SizedBox(height: 24),
                    _buildTutorialsSection(),
                    const SizedBox(height: 24),
                    _buildContactSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Como podemos ajudar?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ).withAccessibility(
          label: 'Título da seção de ajuda',
        ),
        const SizedBox(height: 16),
        const Text(
          'Selecione uma das opções abaixo ou explore nossas perguntas frequentes.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSupportItem(
              icon: Icons.play_circle_outline,
              title: 'Tutoriais',
              onTap: () => _scrollToSection(1),
            ),
            _buildSupportItem(
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              onTap: () => _scrollToSection(0),
            ),
            _buildSupportItem(
              icon: Icons.mail_outline,
              title: 'Contato',
              onTap: () => _scrollToSection(2),
            ),
          ],
        ),
      ],
    );
  }

  void _scrollToSection(int section) {
    switch (section) {
      case 0:
        // Scroll para FAQ
        Scrollable.ensureVisible(
          _faqKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      case 1:
        // Scroll para Tutoriais
        Scrollable.ensureVisible(
          _tutorialsKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
      case 2:
        // Scroll para Contato
        Scrollable.ensureVisible(
          _contactKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        break;
    }
  }

  // Keys para scroll
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _tutorialsKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    ).withAccessibility(
      label: '$title botão de suporte',
      hint: 'Toque para navegar para a seção de $title',
      isButton: true,
    );
  }

  Widget _buildFaqSection() {
    return Column(
      key: _faqKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perguntas Frequentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ).withAccessibility(
          label: 'Título da seção de perguntas frequentes',
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _faqs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildFaqItem(
                question: _faqs[index]['question']!,
                answer: _faqs[index]['answer']!,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required int index,
  }) {
    final isExpanded = _expandedIndex == index;
    
    return Column(
      children: [
        ListTile(
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? -1 : index;
            });
          },
        ).withAccessibility(
          label: question,
          hint: isExpanded ? 'Toque para fechar' : 'Toque para ver a resposta',
          isButton: true,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTutorialsSection() {
    return Column(
      key: _tutorialsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tutoriais',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ).withAccessibility(
          label: 'Título da seção de tutoriais',
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              _buildTutorialItem(
                title: 'Primeiros passos com o Ray Club',
                subtitle: 'Conheça as funcionalidades principais',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tutorial em breve!'))
                  );
                },
              ),
              const Divider(height: 1),
              _buildTutorialItem(
                title: 'Como criar seu primeiro treino',
                subtitle: 'Aprenda a montar treinos personalizados',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tutorial em breve!'))
                  );
                },
              ),
              const Divider(height: 1),
              _buildTutorialItem(
                title: 'Participando de desafios',
                subtitle: 'Saiba como competir e ganhar pontos',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tutorial em breve!'))
                  );
                },
              ),
              const Divider(height: 1),
              _buildTutorialItem(
                title: 'Utilizando a seção de nutrição',
                subtitle: 'Acompanhe sua alimentação diária',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tutorial em breve!'))
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTutorialItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.play_arrow,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ).withAccessibility(
      label: title,
      hint: subtitle,
    );
  }

  Widget _buildContactSection() {
    return Column(
      key: _contactKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entre em Contato',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ).withAccessibility(
          label: 'Título da seção de contato',
        ),
        const SizedBox(height: 8),
        const Text(
          'Ainda tem dúvidas? Nossa equipe está pronta para ajudar.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildContactItem(
                icon: Icons.email_outlined,
                title: 'E-mail',
                subtitle: 'suporte@rayclub.com.br',
                onTap: () => _launchEmail('suporte@rayclub.com.br'),
              ),
              const Divider(height: 1),
              _buildContactItem(
                icon: Icons.chat_outlined,
                title: 'Chat',
                subtitle: 'Converse com um atendente',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat em breve!'))
                  );
                },
              ),
              const Divider(height: 1),
              _buildContactItem(
                icon: Icons.phone_outlined,
                title: 'Telefone',
                subtitle: '(11) 0000-0000',
                onTap: () => _launchPhone('11000000000'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchEmail(String email) async {
    // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
    // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
    /*
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Suporte Ray Club',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o e-mail: $email'))
      );
    }
    */
    
    // Mensagem temporária
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contato por e-mail temporariamente indisponível. Use: $email'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
    // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
    /*
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível ligar para: $phone'))
      );
    }
    */
    
    // Mensagem temporária
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ligação telefônica temporariamente indisponível. Use: $phone'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
      ),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ).withAccessibility(
      label: '$title - $subtitle',
      hint: 'Toque para entrar em contato via $title',
    );
  }
} 