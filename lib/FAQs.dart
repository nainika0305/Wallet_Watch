import 'package:flutter/material.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
        backgroundColor: const Color(0xFFCDB4DB), // Soft Lavender
      ),

    body: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
      colors: [
      Color(0xFFFFDBE9),
      Color(0xFFE6D8FF), // Very light lavender
      Color(0xFFBDE0FE), // Very light blue
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      ),
      ),

    child:  Container(
        color: const Color(0xFFF9F9F9), // Slightly darker than white (light gray)
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildFAQItem(
              context,
              icon: Icons.attach_money,
              question: 'What is compound interest?',
              answer:
              'Compound interest is the interest on a loan or deposit that is calculated based on both the initial principal and the accumulated interest from previous periods.',
              color: const Color(0xFFCDB4DB), // Soft Lavender
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.account_balance_wallet,
              question: 'How do I create an emergency fund?',
              answer:
              'Start by saving 3-6 months of living expenses in a separate account. Focus on cutting non-essential expenses to build your fund faster.',
              color: const Color(0xFFFFC8DD), // Light Pinkish
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.money_off,
              question: 'What are the risks of investing in the stock market?',
              answer:
              'The stock market is volatile, and prices can fluctuate dramatically. Risks include market crashes, poor company performance, and changes in economic conditions.',
              color: const Color(0xFFFFAFCC), // Vibrant Rose Pink
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.savings,
              question: 'What is the 50/30/20 rule in budgeting?',
              answer:
              'The 50/30/20 rule suggests that you allocate 50% of your income to needs, 30% to wants, and 20% to savings or debt repayment.',
              color: const Color(0xFFBDE0FE), // Sky Blue
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.assessment,
              question: 'What is financial independence?',
              answer:
              'Financial independence means having enough income to cover your living expenses without relying on active employment, usually achieved through savings and investments.',
              color: const Color(0xFFA2D2FF), // Periwinkle Blue
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.house,
              question: 'Is renting or buying a home better?',
              answer:
              'It depends on your financial situation. Buying can build equity, but renting offers flexibility. Consider your long-term goals, maintenance costs, and market conditions.',
              color: const Color(0xFFCDB4DB), // Soft Lavender
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.redeem,
              question: 'How can I reduce my taxes legally?',
              answer:
              'Contribute to retirement accounts like 401(k)s and IRAs, take advantage of tax deductions, and consider tax-efficient investments to reduce your taxable income.',
              color: const Color(0xFFFFC8DD), // Light Pinkish
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.credit_card,
              question: 'What is a credit score?',
              answer:
              'A credit score is a numerical representation of your creditworthiness, typically ranging from 300 to 850. It affects your ability to borrow money and the interest rates you’ll receive.',
              color: const Color(0xFFFFAFCC), // Vibrant Rose Pink
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              context,
              icon: Icons.pie_chart,
              question: 'What is the importance of diversification in investing?',
              answer:
              'Diversification spreads your investments across different asset classes to reduce risk. It helps minimize the impact of any single investment’s poor performance on your overall portfolio.',
              color: const Color(0xFFBDE0FE), // Sky Blue
            ),
          ],
        ),
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
      color: color, // Card background color set to the provided shades
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
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color set to black
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
                color: Colors.black, // Text color set to black
              ),
            ),
          ],
        ),
      ),
    );
  }
}
