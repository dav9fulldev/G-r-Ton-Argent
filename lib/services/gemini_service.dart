import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction_model.dart';
import '../config/api_keys.dart';
import '../utils/category_utils.dart';

class GeminiService extends ChangeNotifier {
  // Configuration pour l'API Gemini
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  // Clé API récupérée depuis le fichier de configuration sécurisé
  static String get _apiKey => ApiKeys.geminiApiKey;
  
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fonction centrale pour obtenir une analyse conversationnelle IA via Gemini
  /// Cette fonction simule une conversation avec un conseiller financier
  Future<Map<String, dynamic>> analyserDepense(double budget, double depenses, double nouvelleDepense, {TransactionCategory? category, String? userChoice}) async {
    _setLoading(true);
    _clearError();

    try {
      // Si l'utilisateur a choisi une option avec prix spécifique, utiliser directement la réponse contextuelle
      if (userChoice != null && userChoice.contains('(') && userChoice.contains('FCFA')) {
        return _getContextualResponse(budget, depenses, nouvelleDepense, category, userChoice);
      }
      
      // Sinon, utiliser Gemini pour les choix génériques ou l'analyse initiale
      final prompt = _buildConversationPrompt(budget, depenses, nouvelleDepense, category, userChoice);
      final response = await _callGemini(prompt);
      return _parseChatbotResponse(response, budget, depenses, nouvelleDepense, category, userChoice: userChoice);
    } catch (e) {
      _setError('Erreur lors de la génération des conseils: $e');
      // Retourner une analyse par défaut en cas d'erreur
      return _getDefaultChatbotResponse(budget, depenses, nouvelleDepense, category);
    } finally {
      _setLoading(false);
    }
  }

