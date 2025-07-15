import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:url_launcher/url_launcher.dart';

class AuthHelper {
  /// Get Google-optimized WebView settings
  static iaw.InAppWebViewSettings getGoogleAuthSettings() {
    return iaw.InAppWebViewSettings(
      javaScriptEnabled: true,
      javaScriptCanOpenWindowsAutomatically: true,
      domStorageEnabled: true,
      databaseEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      allowFileAccessFromFileURLs: true,
      allowUniversalAccessFromFileURLs: true,
      mixedContentMode: iaw.MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      cacheEnabled: true,
      clearCache: false,
      thirdPartyCookiesEnabled: true,
      useHybridComposition: true,
      allowsBackForwardNavigationGestures: true,
      useShouldOverrideUrlLoading: true,
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,
      userAgent: getGoogleCompatibleUserAgent(),
      useOnLoadResource: true,
      useOnDownloadStart: true,
      disableDefaultErrorPage: false,
      hardwareAcceleration: true,
      verticalScrollBarEnabled: true,
      horizontalScrollBarEnabled: true,
      networkAvailable: true,
      minimumLogicalFontSize: 8,
      iframeAllow: "camera; microphone; geolocation",
      iframeAllowFullscreen: true,
      // Additional security settings
      allowsLinkPreview: true,
      allowsPictureInPictureMediaPlayback: true,
      applicationNameForUserAgent: "Chrome",
      // Enhanced compatibility
      disableContextMenu: false,
      disableHorizontalScroll: false,
      disableVerticalScroll: false,
      enableViewportScale: true,
      suppressesIncrementalRendering: false,
    );
  }

  /// Get Google-compatible user agent
  static String getGoogleCompatibleUserAgent() {
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 Edg/123.0.0.0';
  }

  /// Get advanced browser spoofing script
  static String getAdvancedBrowserSpoofingScript() {
    return '''
      // Comprehensive webdriver detection removal
      const webdriverProps = [
        '__webdriver_evaluate', '__webdriver_script_function', '__webdriver_script_func',
        '__webdriver_script_fn', '__webdriver_unwrapped', '__webdriver_evaluate',
        '__selenium_evaluate', '__selenium_unwrapped', '__fxdriver_evaluate',
        '__fxdriver_unwrapped', '__driver_evaluate', '__driver_unwrapped',
        'webdriver', '__webdriver', '_selenium', 'callSelenium', '_Selenium_IDE_Recorder'
      ];
      
      webdriverProps.forEach(prop => {
        try {
          delete navigator[prop];
          delete window[prop];
        } catch(e) {}
      });
      
      // Override webdriver property
      Object.defineProperty(navigator, 'webdriver', {
        get: () => undefined,
        configurable: true
      });
      
      // Add comprehensive Chrome object simulation
      if (!window.chrome) {
        window.chrome = {
          runtime: {
            onConnect: null,
            onMessage: null,
            connect: function() { return { postMessage: function() {}, onMessage: { addListener: function() {} } }; },
            sendMessage: function() {},
            getManifest: function() { return {}; },
            getURL: function(path) { return 'chrome-extension://fake/' + path; }
          },
          loadTimes: function() {
            return {
              commitLoadTime: Date.now() / 1000 - Math.random(),
              connectionInfo: 'h2',
              finishDocumentLoadTime: Date.now() / 1000 - Math.random(),
              finishLoadTime: Date.now() / 1000 - Math.random(),
              firstPaintAfterLoadTime: 0,
              firstPaintTime: Date.now() / 1000 - Math.random(),
              navigationType: 'Other',
              npnNegotiatedProtocol: 'h2',
              requestTime: Date.now() / 1000 - Math.random(),
              startLoadTime: Date.now() / 1000 - Math.random(),
              wasAlternateProtocolAvailable: false,
              wasFetchedViaSpdy: true,
              wasNpnNegotiated: true
            };
          },
          csi: function() {
            return {
              onloadT: Date.now(),
              pageT: Date.now() - performance.timing.navigationStart,
              startE: performance.timing.navigationStart,
              tran: 15
            };
          },
          app: {
            isInstalled: false,
            InstallState: { DISABLED: 'disabled', INSTALLED: 'installed', NOT_INSTALLED: 'not_installed' },
            RunningState: { CANNOT_RUN: 'cannot_run', READY_TO_RUN: 'ready_to_run', RUNNING: 'running' }
          }
        };
      }
      
      // Override navigator properties to appear more legitimate
      Object.defineProperty(navigator, 'plugins', {
        get: () => [
          { name: 'Chrome PDF Plugin', filename: 'internal-pdf-viewer', description: 'Portable Document Format' },
          { name: 'Chrome PDF Viewer', filename: 'mhjfbmdgcfjbbpaeojofohoefgiehjai', description: '' },
          { name: 'Native Client', filename: 'internal-nacl-plugin', description: '' }
        ]
      });
      
      Object.defineProperty(navigator, 'languages', {
        get: () => ['en-US', 'en']
      });
      
      Object.defineProperty(navigator, 'platform', {
        get: () => 'Win32'
      });
      
      // Override permissions API
      if (navigator.permissions && navigator.permissions.query) {
        const originalQuery = navigator.permissions.query;
        navigator.permissions.query = function(parameters) {
          return originalQuery(parameters).then(function(result) {
            if (parameters.name === 'notifications') {
              return { state: 'granted' };
            }
            return result;
          }).catch(() => ({ state: 'granted' }));
        };
      }
      
      // Add missing window properties
      if (!window.outerHeight) window.outerHeight = screen.height;
      if (!window.outerWidth) window.outerWidth = screen.width;
      
      // Override toString methods to hide modifications
      const originalToString = Function.prototype.toString;
      Function.prototype.toString = function() {
        if (this === navigator.webdriver) {
          return 'function webdriver() { [native code] }';
        }
        return originalToString.apply(this, arguments);
      };
      
      console.log('Advanced authentication helpers injected');
    ''';
  }

