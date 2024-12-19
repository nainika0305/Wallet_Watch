import 'package:flutter/material.dart';

class MeetTheTeamPage extends StatelessWidget {
  const MeetTheTeamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold: Main page structure
    return Scaffold(
      // AppBar with title and icon
      appBar: AppBar(
        title: const Text(
          'Meet the Team',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFCDB4DB), // Soft Lavender color
        elevation: 0, // No elevation for the app bar
        actions: [
          // Adding a 'people' icon to the app bar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.people, // Icon representing team members
              size: 30,
              color: Colors.white, // White color for the icon
            ),
          ),
        ],
      ),

      // Main body of the page
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFCDB4DB), // Soft Lavender
              const Color(0xFFBDE0FE), // Calming Sky Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        // Padding to create space around the content
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          // Column for vertical alignment of the content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20), // Spacing between content

              // Container for the app logo
              Container(
                height: 100, // Height of the logo
                width: 100, // Width of the logo
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Circular shape for the logo
                  image: DecorationImage(
                    image: AssetImage('assets/ourLogo.png'), // Replace with app logo
                    fit: BoxFit.cover, // Ensure the image covers the circle
                  ),
                ),
              ),

              const SizedBox(height: 20), // Spacing after the logo

              // Main description text about the team and app
              const Text(
                'We are the team behind the Wallet Watch app, a finance tracker designed to help you manage your expenses and savings. Our goal was to create an easy-to-use tool that helps users track their financial activities and make informed decisions. The app allows users to track their expenses, income, and set budgets. It also provides useful insights through graphs and financial tips.',
                style: TextStyle(
                  fontSize: 16, // Font size of the description
                  color: Colors.white, // White color for the text
                  height: 1.5, // Line height for readability
                ),
                textAlign: TextAlign.center, // Center align the text
              ),

              const SizedBox(height: 40), // Spacing between description and team cards

              // Build the card for the first team member
              _buildTeamMemberCard(
                name: 'Nainika Agrawal',
                imagePath: 'assets/member1.jpg', // Replace with actual image path
              ),

              const SizedBox(height: 40), // Spacing between the first and second team member cards

              // Build the card for the second team member
              _buildTeamMemberCard(
                name: 'Kavya Gupta',
                imagePath: 'assets/member2.jpg', // Replace with actual image path
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a team member card with name and image
  Widget _buildTeamMemberCard({
    required String name,
    required String imagePath,
  }) {
    return Card(
      elevation: 15, // Shadow elevation for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Rounded corners for the card
      ),
      color: const Color(0xFFFFC8DD), // Light Pinkish Shade for the card
      shadowColor: Colors.black.withOpacity(0.2), // Subtle shadow for depth
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding inside the card
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the row
          crossAxisAlignment: CrossAxisAlignment.center, // Vertically center the content
          children: [
            // Circle avatar for the team member's image
            CircleAvatar(
              radius: 60, // Uniform size for both avatars
              backgroundImage: AssetImage(imagePath), // Image of the team member
            ),

            const SizedBox(width: 20), // Spacing between avatar and name

            // Text for the team member's name
            Expanded(
              child: Text(
                name, // Name of the team member
                style: TextStyle(
                  fontSize: 22, // Font size for the name
                  fontWeight: FontWeight.bold, // Bold text for the name
                  color: const Color(0xFF9C4D97), // Lighter purple for contrast
                  overflow: TextOverflow.ellipsis, // Prevent overflow of long names
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
