import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class GoogleAuthSolution {
  static const String _googleClientId = 'your-google-client-id.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _googleClientId,
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Main method to handle Google Sign-In with multiple fallback options
  static Future<void> handleGoogleSignIn(BuildContext context, String targetUrl) async {
    // Show options dialog
    await _showSignInOptionsDialog(context, targetUrl);
  }

  /// Show dialog with different sign-in options
  static Future<void> _showSignInOptionsDialog(BuildContext context, String targetUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.account_circle, color: Colors.blue),
              SizedBox(width: 8),
              Text('Google Sign-In Options'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(height: 8),
                      Text(
                        'Google Security Notice',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Google blocks sign-ins from embedded browsers for security. Choose a method below:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Option 1: Native Google Sign-In (Recommended)
                _buildOptionCard(
                  icon: Icons.verified_user,
                  title: 'Native Google Sign-In',
                  subtitle: 'Most secure and reliable',
                  description: 'Uses official Google authentication',
                  color: Colors.green,
                  isRecommended: true,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _handleNativeGoogleSignIn(context, targetUrl);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Option 2: Custom Tabs (Android) / Safari View (iOS)
                _buildOptionCard(
                  icon: Icons.tab,
                  title: 'Secure Browser Tab',
                  subtitle: 'Opens in secure browser tab',
                  description: 'Better than WebView, maintains security',
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _openInCustomTab(context, targetUrl);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Option 3: External Browser
                _buildOptionCard(
                  icon: Icons.open_in_browser,
                  title: 'External Browser',
                  subtitle: 'Opens in default browser',
                  description: 'Most compatible, requires manual return',
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _openInExternalBrowser(targetUrl);
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Option 4: Enhanced WebView (Last Resort)
                _buildOptionCard(
                  icon: Icons.web,
                  title: 'Enhanced WebView',
                  subtitle: 'Try with security fixes',
                  description: 'May still be blocked by Google',
                  color: Colors.grey,
                  onTap: () {
                    Navigator.of(context).pop();
                    // Return to WebView with enhanced settings
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Method 1: Native Google Sign-In (Most Reliable)
  static Future<void> _handleNativeGoogleSignIn(BuildContext context, String targetUrl) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Signing in with Google...'),
                ],
              ),
            ),
          ),
        ),
      );

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (account != null) {
        // Success - show success dialog and redirect
        if (context.mounted) {
          await _showSuccessDialog(context, account, targetUrl);
        }
      } else {
        // User cancelled
        if (context.mounted) {
          _showErrorSnackBar(context, 'Sign-in was cancelled');
        }
      }
    } catch (error) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      
      debugPrint('Google Sign-In error: $error');
      
      if (context.mounted) {
        // Show error and offer alternatives
        await _showSignInErrorDialog(context, error.toString(), targetUrl);
      }
    }
  }

  /// Method 2: Custom Tabs / Safari View Controller
  static Future<void> _openInCustomTab(BuildContext context, String url) async {
    try {
      if (kIsWeb) {
        // For web, use regular browser
        await _openInExternalBrowser(url);
        return;
      }

      if (Platform.isAndroid) {
        // Use Custom Tabs on Android
        await launchUrl(
          Uri.parse(url),
          customTabsOptions: CustomTabsOptions(
            colorSchemes: CustomTabsColorSchemes.defaults(
              toolbarColor: Colors.blue,
            ),
            shareState: CustomTabsShareState.on,
            urlBarHidingEnabled: true,
            showTitle: true,
            closeButton: CustomTabsCloseButton(
              icon: CustomTabsCloseButtonIcons.back,
            ),
          ),
        );
      } else if (Platform.isIOS) {
        // Use Safari View Controller on iOS
        await launchUrl(
          Uri.parse(url),
          safariVCOptions: SafariViewControllerOptions(
            preferredBarTintColor: Colors.blue,
            preferredControlTintColor: Colors.white,
            barCollapsingEnabled: true,
            entersReaderIfAvailable: false,
          ),
        );
      } else {
        // Fallback to external browser
        await _openInExternalBrowser(url);
      }
      
      if (context.mounted) {
        _showInfoSnackBar(context, 'Opened in secure browser tab. Return to app when done.');
      }
    } catch (e) {
      debugPrint('Custom Tab error: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to open secure tab. Trying external browser...');
        await _openInExternalBrowser(url);
      }
    }
  }

  /// Method 3: External Browser
  static Future<void> _openInExternalBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('External browser error: $e');
    }
  }

  /// Show success dialog after successful authentication
  static Future<void> _showSuccessDialog(BuildContext context, GoogleSignInAccount account, String targetUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Sign-In Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, ${account.displayName ?? 'User'}!'),
              const SizedBox(height: 8),
              Text('Email: ${account.email}'),
              const SizedBox(height: 16),
              const Text('You can now access Google services. Would you like to open the service in your browser?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Stay in App'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _openInExternalBrowser(targetUrl);
              },
              child: const Text('Open Service'),
            ),
          ],
        );
      },
    );
  }

  /// Show error dialog with alternative options
  static Future<void> _showSignInErrorDialog(BuildContext context, String error, String targetUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Sign-In Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Google Sign-In encountered an error:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Try these alternatives:'),
              const SizedBox(height: 8),
              const Text('• Open in external browser (most reliable)'),
              const Text('• Use secure browser tab'),
              const Text('• Check your internet connection'),
              const Text('• Try again later'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _openInExternalBrowser(targetUrl);
              },
              child: const Text('Open in Browser'),
            ),
          ],
        );
      },
    );
  }

  /// Utility methods for showing messages
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  static void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Check if Google Sign-In is available
  static Future<bool> isGoogleSignInAvailable() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      return false;
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Get current signed-in user
  static GoogleSignInAccount? getCurrentUser() {
    return _googleSignIn.currentUser;
  }
}