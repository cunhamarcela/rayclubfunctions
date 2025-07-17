// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/providers/auth_provider.dart';
import '../providers/recipe_favorites_providers.dart';
import '../widgets/nutrition_card.dart';

/// Tela que exibe as receitas favoritas do usuário
@RoutePage()
class FavoriteRecipesScreen extends ConsumerWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null) {
      return _buildNotLoggedIn(context);
    }
    
    final favoriteRecipesAsync = ref.watch(favoriteRecipesProvider(currentUser.id));
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Minhas Receitas Favoritas ✨',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: favoriteRecipesAsync.when(
        data: (recipes) => _buildRecipesList(context, recipes),
        loading: () => _buildLoading(),
        error: (error, _) => _buildError(context, ref, currentUser.id),
      ),
    );
  }

  /// Constrói a lista de receitas favoritas
  Widget _buildRecipesList(BuildContext context, List recipes) {
    if (recipes.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Implementar refresh se necessário
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: NutritionCard(
              title: recipe.title,
              description: recipe.description,
              imageUrl: recipe.imageUrl,
              preparationTime: recipe.preparationTimeMinutes,
              calories: recipe.calories,
              difficulty: recipe.difficulty,
              category: recipe.category,
              onTap: () {
                // Navegar para detalhes da receita
                context.router.pushNamed('/recipes/${recipe.id}');
              },
            ),
          );
        },
      ),
    );
  }

  /// Estado vazio quando não há receitas favoritas
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 60,
                color: Colors.orange.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma receita salva ainda 🍳',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Que tal explorar nossas receitas e salvar suas favoritas? '
              'Toque no ícone de bookmark 📌 nos detalhes da receita!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Voltar para explorar receitas
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Explorar Receitas ✨',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado de carregamento
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando suas receitas favoritas... 🍴',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de erro
  Widget _buildError(BuildContext context, WidgetRef ref, String userId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Algo deu errado 😔',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Não conseguimos carregar suas receitas favoritas. '
              'Vamos tentar novamente?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.refresh(favoriteRecipesProvider(userId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Tentar Novamente 🔄',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado quando usuário não está logado
  Widget _buildNotLoggedIn(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Receitas Favoritas',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.login,
                  size: 60,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Faça login para ver suas receitas favoritas! 🔐',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Entre na sua conta para salvar e acessar suas receitas preferidas a qualquer momento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navegar para tela de login
                  context.router.pushNamed('/auth/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fazer Login ✨',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 