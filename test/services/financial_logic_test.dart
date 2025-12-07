import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_watch/services/financial_logic.dart';

void main() {
  group('FINANCIAL LOGIC — Utilities Suite', () {

    // Validates logic for FR5.7: The system shall... display the converted amount.
    // Supports the "Currency Conversion" feature described in Section 7 of SRS.
    test('Convert: Standard Rate', () {
      expect(FinancialLogic.convertCurrency(100, 1.5), 150.0);
    });

    test('Convert: Zero Amount', () {
      expect(FinancialLogic.convertCurrency(0, 80.0), 0.0);
    });

    // Ensures precision for financial calculations (Critical for Data Integrity NFR2.2)
    test('Convert: High Precision', () {
      double result = FinancialLogic.convertCurrency(10.123, 2.0);
      expect(result, 20.246);
    });

    // Validates logic for the "Tax Estimation Tool" feature (Section 8 of SRS).
    // Supports User Capability listed in Section 2.2: "Use a tax estimation tool".
    test('Tax: 10% of standard income', () {
      expect(FinancialLogic.estimateTax(100000, 0.10), 10000.0);
    });

    test('Tax: 0% tax rate', () {
      expect(FinancialLogic.estimateTax(500000, 0.0), 0.0);
    });

    test('Tax: Zero income yields zero tax', () {
      expect(FinancialLogic.estimateTax(0, 0.30), 0.0);
    });

    // Satisfies FR2.7: The system shall provide a filter on the "Transactions" page to view by Income, Expense, or Category.
    test('Filter: Returns only matching types', () {
      final data = [
        {"type": "Income", "val": 10},
        {"type": "Expense", "val": 20},
        {"type": "Income", "val": 30},
      ];
      final res = FinancialLogic.filterTransactions(data, "Income");
      expect(res.length, 2);
      expect(res[0]["val"], 10);
      expect(res[1]["val"], 30);
    });

    // Validates robustness of the filter for FR2.7 (Empty results case)
    test('Filter: Returns empty list if no matches', () {
      final data = [
        {"type": "Expense", "val": 20},
      ];
      final res = FinancialLogic.filterTransactions(data, "Income");
      expect(res.isEmpty, true);
    });

    test('Filter: Handles empty input list gracefully', () {
      final res = FinancialLogic.filterTransactions([], "Income");
      expect(res.isEmpty, true);
    });

    // Ensures strict matching to prevent data leakage between categories (Data Integrity NFR2.2)
    test('Filter: Case sensitivity check (Assuming strict match)', () {
      final data = [{"type": "income"}]; // lowercase
      // If your logic checks "Income" (uppercase), this should return empty
      final res = FinancialLogic.filterTransactions(data, "Income");
      expect(res.isEmpty, true);
    });
  });
}