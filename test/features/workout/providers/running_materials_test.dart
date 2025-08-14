import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ray_club_app/features/workout/providers/workout_material_providers.dart';
import 'package:ray_club_app/services/pdf_service.dart';
import 'package:ray_club_app/models/material.dart';

// Gerar mocks
@GenerateMocks([PdfService])
import 'running_materials_test.mocks.dart';

void main() {
  group('RunningMaterialsProvider Tests', () {
    late MockPdfService mockPdfService;
    late ProviderContainer container;

    setUp(() {
      mockPdfService = MockPdfService();
      container = ProviderContainer(
        overrides: [
          pdfServiceProvider.overrideWithValue(mockPdfService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('deve retornar lista vazia quando não há materiais de corrida', () async {
      // Arrange
      when(mockPdfService.getMaterialsByContext(MaterialContext.workout))
          .thenAnswer((_) async => []);

      // Act
      final result = await container.read(runningMaterialsProvider.future);

      // Assert
      expect(result, isEmpty);
      verify(mockPdfService.getMaterialsByContext(MaterialContext.workout)).called(1);
    });

    test('deve filtrar e retornar apenas materiais relacionados à corrida', () async {
      // Arrange
      final allMaterials = [
        const Material(
          id: '1',
          title: 'Planilha de Treino 5KM',
          description: 'Guia para corrida de 5km',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/5km.pdf',
        ),
        const Material(
          id: '2',
          title: 'Exercícios de Musculação',
          description: 'Treinos para academia',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'musculacao/treino-a.pdf',
        ),
        const Material(
          id: '3',
          title: 'Planilha de Treino 10KM',
          description: 'Programa para running de 10km',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/10km.pdf',
        ),
        const Material(
          id: '4',
          title: 'Guia de Pilates',
          description: 'Exercícios de pilates',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'pilates/basico.pdf',
        ),
      ];

      when(mockPdfService.getMaterialsByContext(MaterialContext.workout))
          .thenAnswer((_) async => allMaterials);

      // Act
      final result = await container.read(runningMaterialsProvider.future);

      // Assert
      expect(result, hasLength(2));
      expect(result.every((material) => 
        material.title.toLowerCase().contains('km') ||
        material.title.toLowerCase().contains('corrida') ||
        material.description.toLowerCase().contains('corrida') ||
        material.description.toLowerCase().contains('running')
      ), isTrue);
      
      // Verificar se os materiais corretos foram retornados
      expect(result.map((m) => m.id), containsAll(['1', '3']));
      verify(mockPdfService.getMaterialsByContext(MaterialContext.workout)).called(1);
    });

    test('deve filtrar materiais por diferentes palavras-chave de corrida', () async {
      // Arrange
      final materials = [
        const Material(
          id: '1',
          title: 'Treino de CORRIDA iniciante',
          description: 'Para começar a correr',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/iniciante.pdf',
        ),
        const Material(
          id: '2',
          title: 'Running Advanced',
          description: 'Advanced running techniques',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/advanced.pdf',
        ),
        const Material(
          id: '3',
          title: 'Maratona 42km',
          description: 'Preparação para maratona',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/maratona.pdf',
        ),
      ];

      when(mockPdfService.getMaterialsByContext(MaterialContext.workout))
          .thenAnswer((_) async => materials);

      // Act
      final result = await container.read(runningMaterialsProvider.future);

      // Assert
      expect(result, hasLength(3));
      expect(result.map((m) => m.id), containsAll(['1', '2', '3']));
    });

    test('deve manter order_index dos materiais filtrados', () async {
      // Arrange
      final materials = [
        const Material(
          id: '1',
          title: 'Planilha 10KM',
          description: 'Corrida 10km',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/10km.pdf',
          orderIndex: 2,
        ),
        const Material(
          id: '2',
          title: 'Planilha 5KM',
          description: 'Corrida 5km',
          materialType: MaterialType.pdf,
          materialContext: MaterialContext.workout,
          filePath: 'corrida/5km.pdf',
          orderIndex: 1,
        ),
      ];

      when(mockPdfService.getMaterialsByContext(MaterialContext.workout))
          .thenAnswer((_) async => materials);

      // Act
      final result = await container.read(runningMaterialsProvider.future);

      // Assert
      expect(result, hasLength(2));
      expect(result.first.orderIndex, 2);
      expect(result.last.orderIndex, 1);
    });
  });
} 