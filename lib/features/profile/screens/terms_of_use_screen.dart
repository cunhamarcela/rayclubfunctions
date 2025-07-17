// Flutter imports:
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';

/// Tela que exibe os termos de uso completos
@RoutePage()
class TermsOfUseScreen extends StatelessWidget {
  /// Construtor padrão
  const TermsOfUseScreen({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/terms-of-use';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MarkdownWidget(
            data: _termsContent,
            config: MarkdownConfig(
              configs: [
                H1Config(
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                H2Config(
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                H3Config(
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                PConfig(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Conteúdo dos termos de uso em formato Markdown
const String _termsContent = '''
# Termos de Uso

## 1. Aceitação dos Termos

Ao acessar e usar o aplicativo Ray Club ("Aplicativo"), você concorda em cumprir e ficar vinculado aos seguintes Termos de Uso. Se você não concordar com estes termos, por favor, não use nosso Aplicativo.

## 2. Uso do Aplicativo

### 2.1 Elegibilidade
Você deve ter pelo menos 18 anos de idade para usar este Aplicativo. Ao usar o Aplicativo, você declara e garante que tem pelo menos 18 anos de idade.

### 2.2 Registro
Para acessar determinados recursos do Aplicativo, você pode precisar se registrar e criar uma conta. Você concorda em fornecer informações precisas e completas durante o processo de registro e em atualizar essas informações para mantê-las precisas.

### 2.3 Segurança da Conta
Você é responsável por manter a confidencialidade de suas credenciais de login e por todas as atividades que ocorrem em sua conta. Você concorda em notificar imediatamente a Ray Club sobre qualquer uso não autorizado de sua conta.

## 3. Conteúdo do Usuário

### 3.1 Propriedade
O Aplicativo pode permitir que você publique, carregue ou forneça textos, fotos e outros conteúdos. Você mantém todos os direitos sobre seu conteúdo, mas concede à Ray Club uma licença mundial, não exclusiva e isenta de royalties para usar, reproduzir, modificar, adaptar, publicar, distribuir e exibir esse conteúdo em conexão com o Aplicativo.

### 3.2 Conteúdo Proibido
Você concorda em não publicar conteúdo que seja ilegal, ofensivo, ameaçador, difamatório ou que viole direitos de terceiros.

## 4. Propriedade Intelectual

### 4.1 Direitos da Ray Club
O Aplicativo e todo o conteúdo, recursos e funcionalidades nele contidos são de propriedade da Ray Club e são protegidos por leis de direitos autorais, marcas registradas e outras leis de propriedade intelectual.

### 4.2 Restrições de Uso
Você não pode modificar, reproduzir, distribuir, criar trabalhos derivados, exibir publicamente, executar publicamente, republicar, baixar, armazenar ou transmitir qualquer material do Aplicativo, exceto conforme permitido por estes Termos.

## 5. Isenção de Responsabilidade

### 5.1 Atividade Física
Consulte um profissional de saúde antes de iniciar qualquer programa de exercícios. A Ray Club não é responsável por lesões ou danos que possam resultar do uso do Aplicativo ou da participação em atividades físicas sugeridas.

### 5.2 Precisão do Conteúdo
A Ray Club não garante a precisão, integridade ou atualidade das informações fornecidas no Aplicativo.

## 6. Limitação de Responsabilidade

Em nenhuma circunstância a Ray Club será responsável por danos indiretos, incidentais, especiais, consequentes ou punitivos decorrentes do uso ou incapacidade de uso do Aplicativo.

## 7. Rescisão

A Ray Club pode encerrar ou suspender sua conta e acesso ao Aplicativo a qualquer momento, sem aviso prévio, por qualquer motivo, incluindo violação destes Termos.

## 8. Modificações nos Termos

A Ray Club se reserva o direito de modificar estes Termos a qualquer momento. As mudanças entram em vigor imediatamente após a publicação. É sua responsabilidade verificar periodicamente estes Termos.

## 9. Lei Aplicável

Estes Termos serão regidos e interpretados de acordo com as leis do Brasil, sem considerar seus conflitos de princípios legais.

## 10. Contato

Se você tiver dúvidas sobre estes Termos, entre em contato conosco pelo email: suporte@rayclub.com.br

**Data de vigência:** 01 de junho de 2023
'''; 