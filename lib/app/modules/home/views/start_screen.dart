import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Time and status bar space
            const SizedBox(height: 40),

            // Image container with decorative elements
            Container(
              height: 400,
              width: double.infinity,
              child: Stack(
                children: [
                  // Main image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/music_player.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Decorative waves
                  CustomPaint(
                    size: const Size(double.infinity, 400),
                    painter: WavePainter(),
                  ),

                  // Decorative dots
                  Positioned(
                    top: 40,
                    right: 30,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  // More decorative elements
                  Positioned(
                    bottom: 60,
                    left: 20,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.blue[200],
                        borderRadius: BorderRadius.circular(7.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Title text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: [
                  const TextSpan(text: 'GoPlay '),
                  TextSpan(
                    text: 'Music',
                    style: TextStyle(
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Description text
            Text(
              'Experience the best curated music from around the world, personalized just for you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            // Navigation dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == 0 ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.blue[600] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Next button
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                onPressed: () => Get.toNamed('/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the wave effect
class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    // Create wave pattern
    for (var i = 0; i < size.width; i += 60) {
      path.quadraticBezierTo(
        i + 30,
        size.height * 0.25,
        i + 60,
        size.height * 0.3,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}