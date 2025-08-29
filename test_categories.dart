import 'lib/utils/category_utils.dart';
import 'lib/models/transaction_model.dart';

void main() {
  print('🧪 Test des traductions de catégories\n');
  
  print('📋 Test de getCategoryName:');
  for (final category in TransactionCategory.values) {
    final name = CategoryUtils.getCategoryName(category);
    print('  ${category.name} → $name');
  }
  
  print('\n🎨 Test de getCategoryIcon:');
  for (final category in TransactionCategory.values) {
    final icon = CategoryUtils.getCategoryIcon(category);
    print('  ${category.name} → $icon');
  }
  
  print('\n🎨 Test de getCategoryColor:');
  for (final category in TransactionCategory.values) {
    final color = CategoryUtils.getCategoryColor(category);
    print('  ${category.name} → 0x${color.toRadixString(16).toUpperCase()}');
  }
  
  print('\n💰 Catégories de revenus:');
  final incomeCategories = CategoryUtils.getIncomeCategories();
  for (final category in incomeCategories) {
    print('  ${CategoryUtils.getCategoryIcon(category)} ${CategoryUtils.getCategoryName(category)}');
  }
  
  print('\n💸 Catégories de dépenses:');
  final expenseCategories = CategoryUtils.getExpenseCategories();
  for (final category in expenseCategories) {
    print('  ${CategoryUtils.getCategoryIcon(category)} ${CategoryUtils.getCategoryName(category)}');
  }
  
  print('\n✅ Test terminé !');
}
