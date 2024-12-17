import 'package:flutter/material.dart';

class HiPage extends StatefulWidget {
  const HiPage({super.key});

  @override
  _HiPageState createState() => _HiPageState();
}

class _HiPageState extends State<HiPage> with SingleTickerProviderStateMixin {
  // Animation controller and animation initialization
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to initialize animation
  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  // Animated wallet icon widget
  Widget _buildAnimatedWalletIcon() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            size: 170,
            color: Colors.white,
          ),
        );
      },
    );
  }

  // Tagline displayed on the page
  Widget _buildTagline() {
    return const Text(
      'Your Wallet Deserves the Best\nTrack It Right!',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: Colors.white,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Feature icons displayed below the tagline
  Widget _buildFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _FeatureCard(icon: Icons.pie_chart_outline, label: 'Track Expenses'),
        _FeatureCard(icon: Icons.savings_outlined, label: 'Save Smartly'),
        _FeatureCard(icon: Icons.notifications_outlined, label: 'Stay Alert'),
      ],
    );
  }

  // Gradient button that takes user to the next page
  Widget _buildGradientButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/wrapper');
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
        elevation: 12,
        shadowColor: Colors.pink[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.transparent,
      ).copyWith(
        foregroundColor: MaterialStateProperty.all(Colors.white),
        overlayColor: MaterialStateProperty.all(Colors.purpleAccent.withOpacity(0.2)),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.pink, Colors.purpleAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          alignment: Alignment.center,
          child: const Text(
            'Next',
            style: TextStyle(
              fontSize: 28, // Made larger
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // Motivational text displayed at the bottom
  Widget _buildMotivationalText() {
    return const Text(
      'Track. Save. Achieve!',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Main body of the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Wallet Watch',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink[300],
        elevation: 10,
        shadowColor: Colors.purple[100],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimatedWalletIcon(),
                const SizedBox(height: 25),
                _buildTagline(),
                const SizedBox(height: 35),
                _buildFeatureIcons(),
                const SizedBox(height: 50),
                _buildGradientButton(),
                const SizedBox(height: 25),
                _buildMotivationalText(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Feature card widget used to display the icons
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.pink[100],
          child: Icon(
            icon,
            size: 35,
            color: Colors.pink[800],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
