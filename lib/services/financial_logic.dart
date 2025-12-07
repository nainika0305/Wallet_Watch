// lib/services/financial_logic.dart

class FinancialLogic {
  /// Calculates the converted amount based on the rate
  static double convertCurrency(double amount, double rate) {
    return amount * rate;
  }

  /// Calculates tax based on income and a specific tax rate (e.g., 0.10 for 10%)
  static double estimateTax(double income, double taxRate) {
    return income * taxRate;
  }

  /// Filters a list of transactions to return only those matching the 'type'
  static List<Map<String, dynamic>> filterTransactions(
      List<Map<String, dynamic>> transactions, String type) {
    return transactions.where((t) => t["type"] == type).toList();
  }
}