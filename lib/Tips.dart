import 'package:flutter/material.dart';

class Tips extends StatelessWidget {
  const Tips({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Tips'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTipItem(
              context,
              icon: Icons.accessibility_new,
              title: '50/30/20 Rule',
              description:
              'Allocate 50% of your income to needs, 30% to wants, and 20% to savings and debt repayment.',
              color: const Color(0xFFCDB4DB), // Soft Lavender
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.emergency,
              title: 'Emergency Fund',
              description:
              'Always have an emergency fund with at least 3-6 months of living expenses in case of unexpected events.',
              color: const Color(0xFFFFC8DD), // Light Pinkish
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.receipt,
              title: 'Track Every Expense',
              description:
              'Consistently track your expenses to understand your spending habits and make better financial decisions.',
              color: const Color(0xFFFFAFCC), // Vibrant Rose Pink
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.money_off,
              title: 'Avoid High-Interest Debt',
              description:
              'Pay off high-interest debt, like credit card balances, as quickly as possible to avoid significant interest charges.',
              color: const Color(0xFFBDE0FE), // Sky Blue
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.savings,
              title: 'Automate Your Savings',
              description:
              'Set up automatic transfers to your savings account to ensure you’re consistently saving each month.',
              color: const Color(0xFFA2D2FF), // Periwinkle Blue
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.show_chart,
              title: 'Diversify Your Investments',
              description:
              'Don’t put all your money into one investment. Diversify across stocks, bonds, and other assets to reduce risk.',
              color: const Color(0xFFCDB4DB), // Soft Lavender
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.calendar_today,
              title: 'Plan for Retirement',
              description:
              'Start contributing to retirement accounts like a 401(k) or IRA as soon as possible to take advantage of tax benefits.',
              color: const Color(0xFFFFC8DD), // Light Pinkish
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.calculate,
              title: 'Create a Budget',
              description:
              'Create and stick to a budget to track your income and expenses, ensuring you live within your means and save for your goals.',
              color: const Color(0xFFFFAFCC), // Vibrant Rose Pink
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.gesture,
              title: 'Review Your Credit Report',
              description:
              'Check your credit report regularly for any inaccuracies and to ensure you maintain a healthy credit score.',
              color: const Color(0xFFBDE0FE), // Sky Blue
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.insights,
              title: 'Understand Your Taxes',
              description:
              'Stay informed about tax laws and consider tax-efficient investing strategies to maximize your returns.',
              color: const Color(0xFFA2D2FF), // Periwinkle Blue
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.house,
              title: 'Buy a Home Wisely',
              description:
              'If buying a home, ensure it fits your budget, and consider long-term costs like maintenance, taxes, and insurance.',
              color: const Color(0xFFCDB4DB), // Soft Lavender
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              context,
              icon: Icons.health_and_safety,
              title: 'Protect Your Wealth with Insurance',
              description:
              'Consider life, health, disability, and property insurance to protect yourself and your family from unexpected financial setbacks.',
              color: const Color(0xFFFFC8DD), // Light Pinkish
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context,
      {required IconData icon,
        required String title,
        required String description,
        required Color color}) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: color, // Set the card color based on the passed color
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 30,
              child: Icon(
                icon,
                color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 16,
                      color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
