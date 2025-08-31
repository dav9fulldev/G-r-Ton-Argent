import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart'; // Added import for UserModel

class GeminiService extends ChangeNotifier {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  static const String _apiKey = 'AIzaSyDSi9hzAndIPYi3S2MaxO40RT6odd6bBHw';

  Future<String> sendMessage({
    required String userMessage,
    required String userName,
    required double monthlyBudget,
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    List<TransactionModel>? recentTransactions,
    List<String>? conversationHistory,
  }) async {
    try {
      final user = UserModel(
        uid: 'temp_uid',
        name: userName, 
        monthlyBudget: monthlyBudget,
        email: '',
        createdAt: DateTime.now(),
        aiAdviceEnabled: true,
      );
      final context = _buildContext(user, recentTransactions ?? [], userMessage, conversationHistory ?? []);

      // Construire l'historique de conversation
      String conversationText = '';
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        conversationText = '\n\nHISTORIQUE DE LA CONVERSATION:\n';
        for (final message in conversationHistory) {
          conversationText += 'Assistant: $message\n';
        }
      }

      // Message optimisé avec historique
      final fullMessage = '''Tu es un conseiller financier de l'application GèrTonArgent. 

CONTEXTE: $context$conversationText

MESSAGE UTILISATEUR: $userMessage

RÈGLES IMPORTANTES:
- Utilise SEULEMENT le prénom (pas le nom complet)
- Ne répète PAS les informations déjà données
- Va directement au sujet sans redire ce qui a déjà été dit
- Sois direct et concis (1-2 phrases max)
- Donne des conseils concrets et des alternatives
- Considère l'historique de la conversation pour éviter la répétition
- Si l'utilisateur dit "impulsif" → Propose directement des alternatives
- Si l'utilisateur demande des conseils → Donne des suggestions spécifiques
- Si l'utilisateur tape un nombre seul → Demande confirmation "X FCFA ?"
- Si l'utilisateur dit "bye", "au revoir", "merci" → Propose de fermer le chatbot

RÉPONSE:''';

      if (kDebugMode) {
        print('=== REQUÊTE GEMINI ===');
        print('URL: $_baseUrl?key=${_apiKey.substring(0, 10)}...');
        print('Message complet: $fullMessage');
        print('Body JSON: ${jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': fullMessage,
                }
              ]
            }
          ]
        })}');
        print('=== FIN REQUÊTE ===');
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
                  'text': fullMessage,
                }
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (kDebugMode) {
          print('Réponse API Gemini: ${response.body}');
        }
        
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          final responseText = data['candidates'][0]['content']['parts'][0]['text'];
          if (kDebugMode) {
            print('=== RÉPONSE GEMINI ===');
            print('Texte de réponse: $responseText');
            print('=== FIN RÉPONSE ===');
          }
          return responseText;
        } else {
          if (kDebugMode) {
            print('Structure de réponse invalide: $data');
          }
          throw Exception('Réponse invalide de l\'API Gemini');
        }
      } else {
        if (kDebugMode) {
          print('Erreur HTTP: ${response.statusCode}');
          print('Corps de réponse: ${response.body}');
        }
        throw Exception('Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erreur Gemini API: $e');
        print('URL: $_baseUrl?key=${_apiKey.substring(0, 10)}...');
        print('Message: $userMessage');
      }
      
      // Fallback temporaire pour tester
      return 'Désolé, l\'API ne fonctionne pas actuellement. Erreur: $e';
    }
  }

  String _buildContext(UserModel user, List<TransactionModel> transactions, String userMessage, List<String> conversationHistory) {
    final firstName = user.name.split(' ').last;
    final totalExpenses = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpenses;
    final budgetRemaining = user.monthlyBudget - totalExpenses;
    final budgetPercentage = user.monthlyBudget > 0 ? (totalExpenses / user.monthlyBudget) * 100 : 0;

    // Analyser le message utilisateur pour détecter l'intention
    final userMessageLower = userMessage.toLowerCase();
    final isEndingConversation = userMessageLower.contains('merci') || 
                                userMessageLower.contains('ok') || 
                                userMessageLower.contains('d\'accord') ||
                                userMessageLower.contains('fin') ||
                                userMessageLower.contains('terminé') ||
                                userMessageLower.contains('fermer');

    // Construire l'historique de conversation
    final conversationContext = conversationHistory.isNotEmpty 
        ? '\nHISTORIQUE DE CONVERSATION:\n${conversationHistory.join('\n')}'
        : '';

    return '''
Tu es l'assistant financier intelligent de l'application GèrTonArgent.

INFORMATIONS UTILISATEUR:
- Prénom: $firstName
- Budget mensuel: ${user.monthlyBudget} FCFA
- Dépenses déjà effectuées: ${totalExpenses.toStringAsFixed(0)} FCFA (${budgetPercentage.toStringAsFixed(1)}% du budget)
- Budget restant: ${budgetRemaining.toStringAsFixed(0)} FCFA
- Solde actuel: ${balance.toStringAsFixed(0)} FCFA

TRANSACTIONS RÉCENTES:
${transactions.take(3).map((t) => '- ${t.amount} FCFA pour ${_getCategoryName(t.category)} (${t.type.name})').join('\n')}

RÈGLES DE CONVERSATION STRICTES:
1. Utilise SEULEMENT le prénom "$firstName" (jamais le nom complet)
2. Ne répète JAMAIS les informations déjà données dans la conversation
3. Va directement au sujet sans redire ce qui a déjà été dit
4. Sois direct et concis (1-2 phrases maximum)
5. Pose des questions ou donne des conseils concrets
6. Évite les salutations répétitives

GESTION DE LA FIN DE CONVERSATION:
- Si l'utilisateur dit "merci", "ok", "d'accord", "fin", "terminé" → Réponds simplement "Parfait ! N'hésitez pas si vous avez d'autres questions." et arrête la conversation
- Si l'utilisateur dit "fermer" → Réponds "Au revoir !" et arrête la conversation
- Ne pose JAMAIS de questions après que l'utilisateur ait exprimé sa satisfaction

LOGIQUE DE CONVERSATION:
- Si l'utilisateur confirme que c'est nécessaire → Donne des conseils d'optimisation
- Si l'utilisateur dit que c'est impulsif → Propose des alternatives
- Si l'utilisateur demande des alternatives → Donne des suggestions concrètes
- Si l'utilisateur exprime sa satisfaction → Termine la conversation poliment

$conversationContext

MESSAGE UTILISATEUR: $userMessage

RÉPONSE:''';
  }

   String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Nourriture';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.entertainment:
        return 'Divertissement';
      case TransactionCategory.health:
        return 'Santé';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.utilities:
        return 'Factures';
      case TransactionCategory.education:
        return 'Éducation';
      case TransactionCategory.salary:
        return 'Salaire';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investissement';
      case TransactionCategory.other:
        return 'Autre';
    }
  }

  String _generateFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Réponses intelligentes basées sur le contenu du message
    if (lowerMessage.contains('impulsif') || lowerMessage.contains('impulsive')) {
      return '💡 Achat impulsif détecté ! Pour économiser, attendez 24h avant d\'acheter. Si vous y pensez encore, c\'est peut-être nécessaire. Sinon, vous venez d\'économiser !';
    }
    
    if (lowerMessage.contains('transport') || lowerMessage.contains('voiture') || lowerMessage.contains('taxi')) {
      return '🚌 Alternatives économiques : marche (gratuit), bus (200-500 FCFA), covoiturage. Vous économiserez 70-90% !';
    }
    
    if (lowerMessage.contains('nourriture') || lowerMessage.contains('restaurant') || lowerMessage.contains('manger')) {
      return '🍽️ Conseils : cuisinez à la maison (économisez 60%), achetez en gros, évitez les restaurants. Budget alimentaire recommandé : 30% max.';
    }
    
    if (lowerMessage.contains('nécessaire') || lowerMessage.contains('besoin')) {
      return '✅ Si c\'est vraiment nécessaire, allez-y ! Mais vérifiez : pouvez-vous l\'emprunter ? L\'acheter d\'occasion ? Attendre les soldes ?';
    }
    
    if (lowerMessage.contains('attendre') || lowerMessage.contains('plus tard')) {
      return '⏰ Excellente décision ! En attendant, mettez cet argent de côté. Vous verrez si vous en avez vraiment besoin plus tard.';
    }
    
    if (lowerMessage.contains('budget') || lowerMessage.contains('impact')) {
      return '📊 Règle d\'or : dépensez max 30% de votre budget restant par achat. Au-delà, réfléchissez bien !';
    }
    
    if (lowerMessage.contains('quoi') && lowerMessage.contains('exemple')) {
      return '🍳 Exemples concrets : 1) Préparez vos repas le dimanche (économisez 2000 FCFA/semaine), 2) Achetez les légumes au marché local (50% moins cher), 3) Utilisez les restes pour le lendemain. Voulez-vous que je vous aide à planifier ?';
    }
    
    if (lowerMessage.contains('ok') || lowerMessage.contains('d\'accord')) {
      return '👍 Parfait ! Maintenant, posez-vous ces questions : 1) Puis-je vivre sans cet achat ? 2) Y a-t-il une alternative moins chère ? 3) Puis-je attendre ? Votre réponse ?';
    }
    
    if (lowerMessage.contains('oui') && lowerMessage.contains('nécessaire')) {
      return '✅ D\'accord, si c\'est vraiment nécessaire ! Mais avant d\'acheter, vérifiez : 1) Prix comparés ? 2) Promotions en cours ? 3) Qualité/prix optimal ? Voulez-vous que je vous aide à optimiser cet achat ?';
    }
    
    if (lowerMessage.contains('non') || lowerMessage.contains('pas nécessaire')) {
      return '🎉 Excellente décision ! Vous venez d\'économiser ! Mettez cet argent de côté pour un objectif important. Voulez-vous que je vous aide à définir un objectif d\'épargne ?';
    }
    
    // Réponse par défaut
    return '💭 Réfléchissez : cette dépense vous apporte-t-elle vraiment de la valeur ? Pouvez-vous la reporter ou la réduire ? Votre budget vous remerciera !';
  }
}
