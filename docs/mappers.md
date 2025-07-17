# Documentação dos Mappers no Ray Club App

## Visão Geral

Os Mappers são classes utilitárias implementadas para realizar a conversão segura entre os dados retornados pelo Supabase (em formato de JSON com snake_case) e os modelos de domínio da aplicação (classes Dart com camelCase). Estas classes resolvem os seguintes problemas:

1. **Conversão de convenções de nomenclatura**: Transformação entre snake_case (padrão em bancos de dados) e camelCase (padrão em Dart)
2. **Tratamento de valores nulos**: Prevenção de erros do tipo "Null is not a subtype of type 'String' in type cast"
3. **Conversão de tipos**: Manipulação segura de tipos de dados (strings para enums, timestamps para DateTime, etc.)
4. **Valores padrão seguros**: Fornecimento de valores padrão quando dados opcionais estão ausentes

## Implementações

### 1. BenefitMapper

**Localização**: `lib/features/benefits/mappers/benefit_mapper.dart`

**Funcionalidades principais**:
- Conversão de campos snake_case para camelCase
- Mapeamento de strings de tipo para o enum `BenefitType` 
- Tratamento seguro de campos nulos com valores padrão
- Abordagem em duas etapas: tentativa com fromJson padrão, e fallback para construção manual

**Exemplo de conversão**:
```dart
// Conversor principal
static Benefit fromSupabase(Map<String, dynamic> json) {
  try {
    // Pré-processamento para campos problemáticos
    final processedJson = {
      ...json,
      'type': _parseBenefitType(json['type']).toString().split('.').last,
      'imageUrl': json['image_url'] ?? '',
      // Outros campos convertidos...
    };
    
    return Benefit.fromJson(processedJson);
  } 
  catch (e) {
    // Abordagem manual de fallback
    return Benefit(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      // Outros campos com valores seguros...
    );
  }
}
```

**Métodos auxiliares**:
- `_parseBenefitType`: Converte strings para o enum BenefitType
- `_parseDateTime`: Converte strings e timestamps para DateTime
- `_parseInt`: Converte diversos formatos para int de forma segura
- `toSupabase`: Mapeia de volta para o formato do Supabase

### 2. ChallengeMapper

**Localização**: `lib/features/challenges/mappers/challenge_mapper.dart`

**Funcionalidades principais**:
- Conversão de campos snake_case para camelCase
- Tratamento seguro de arrays (requirements, participants, invitedUsers)
- Conversão segura de datas e integers
- Detecção inteligente de quando o mapper é necessário

**Exemplo de conversão**:
```dart
static Challenge fromSupabase(Map<String, dynamic> json) {
  try {
    // Pré-processamento para campos problemáticos
    final processedJson = {
      ...json,
      'imageUrl': json['image_url'],
      'startDate': json['start_date'],
      // Outros campos convertidos...
      'requirements': _parseStringArray(json['requirements']),
      'participants': _parseStringArray(json['participants']),
    };
    
    return Challenge.fromJson(processedJson);
  } 
  catch (e) {
    // Abordagem manual de fallback
    return Challenge(
      id: json['id'] ?? '',
      // Outros campos com tratamento seguro...
    );
  }
}
```

**Métodos auxiliares**:
- `_parseStringArray`: Converte diversos formatos para List<String>
- `_parseDateTime`: Trata datas de forma segura
- `_parseInt`: Converte diversos formatos para int
- `toSupabase`: Converte de volta para o formato do Supabase

## Integração com Repositórios

Os mappers são integrados nos repositórios correspondentes (`SupabaseBenefitRepository` e `SupabaseChallengeRepository`), onde substituem o uso direto do método `fromJson` do modelo. 

### Exemplo de uso no SupabaseChallengeRepository:

```dart
Future<Challenge> getChallengeById(String id) async {
  try {
    final response = await _client
        .from(_challengesTable)
        .select()
        .eq('id', id)
        .single();
    
    // Verificar se precisa de mapper personalizado
    if (ChallengeMapper.needsMapper(response)) {
      return ChallengeMapper.fromSupabase(response);
    }
    
    // Caso contrário, usar método padrão do Freezed
    return Challenge.fromJson(response);
  } catch (e, stackTrace) {
    throw _handleError(e, stackTrace, 'Erro ao buscar detalhes do desafio');
  }
}
```

## Testes

Cada mapper possui seus próprios testes para garantir o correto funcionamento:

- `test/features/benefits/mappers/benefit_mapper_test.dart`
- `test/features/challenges/mappers/challenge_mapper_test.dart`

Os testes verificam:
- Conversão de JSON para modelo
- Tratamento de valores nulos
- Conversão de enums e tipos complexos
- Detecção correta de quando é necessário usar o mapper

## Benefícios da Implementação

1. **Robustez**: Elimina erros de tipo nulo em runtime
2. **Manutenção**: Centraliza a lógica de conversão
3. **Clareza**: Separa responsabilidades (os repositórios não precisam conhecer detalhes de conversão)
4. **Flexibilidade**: Permite adaptar diversos formatos de dados do backend para o modelo de domínio
5. **Testabilidade**: Facilita a criação de testes unitários para a lógica de conversão 