  /// Show authentication options dialog
  static Future<void> showAuthenticationOptions(BuildContext context, String url) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Options'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Having trouble signing in? Try these solutions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildOptionTile(
                  icon: Icons.open_in_browser,
                  title: 'Open in Browser',
                  description: 'Most reliable method - opens in your default browser',
                  color: Colors.green,
                ),
                
                _buildOptionTile(
                  icon: Icons.refresh,
                  title: 'Clear Cache & Cookies',
                  description: 'Removes stored authentication data',
                  color: Colors.orange,
                ),
                
                _buildOptionTile(
                  icon: Icons.desktop_windows,
                  title: 'Toggle Desktop Mode',
                  description: 'Switch between mobile and desktop view',
                  color: Colors.blue,
                ),
                
                _buildOptionTile(
                  icon: Icons.security,
                  title: 'Apply Security Fixes',
                  description: 'Enhanced browser compatibility',
                  color: Colors.purple,
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why does this happen?',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Google blocks sign-ins from embedded browsers for security reasons. Using the browser option bypasses this restriction.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _openInBrowser(url);
              },
              child: const Text('Open in Browser'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Error opening browser: $e');
    }
  }

  /// Get comprehensive authentication troubleshooting tips
  static List<Map<String, dynamic>> getAuthTroubleshootingTips() {
    return [
      {
        'title': 'Use Browser Instead',
        'description': 'Open the service in your default browser for the most reliable authentication experience.',
        'icon': Icons.open_in_browser,
        'color': Colors.green,
        'priority': 1,
      },
      {
        'title': 'Clear Browser Data',
        'description': 'Clear cookies, cache, and stored data to resolve authentication conflicts.',
        'icon': Icons.clear_all,
        'color': Colors.orange,
        'priority': 2,
      },
      {
        'title': 'Check Network Connection',
        'description': 'Ensure you have a stable internet connection and try again.',
        'icon': Icons.wifi,
        'color': Colors.blue,
        'priority': 3,
      },
      {
        'title': 'Try Incognito/Private Mode',
        'description': 'Use private browsing mode to avoid conflicts with existing sessions.',
        'icon': Icons.privacy_tip,
        'color': Colors.purple,
        'priority': 4,
      },
      {
        'title': 'Update Browser',
        'description': 'Make sure you\'re using the latest version of your browser.',
        'icon': Icons.update,
        'color': Colors.teal,
        'priority': 5,
      },
    ];
  }
}