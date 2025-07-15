import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';

class AlternativeAuthSolutions {
  
  /// Solution 1: Chrome Custom Tabs (Android) / Safari View Controller (iOS)
  static Future<void> openWithNativeBrowser(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      
      if (Platform.isAndroid) {
        // Use Chrome Custom Tabs for Android
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          browserConfiguration: const BrowserConfiguration(
            showTitle: true,
          ),
        );
      } else if (Platform.isIOS) {
        // Use SFSafariViewController for iOS
        await launchUrl(
          uri,
          mode: LaunchMode.inAppBrowserView,
          browserConfiguration: const BrowserConfiguration(
            showTitle: true,
          ),
        );
      } else {
        // Desktop - use system browser
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error opening native browser: $e');
    }
  }

  /// Solution 2: Deep Link Authentication Flow
  static Future<void> setupDeepLinkAuth(BuildContext context, String platform) async {
    final Map<String, String> authUrls = {
      'google': 'https://accounts.google.com/oauth/authorize?client_id=your_client_id&redirect_uri=your_app://auth&response_type=code&scope=openid%20email%20profile',
      'microsoft': 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=your_client_id&response_type=code&redirect_uri=your_app://auth&scope=openid%20email%20profile',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your preferred authentication method:'),
            const SizedBox(height: 16),
            
            // Native Browser Option
            ListTile(
              leading: const Icon(Icons.open_in_browser, color: Colors.blue),
              title: const Text('Open in Browser'),
              subtitle: const Text('Most reliable - opens in your default browser'),
              onTap: () {
                Navigator.of(context).pop();
                openWithNativeBrowser(authUrls[platform] ?? 'https://google.com');
              },
            ),
            
            // App-to-App Authentication
            ListTile(
              leading: const Icon(Icons.apps, color: Colors.green),
              title: const Text('Use Google/Microsoft App'),
              subtitle: const Text('Opens the official app if installed'),
              onTap: () {
                Navigator.of(context).pop();
                _tryAppToAppAuth(platform);
              },
            ),
            
            // QR Code Authentication
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.orange),
              title: const Text('QR Code Login'),
              subtitle: const Text('Scan with your phone\'s camera'),
              onTap: () {
                Navigator.of(context).pop();
                _showQRCodeAuth(context, platform);
              },
            ),
            
            // Manual Token Entry
            ListTile(
              leading: const Icon(Icons.key, color: Colors.purple),
              title: const Text('Manual Token Entry'),
              subtitle: const Text('Enter authentication token manually'),
              onTap: () {
                Navigator.of(context).pop();
                _showManualTokenEntry(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Solution 3: App-to-App Authentication
  static Future<void> _tryAppToAppAuth(String platform) async {
    try {
      String appUrl = '';
      String fallbackUrl = '';
      
      switch (platform) {
        case 'google':
          appUrl = 'googlechrome://navigate?url=https://accounts.google.com';
          fallbackUrl = 'https://accounts.google.com';
          break;
        case 'microsoft':
          appUrl = 'ms-outlook://signin';
          fallbackUrl = 'https://login.microsoftonline.com';
          break;
      }
      
      final Uri appUri = Uri.parse(appUrl);
      final Uri fallbackUri = Uri.parse(fallbackUrl);
      
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri);
      } else {
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('App-to-app auth failed: $e');
    }
  }

  /// Solution 4: QR Code Authentication
  static void _showQRCodeAuth(BuildContext context, String platform) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Authentication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 64, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('QR Code would appear here'),
                    Text('(Requires backend implementation)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Steps:'),
            const Text('1. Open Google/Microsoft app on your phone'),
            const Text('2. Go to account settings'),
            const Text('3. Scan this QR code'),
            const Text('4. Approve the login request'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _generateQRCode(platform);
            },
            child: const Text('Generate QR Code'),
          ),
        ],
      ),
    );
  }

  /// Solution 5: Manual Token Entry
  static void _showManualTokenEntry(BuildContext context) {
    final TextEditingController tokenController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Token Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Get your authentication token:'),
            const SizedBox(height: 8),
            const Text('1. Open browser and go to the service'),
            const Text('2. Sign in normally'),
            const Text('3. Open Developer Tools (F12)'),
            const Text('4. Go to Application > Cookies'),
            const Text('5. Copy the session token'),
            const SizedBox(height: 16),
            TextField(
              controller: tokenController,
              decoration: const InputDecoration(
                labelText: 'Authentication Token',
                hintText: 'Paste your token here',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processManualToken(tokenController.text);
            },
            child: const Text('Use Token'),
          ),
        ],
      ),
    );
  }

  /// Solution 6: Progressive Web App Approach
  static Future<void> openAsPWA(String url) async {
    try {
      // Add PWA parameters to make it behave more like a native app
      final pwaUrl = '$url?utm_source=pwa&display=standalone';
      final Uri uri = Uri.parse(pwaUrl);
      
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        browserConfiguration: const BrowserConfiguration(
          showTitle: false, // Hide browser UI for PWA-like experience
        ),
      );
    } catch (e) {
      debugPrint('PWA launch failed: $e');
    }
  }

  /// Solution 7: Proxy Server Authentication
  static Future<Map<String, dynamic>?> authenticateViaProxy(String platform, String email, String password) async {
    try {
      // This would connect to your backend server that handles authentication
      final response = await _makeProxyRequest({
        'platform': platform,
        'email': email,
        'password': password,
        'action': 'authenticate',
      });
      
      return response;
    } catch (e) {
      debugPrint('Proxy authentication failed: $e');
      return null;
    }
  }

  /// Solution 8: Session Import/Export
  static Future<void> exportSession(BuildContext context) async {
    try {
      // Export current session data
      final sessionData = await _getCurrentSessionData();
      final jsonData = jsonEncode(sessionData);
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: jsonData));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session data copied to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Session export failed: $e');
    }
  }

  static Future<void> importSession(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData?.text != null) {
        final sessionData = jsonDecode(clipboardData!.text!);
        await _restoreSessionData(sessionData);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session imported successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Session import failed: $e');
    }
  }

  /// Solution 9: Alternative AI Platforms (No Google Required)
  static List<Map<String, dynamic>> getAlternativePlatforms() {
    return [
      {
        'name': 'Claude (Anthropic)',
        'url': 'https://claude.ai',
        'description': 'Works with email/password, no Google required',
        'authMethod': 'email',
        'reliability': 'high',
      },
      {
        'name': 'Perplexity AI',
        'url': 'https://www.perplexity.ai',
        'description': 'Can be used without login',
        'authMethod': 'optional',
        'reliability': 'high',
      },
      {
        'name': 'Poe by Quora',
        'url': 'https://poe.com',
        'description': 'Multiple AI models, email signup',
        'authMethod': 'email',
        'reliability': 'medium',
      },
      {
        'name': 'Character.AI',
        'url': 'https://character.ai',
        'description': 'Email/password authentication',
        'authMethod': 'email',
        'reliability': 'high',
      },
      {
        'name': 'Hugging Face Chat',
        'url': 'https://huggingface.co/chat',
        'description': 'Open source models, email signup',
        'authMethod': 'email',
        'reliability': 'medium',
      },
    ];
  }

  /// Solution 10: Local AI Models
  static List<Map<String, dynamic>> getLocalAIOptions() {
    return [
      {
        'name': 'Ollama',
        'description': 'Run AI models locally on your device',
        'setup': 'Install Ollama app and download models',
        'pros': 'No internet required, complete privacy',
        'cons': 'Requires powerful device, large downloads',
      },
      {
        'name': 'LM Studio',
        'description': 'Local AI model runner with GUI',
        'setup': 'Download LM Studio and models',
        'pros': 'User-friendly interface, good performance',
        'cons': 'Desktop only, requires storage space',
      },
      {
        'name': 'GPT4All',
        'description': 'Open source local AI assistant',
        'setup': 'Install GPT4All application',
        'pros': 'Free, privacy-focused, offline',
        'cons': 'Limited compared to cloud models',
      },
    ];
  }

  // Helper methods
  static Future<void> _generateQRCode(String platform) async {
    // Implementation would generate QR code for authentication
    debugPrint('Generating QR code for $platform');
  }

  static Future<void> _processManualToken(String token) async {
    // Implementation would process the manually entered token
    debugPrint('Processing manual token: ${token.substring(0, 10)}...');
  }

  static Future<Map<String, dynamic>> _makeProxyRequest(Map<String, dynamic> data) async {
    // Implementation would make request to your backend proxy server
    await Future.delayed(const Duration(seconds: 2)); // Simulate network request
    return {'success': true, 'token': 'fake_token'};
  }

  static Future<Map<String, dynamic>> _getCurrentSessionData() async {
    // Implementation would extract current session cookies/tokens
    return {'cookies': [], 'tokens': {}, 'timestamp': DateTime.now().toIso8601String()};
  }

  static Future<void> _restoreSessionData(Map<String, dynamic> data) async {
    // Implementation would restore session cookies/tokens
    debugPrint('Restoring session data: $data');
  }
}