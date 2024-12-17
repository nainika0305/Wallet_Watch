import 'package:flutter/material.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFAQItem(
              context,
              icon: Icons.attach_money,
              question: 'What is compound interest?',
              answer:
              'Compound interest is the interest on a loan or deposit that is calculated based on both the initial principal and the accumulated interest from previous periods.',
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.account_balance_wallet,
              question: 'How do I create an emergency fund?',
              answer:
              'Start by saving 3-6 months of living expenses in a separate account. Focus on cutting non-essential expenses to build your fund faster.',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.money_off,
              question: 'What are the risks of investing in the stock market?',
              answer:
              'The stock market is volatile, and prices can fluctuate dramatically. Risks include market crashes, poor company performance, and changes in economic conditions.',
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.savings,
              question: 'What is the 50/30/20 rule in budgeting?',
              answer:
              'The 50/30/20 rule suggests that you allocate 50% of your income to needs, 30% to wants, and 20% to savings or debt repayment.',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.assessment,
              question: 'What is financial independence?',
              answer:
              'Financial independence means having enough income to cover your living expenses without relying on active employment, usually achieved through savings and investments.',
              color: Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.house,
              question: 'Is renting or buying a home better?',
              answer:
              'It depends on your financial situation. Buying can build equity, but renting offers flexibility. Consider your long-term goals, maintenance costs, and market conditions.',
              color: Colors.brown,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.redeem,
              question: 'How can I reduce my taxes legally?',
              answer:
              'Contribute to retirement accounts like 401(k)s and IRAs, take advantage of tax deductions, and consider tax-efficient investments to reduce your taxable income.',
              color: Colors.cyan,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.credit_card,
              question: 'What is a credit score?',
              answer:
              'A credit score is a numerical representation of your creditworthiness, typically ranging from 300 to 850. It affects your ability to borrow money and the interest rates you’ll receive.',
              color: Colors.indigo,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.pie_chart,
              question: 'What is the importance of diversification in investing?',
              answer:
              'Diversification spreads your investments across different asset classes to reduce risk. It helps minimize the impact of any single investment’s poor performance on your overall portfolio.',
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context,
      {required IconData icon,
        required String question,
        required String answer,
        required Color color}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  radius: 30,
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
