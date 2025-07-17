// Flutter imports:
import 'package:flutter/material.dart';

/// Classe que contém a política de privacidade do aplicativo
class PrivacyPolicy {
  /// Título da política de privacidade
  static const String title = 'Política de Privacidade';

  /// Data da última atualização
  static const String lastUpdated = '01 de Abril de 2025';

  /// Conteúdo completo da política de privacidade
  static const String content = '''
# Política de Privacidade - Ray Club

**Última Atualização:** $lastUpdated

## 1. Introdução

O Ray Club ("nós", "nosso" ou "aplicativo") está comprometido em proteger sua privacidade. Esta Política de Privacidade explica como coletamos, usamos, divulgamos e protegemos suas informações quando você utiliza nosso aplicativo móvel.

## 2. Informações que Coletamos

### 2.1 Informações Fornecidas pelo Usuário
- Informações de cadastro (nome, e-mail, senha)
- Dados de perfil (foto, altura, peso, objetivos de fitness)
- Registros de treinos e atividades físicas
- Informações sobre nutrição e dieta
- Progressos e metas de condicionamento físico
- Participação em desafios e competições

### 2.2 Informações Coletadas Automaticamente
- Dados de uso do aplicativo
- Informações do dispositivo (modelo, sistema operacional, idioma)
- Dados de localização (apenas quando estritamente necessário e com sua permissão explícita)
- Fotos (quando permitido para registro de progresso)
- Métricas de desempenho (para análise de progressão nos treinos)

## 3. Como Usamos Suas Informações

Utilizamos suas informações para:
- Fornecer, personalizar e melhorar nossos serviços
- Processar e gerenciar sua conta
- Oferecer treinos e planos de nutrição personalizados
- Permitir sua participação em desafios e programas de incentivo
- Comunicar-nos com você sobre atualizações, novidades e conquistas
- Análise e melhoria contínua do aplicativo
- Enviar notificações sobre treinos, novas funcionalidades ou benefícios (com sua permissão)

## 4. Compartilhamento de Informações

Podemos compartilhar suas informações com:
- Provedores de serviços terceirizados que nos auxiliam na operação do aplicativo
- Parceiros que oferecem benefícios e descontos através do aplicativo
- Autoridades governamentais quando exigido por lei
- Outros participantes de desafios (apenas informações limitadas como nome e progresso)

Não vendemos ou alugamos suas informações pessoais a terceiros para fins de marketing.

## 5. Segurança de Dados

Implementamos medidas técnicas e organizacionais apropriadas para proteger suas informações contra acesso não autorizado, alteração, divulgação ou destruição, incluindo:
- Criptografia de dados sensíveis
- Armazenamento seguro com Supabase
- Acesso restrito a informações pessoais
- Monitoramento regular de nossos sistemas

## 6. Seus Direitos

Você tem o direito de:
- Acessar e atualizar suas informações pessoais
- Solicitar a exclusão de seus dados
- Opor-se ao processamento de seus dados
- Retirar seu consentimento a qualquer momento
- Solicitar a portabilidade de seus dados
- Apresentar uma reclamação a uma autoridade de proteção de dados

## 7. Uso da Câmera e Galeria de Fotos

O aplicativo solicita acesso à câmera e galeria de fotos para:
- Permitir que você atualize sua foto de perfil
- Registrar seu progresso físico através de fotos "antes e depois"
- Compartilhar imagens relacionadas aos seus treinos e conquistas
- Digitalizar códigos QR para cupons e benefícios exclusivos

Estas permissões são opcionais e você pode usar grande parte do aplicativo sem concedê-las.

## 8. Rastreamento do Usuário

Utilizamos tecnologias de rastreamento para melhorar a experiência do usuário e entender como nosso aplicativo é utilizado. Isto nos ajuda a:
- Personalizar conteúdo baseado em seu uso anterior
- Analisar quais recursos são mais úteis
- Identificar e corrigir problemas técnicos
- Melhorar a eficácia dos nossos programas de treino

Você pode gerenciar suas preferências de rastreamento nas configurações do aplicativo ou do dispositivo.

## 9. Uso de Notificações

Enviamos notificações para:
- Lembretes de treinos agendados
- Atualizações sobre desafios e competições
- Novos benefícios disponíveis
- Dicas de nutrição e bem-estar

Você pode gerenciar suas preferências de notificação nas configurações do aplicativo.

## 10. Armazenamento e Transferência Internacional de Dados

Seus dados podem ser armazenados e processados em servidores localizados fora do seu país de residência, onde as leis de proteção de dados podem diferir. Ao usar nosso aplicativo, você concorda com essa transferência de informações. Tomamos medidas para garantir que seus dados recebam um nível adequado de proteção onde quer que sejam processados.

## 11. Crianças

Nosso aplicativo não é destinado a menores de 13 anos, e não coletamos intencionalmente informações pessoais de crianças menores de 13 anos. Se você é pai ou responsável e acredita que seu filho nos forneceu informações pessoais, entre em contato conosco para que possamos tomar as medidas necessárias.

## 12. Alterações a Esta Política

Podemos atualizar esta Política de Privacidade periodicamente. Recomendamos que você revise esta política regularmente para estar ciente de quaisquer alterações. Notificaremos você sobre alterações significativas através do aplicativo ou por e-mail.

## 13. Contato

Se você tiver dúvidas sobre esta Política de Privacidade, entre em contato conosco pelo e-mail: privacy@rayclub.com
''';

  /// Versão resumida da política para exibição em diálogos
  static const String shortVersion = '''
O Ray Club coleta dados como perfil, treinos, nutrição e fotos para fornecer serviços personalizados. 
Utilizamos a câmera e galeria para registro de progresso e perfil. 
Também coletamos dados de uso para melhorar a experiência e permitir sua participação em desafios.
Seus dados são protegidos e não são vendidos a terceiros para marketing.
Você tem controle sobre suas permissões e pode gerenciar preferências no app.
''';
} 