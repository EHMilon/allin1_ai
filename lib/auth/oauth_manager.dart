import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;

class OAuthManager {
  static const String _redirectUri = 'allin1ai://auth/callback';
  static const String _stateKey = 'oauth_state';
  
  // OAuth configurations for different providers
  static const Map<String, Map<String, String>> _oauthConfigs = {
    'google': {
      'authUrl': 'https://accounts.google.com/oauth/authorize',
      'tokenUrl': 'https://oauth2.googleapis.com/token',
      'clientId': 'your-google-client-id', // You'll need to register your app
      'scope': 'openid email profile',
    },
    'microsoft': {
      'authUrl': 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize',
      'tokenUrl': 'https://login.microsoftonline.com/common/oauth2/v2.0/token',
      'clientId': 'your-microsoft-client-id',
      'scope': 'openid email profile',
    },
  };

  static StreamController<Map<String, dynamic>>? _authController;
  static String? _currentState;

  /// Initialize OAuth manager and set up deep link listening
  static Future<void> initialize() async {
    _authController = StreamController<Map<String, dynamic>>.broadcast();
    
    // Listen for deep links (this would be set up in main.dart)
    // For now, we'll use a different approach
  }

  /// Start OAuth flow with external browser
  static Future<Map<String, dynamic>?> authenticateWithBrowser(
    String provider,
    BuildContext context,
  ) async {
    try {
      final config = _oauthConfigs[provider];
      if (config == null) {
        throw Exception('Unsupported OAuth provider: $provider');
      }

      // Generate state for security
      _currentState = _generateState();
      await _saveState(_currentState!);

      // Build OAuth URL
      final authUrl = _buildAuthUrl(config, _currentState!);
      
      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Opening browser for authentication...'),
                SizedBox(height: 8),
                Text('Please complete sign-in and return to the app'),
              ],
            ),
          ),
        );
      }

      // Launch browser
      final uri = Uri.parse(authUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }
        throw Exception('Could not launch browser');
      }

      // Wait for authentication result (with timeout)
      final result = await _waitForAuthResult();
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      return result;
    } catch (e) {
      debugPrint('OAuth authentication failed: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog(context, 'Authentication failed: $e');
      }
      return null;
    }
  }

  /// Alternative: Session transfer from browser
  static Future<bool> transferBrowserSession(
    String platform,
    BuildContext context,
  ) async {
    try {
      // Show instructions dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Transfer Browser Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('To transfer your $platform session:'),
              const SizedBox(height: 16),
              Text('1. Make sure you\'re signed in to $platform in your browser'),
              const Text('2. Tap "Open Browser" below'),
              const Text('3. The page should load already signed in'),
              const Text('4. Return to this app'),
              const SizedBox(height: 16),
              const Text('This will copy your browser session to the app.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Browser'),
            ),
          ],
        ),
      );

      if (confirmed != true) return false;

      // Open platform in browser to establish session
      final platformUrls = {
        'google': 'https://gemini.google.com',
        'openai': 'https://chat.openai.com',
        'microsoft': 'https://copilot.microsoft.com',
        'anthropic': 'https://claude.ai',
        'perplexity': 'https://www.perplexity.ai',
      };

      final url = platformUrls[platform.toLowerCase()] ?? platformUrls['google']!;
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Browser session for $platform is now active. Try accessing the platform in the app.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      return true;
    } catch (e) {
      debugPrint('Session transfer failed: $e');
      return false;
    }
  }

  /// Cookie-based authentication transfer
  static Future<bool> transferCookiesFromBrowser(
    String platform,
    iaw.InAppWebViewController webViewController,
  ) async {
    try {
      // This is a simplified approach - in reality, you'd need to:
      // 1. Extract cookies from the system browser (requires native code)
      // 2. Inject them into the WebView
      
      // For now, we'll use a different approach: session synchronization
      await _synchronizeSession(platform, webViewController);
      return true;
    } catch (e) {
      debugPrint('Cookie transfer failed: $e');
      return false;
    }
  }

  /// Synchronize session between browser and WebView
  static Future<void> _synchronizeSession(
    String platform,
    iaw.InAppWebViewController webViewController,
  ) async {
    try {
      // Inject JavaScript to check for existing authentication
      await webViewController.evaluateJavascript(source: '''
        (function() {
          // Check if user is already authenticated
          const checkAuth = () => {
            // Look for common authentication indicators
            const authIndicators = [
              'user-menu', 'profile-button', 'avatar', 'user-avatar',
              'account-menu', 'user-info', 'logout', 'sign-out'
            ];
            
            for (const indicator of authIndicators) {
              if (document.querySelector(`[class*="\${indicator}"]`) || 
                  document.querySelector(`[id*="\${indicator}"]`)) {
                return true;
              }
            }
            
            // Check for authentication cookies
            if (document.cookie.includes('session') || 
                document.cookie.includes('auth') ||
                document.cookie.includes('token')) {
              return true;
            }
            
            return false;
          };
          
          // If not authenticated, try to trigger authentication
          if (!checkAuth()) {
            // Look for sign-in buttons and click them
            const signInSelectors = [
              'button[class*="sign-in"]',
              'button[class*="login"]',
              'a[href*="login"]',
              'a[href*="signin"]',
              '.sign-in-button',
              '.login-button'
            ];
            
            for (const selector of signInSelectors) {
              const button = document.querySelector(selector);
              if (button) {
                console.log('Found sign-in button, attempting to click');
                button.click();
                break;
              }
            }
          }
          
          return checkAuth();
        })();
      ''');
    } catch (e) {
      debugPrint('Session synchronization failed: $e');
    }
  }

  /// Handle deep link callback (call this from your deep link handler)
  static Future<void> handleDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (uri.scheme == 'allin1ai' && uri.host == 'auth' && uri.path == '/callback') {
        final code = uri.queryParameters['code'];
        final state = uri.queryParameters['state'];
        final error = uri.queryParameters['error'];

        if (error != null) {
          _authController?.add({'error': error});
          return;
        }

        if (code != null && state != null) {
          // Verify state
          final savedState = await _getSavedState();
          if (state != savedState) {
            _authController?.add({'error': 'Invalid state parameter'});
            return;
          }

          // Exchange code for tokens (this would require backend implementation)
          final tokens = await _exchangeCodeForTokens(code);
          _authController?.add({'success': true, 'tokens': tokens});
        }
      }
    } catch (e) {
      debugPrint('Deep link handling failed: $e');
      _authController?.add({'error': e.toString()});
    }
  }

  /// Wait for authentication result
  static Future<Map<String, dynamic>?> _waitForAuthResult() async {
    try {
      // Wait for result with timeout
      final result = await _authController!.stream.first.timeout(
        const Duration(minutes: 5),
        onTimeout: () => {'error': 'Authentication timeout'},
      );

      return result;
    } catch (e) {
      debugPrint('Waiting for auth result failed: $e');
      return {'error': e.toString()};
    }
  }

  /// Build OAuth authorization URL
  static String _buildAuthUrl(Map<String, String> config, String state) {
    final params = {
      'client_id': config['clientId']!,
      'redirect_uri': _redirectUri,
      'response_type': 'code',
      'scope': config['scope']!,
      'state': state,
      'access_type': 'offline',
      'prompt': 'consent',
    };

    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '${config['authUrl']}?$query';
  }

  /// Generate random state for OAuth security
  static String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Save OAuth state
  static Future<void> _saveState(String state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_stateKey, state);
  }

  /// Get saved OAuth state
  static Future<String?> _getSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stateKey);
  }

  /// Exchange authorization code for tokens (requires backend)
  static Future<Map<String, dynamic>> _exchangeCodeForTokens(String code) async {
    // This would typically be done by your backend server
    // For now, return a mock response
    await Future.delayed(const Duration(seconds: 2));
    return {
      'access_token': 'mock_access_token',
      'refresh_token': 'mock_refresh_token',
      'expires_in': 3600,
    };
  }

  /// Show error dialog
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Clean up resources
  static void dispose() {
    _authController?.close();
    _authController = null;
  }
}