     /// Construit le prompt conversationnel pour Gemini
   String _buildConversationPrompt(double budget, double depenses, double nouvelleDepense, TransactionCategory? category, String? userChoice) {
    final totalApresDepense = depenses + nouvelleDepense;
    final pourcentageBudget = (totalApresDepense / budget) * 100;
    final resteBudget = budget - totalApresDepense;

         final categoryInfo = category != null ? '\nCatégorie de dépense : ${_getCategoryName(category)}' : '';
     final userChoiceInfo = userChoice != null ? '\n\nL\'utilisateur a choisi : "$userChoice"' : '';

         return '''
Tu es un conseiller financier personnel expert, spécialisé dans la gestion de budget en Côte d'Ivoire. Tu as une personnalité chaleureuse et bienveillante, comme un ami qui veut le meilleur pour son ami.

L'utilisateur s'apprête à faire une dépense de ${nouvelleDepense.toStringAsFixed(0)} FCFA.${categoryInfo}${userChoiceInfo}

Voici sa situation financière actuelle :
- Budget mensuel : ${budget.toStringAsFixed(0)} FCFA
- Dépenses déjà effectuées : ${depenses.toStringAsFixed(0)} FCFA
- Après cette dépense : ${totalApresDepense.toStringAsFixed(0)} FCFA (${pourcentageBudget.toStringAsFixed(1)}% du budget)
- Reste du budget : ${resteBudget.toStringAsFixed(0)} FCFA

**Ton rôle** : Répondre intelligemment selon le choix de l'utilisateur et calculer les économies réalisées.

**Format de réponse requis** :
Réponds EXACTEMENT dans ce format :

MESSAGE: [message intelligent et spécifique au choix de l'utilisateur, max 2-3 phrases]
OPTIONS: [3-4 nouvelles options logiques selon le contexte, séparées par des virgules]

**Logique de réponse selon le choix** :

**IMPORTANT : Distingue les types de choix** :

1. **Choix avec prix spécifique** (ex: "Gbaka (300 FCFA)") → Actions finales
2. **Choix générique** (ex: "Chercher moins cher") → Plus d'alternatives

**Si l'utilisateur choisit une option avec prix spécifique** :
- Calcule l'économie : Montant initial - Prix choisi
- Félicite pour le bon choix
- Propose des actions finales : "Enregistrer (X FCFA)", "Modifier le montant", "Fermer"

**Si l'utilisateur choisit une option générique** :
- Propose plus d'alternatives spécifiques avec prix

**Exemples de réponses intelligentes** :

**TRANSPORT - Choix avec prix** :
- Si "Gbaka (300 FCFA)" : "🚐 Super choix ! Le Gbaka à 300 FCFA est économique. Tu as économisé ${(nouvelleDepense - 300).toStringAsFixed(0)} FCFA !"
- Si "Bus (200 FCFA)" : "🚌 Parfait ! Le bus à 200 FCFA est un excellent choix. Tu économiseras ${(nouvelleDepense - 200).toStringAsFixed(0)} FCFA !"

**NOURRITURE - Choix avec prix** :
- Si "Street food (1500 FCFA)" : "🍜 Excellente idée ! La street food à 1500 FCFA est délicieuse et économique. Tu économiseras ${(nouvelleDepense - 1500).toStringAsFixed(0)} FCFA !"
- Si "Cuisine maison (800 FCFA)" : "👨‍🍳 Brillant ! Cuisiner à la maison à 800 FCFA est sain et économique. Tu économiseras ${(nouvelleDepense - 800).toStringAsFixed(0)} FCFA !"

**ACHATS - Choix avec prix** :
- Si "Marché populaire (économies 40%)" : "🛍️ Parfait ! Le marché populaire offre de bonnes affaires. Tu économiseras ${(nouvelleDepense * 0.4).toStringAsFixed(0)} FCFA !"
- Si "Achat groupé (économies 25%)" : "👥 Super idée ! L'achat groupé permet de partager les coûts. Tu économiseras ${(nouvelleDepense * 0.25).toStringAsFixed(0)} FCFA !"

**DIVERTISSEMENT - Choix avec prix** :
- Si "Parc public (0 FCFA)" : "🌳 Excellente idée ! Le parc public est agréable et gratuit. Tu économiseras ${nouvelleDepense.toStringAsFixed(0)} FCFA !"
- Si "Événement local (2000 FCFA)" : "🎉 Parfait ! L'événement local à 2000 FCFA est convivial. Tu économiseras ${(nouvelleDepense - 2000).toStringAsFixed(0)} FCFA !"

**SANTÉ - Choix avec prix** :
- Si "Pharmacie populaire (économies 30%)" : "💊 Bon choix ! La pharmacie populaire offre des prix abordables. Tu économiseras ${(nouvelleDepense * 0.3).toStringAsFixed(0)} FCFA !"
- Si "Consultation gratuite (0 FCFA)" : "👨‍⚕️ Sage choix ! La consultation gratuite te permet de te soigner sans coût. Tu économiseras ${nouvelleDepense.toStringAsFixed(0)} FCFA !"

**TRANSPORT - Choix générique** :
- Si "Chercher moins cher" : "💡 Voici d'autres options économiques :"
- Options : "Taxi (600-1000 FCFA)", "Moto (500-800 FCFA)", "Woro-woro (400-700 FCFA)", "Marcher (0 FCFA)"

**NOURRITURE - Choix générique** :
- Si "Chercher moins cher" : "🍽️ Voici d'autres options pour économiser :"
- Options : "Street food (1000-2000 FCFA)", "Cantine populaire (800-1500 FCFA)", "Marché local (500-1200 FCFA)", "Cuisine maison (300-800 FCFA)"

**Règles** :
- Si le choix contient "(X FCFA)" → Actions finales
- Si le choix est générique → Plus d'alternatives
- Calcule TOUJOURS l'économie réalisée
- Sois encourageant et félicite le bon choix
- Utilise des emojis appropriés
''';
  }

