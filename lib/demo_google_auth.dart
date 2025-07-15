import 'package:flutter/material.dart';
import 'simple_auth_screen.dart';

class DemoGoogleAuth extends StatelessWidget {
  const DemoGoogleAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Sign-In Issue Fixed!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This demo shows how the Google Sign-In issue has been resolved with multiple authentication methods.',
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Test with Google Services:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            // Gemini Test
            ElevatedButton.icon(
              onPressed: () => _navigateToAuth(
                context,
                'Google Gemini',
                'https://gemini.google.com/',
                'gemini',
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Test Gemini Sign-In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Google AI Test
            ElevatedButton.icon(
              onPressed: () => _navigateToAuth(
                context,
                'Google AI Studio',
                'https://aistudio.google.com/',
                'google',
              ),
              icon: const Icon(Icons.psychology),
              label: const Text('Test Google AI Studio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Google Drive Test
            ElevatedButton.icon(
              onPressed: () => _navigateToAuth(
                context,
                'Google Drive',
                'https://drive.google.com/',
                'google',
              ),
              icon: const Icon(Icons.cloud),
              label: const Text('Test Google Drive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Text(
              'Test with Non-Google Services:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 16),
            
            // OpenAI Test
            ElevatedButton.icon(
              onPressed: () => _navigateToAuth(
                context,
                'ChatGPT',
                'https://chat.openai.com/',
                'openai',
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Test ChatGPT (Non-Google)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What to Expect:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Google services will show specialized authentication options'),
                  Text('• Non-Google services will show standard options'),
                  Text('• Multiple fallback methods ensure success'),
                  Text('• Clear explanations for each option'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAuth(BuildContext context, String name, String url, String platform) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SimpleAuthScreen(
          platform: platform,
          platformUrl: url,
          platformName: name,
        ),
      ),
    );
  }
}