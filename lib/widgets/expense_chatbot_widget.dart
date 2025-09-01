import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction_model.dart';
// import '../utils/category_utils.dart';

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
    final authService = Provider.of<AuthService>(context, listen: false);
    final transactionService = Provider.of<TransactionService>(context, listen: false);
    
    final user = authService.currentUser;
    if (user == null) return;
    
    final totalExpenses = transactionService.currentMonthExpenses.fold(0.0, (s, t) => s + t.amount);
    final budgetPercentage = user.monthlyBudget > 0 ? (totalExpenses / user.monthlyBudget) * 100 : 0;
    final impactPercentage = user.monthlyBudget > 0 ? (widget.amount / user.monthlyBudget) * 100 : 0;
    
    final welcomeMessage = '''
Bonjour ${user.name.split(' ').last} ! 

Cette dépense de ${widget.amount.toStringAsFixed(0)} FCFA représente ${impactPercentage.toStringAsFixed(1)}% de votre budget restant.

Cette dépense est-elle vraiment nécessaire ou c'est un achat impulsif ?
''';
    
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
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Ajouter le message utilisateur
    _messages.add(ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _messageController.clear();
    _scrollToBottom();

    // Vérifier si l'utilisateur veut terminer la conversation
    final messageLower = message.toLowerCase();
    final isEndingConversation = messageLower.contains('merci') || 
                                messageLower.contains('ok') || 
                                messageLower.contains('d\'accord') ||
                                messageLower.contains('fin') ||
                                messageLower.contains('terminé') ||
                                messageLower.contains('fermer') ||
                                messageLower.contains('au revoir');

    if (isEndingConversation) {
      // Ajouter un message de fin et fermer le chatbot
      _messages.add(ChatMessage(
        text: 'Parfait ! N\'hésitez pas si vous avez d\'autres questions.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
      // Fermer le chatbot après 2 secondes
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
      return;
    }

    // Afficher l'indicateur de frappe
    setState(() {
      _isTyping = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final transactionService = Provider.of<TransactionService>(context, listen: false);
      final geminiService = Provider.of<GeminiService>(context, listen: false);

      final user = authService.currentUser;
      if (user == null) return;

      // Construire l'historique de conversation
      final conversationHistory = _messages
          .where((msg) => !msg.isUser)
          .map((msg) => msg.text)
          .toList();

      final response = await geminiService.sendMessage(
        userMessage: message,
        userName: user.name,
        monthlyBudget: user.monthlyBudget,
        totalIncome: transactionService.currentMonthIncomes.fold(0.0, (s, t) => s + t.amount),
        totalExpenses: transactionService.currentMonthExpenses.fold(0.0, (s, t) => s + t.amount),
        currentBalance: transactionService.currentBalance,
        recentTransactions: transactionService.transactions.take(5).toList(),
        conversationHistory: conversationHistory,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: 'Désolé, une erreur s\'est produite. Veuillez réessayer.',
            isUser: false,
            timestamp: DateTime.now(),
          ));
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 12 : 16), // Plus petit sur web
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
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 6 : 8), // Plus petit sur web
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.green.shade700,
                    size: MediaQuery.of(context).size.width > 600 ? 16 : 20, // Plus petit sur web
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width > 600 ? 8 : 12), // Plus petit sur web
                Expanded(
                  child: Text(
                    'Assistant Financier',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 16, // Plus petit sur web
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    onPressed: widget.onClose,
                    icon: Icon(
                      Icons.close, 
                      color: Colors.green.shade700,
                      size: MediaQuery.of(context).size.width > 600 ? 18 : 20, // Plus petit sur web
                    ),
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
