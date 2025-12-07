import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:wallet_watch/services/User_service.dart';
import 'package:wallet_watch/services/transaction_service.dart';
import 'package:wallet_watch/services/budget_service.dart';
import 'package:wallet_watch/services/goal_service.dart';
import 'package:wallet_watch/services/loan_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late TransactionService transactionService;
  late BudgetService budgetService;
  late GoalService goalService;
  late UserService userService;
  late LoanService loanService;
  const userId = "system_test_user_final";

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    transactionService = TransactionService(firestore: fakeFirestore);
    budgetService = BudgetService(firestore: fakeFirestore);
    goalService = GoalService(firestore: fakeFirestore);
    userService = UserService(firestore: fakeFirestore);
    loanService = LoanService(firestore: fakeFirestore);
  });

  group("SYSTEM INTEGRATION — Real Money Flow", () {

    test("Full User Journey: Balance updates on Spend & Repayment", () async {
      print('\n Start tests');

      // --- STEP 1: SETUP (Balance: 50,000) ---
      print('\n[STEP 1] Setup: User starts with 50,000');
      await userService.createUserProfile(userId, {
        "name": "Nainika",
        "email": "test@walletwatch.com",
        "totalMoney": 50000.0
      });
      expect(await userService.getTotalMoney(userId), 50000.0);


      // --- STEP 2: BUDGET ---
      print('\n[STEP 2] Setup: Set Budget Limit to 10,000');
      await budgetService.setBudget(userId, 10000.0);


      // --- STEP 3: EXPENSE (Cost: 2,000) ---
      // Logic: 1. Add Transaction -> 2. Update Budget -> 3. DEDUCT MONEY
      print('\n[STEP 3] Action: Buy Laptop (Expense: 2000.0)');

      // 3.1 Record the Transaction
      await transactionService.addTransaction(userId, {
        "amount": 2000.0,
        "type": "Expense",
        "category": "Electronics",
        "date": DateTime.now().toString(),
      });

      // 3.2 Update Budget Tracker
      await budgetService.addToSpent(userId, 2000.0);
      final budgetDoc = await fakeFirestore.collection("users").doc(userId).get();
      expect(budgetDoc.data()?["spent"], 2000.0);

      // 3.3 DEDUCT FROM WALLET (Crucial Step)
      // UI Logic: Old Balance (50,000) - Expense (2,000) = 48,000
      double currentBalance = await userService.getTotalMoney(userId);
      await userService.updateTotalMoney(userId, currentBalance - 2000.0);

      final balanceAfterExpense = await userService.getTotalMoney(userId);
      print('   -> Balance deducted. New Balance: $balanceAfterExpense');
      expect(balanceAfterExpense, 48000.0);


      // --- STEP 4: GOAL ---
      print('\n[STEP 4] Action: Create Goal (Europe Trip)');
      await goalService.addGoal(userId, {
        "title": "Europe Trip",
        "target": 150000.0,
        "saved": 0.0
      });


      // --- STEP 5: LOAN REPAYMENT (Cost: 10,000) ---
      // Logic: 1. Take Loan -> 2. Repay Part -> 3. DEDUCT MONEY
      print('\n[STEP 5] Action: Loan Creation and Repayment');

      // 5.1 Create the Liability (No cash flow assumed, just tracking debt)
      await loanService.createLoan(userId, 50000.0);
      final loanSnap = await fakeFirestore.collection("users").doc(userId).collection("loans").get();
      final loanId = loanSnap.docs.first.id;

      // 5.2 Repay 10,000
      print('   -> Repaying 10,000 towards loan...');
      await loanService.repayLoan(userId, loanId, 10000.0);

      // 5.3 DEDUCT FROM WALLET
      // UI Logic: Current (48,000) - Repayment (10,000) = 38,000
      currentBalance = await userService.getTotalMoney(userId);
      await userService.updateTotalMoney(userId, currentBalance - 10000.0);

      final balanceAfterLoan = await userService.getTotalMoney(userId);
      print('   -> Repayment complete. New Balance: $balanceAfterLoan');
      expect(balanceAfterLoan, 38000.0);


      // --- STEP 6: SALARY (Income: 5,000) ---
      print('\n[STEP 6] Action: Salary Credit (+5000)');

      currentBalance = await userService.getTotalMoney(userId);
      await userService.updateTotalMoney(userId, currentBalance + 5000.0);

      final finalBalance = await userService.getTotalMoney(userId);
      print('   -> Salary credited. Final Balance: $finalBalance');

      // Calculation: 38,000 + 5,000 = 43,000
      expect(finalBalance, 43000.0);

      print('\n TEST COMPLETED SUCCESSFULLY\n');
    });

  });
}