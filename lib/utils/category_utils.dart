import '../models/transaction_model.dart';

/// Utilitaires pour la gestion des catégories de transactions
class CategoryUtils {
  /// Retourne le nom traduit en français d'une catégorie
  static String getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Nourriture';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.entertainment:
        return 'Divertissement';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.health:
        return 'Santé';
      case TransactionCategory.education:
        return 'Éducation';
      case TransactionCategory.utilities:
        return 'Services';
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

  /// Retourne l'icône associée à une catégorie
  static String getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return '🍽️';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.health:
        return '🏥';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.utilities:
        return '⚡';
      case TransactionCategory.salary:
        return '💰';
      case TransactionCategory.freelance:
        return '💻';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.other:
        return '📋';
    }
  }

  /// Retourne la couleur associée à une catégorie
  static int getCategoryColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 0xFFFF9800; // Orange
      case TransactionCategory.transport:
        return 0xFF2196F3; // Blue
      case TransactionCategory.entertainment:
        return 0xFF9C27B0; // Purple
      case TransactionCategory.shopping:
        return 0xFFE91E63; // Pink
      case TransactionCategory.health:
        return 0xFFF44336; // Red
      case TransactionCategory.education:
        return 0xFF3F51B5; // Indigo
      case TransactionCategory.utilities:
        return 0xFF009688; // Teal
      case TransactionCategory.salary:
        return 0xFF4CAF50; // Green
      case TransactionCategory.freelance:
        return 0xFFFFC107; // Amber
      case TransactionCategory.investment:
        return 0xFF00BCD4; // Cyan
      case TransactionCategory.other:
        return 0xFF9E9E9E; // Grey
    }
  }

  /// Retourne la liste des catégories avec leurs noms traduits
  static List<MapEntry<TransactionCategory, String>> getCategoryList() {
    return TransactionCategory.values.map((category) {
      return MapEntry(category, getCategoryName(category));
    }).toList();
  }

  /// Retourne la liste des catégories de dépenses uniquement
  static List<TransactionCategory> getExpenseCategories() {
    return [
      TransactionCategory.food,
      TransactionCategory.transport,
      TransactionCategory.entertainment,
      TransactionCategory.shopping,
      TransactionCategory.health,
      TransactionCategory.education,
      TransactionCategory.utilities,
      TransactionCategory.other,
    ];
  }

  /// Retourne la liste des catégories de revenus uniquement
  static List<TransactionCategory> getIncomeCategories() {
    return [
      TransactionCategory.salary,
      TransactionCategory.freelance,
      TransactionCategory.investment,
      TransactionCategory.other,
    ];
  }
}
