import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

// Import webview packages
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'auth_helper.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title = 'AI Assistant',
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  wf.WebViewController? webViewController;
  iaw.InAppWebViewController? inAppWebViewController;
  iaw.PullToRefreshController? pullToRefreshController;
  double progress = 0.0;
  bool isLoading = true;
  String currentUrl = '';
  bool canGoBack = false;
  bool canGoForward = false;
  bool isDesktop = false;
  bool useInAppWebView = true;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.url;
    _initializePlatform();
  }

  void _initializePlatform() {
    // Determine platform and WebView type
    if (kIsWeb) {
      isDesktop = true;
      useInAppWebView = false;
    } else {
      try {
        isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
        useInAppWebView = Platform.isAndroid || Platform.isIOS;
      } catch (e) {
        // Fallback if Platform is not available
        isDesktop = true;
        useInAppWebView = false;
      }
    }

    if (useInAppWebView) {
      _initializeMobileWebView();
    } else {
      _initializeDesktopWebView();
    }
  }

  void _initializeDesktopWebView() {
    try {
      webViewController = wf.WebViewController()
        ..setJavaScriptMode(wf.JavaScriptMode.unrestricted)
        ..setUserAgent(_getSecureUserAgent())
        ..setNavigationDelegate(
          wf.NavigationDelegate(
            onProgress: (int progress) {
              if (mounted) {
                setState(() {
                  this.progress = progress / 100.0;
                });
              }
            },
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  isLoading = true;
                  currentUrl = url;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  isLoading = false;
                  currentUrl = url;
                });
                _updateNavigationState();
                _injectSecurityHeaders();
              }
            },
            onWebResourceError: (wf.WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
              if (mounted) {
                _showErrorSnackBar(error.description);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } catch (e) {
      debugPrint('Desktop WebView initialization failed: $e');
      // Set webViewController to null to show fallback UI
      webViewController = null;
    }
  }

  void _initializeMobileWebView() {
    try {
      pullToRefreshController = iaw.PullToRefreshController(
        settings: iaw.PullToRefreshSettings(
          color: Colors.blue,
        ),
        onRefresh: () async {
          if (inAppWebViewController != null) {
            await inAppWebViewController!.reload();
          }
        },
      );
    } catch (e) {
      debugPrint('Mobile WebView initialization failed: $e');
      pullToRefreshController = null;
    }
  }

  Future<void> _updateNavigationState() async {
    try {
      if (webViewController != null) {
        final back = await webViewController!.canGoBack();
        final forward = await webViewController!.canGoForward();
        if (mounted) {
          setState(() {
            canGoBack = back;
            canGoForward = forward;
          });
        }
      } else if (inAppWebViewController != null) {
        final back = await inAppWebViewController!.canGoBack();
        final forward = await inAppWebViewController!.canGoForward();
        if (mounted) {
          setState(() {
            canGoBack = back;
            canGoForward = forward;
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating navigation state: $e');
    }
  }

  Future<void> _launchInBrowser() async {
    try {
      final Uri url = Uri.parse(widget.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (mounted && context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted && context.mounted) {
          _showErrorSnackBar('Could not launch ${widget.url}');
        }
      }
    } catch (e) {
      debugPrint('Error launching browser: $e');
      if (mounted && context.mounted) {
        _showErrorSnackBar('Error opening browser: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (canGoBack) {
          try {
            if (webViewController != null) {
              await webViewController!.goBack();
            } else if (inAppWebViewController != null) {
              await inAppWebViewController!.goBack();
            }
          } catch (e) {
            debugPrint('Error going back: $e');
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          }
        } else {
          if (mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: _buildActions(),
        ),
        body: Column(
          children: [
            if (isLoading)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            Expanded(
              child: _buildWebView(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: canGoBack ? Colors.white : Colors.white54,
        ),
        onPressed: canGoBack ? _goBack : null,
      ),
      IconButton(
        icon: Icon(
          Icons.arrow_forward,
          color: canGoForward ? Colors.white : Colors.white54,
        ),
        onPressed: canGoForward ? _goForward : null,
      ),
      IconButton(
        icon: const Icon(Icons.refresh, color: Colors.white),
        onPressed: _reload,
      ),
      if (useInAppWebView) ...[
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'clear_cache',
              child: Text('Clear Cache'),
            ),
            const PopupMenuItem<String>(
              value: 'clear_cookies',
              child: Text('Clear Cookies'),
            ),
            const PopupMenuItem<String>(
              value: 'desktop_mode',
              child: Text('Toggle Desktop Mode'),
            ),
            const PopupMenuItem<String>(
              value: 'fix_auth',
              child: Text('Fix Authentication Issues'),
            ),
            const PopupMenuItem<String>(
              value: 'fix_google_auth',
              child: Text('Fix Google Sign-in Issues'),
            ),
            const PopupMenuItem<String>(
              value: 'auth_options',
              child: Text('Authentication Options'),
            ),
            const PopupMenuItem<String>(
              value: 'open_browser',
              child: Text('Open in Browser'),
            ),
          ],
        ),
      ] else ...[
        IconButton(
          icon: const Icon(Icons.open_in_browser, color: Colors.white),
          onPressed: _launchInBrowser,
        ),
      ],
    ];
  }

  Future<void> _goBack() async {
    try {
      if (webViewController != null) {
        await webViewController!.goBack();
        await _updateNavigationState();
      } else if (inAppWebViewController != null) {
        await inAppWebViewController!.goBack();
        await _updateNavigationState();
      } else {
        debugPrint('No WebView controller available for navigation');
        if (mounted) {
          _showErrorSnackBar('Navigation not available');
        }
      }
    } catch (e) {
      debugPrint('Error going back: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to go back: $e');
      }
    }
  }

  Future<void> _goForward() async {
    try {
      if (webViewController != null) {
        await webViewController!.goForward();
        await _updateNavigationState();
      } else if (inAppWebViewController != null) {
        await inAppWebViewController!.goForward();
        await _updateNavigationState();
      } else {
        debugPrint('No WebView controller available for navigation');
        if (mounted) {
          _showErrorSnackBar('Navigation not available');
        }
      }
    } catch (e) {
      debugPrint('Error going forward: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to go forward: $e');
      }
    }
  }

  Future<void> _reload() async {
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          progress = 0.0;
        });
      }
      
      if (webViewController != null) {
        await webViewController!.reload();
      } else if (inAppWebViewController != null) {
        await inAppWebViewController!.reload();
      } else {
        debugPrint('No WebView controller available for reload');
        if (mounted) {
          setState(() {
            isLoading = false;
            progress = 1.0;
          });
          _showErrorSnackBar('Reload not available');
        }
      }
    } catch (e) {
      debugPrint('Error reloading: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          progress = 1.0;
        });
        _showErrorSnackBar('Failed to reload: $e');
      }
    }
  }

  Future<void> _handleMenuAction(String value) async {
    try {
      switch (value) {
        case 'clear_cache':
          if (inAppWebViewController != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clearing cache...'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
            await iaw.InAppWebViewController.clearAllCache();
            await inAppWebViewController!.reload();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } else {
            if (mounted) {
              _showErrorSnackBar('WebView not available for cache clearing');
            }
          }
          break;
        case 'clear_cookies':
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Clearing cookies...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          await iaw.CookieManager.instance().deleteAllCookies();
          if (inAppWebViewController != null) {
            await inAppWebViewController!.reload();
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cookies cleared successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
          break;
        case 'desktop_mode':
          await _toggleDesktopMode();
          break;
        case 'fix_auth':
          await _handleAuthenticationIssues();
          break;
        case 'fix_google_auth':
          await _handleGoogleAuthenticationIssues();
          break;
        case 'auth_options':
          await AuthHelper.showAuthenticationOptions(context, widget.url);
          break;
        case 'open_browser':
          await _launchInBrowser();
          break;
        default:
          debugPrint('Unknown menu action: $value');
          if (mounted) {
            _showErrorSnackBar('Unknown action: $value');
          }
      }
    } catch (e) {
      debugPrint('Error handling menu action: $e');
      if (mounted) {
        _showErrorSnackBar('Error performing action: $e');
      }
    }
  }

  Widget _buildWebView() {
    if (useInAppWebView) {
      return _buildMobileWebView();
    } else {
      return _buildDesktopWebView();
    }
  }

  Widget _buildDesktopWebView() {
    if (webViewController == null) {
      return _buildFallbackUI();
    }

    try {
      return wf.WebViewWidget(controller: webViewController!);
    } catch (e) {
      debugPrint('Error building desktop WebView: $e');
      return _buildFallbackUI();
    }
  }

  Widget _buildMobileWebView() {
    try {
      return iaw.InAppWebView(
        initialUrlRequest: iaw.URLRequest(
          url: iaw.WebUri(widget.url),
          headers: {
            'User-Agent': widget.url.contains('google') || widget.url.contains('gemini') 
                ? _getGoogleCompatibleUserAgent() 
                : _getSecureUserAgent(),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'DNT': '1',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-User': '?1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Ch-Ua': '"Chromium";v="123", "Not:A-Brand";v="8"',
            'Sec-Ch-Ua-Mobile': '?0',
            'Sec-Ch-Ua-Platform': '"Windows"',
          },
        ),
        initialSettings: iaw.InAppWebViewSettings(
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
          userAgent: widget.url.contains('google') || widget.url.contains('gemini') 
              ? _getGoogleCompatibleUserAgent() 
              : _getSecureUserAgent(),
          useOnLoadResource: true,
          useOnDownloadStart: true,
          disableDefaultErrorPage: false,
          hardwareAcceleration: true,
          verticalScrollBarEnabled: true,
          horizontalScrollBarEnabled: true,
          networkAvailable: true,
          regexToCancelSubFramesLoading: null,
          contentBlockers: [],
          minimumLogicalFontSize: 8,
          iframeAllow: "camera; microphone; geolocation",
          iframeAllowFullscreen: true,
        ),
        pullToRefreshController: pullToRefreshController,
        onWebViewCreated: (controller) {
          inAppWebViewController = controller;
          _setupJavaScriptHandlers(controller);
        },
        onLoadStart: (controller, url) {
          debugPrint('Started loading: $url');
          if (mounted) {
            setState(() {
              isLoading = true;
              progress = 0.0;
              currentUrl = url.toString();
            });
          }
        },
        onLoadStop: (controller, url) async {
          debugPrint('Finished loading: $url');
          pullToRefreshController?.endRefreshing();
          await _updateNavigationState();
          await _injectMobileOptimizations(controller);
          
          if (mounted) {
            setState(() {
              isLoading = false;
              progress = 1.0;
              currentUrl = url.toString();
            });
          }
        },
        onReceivedError: (controller, request, error) {
          debugPrint('Error loading ${request.url}: ${error.description}');
          pullToRefreshController?.endRefreshing();
          if (mounted) {
            setState(() {
              isLoading = false;
              progress = 1.0;
            });
            
            // Handle specific authentication errors
            String errorMessage = error.description;
            if (error.description.toLowerCase().contains('net::err_cert')) {
              errorMessage = 'SSL Certificate error. Try clearing cache or using a different network.';
            } else if (error.description.toLowerCase().contains('net::err_internet_disconnected')) {
              errorMessage = 'No internet connection. Please check your network.';
            } else if (error.description.toLowerCase().contains('net::err_name_not_resolved')) {
              errorMessage = 'Cannot reach the server. Please check your internet connection.';
            } else if (error.description.toLowerCase().contains('timeout')) {
              errorMessage = 'Connection timeout. Please try again.';
            }
            
            _showErrorSnackBar(errorMessage);
          }
        },
        onProgressChanged: (controller, newProgress) {
          if (mounted) {
            setState(() {
              progress = newProgress / 100.0;
            });
          }
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint('WebView Console: ${consoleMessage.message}');
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          return iaw.NavigationActionPolicy.ALLOW;
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          debugPrint('HTTP Error: ${errorResponse.statusCode} for ${request.url}');
        },
        onPermissionRequest: (controller, request) async {
          return iaw.PermissionResponse(
            resources: request.resources,
            action: iaw.PermissionResponseAction.GRANT,
          );
        },
      );
    } catch (e) {
      debugPrint('Error building mobile WebView: $e');
      return _buildFallbackUI();
    }
  }

  Widget _buildFallbackUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.web_asset_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'WebView not available on this platform',
            style: TextStyle(fontSize: 18, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _launchInBrowser,
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Open in Browser'),
          ),
        ],
      ),
    );
  }

  String _getMobileUserAgent() {
    return 'Mozilla/5.0 (Linux; Android 14; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36';
  }

  String _getSecureUserAgent() {
    // Latest Chrome user agent that passes Google's security checks
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36';
  }

  String _getGoogleCompatibleUserAgent() {
    // Specific user agent optimized for Google services
    return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36 Edg/123.0.0.0';
  }

  Future<void> _toggleDesktopMode() async {
    try {
      if (inAppWebViewController != null) {
        final currentUserAgent = await inAppWebViewController!.getSettings();
        final newUserAgent = currentUserAgent?.userAgent?.contains('Mobile') == true
            ? _getSecureUserAgent()
            : _getMobileUserAgent();
        
        await inAppWebViewController!.setSettings(
          settings: iaw.InAppWebViewSettings(
            userAgent: newUserAgent,
            javaScriptEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            thirdPartyCookiesEnabled: true,
          ),
        );
        await inAppWebViewController!.reload();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newUserAgent.contains('Mobile') 
                  ? 'Switched to mobile mode' 
                  : 'Switched to desktop mode'
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error toggling desktop mode: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to toggle desktop mode: $e');
      }
    }
  }

  Future<void> _handleAuthenticationIssues() async {
    try {
      if (inAppWebViewController != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Applying advanced authentication fixes...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Clear any problematic cookies that might cause auth issues
        await iaw.CookieManager.instance().deleteAllCookies();
        
        // Update user agent to Google-compatible version
        await inAppWebViewController!.setSettings(
          settings: iaw.InAppWebViewSettings(
            userAgent: _getGoogleCompatibleUserAgent(),
            javaScriptEnabled: true,
            domStorageEnabled: true,
            databaseEnabled: true,
            thirdPartyCookiesEnabled: true,
            cacheEnabled: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            mixedContentMode: iaw.MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
        );
        
        // Inject comprehensive authentication helpers
        await inAppWebViewController!.evaluateJavascript(source: '''
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
        ''');
        
        // Wait a moment for the JavaScript to take effect
        await Future.delayed(const Duration(milliseconds: 500));
        
        await inAppWebViewController!.reload();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Advanced authentication fixes applied. Page reloaded with enhanced compatibility.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('WebView not available for authentication fixes');
        }
      }
    } catch (e) {
      debugPrint('Error handling authentication issues: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to apply authentication fixes: $e');
      }
    }
  }

  Future<void> _handleGoogleAuthenticationIssues() async {
    try {
      if (inAppWebViewController != null) {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Applying Google-specific authentication fixes...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // Clear all cookies and cache
        await iaw.CookieManager.instance().deleteAllCookies();
        await iaw.InAppWebViewController.clearAllCache();
        
        // Set Google-optimized settings
        await inAppWebViewController!.setSettings(
          settings: AuthHelper.getGoogleAuthSettings(),
        );
        
        // Inject advanced browser spoofing
        await inAppWebViewController!.evaluateJavascript(
          source: AuthHelper.getAdvancedBrowserSpoofingScript(),
        );
        
        // Wait for JavaScript to take effect
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Navigate to Google sign-in page if not already there
        String targetUrl = currentUrl;
        if (!currentUrl.contains('accounts.google.com')) {
          if (widget.url.contains('gemini')) {
            targetUrl = 'https://gemini.google.com/';
          } else if (widget.url.contains('google')) {
            targetUrl = widget.url;
          }
        }
        
        await inAppWebViewController!.loadUrl(
          urlRequest: iaw.URLRequest(
            url: iaw.WebUri(targetUrl),
            headers: {
              'User-Agent': _getGoogleCompatibleUserAgent(),
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
              'Accept-Encoding': 'gzip, deflate, br',
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
              'Sec-Ch-Ua': '"Chromium";v="123", "Not:A-Brand";v="8"',
              'Sec-Ch-Ua-Mobile': '?0',
              'Sec-Ch-Ua-Platform': '"Windows"',
              'Sec-Fetch-Dest': 'document',
              'Sec-Fetch-Mode': 'navigate',
              'Sec-Fetch-Site': 'none',
              'Sec-Fetch-User': '?1',
              'Upgrade-Insecure-Requests': '1'
            },
          ),
        );
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google authentication fixes applied. Try signing in now.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('WebView not available for Google authentication fixes');
        }
      }
    } catch (e) {
      debugPrint('Error handling Google authentication issues: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to apply Google authentication fixes: $e');
      }
    }
  }

  void _setupJavaScriptHandlers(iaw.InAppWebViewController controller) {
    try {
      controller.addJavaScriptHandler(
        handlerName: 'flutterHandler',
        callback: (args) {
          try {
            debugPrint('JavaScript message: $args');
          } catch (e) {
            debugPrint('Error handling JavaScript message: $e');
          }
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'authHandler',
        callback: (args) {
          try {
            debugPrint('Authentication event: $args');
            // Handle authentication events
            if (args.isNotEmpty && args[0] == 'login_success') {
              debugPrint('Login successful detected');
            } else if (args.isNotEmpty && args[0] == 'login_error') {
              debugPrint('Login error detected: ${args.length > 1 ? args[1] : 'Unknown error'}');
            }
          } catch (e) {
            debugPrint('Error handling authentication event: $e');
          }
        },
      );
      
      controller.addJavaScriptHandler(
        handlerName: 'errorHandler',
        callback: (args) {
          try {
            debugPrint('WebView error reported: $args');
            if (mounted && args.isNotEmpty) {
              _showErrorSnackBar('Page error: ${args[0]}');
            }
          } catch (e) {
            debugPrint('Error handling WebView error: $e');
          }
        },
      );
    } catch (e) {
      debugPrint('Error setting up JavaScript handlers: $e');
    }
  }

  Future<void> _injectMobileOptimizations(iaw.InAppWebViewController controller) async {
    try {
      const css = '''
        body {
          -webkit-touch-callout: none;
          -webkit-user-select: none;
          -khtml-user-select: none;
          -moz-user-select: none;
          -ms-user-select: none;
          user-select: none;
        }
        
        button, input, select, textarea, a {
          min-height: 44px;
          min-width: 44px;
        }
        
        input, select, textarea {
          font-size: 16px !important;
        }
      ''';
      
      await controller.evaluateJavascript(source: '''
        var style = document.createElement('style');
        style.innerHTML = `$css`;
        document.head.appendChild(style);
        
        // Inject security enhancements for authentication
        window.addEventListener('load', function() {
          // Override navigator properties to appear more like a real browser
          Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
          });
          
          // Add missing properties that some sites check for
          if (!window.chrome) {
            window.chrome = {
              runtime: {},
              loadTimes: function() {},
              csi: function() {},
            };
          }
          
          // Enhance form submission for better compatibility
          document.addEventListener('submit', function(e) {
            setTimeout(function() {
              if (e.target && e.target.tagName === 'FORM') {
                console.log('Form submitted, ensuring proper handling');
              }
            }, 100);
          });
        });
      ''');
    } catch (e) {
      debugPrint('Error injecting mobile optimizations: $e');
    }
  }

  Future<void> _injectSecurityHeaders() async {
    try {
      if (webViewController != null) {
        await webViewController!.runJavaScript('''
          // Override navigator properties to appear more like a real browser
          Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
          });
          
          // Add missing properties that some sites check for
          if (!window.chrome) {
            window.chrome = {
              runtime: {},
              loadTimes: function() {},
              csi: function() {},
            };
          }
          
          // Enhance authentication compatibility
          window.addEventListener('load', function() {
            console.log('Security enhancements loaded');
          });
        ''');
      }
    } catch (e) {
      debugPrint('Error injecting security headers: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $message'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _reload,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    try {
      // Clean up controllers if needed
      webViewController = null;
      inAppWebViewController = null;
      pullToRefreshController = null;
    } catch (e) {
      debugPrint('Error during dispose: $e');
    }
    super.dispose();
  }
}