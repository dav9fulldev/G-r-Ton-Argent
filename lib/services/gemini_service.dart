import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

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
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    try {
      final context = _buildContext(
        userName: userName,
        monthlyBudget: monthlyBudget,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        currentBalance: currentBalance,
        recentTransactions: recentTransactions,
      );

      // Construire l'historique de conversation
      String conversationText = '';
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        conversationText = '\n\nHISTORIQUE DE LA CONVERSATION:\n';
        for (final message in conversationHistory) {
          final role = message['isUser'] ? 'Utilisateur' : 'Assistant';
          final text = message['text'];
          conversationText += '$role: $text\n';
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

  String _buildContext({
    required String userName,
    required double monthlyBudget,
    required double totalIncome,
    required double totalExpenses,
    required double currentBalance,
    List<TransactionModel>? recentTransactions,
  }) {
    final recentTransactionsText = recentTransactions?.isNotEmpty == true
        ? recentTransactions!.take(5).map((t) => 
            '- ${_getCategoryName(t.category)}: ${t.amount.toStringAsFixed(0)} FCFA (${t.description})'
          ).join('\n')
        : 'Aucune transaction récente';

    final budgetPercentage = (totalExpenses / monthlyBudget) * 100;
    final remainingBudget = monthlyBudget - totalExpenses;

    // Extraire le prénom (dernier mot du nom complet)
    final nameParts = userName.split(' ');
    final firstName = nameParts.length > 1 ? nameParts.last : userName;

    return '''Tu es l'assistant financier intelligent de l'application GèrTonArgent. Tu dois guider l'utilisateur dans ses décisions d'achat.

INFORMATIONS UTILISATEUR:
- Prénom: $firstName
- Budget mensuel: ${monthlyBudget.toStringAsFixed(0)} FCFA
- Dépenses déjà effectuées: ${totalExpenses.toStringAsFixed(0)} FCFA (${budgetPercentage.toStringAsFixed(1)}% du budget)
- Budget restant: ${remainingBudget.toStringAsFixed(0)} FCFA
- Solde actuel: ${currentBalance.toStringAsFixed(0)} FCFA

TRANSACTIONS RÉCENTES:
$recentTransactionsText

TON RÔLE - GUIDE DÉCISIONNEL:
1. ANALYSE IMMÉDIATE: Calculer et afficher le pourcentage de la nouvelle dépense sur le budget restant
2. ÉVALUATION: Poser des questions stratégiques pour aider l'utilisateur à réfléchir
3. GUIDANCE: Proposer des alternatives ou des conseils selon les réponses
4. DÉCISION FINALE: Aider l'utilisateur à prendre une décision éclairée

QUESTIONS STRATÉGIQUES À POSER:
- "Cette dépense est-elle vraiment nécessaire ou c'est un achat impulsif ?"
- "Cette dépense peut-elle attendre ou c'est urgent ?"
- "Avez-vous déjà dépensé beaucoup dans cette catégorie ce mois-ci ?"

LOGIQUE DE CONVERSATION:
- Si l'utilisateur dit "c'est impulsif" → Proposer directement des alternatives
- Si l'utilisateur dit "c'est nécessaire" → Vérifier l'urgence et les alternatives
- Si l'utilisateur demande des conseils → Donner des suggestions concrètes
- Si l'utilisateur n'a pas de dépenses prévues → Proposer l'épargne et la planification
- Si l'utilisateur fixe un objectif d'épargne → Proposer des stratégies pour l'atteindre
- Si l'utilisateur dit "bye", "au revoir", "merci" → Proposer de fermer le chatbot
- Ne pas demander "avez-vous des alternatives" car s'il en avait, il n'aurait pas besoin de conseil

RÈGLES DE CONVERSATION:
- Utilise SEULEMENT le prénom "$firstName" (jamais le nom complet)
- Ne répète PAS les informations déjà données dans la conversation
- Va directement au sujet sans redire ce qui a déjà été dit
- Sois direct et concis (1-2 phrases maximum)
- Donne des conseils concrets et des alternatives
- Évite les salutations répétitives
- Si l'utilisateur dit "impulsif" → Propose directement des alternatives
- Si l'utilisateur demande des conseils → Donne des suggestions spécifiques
- Si l'utilisateur dit "bye", "au revoir", "merci", "ok bye" → Propose de fermer le chatbot
- Si l'utilisateur tape un nombre seul (ex: "10000") → Demande confirmation avec l'unité

EXEMPLE DE DÉROULEMENT:
1. Première réponse: "Cette dépense représente X% de votre budget restant. Cette dépense est-elle vraiment nécessaire ?"
2. Réponses suivantes: Directement au sujet sans répéter les informations déjà données

OBJECTIF: Éviter les dépenses inutiles en aidant l'utilisateur à prendre des décisions réfléchies.

IMPORTANT: Si l'utilisateur a déjà répondu à une question, ne la répète pas. Va directement au conseil ou à la question suivante.''';
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