  /// Appelle Gemini via HTTP
  Future<String> _callGemini(String prompt) async {
    try {
      // Vérifier si la clé API est configurée
      if (!ApiKeys.isGeminiConfigured) {
        throw Exception('Clé API Gemini non configurée. Utilisation des conseils par défaut.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': prompt,
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 50,
            'topP': 0.9,
            'maxOutputTokens': 400,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List;
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List;
          if (parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
        throw Exception('Réponse invalide de Gemini');
      } else {
        throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel à Gemini: $e');
    }
  }



          /// Parse la réponse de Gemini pour le chatbot
    Map<String, dynamic> _parseChatbotResponse(String response, double budget, double depenses, double nouvelleDepense, TransactionCategory? category, {String? userChoice}) {
      try {
        final lines = response.split('\n');
        String message = '';
        List<String> options = [];
        
        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.startsWith('MESSAGE:')) {
            message = trimmedLine.substring(8).trim();
          } else if (trimmedLine.startsWith('OPTIONS:')) {
            final optionsText = trimmedLine.substring(8).trim();
            options = optionsText.split(',').map((e) => e.trim()).toList();
          }
        }
        
        // Si le parsing échoue, utiliser la réponse contextuelle ou par défaut
        if (message.isEmpty) {
          if (userChoice != null) {
            return _getContextualResponse(budget, depenses, nouvelleDepense, category, userChoice);
          } else {
            return _getDefaultChatbotResponse(budget, depenses, nouvelleDepense, category);
          }
        }
        
        return {
          'message': message,
          'options': options.isNotEmpty ? options : ['Continuer', 'Chercher moins cher', 'Reporter'],
        };
      } catch (e) {
        if (userChoice != null) {
          return _getContextualResponse(budget, depenses, nouvelleDepense, category, userChoice);
        } else {
          return _getDefaultChatbotResponse(budget, depenses, nouvelleDepense, category);
        }
      }
    }

       /// Réponse par défaut pour le chatbot
    Map<String, dynamic> _getDefaultChatbotResponse(double budget, double depenses, double nouvelleDepense, TransactionCategory? category) {
     final totalApresDepense = depenses + nouvelleDepense;
     final pourcentageBudget = (totalApresDepense / budget) * 100;
     final resteBudget = budget - totalApresDepense;

     final pourcentageDepense = (nouvelleDepense / budget) * 100;
     final categoryName = category != null ? CategoryUtils.getCategoryName(category) : 'cette dépense';
     
     // Message court et direct
     String message = 'Hey ! 👋 ${nouvelleDepense.toStringAsFixed(0)} FCFA pour $categoryName, c\'est ${pourcentageDepense.toStringAsFixed(1)}% de ton budget. ';
     
     if (nouvelleDepense > budget * 0.3) {
       message += 'C\'est important ! 🤔';
     } else if (nouvelleDepense > budget * 0.15) {
       message += 'C\'est significatif ! 💰';
     } else {
       message += 'C\'est raisonnable ! ✅';
     }
     
     // Options contextuelles selon la catégorie
     List<String> options = [];
     
     if (category != null) {
       switch (category) {
         case TransactionCategory.transport:
           if (nouvelleDepense > 2000) {
             options = ['Prendre gbaka (150-300 FCFA)', 'Bus (200-400 FCFA)', 'Marche à pied', 'Covoiturage'];
           } else {
             options = ['Continuer', 'Comparer les prix', 'Voir alternatives'];
           }
           break;
         case TransactionCategory.food:
           if (nouvelleDepense > 5000) {
             options = ['Marché local', 'Cuisine maison', 'Restaurant populaire', 'Street food'];
           } else {
             options = ['Continuer', 'Optimiser', 'Voir conseils'];
           }
           break;
         case TransactionCategory.shopping:
           if (nouvelleDepense > 8000) {
             options = ['Marché populaire', 'Négocier le prix', 'Attendre les soldes', 'Achat groupé'];
           } else {
             options = ['Continuer', 'Chercher moins cher', 'Voir alternatives'];
           }
           break;
         case TransactionCategory.entertainment:
           if (nouvelleDepense > 7000) {
             options = ['Activité gratuite', 'Parc public', 'Événement local', 'Jeux à la maison'];
           } else {
             options = ['Continuer', 'Optimiser', 'Voir conseils'];
           }
           break;
         case TransactionCategory.health:
           options = ['Continuer', 'Pharmacie populaire', 'Mutuelle', 'Consultation gratuite'];
           break;
         default:
           if (nouvelleDepense > budget * 0.3) {
             options = ['Reporter', 'Chercher moins cher', 'Continuer quand même'];
           } else if (nouvelleDepense > budget * 0.15) {
             options = ['Continuer', 'Chercher moins cher', 'Voir alternatives'];
           } else {
             options = ['Continuer', 'Optimiser', 'Voir conseils'];
           }
       }
     } else {
       if (nouvelleDepense > budget * 0.3) {
         options = ['Reporter', 'Chercher moins cher', 'Continuer quand même'];
       } else if (nouvelleDepense > budget * 0.15) {
         options = ['Continuer', 'Chercher moins cher', 'Voir alternatives'];
       } else {
         options = ['Continuer', 'Optimiser', 'Voir conseils'];
       }
     }
     
     return {
       'message': message,
       'options': options,
     };
   }

                 /// Réponse contextuelle selon le choix de l'utilisateur
    Map<String, dynamic> _getContextualResponse(double budget, double depenses, double nouvelleDepense, TransactionCategory? category, String userChoice) {
      String message = '';
      List<String> options = [];
      
      // Vérifier si c'est un choix avec prix spécifique (choix final)
      final hasSpecificPrice = userChoice.contains('(') && userChoice.contains('FCFA');
      
      if (hasSpecificPrice) {
        // Choix avec prix spécifique → Actions finales (peu importe l'étape)
        final priceMatch = RegExp(r'\((\d+)\s*FCFA\)').firstMatch(userChoice);
        final price = priceMatch != null ? int.parse(priceMatch.group(1)!) : 0;
        final economie = nouvelleDepense - price;
        
        // Réponses intelligentes et naturelles par catégorie
        if (category == TransactionCategory.transport) {
          if (userChoice.contains('gbaka') || userChoice.contains('Gbaka')) {
            message = '🚐 Ah parfait ! Le gbaka à $price FCFA, c\'est vraiment le bon choix ! Tu vas économiser ${economie.toStringAsFixed(0)} FCFA et en plus c\'est rapide. Bravo pour cette décision intelligente !';
          } else if (userChoice.contains('bus') || userChoice.contains('Bus')) {
            message = '🚌 Excellente idée ! Le bus à $price FCFA, c\'est économique et pratique. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu contribues à l\'environnement. Continue comme ça !';
          } else if (userChoice.contains('woro') || userChoice.contains('Woro')) {
            message = '🚐 Super choix ! Le woroworo à $price FCFA, c\'est vraiment une option viable. Tu as économisé ${economie.toStringAsFixed(0)} FCFA par rapport à un trajet plus cher ! Bravo pour ta gestion budgétaire !';
          } else if (userChoice.contains('taxi') || userChoice.contains('Taxi')) {
            message = '🚕 Pas mal ! Le taxi à $price FCFA, c\'est confortable et rapide. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu arrives à l\'heure. Bon compromis !';
          } else if (userChoice.contains('moto') || userChoice.contains('Moto')) {
            message = '🏍️ Bon choix ! La moto à $price FCFA, c\'est rapide et pratique. Tu économises ${economie.toStringAsFixed(0)} FCFA !';
          } else if (userChoice.contains('marche') || userChoice.contains('Marche') || userChoice.contains('0 FCFA')) {
            message = '🚶‍♂️ Génial ! Marcher, c\'est gratuit et c\'est excellent pour la santé. Tu économises ${nouvelleDepense.toStringAsFixed(0)} FCFA et tu fais de l\'exercice. Double bénéfice !';
          }
        } else if (category == TransactionCategory.food) {
          if (userChoice.contains('street') || userChoice.contains('Street')) {
            message = '🍜 Excellente idée ! La street food à $price FCFA, c\'est délicieux et authentique. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu découvres la vraie cuisine locale. Parfait !';
          } else if (userChoice.contains('cantine') || userChoice.contains('Cantine')) {
            message = '🍽️ Super choix ! La cantine populaire à $price FCFA, c\'est vraiment un bon rapport qualité-prix. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu manges équilibré. Continue comme ça !';
          } else if (userChoice.contains('marché') || userChoice.contains('Marché') || userChoice.contains('local')) {
            message = '🥬 Brillant ! Le marché local à $price FCFA, c\'est frais et économique. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu soutiens les producteurs locaux. Très malin !';
          } else if (userChoice.contains('cuisine') || userChoice.contains('Cuisine') || userChoice.contains('maison')) {
            message = '👨‍🍳 Fantastique ! Cuisiner à la maison à $price FCFA, c\'est sain et économique. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu maîtrises ce que tu manges. Excellente décision !';
          } else if (userChoice.contains('restaurant') || userChoice.contains('Restaurant')) {
            message = '🍴 Pas mal ! Le restaurant à $price FCFA, c\'est agréable pour se faire plaisir. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu passes un bon moment. Bon équilibre !';
          }
        } else if (category == TransactionCategory.shopping) {
          if (userChoice.contains('marché') || userChoice.contains('Marché') || userChoice.contains('populaire')) {
            message = '🛍️ Super stratégie ! Le marché populaire à $price FCFA, c\'est vraiment malin. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu trouves des bonnes affaires. Continue comme ça !';
          } else if (userChoice.contains('achat') || userChoice.contains('gros')) {
            message = '📦 Excellente stratégie ! L\'achat en gros à $price FCFA, c\'est intelligent pour économiser à long terme. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu as des réserves. Très bien pensé !';
          } else if (userChoice.contains('groupé') || userChoice.contains('Groupé')) {
            message = '👥 Génial ! L\'achat groupé à $price FCFA, c\'est une excellente idée. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu partages les coûts avec d\'autres. Très malin !';
          } else if (userChoice.contains('soldes') || userChoice.contains('Soldes')) {
            message = '🏷️ Parfait ! Attendre les soldes à $price FCFA, c\'est de la patience récompensée. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu as la même qualité. Bravo pour ta patience !';
          }
        } else if (category == TransactionCategory.entertainment) {
          if (userChoice.contains('parc') || userChoice.contains('Parc') || userChoice.contains('public')) {
            message = '🌳 Fantastique ! Le parc public à $price FCFA, c\'est gratuit et super pour se détendre. Tu économises ${nouvelleDepense.toStringAsFixed(0)} FCFA et tu prends l\'air. Parfait pour le moral !';
          } else if (userChoice.contains('événement') || userChoice.contains('Événement') || userChoice.contains('local')) {
            message = '🎉 Excellente idée ! L\'événement local à $price FCFA, c\'est convivial et pas cher. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu rencontres du monde. Super choix !';
          } else if (userChoice.contains('gratuit') || userChoice.contains('Gratuit') || userChoice.contains('0 FCFA')) {
            message = '🎯 Génial ! L\'activité gratuite, c\'est parfait pour s\'amuser sans dépenser. Tu économises ${nouvelleDepense.toStringAsFixed(0)} FCFA et tu passes un bon moment. Très malin !';
          } else if (userChoice.contains('maison') || userChoice.contains('Maison')) {
            message = '🏠 Brillant ! Les jeux à la maison à $price FCFA, c\'est convivial et économique. Tu économises ${economie.toStringAsFixed(0)} FCFA et tu passes du temps en famille. Parfait !';
          }
        } else if (category == TransactionCategory.health) {
          if (userChoice.contains('pharmacie') || userChoice.contains('Pharmacie') || userChoice.contains('populaire')) {
            message = '💊 Très bonne décision ! La pharmacie populaire à $price FCFA, c\'est fiable et abordable. Tu économises ${economie.toStringAsFixed(0)} FCFA sur ta santé. C\'est important de prendre soin de soi !';
          } else if (userChoice.contains('mutuelle') || userChoice.contains('Mutuelle')) {
            message = '🏥 Excellente décision ! La mutuelle à $price FCFA, c\'est une protection intelligente. Tu économises ${economie.toStringAsFixed(0)} FCFA à long terme. Très bien pensé !';
          } else if (userChoice.contains('consultation') || userChoice.contains('Consultation') || userChoice.contains('gratuit')) {
            message = '👨‍⚕️ Parfait ! La consultation gratuite, c\'est une excellente option. Tu économises ${nouvelleDepense.toStringAsFixed(0)} FCFA et tu prends soin de ta santé. Très malin !';
          }
        } else {
          // Catégorie générique
          message = '💡 Excellente décision ! Tu économises ${economie.toStringAsFixed(0)} FCFA avec ce choix intelligent. Continue comme ça !';
        }
        
        // Actions finales pour TOUS les choix avec prix spécifiques
        options = ['Enregistrer ($price FCFA)', 'Modifier le montant', 'Fermer'];
      } else {
        // Choix générique → Plus d'alternatives intelligentes
        if (userChoice.contains('chercher') || userChoice.contains('alternatives') || userChoice.contains('moins cher')) {
          // Proposer plus d'alternatives selon la catégorie
          if (category == TransactionCategory.transport) {
            message = '💡 Ok, je vois que tu veux optimiser ! Voici d\'autres options sympas :';
            options = ['Taxi (600-1000 FCFA)', 'Moto (500-800 FCFA)', 'Woro-woro (400-700 FCFA)', 'Marcher (0 FCFA)'];
          } else if (category == TransactionCategory.food) {
            message = '🍽️ Pas de souci ! Voici d\'autres options pour bien manger sans se ruiner :';
            options = ['Street food (1000-2000 FCFA)', 'Cantine populaire (800-1500 FCFA)', 'Marché local (500-1200 FCFA)', 'Cuisine maison (300-800 FCFA)'];
          } else if (category == TransactionCategory.shopping) {
            message = '🛍️ Bien sûr ! Voici comment faire de bonnes affaires :';
            options = ['Marché populaire (économies 40%)', 'Achat en gros (économies 30%)', 'Achat groupé (économies 25%)', 'Attendre les soldes (économies 50%)'];
          } else if (category == TransactionCategory.entertainment) {
            message = '🎮 Pas de problème ! Voici des activités sympas qui ne coûtent pas cher :';
            options = ['Parc public (0-500 FCFA)', 'Événement local (1000-3000 FCFA)', 'Activité gratuite (0 FCFA)', 'Jeux à la maison (200-1000 FCFA)'];
          } else if (category == TransactionCategory.health) {
            message = '🏥 Bien sûr ! Voici comment prendre soin de ta santé sans te ruiner :';
            options = ['Pharmacie populaire (économies 30%)', 'Mutuelle (protection long terme)', 'Consultation gratuite (0 FCFA)', 'Prévention (économies 70%)'];
          } else {
            message = '💡 Pas de souci ! Voici d\'autres alternatives intelligentes :';
            options = ['Comparer les prix', 'Négocier', 'Attendre les soldes', 'Achat groupé'];
          }
        } else {
          // Choix générique non reconnu
          message = '💡 Merci pour cette conversation ! Tu as pris une décision éclairée pour ton budget. Continue comme ça !';
          options = ['Enregistrer la transaction', 'Modifier le montant', 'Fermer'];
        }
      }
      
      return {
        'message': message,
        'options': options,
      };
  }

     /// Retourne le nom de la catégorie en français
   String _getCategoryName(TransactionCategory category) {
     return CategoryUtils.getCategoryName(category);
   }

   /// Parse la réponse de Gemini en liste de conseils pour le dashboard
   List<String> _parseFinancialTips(String response) {
    final lines = response.split('\n');
     final tips = <String>[];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isNotEmpty && 
          (trimmedLine.startsWith('-') || 
           trimmedLine.startsWith('•') || 
           trimmedLine.startsWith('Conseil') ||
           trimmedLine.contains(':'))) {
        
        // Nettoyer le formatage
         String tip = trimmedLine;
         if (tip.startsWith('- ')) tip = tip.substring(2);
         if (tip.startsWith('• ')) tip = tip.substring(2);
         if (tip.contains(':')) {
           tip = tip.split(':').skip(1).join(':').trim();
         }
         
         if (tip.isNotEmpty) {
           tips.add(tip);
        }
      }
    }
    
