import 'package:flutter/material.dart';

// Main StatefulWidget representing the page
class HiPage extends StatefulWidget {
  const HiPage({super.key});

  @override
  _HiPageState createState() => _HiPageState();
}

// State class for managing animations and building UI
class _HiPageState extends State<HiPage> with SingleTickerProviderStateMixin {
  // Animation controller to manage animation lifecycle
  late AnimationController _controller;

  // Animation for smooth translation effect
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initializing animation when the widget is created
    _initializeAnimation();
  }

  @override
  void dispose() {
    // Releasing animation resources when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  // Function to initialize animation controller and its behavior
  void _initializeAnimation() {
    // Configuring the animation controller with duration and vsync
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )
    // Repeating the animation in reverse mode for a seamless effect
      ..repeat(reverse: true);

    // Creating a tween animation for smooth transitions
    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _controller, // Assigning the animation controller
        curve: Curves.easeInOut, // Applying an ease-in-out curve
      ),
    );
  }

  // Widget to build the animated wallet icon
  Widget _buildAnimatedWalletIcon() {
    // AnimatedBuilder updates widget on every animation tick
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Applying a translation transform based on animation value
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Image.asset(
            'assets/ourLogo.png', // Path to your custom logo
            width: 170, // Adjust size to match the previous icon size
            height: 170, // Maintain aspect ratio if needed
            fit: BoxFit.contain, // Ensures the image fits within bounds
          ),
        );
      },
    );
  }

  // Widget to display the tagline text
  Widget _buildTagline() {
    return const Text(
      'Your Wallet Deserves the Best\nTrack It Right!', // Tagline message
      style: TextStyle(
        fontSize: 26, // Font size for visibility
        fontWeight: FontWeight.bold, // Bold font weight for emphasis
        fontStyle: FontStyle.italic, // Italic style for aesthetic appeal
        color: Color(0xFFAF69B1), // Darker lavender tone for contrast
        height: 1.6, // Line height for spacing
      ),
      textAlign: TextAlign.center, // Center-aligning text for symmetry
    );
  }

  // Widget to display icons with features
  Widget _buildFeatureIcons() {
    // Row widget to align icons horizontally
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Spacing between icons
      children: const [
        _FeatureCard(
          icon: Icons.pie_chart_outline, // Pie chart icon
          label: 'Track Expenses', // Label for the feature
        ),
        _FeatureCard(
          icon: Icons.savings_outlined, // Savings icon
          label: 'Save Smartly', // Label for the feature
        ),
        _FeatureCard(
          icon: Icons.notifications_outlined, // Notifications icon
          label: 'Stay Alert', // Label for the feature
        ),
      ],
    );
  }

  // Widget to create a gradient-styled button
  Widget _buildGradientButton() {
    return ElevatedButton(
      // Action triggered when the button is pressed
      onPressed: () {
        Navigator.pushNamed(context, '/wrapper'); // Navigating to '/wrapper'
      },
      // Styling the button with padding, elevation, and custom colors
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 20, // Vertical padding for a larger button
          horizontal: 80, // Horizontal padding for wider button
        ),
        elevation: 0, // Removing the shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        backgroundColor: Colors.transparent, // Transparent background
      ).copyWith(
        foregroundColor: MaterialStateProperty.all(Colors.white), // Text color
        overlayColor: MaterialStateProperty.all(
          const Color(0xFFA084CA).withOpacity(0.2), // Overlay color on press
        ),
      ),
      // Gradient decoration for the button
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB392AC), Color(0xFFA084CA)], // Darker gradient colors
            begin: Alignment.centerLeft, // Start gradient on the left
            end: Alignment.centerRight, // End gradient on the right
          ),
          borderRadius: BorderRadius.circular(16), // Rounded gradient edges
        ),
        child: Container(
          alignment: Alignment.center, // Center-aligning the text
          child: const Text(
            'Next', // Button label
            style: TextStyle(
              fontSize: 28, // Font size for visibility
              fontWeight: FontWeight.bold, // Bold text for emphasis
              letterSpacing: 1.5, // Spacing between letters
              color: Color(0xFF443C68), // Darker shade for contrast
            ),
          ),
        ),
      ),
    );
  }

  // Widget to display motivational text at the bottom
  Widget _buildMotivationalText() {
    return const Text(
      'Track. Save. Achieve!', // Motivational message
      style: TextStyle(
        fontSize: 20, // Font size for visibility
        fontWeight: FontWeight.w500, // Medium font weight for readability
        color: Color(0xFFAF69B1), // Darker lavender tone
      ),
      textAlign: TextAlign.center, // Center-aligning the text
    );
  }

  // Main build function to construct the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App bar title with styling
        title: const Text(
          'Welcome to Wallet Watch', // App bar title text
          style: TextStyle(
            fontSize: 26, // Font size for visibility
            fontWeight: FontWeight.bold, // Bold font weight for emphasis
          ),
        ),
        backgroundColor: const Color(0xFFFFAFCC), // Vibrant rose pink background
        elevation: 10, // Shadow depth for the app bar
        shadowColor: const Color(0xFFCDB4DB), // Shadow color
        centerTitle: true, // Center-aligning the title
      ),
      // Stack to layer background gradient and content
      body: Stack(
        children: [
          // Container for the background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCDB4DB), Color(0xFFBDE0FE)], // Gradient colors
                begin: Alignment.topCenter, // Start gradient at the top
                end: Alignment.bottomCenter, // End gradient at the bottom
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0), // Padding for the content
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center-aligning content
              children: [
                _buildAnimatedWalletIcon(), // Animated wallet icon
                const SizedBox(height: 25), // Spacing between widgets
                _buildTagline(), // Tagline text
                const SizedBox(height: 35), // Spacing between widgets
                _buildFeatureIcons(), // Feature icons
                const SizedBox(height: 50), // Spacing before the button
                _buildGradientButton(), // Gradient button
                const SizedBox(height: 25), // Spacing after the button
                _buildMotivationalText(), // Motivational text
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// StatelessWidget for feature cards displaying icons and labels
class _FeatureCard extends StatelessWidget {
  final IconData icon; // Icon data for the card
  final String label; // Label text for the feature

  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    // Column to display the icon and its label
    return Column(
      children: [
        CircleAvatar(
          radius: 35, // Size of the circular avatar
          backgroundColor: const Color(0xFFA084CA), // Darker lavender background
          child: Icon(
            icon, // Icon to display
            size: 35, // Icon size
            color: const Color(0xFF443C68), // Darker shade for contrast
          ),
        ),
        const SizedBox(height: 10), // Spacing between icon and label
        Text(
          label, // Label text
          style: const TextStyle(
            fontSize: 16, // Font size for readability
            fontWeight: FontWeight.w500, // Medium font weight
            color: Color(0xFF443C68), // Text color
          ),
        ),
      ],
    );
  }
}
