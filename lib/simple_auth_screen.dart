import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'web_view_screen.dart';
import 'google_auth_solution.dart';

class SimpleAuthScreen
    extends
        StatelessWidget {
  final String platform;
  final String platformUrl;
  final String platformName;

  const SimpleAuthScreen({
    super.key,
    required this.platform,
    required this.platformUrl,
    required this.platformName,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Access $platformName',
        ),
        backgroundColor: Theme.of(
          context,
        ).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(
            24.0,
          ),
          children: [
            Icon(
              _getPlatformIcon(
                platform,
              ),
              size: 80,
              color: Theme.of(
                context,
              ).primaryColor,
            ),
            const SizedBox(
              height: 24,
            ),

            Text(
              'How would you like to access $platformName?',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 40,
            ),

            // Special handling for Google services
            if (_isGoogleService()) ...[
              // Google Sign-In Solution
              ElevatedButton.icon(
                onPressed: () => GoogleAuthSolution.handleGoogleSignIn(
                  context,
                  platformUrl,
                ),
                icon: const Icon(
                  Icons.account_circle,
                ),
                label: const Text(
                  'Google Sign-In Solutions',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),
              const Text(
                '✓ Multiple authentication methods\n✓ Bypasses WebView restrictions\n✓ Secure and reliable',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(
                height: 24,
              ),

              const Divider(),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Alternative Options:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
            ],

            // Option 1: Open in Browser (Recommended)
            ElevatedButton.icon(
              onPressed: () => _openInBrowser(),
              icon: const Icon(
                Icons.open_in_browser,
              ),
              label: Text(
                _isGoogleService()
                    ? 'Open in Browser'
                    : 'Open in Browser (Recommended)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isGoogleService()
                    ? Colors.orange
                    : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),
            Text(
              _isGoogleService()
                  ? '✓ Works for Google services\n✓ Full browser features\n⚠ Requires manual return to app'
                  : '✓ Most reliable - 95% success rate\n✓ Full browser features\n✓ No authentication issues',
              style: TextStyle(
                color: _isGoogleService()
                    ? Colors.orange
                    : Colors.green,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 32,
            ),

            // Option 2: Try in App
            OutlinedButton.icon(
              onPressed: () => _openInApp(
                context,
              ),
              icon: const Icon(
                Icons.web,
              ),
              label: const Text(
                'Try in App',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),
            Text(
              _isGoogleService()
                  ? '⚠ Google blocks WebView sign-ins\n⚠ May show security warnings\n⚠ Use other options instead'
                  : '⚠ May have sign-in restrictions\n⚠ Use if browser option doesn\'t work',
              style: TextStyle(
                color: _isGoogleService()
                    ? Colors.red
                    : Colors.orange,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(
              height: 40,
            ),

            // Help text
            Container(
              padding: const EdgeInsets.all(
                16,
              ),
              decoration: BoxDecoration(
                color: _isGoogleService()
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  8,
                ),
                border: Border.all(
                  color: _isGoogleService()
                      ? Colors.red.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isGoogleService()
                        ? Icons.warning
                        : Icons.info_outline,
                    color: _isGoogleService()
                        ? Colors.red
                        : Colors.blue,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    _isGoogleService()
                        ? 'Google Sign-In Issue Detected'
                        : 'Having trouble signing in?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    _isGoogleService()
                        ? 'Google blocks sign-ins from embedded browsers for security. Use the "Google Sign-In Solutions" button above for the best experience, or try opening in your browser.'
                        : 'Use "Open in Browser" for the most reliable experience. You can bookmark the page and return to it anytime.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
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

  bool _isGoogleService() {
    final platformLower = platform.toLowerCase();
    final url = platformUrl.toLowerCase();

    return platformLower.contains(
          'google',
        ) ||
        platformLower.contains(
          'gemini',
        ) ||
        url.contains(
          'google.com',
        ) ||
        url.contains(
          'gemini.google.com',
        ) ||
        url.contains(
          'accounts.google.com',
        );
  }

  IconData _getPlatformIcon(
    String platform,
  ) {
    switch (platform.toLowerCase()) {
      case 'google':
      case 'gemini':
        return Icons.auto_awesome;
      case 'openai':
      case 'chatgpt':
        return Icons.chat_bubble_outline;
      case 'microsoft':
      case 'copilot':
        return Icons.code;
      case 'anthropic':
      case 'claude':
        return Icons.psychology;
      case 'perplexity':
        return Icons.search;
      default:
        return Icons.smart_toy;
    }
  }

  Future<
    void
  >
  _openInBrowser() async {
    try {
      final uri = Uri.parse(
        platformUrl,
      );
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error opening browser: $e',
      );
    }
  }

  void _openInApp(
    BuildContext context,
  ) {
    Navigator.of(
      context,
    ).pushReplacement(
      MaterialPageRoute(
        builder:
            (
              context,
            ) => WebViewScreen(
              url: platformUrl,
              title: platformName,
            ),
      ),
    );
  }
}