    // Si aucun conseil n'a été trouvé, traiter la réponse comme un seul conseil
     if (tips.isEmpty && response.trim().isNotEmpty) {
       tips.add(response.trim());
     }
     
     return tips.take(3).toList(); // Limiter à 3 conseils
  }

  /// Conseils pour le dashboard (version simplifiée)
  Future<List<String>> getFinancialTips({
    required double currentBalance,
    required double monthlyBudget,
    required List<TransactionModel> transactions,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
      final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
      final remainingBudget = monthlyBudget - totalExpenses;

      final prompt = '''
Analyse cette situation financière et donne 3 conseils pratiques :

Solde actuel : ${currentBalance.toStringAsFixed(0)} FCFA
Budget mensuel : ${monthlyBudget.toStringAsFixed(0)} FCFA
Dépenses totales : ${totalExpenses.toStringAsFixed(0)} FCFA
Budget restant : ${remainingBudget.toStringAsFixed(0)} FCFA

Donne 3 conseils courts et pratiques en français, adaptés au contexte ivoirien.
Sois encourageant et utilise des emojis appropriés.

Format :
- Conseil 1: [conseil]
- Conseil 2: [conseil]
- Conseil 3: [conseil]
''';

      final response = await _callGemini(prompt);
       // Parser la réponse en liste de conseils
       return _parseFinancialTips(response);
    } catch (e) {
      _setError('Erreur lors de la génération des conseils: $e');
      return _getDefaultFinancialTips(currentBalance, monthlyBudget, transactions);
    } finally {
      _setLoading(false);
    }
  }

  /// Conseils financiers par défaut pour le dashboard
  List<String> _getDefaultFinancialTips(
    double currentBalance,
    double monthlyBudget,
    List<TransactionModel> transactions,
  ) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();
    final totalExpenses = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final remainingBudget = monthlyBudget - totalExpenses;

    final tips = <String>[];

    if (remainingBudget < 0) {
      tips.add('🚨 Votre budget est dépassé. Considérez réduire vos dépenses non essentielles ce mois-ci.');
    } else if (remainingBudget < monthlyBudget * 0.2) {
      tips.add('⚠️ Il vous reste peu de budget. Soyez prudent avec vos dépenses restantes.');
    } else {
      tips.add('✅ Excellent ! Vous gérez bien votre budget. Continuez ainsi !');
    }

    final foodExpenses = expenses.where((e) => e.category == TransactionCategory.food).fold(0.0, (sum, e) => sum + e.amount);
    if (foodExpenses > totalExpenses * 0.4) {
      tips.add('🍽️ Vous dépensez beaucoup en nourriture. Essayez de cuisiner plus à la maison pour économiser.');
    }

    if (tips.length < 3) {
      tips.add('💡 Pensez à épargner au moins 10% de vos revenus pour vos objectifs futurs.');
    }

    return tips.take(3).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
