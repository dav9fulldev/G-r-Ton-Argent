import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
import '../utils/category_utils.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ExpenseChatbotWidget extends StatefulWidget {
  final double amount;
  final TransactionCategory? category;
  final String? description;
  final VoidCallback? onClose;

  const ExpenseChatbotWidget({
    super.key,
    required this.amount,
    this.category,
    this.description,
    this.onClose,
  });

  @override
  State<ExpenseChatbotWidget> createState() => _ExpenseChatbotWidgetState();
}

class _ExpenseChatbotWidgetState extends State<ExpenseChatbotWidget> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final categoryName = widget.category != null 
        ? CategoryUtils.getCategoryName(widget.category!)
        : 'cette dépense';
    
    // Calculer l'impact sur le budget
    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    
    final budget = authService.currentUser?.monthlyBudget ?? 0;
    final totalExpenses = transactionService.totalExpenses;
    final remainingBudget = budget - totalExpenses;
    final impactPercentage = (widget.amount / remainingBudget) * 100;
    
    String welcomeMessage = 'Bonjour ! Je vais analyser votre dépense de ${widget.amount.toStringAsFixed(0)} FCFA pour $categoryName. ';
    welcomeMessage += 'Cette dépense représente ${impactPercentage.toStringAsFixed(1)}% de votre budget restant (${remainingBudget.toStringAsFixed(0)} FCFA). ';
    
    // Ajouter des conseils selon le pourcentage
    if (impactPercentage > 50) {
      welcomeMessage += '⚠️ Attention : dépense importante ! Cette dépense est-elle vraiment nécessaire ou c\'est un achat impulsif ?';
    } else if (impactPercentage > 30) {
      welcomeMessage += '💡 Dépense modérée. Cette dépense est-elle vraiment nécessaire ou c\'est un achat impulsif ?';
    } else {
      welcomeMessage += '✅ Dépense raisonnable. Cette dépense est-elle vraiment nécessaire ou c\'est un achat impulsif ?';
    }
    
    _messages.add(ChatMessage(
      text: welcomeMessage,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Ajouter le message utilisateur
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final transactionService = Provider.of<TransactionService>(context, listen: false);
      
      if (authService.currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      final budget = authService.currentUser!.monthlyBudget;
      final totalExpenses = transactionService.totalExpenses;
      final currentBalance = budget - totalExpenses;
      final recentTransactions = transactionService.currentMonthTransactions.take(5).toList();

      // Construire un message contextuel pour l'IA
      final remainingBudget = budget - totalExpenses;
      final impactPercentage = (widget.amount / remainingBudget) * 100;
      
      String contextualMessage = 'Dépense analysée: ${widget.amount.toStringAsFixed(0)} FCFA pour ${widget.category != null ? CategoryUtils.getCategoryName(widget.category!) : "cette catégorie"}. ';
      contextualMessage += 'Impact: ${impactPercentage.toStringAsFixed(1)}% du budget restant. ';
      contextualMessage += 'Réponse de l\'utilisateur: $userMessage';
      
             // Préparer l'historique de conversation
       final conversationHistory = _messages.map((msg) => {
         'isUser': msg.isUser,
         'text': msg.text,
       }).toList();

       final response = await Provider.of<GeminiService>(context, listen: false).sendMessage(
         userMessage: contextualMessage,
         userName: authService.currentUser!.name,
         monthlyBudget: budget.toDouble(),
         totalIncome: budget.toDouble(),
         totalExpenses: totalExpenses.toDouble(),
         currentBalance: currentBalance.toDouble(),
         recentTransactions: recentTransactions,
         conversationHistory: conversationHistory,
       );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Désolé, je ne peux pas répondre pour le moment. Veuillez réessayer.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                                     child: Text(
                     'Assistant Financier',
                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       color: Colors.green.shade800,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(Icons.close, color: Colors.green.shade700),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

                     // Messages
           Expanded(
             child: ListView.builder(
               controller: _scrollController,
               padding: const EdgeInsets.all(16),
               itemCount: _messages.length + (_isTyping ? 1 : 0),
               itemBuilder: (context, index) {
                 if (index == _messages.length && _isTyping) {
                   return _TypingIndicator();
                 }
                 return Column(
                   children: [
                     _MessageBubble(message: _messages[index]),
                                           // Boutons de réponse rapide pour le premier message seulement
                      if (index == 0 && !_messages[index].isUser)
                        _QuickResponseButtons(
                          onResponse: (response) {
                            _messageController.text = response;
                            _sendMessage();
                          },
                        ),
                   ],
                 );
               },
             ),
           ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    onPressed: _isTyping ? null : _sendMessage,
                    icon: _isTyping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.green.shade700,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.green.shade600
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}



class _QuickResponseButtons extends StatelessWidget {
  final Function(String) onResponse;

  const _QuickResponseButtons({required this.onResponse});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => onResponse('Oui c\'est nécessaire'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade100,
                foregroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Oui c\'est nécessaire', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => onResponse('Non c\'est impulsif'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Non c\'est impulsif', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.smart_toy,
              color: Colors.green.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'En train d\'écrire...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
