// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:riverpod/riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../models/partner_content.dart';
import '../models/partner_studio.dart';

// Provider do repositório
final partnerStudioRepositoryProvider = Provider<PartnerStudioRepository>((ref) {
  final client = Supabase.instance.client;
  return SupabasePartnerStudioRepository(client);
});

// Interface para o repositório
abstract class PartnerStudioRepository {
  Future<List<PartnerStudio>> getPartnerStudios();
  Future<List<PartnerContent>> getStudioContents(String studioId);
}

// Implementação com Supabase
class SupabasePartnerStudioRepository implements PartnerStudioRepository {
  final SupabaseClient _client;
  
  SupabasePartnerStudioRepository(this._client);
  
  @override
  Future<List<PartnerStudio>> getPartnerStudios() async {
    try {
      final response = await _client
        .from('partner_studios')
        .select()
        .order('name');
      
      // Se não há dados no banco, usar dados mock
      if (response.isEmpty) {
        return _getMockStudios();
      }
      
      final studios = response.map((json) => PartnerStudio.fromJson(json)).toList();
      
      // Adicionar apresentação visual para cada estúdio
      return studios.map((studio) {
        // Definir apresentação com base no ID ou nome do estúdio
        switch (studio.name.toLowerCase()) {
          case 'fight fit':
            return studio.withPresentation(
              logoColor: const Color(0xFFE74C3C),
              backgroundColor: const Color(0xFFFDEDEC),
              icon: Icons.sports_mma,
            );
          case 'flow yoga':
            return studio.withPresentation(
              logoColor: const Color(0xFF3498DB),
              backgroundColor: const Color(0xFFEBF5FB),
              icon: Icons.self_improvement,
            );
          case 'goya health club':
            return studio.withPresentation(
              logoColor: const Color(0xFF27AE60),
              backgroundColor: const Color(0xFFE9F7EF),
              icon: Icons.spa,
            );
          case 'the unit':
            return studio.withPresentation(
              logoColor: const Color(0xFF9B59B6),
              backgroundColor: const Color(0xFFF4ECF7),
              icon: Icons.medical_services,
            );
          default:
            return studio.withPresentation(
              logoColor: const Color(0xFF777777),
              backgroundColor: const Color(0xFFF5F5F5),
              icon: Icons.fitness_center,
            );
        }
      }).toList();
    } catch (e) {
      // Se há erro na consulta (ex: tabela não existe), usar dados mock
      return _getMockStudios();
    }
  }
  
  @override
  Future<List<PartnerContent>> getStudioContents(String studioId) async {
    try {
      final response = await _client
        .from('partner_contents')
        .select()
        .eq('studio_id', studioId)
        .order('created_at', ascending: false);
      
      return response.map((json) => PartnerContent.fromJson(json)).toList();
    } catch (e) {
      throw StorageException(
        message: 'Erro ao buscar conteúdos do estúdio: ${e.toString()}',
        originalError: e,
      );
    }
  }
  
  // Método para dados de exemplo para desenvolvimento (fallback)
  List<PartnerStudio> _getMockStudios() {
    return [
      PartnerStudio(
        id: '1',
        name: 'Fight Fit',
        tagline: 'Funcional com luta',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '1',
            title: 'Fundamentos do Muay Thai',
            duration: '45 min',
            difficulty: 'Iniciante',
            imageUrl: 'https://images.pexels.com/photos/6295872/pexels-photo-6295872.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '2',
            title: 'Boxe Funcional',
            duration: '30 min',
            difficulty: 'Intermediário',
            imageUrl: 'https://images.pexels.com/photos/4804076/pexels-photo-4804076.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '3',
            title: 'Fight HIIT',
            duration: '25 min',
            difficulty: 'Avançado',
            imageUrl: 'https://images.pexels.com/photos/4754146/pexels-photo-4754146.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFFE74C3C),
        backgroundColor: const Color(0xFFFDEDEC),
        icon: Icons.sports_mma,
      ),
      
      PartnerStudio(
        id: '2',
        name: 'Flow Yoga',
        tagline: 'Yoga e crioterapia',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '4',
            title: 'Vinyasa Flow',
            duration: '50 min',
            difficulty: 'Todos os níveis',
            imageUrl: 'https://images.pexels.com/photos/6698513/pexels-photo-6698513.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '5',
            title: 'Benefícios da Crioterapia',
            duration: '15 min',
            difficulty: 'Informativo',
            imageUrl: 'https://images.pexels.com/photos/6111616/pexels-photo-6111616.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '6',
            title: 'Yoga para Recuperação',
            duration: '35 min',
            difficulty: 'Iniciante',
            imageUrl: 'https://images.pexels.com/photos/4056723/pexels-photo-4056723.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFF3498DB),
        backgroundColor: const Color(0xFFEBF5FB),
        icon: Icons.self_improvement,
      ),
      
      PartnerStudio(
        id: '3',
        name: 'Goya Health Club',
        tagline: 'Pilates e yoga',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '7',
            title: 'Pilates Reformer',
            duration: '40 min',
            difficulty: 'Intermediário',
            imageUrl: 'https://images.pexels.com/photos/6551133/pexels-photo-6551133.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '8',
            title: 'Hatha Yoga',
            duration: '60 min',
            difficulty: 'Todos os níveis',
            imageUrl: 'https://images.pexels.com/photos/4534680/pexels-photo-4534680.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '9',
            title: 'Mat Pilates',
            duration: '30 min',
            difficulty: 'Iniciante',
            imageUrl: 'https://images.pexels.com/photos/3775593/pexels-photo-3775593.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFF27AE60),
        backgroundColor: const Color(0xFFE9F7EF),
        icon: Icons.spa,
      ),
      
      PartnerStudio(
        id: '4',
        name: 'The Unit',
        tagline: 'Fisioterapia para treino',
        logoUrl: null,
        contents: [
          PartnerContent(
            id: '10',
            title: 'Mobilidade para Atletas',
            duration: '25 min',
            difficulty: 'Todos os níveis',
            imageUrl: 'https://images.pexels.com/photos/8957028/pexels-photo-8957028.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '11',
            title: 'Recuperação de Lesões',
            duration: '45 min',
            difficulty: 'Reabilitação',
            imageUrl: 'https://images.pexels.com/photos/6111609/pexels-photo-6111609.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
          PartnerContent(
            id: '12',
            title: 'Core para Performance',
            duration: '30 min',
            difficulty: 'Intermediário',
            imageUrl: 'https://images.pexels.com/photos/8436735/pexels-photo-8436735.jpeg?auto=compress&cs=tinysrgb&w=800',
          ),
        ],
      ).withPresentation(
        logoColor: const Color(0xFF9B59B6),
        backgroundColor: const Color(0xFFF4ECF7),
        icon: Icons.medical_services,
      ),
    ];
  }
} 