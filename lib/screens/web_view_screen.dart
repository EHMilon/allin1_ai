import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'
    show
        Platform;

// Import webview packages
import 'package:webview_flutter/webview_flutter.dart' as wf;
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;

class WebViewScreen
    extends
        StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({
    super.key,
    required this.url,
    this.title = 'AI Assistant',
  });

  @override
  State<
    WebViewScreen
  >
  createState() => _WebViewScreenState();
}

class _WebViewScreenState
    extends
        State<
          WebViewScreen
        > {
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
        isDesktop =
            Platform.isLinux ||
            Platform.isMacOS ||
            Platform.isWindows;
        useInAppWebView =
            Platform.isAndroid ||
            Platform.isIOS;
      } catch (
        e
      ) {
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
        ..setJavaScriptMode(
          wf.JavaScriptMode.unrestricted,
        )
        ..setUserAgent(
          _getSecureUserAgent(),
        )
        ..setNavigationDelegate(
          wf.NavigationDelegate(
            onProgress:
                (
                  int progress,
                ) {
                  if (mounted) {
                    setState(
                      () {
                        this.progress =
                            progress /
                            100.0;
                      },
                    );
                  }
                },
            onPageStarted:
                (
                  String url,
                ) {
                  if (mounted) {
                    setState(
                      () {
                        isLoading = true;
                        currentUrl = url;
                      },
                    );
                  }
                },
            onPageFinished:
                (
                  String url,
                ) {
                  if (mounted) {
                    setState(
                      () {
                        isLoading = false;
                        currentUrl = url;
                      },
                    );
                    _updateNavigationState();
                  }
                },
            onWebResourceError:
                (
                  wf.WebResourceError error,
                ) {
                  debugPrint(
                    'WebView error: ${error.description}',
                  );
                  if (mounted) {
                    _showErrorSnackBar(
                      error.description,
                    );
                  }
                },
          ),
        )
        ..loadRequest(
          Uri.parse(
            widget.url,
          ),
        );
    } catch (
      e
    ) {
      debugPrint(
        'Desktop WebView initialization failed: $e',
      );
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
          if (inAppWebViewController !=
              null) {
            await inAppWebViewController!.reload();
          }
        },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Mobile WebView initialization failed: $e',
      );
      pullToRefreshController = null;
    }
  }

  Future<
    void
  >
  _updateNavigationState() async {
    try {
      if (webViewController !=
          null) {
        final back = await webViewController!.canGoBack();
        final forward = await webViewController!.canGoForward();
        if (mounted) {
          setState(
            () {
              canGoBack = back;
              canGoForward = forward;
            },
          );
        }
      } else if (inAppWebViewController !=
          null) {
        final back = await inAppWebViewController!.canGoBack();
        final forward = await inAppWebViewController!.canGoForward();
        if (mounted) {
          setState(
            () {
              canGoBack = back;
              canGoForward = forward;
            },
          );
        }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error updating navigation state: $e',
      );
    }
  }

  Future<
    void
  >
  _launchInBrowser() async {
    try {
      final Uri url = Uri.parse(
        widget.url,
      );
      if (await canLaunchUrl(
        url,
      )) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        if (mounted &&
            context.mounted) {
          Navigator.of(
            context,
          ).pop();
        }
      } else {
        if (mounted &&
            context.mounted) {
          _showErrorSnackBar(
            'Could not launch ${widget.url}',
          );
        }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error launching browser: $e',
      );
      if (mounted &&
          context.mounted) {
        _showErrorSnackBar(
          'Error opening browser: $e',
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (
            didPop,
            result,
          ) async {
            if (didPop) return;
            if (canGoBack) {
              try {
                if (webViewController !=
                    null) {
                  await webViewController!.goBack();
                } else if (inAppWebViewController !=
                    null) {
                  await inAppWebViewController!.goBack();
                }
              } catch (
                e
              ) {
                debugPrint(
                  'Error going back: $e',
                );
                if (mounted &&
                    context.mounted) {
                  Navigator.of(
                    context,
                  ).pop();
                }
              }
            } else {
              if (mounted &&
                  context.mounted) {
                Navigator.of(
                  context,
                ).pop();
              }
            }
          },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (isLoading)
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<
                        Color
                      >(
                        Theme.of(
                          context,
                        ).primaryColor,
                      ),
                ),
              Expanded(
                child: _buildWebView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<
    Widget
  >
  _buildActions() {
    return [
      IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: canGoBack
              ? Colors.white
              : Colors.white54,
        ),
        onPressed: canGoBack
            ? _goBack
            : null,
      ),
      IconButton(
        icon: Icon(
          Icons.arrow_forward,
          color: canGoForward
              ? Colors.white
              : Colors.white54,
        ),
        onPressed: canGoForward
            ? _goForward
            : null,
      ),
      IconButton(
        icon: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        onPressed: _reload,
      ),
      PopupMenuButton<
        String
      >(
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
        onSelected: _handleMenuAction,
        itemBuilder:
            (
              BuildContext context,
            ) => [
              const PopupMenuItem<
                String
              >(
                value: 'clear_cache',
                child: Text(
                  'Clear Cache',
                ),
              ),
              const PopupMenuItem<
                String
              >(
                value: 'clear_cookies',
                child: Text(
                  'Clear Cookies',
                ),
              ),
              const PopupMenuItem<
                String
              >(
                value: 'desktop_mode',
                child: Text(
                  'Toggle Desktop Mode',
                ),
              ),
              const PopupMenuItem<
                String
              >(
                value: 'open_browser',
                child: Text(
                  'Open in Browser',
                ),
              ),
            ],
      ),
    ];
  }

  Future<
    void
  >
  _goBack() async {
    try {
      if (webViewController !=
          null) {
        await webViewController!.goBack();
        await _updateNavigationState();
      } else if (inAppWebViewController !=
          null) {
        await inAppWebViewController!.goBack();
        await _updateNavigationState();
      } else {
        debugPrint(
          'No WebView controller available for navigation',
        );
        if (mounted) {
          _showErrorSnackBar(
            'Navigation not available',
          );
        }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error going back: $e',
      );
      if (mounted) {
        _showErrorSnackBar(
          'Failed to go back: $e',
        );
      }
    }
  }

  Future<
    void
  >
  _goForward() async {
    try {
      if (webViewController !=
          null) {
        await webViewController!.goForward();
        await _updateNavigationState();
      } else if (inAppWebViewController !=
          null) {
        await inAppWebViewController!.goForward();
        await _updateNavigationState();
      } else {
        debugPrint(
          'No WebView controller available for navigation',
        );
        if (mounted) {
          _showErrorSnackBar(
            'Navigation not available',
          );
        }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error going forward: $e',
      );
      if (mounted) {
        _showErrorSnackBar(
          'Failed to go forward: $e',
        );
      }
    }
  }

  Future<
    void
  >
  _reload() async {
    try {
      if (mounted) {
        setState(
          () {
            isLoading = true;
            progress = 0.0;
          },
        );
      }

      if (webViewController !=
          null) {
        await webViewController!.reload();
      } else if (inAppWebViewController !=
          null) {
        await inAppWebViewController!.reload();
      } else {
        debugPrint(
          'No WebView controller available for reload',
        );
        if (mounted) {
          setState(
            () {
              isLoading = false;
              progress = 1.0;
            },
          );
          _showErrorSnackBar(
            'Reload not available',
          );
        }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error reloading: $e',
      );
      if (mounted) {
        setState(
          () {
            isLoading = false;
            progress = 1.0;
          },
        );
        _showErrorSnackBar(
          'Failed to reload: $e',
        );
      }
    }
  }

  Future<
    void
  >
  _handleMenuAction(
    String value,
  ) async {
    try {
      switch (value) {
        case 'clear_cache':
          if (inAppWebViewController !=
              null) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Clearing cache...',
                  ),
                  duration: Duration(
                    seconds: 1,
                  ),
                ),
              );
            }
            await iaw.InAppWebViewController.clearAllCache();
            await inAppWebViewController!.reload();
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Cache cleared successfully',
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(
                    seconds: 2,
                  ),
                ),
              );
            }
          } else {
            if (mounted) {
              _showErrorSnackBar(
                'WebView not available for cache clearing',
              );
            }
          }
          break;
        case 'clear_cookies':
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Clearing cookies...',
                ),
                duration: Duration(
                  seconds: 1,
                ),
              ),
            );
          }
          await iaw.CookieManager.instance().deleteAllCookies();
          if (inAppWebViewController !=
              null) {
            await inAppWebViewController!.reload();
          }
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cookies cleared successfully',
                ),
                backgroundColor: Colors.green,
                duration: Duration(
                  seconds: 2,
                ),
              ),
            );
          }
          break;
        case 'desktop_mode':
          await _toggleDesktopMode();
          break;
        case 'open_browser':
          await _launchInBrowser();
          break;
        default:
          debugPrint(
            'Unknown menu action: $value',
          );
          if (mounted) {
            _showErrorSnackBar(
              'Unknown action: $value',
            );
          }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error handling menu action: $e',
      );
      if (mounted) {
        _showErrorSnackBar(
          'Error performing action: $e',
        );
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
    if (webViewController ==
        null) {
      return _buildFallbackUI();
    }

    try {
      return wf.WebViewWidget(
        controller: webViewController!,
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error building desktop WebView: $e',
      );
      return _buildFallbackUI();
    }
  }

  Widget _buildMobileWebView() {
    try {
      return iaw.InAppWebView(
        initialUrlRequest: iaw.URLRequest(
          url: iaw.WebUri(
            widget.url,
          ),
          headers: {
            'User-Agent': _getSecureUserAgent(),
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
            'DNT': '1',
            'Upgrade-Insecure-Requests': '1',
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
          mixedContentMode: iaw.MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE, // More secure
          cacheEnabled: true,
          clearCache: false,
          thirdPartyCookiesEnabled: true,
          useHybridComposition: true,
          allowsBackForwardNavigationGestures: true,
          useShouldOverrideUrlLoading: true,
          supportZoom: true,
          builtInZoomControls: true,
          displayZoomControls: false,
          userAgent: _getSecureUserAgent(),
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
        onWebViewCreated:
            (
              controller,
            ) {
              inAppWebViewController = controller;
              _setupJavaScriptHandlers(
                controller,
              );
            },
        onLoadStart:
            (
              controller,
              url,
            ) {
              debugPrint(
                'Started loading: $url',
              );
              if (mounted) {
                setState(
                  () {
                    isLoading = true;
                    progress = 0.0;
                    currentUrl = url.toString();
                  },
                );
              }
            },
        onLoadStop:
            (
              controller,
              url,
            ) async {
              debugPrint(
                'Finished loading: $url',
              );
              pullToRefreshController?.endRefreshing();
              await _updateNavigationState();
              if (mounted) {
                setState(
                  () {
                    isLoading = false;
                    progress = 1.0;
                    currentUrl = url.toString();
                  },
                );
              }
            },
        onReceivedError:
            (
              controller,
              request,
              error,
            ) {
              debugPrint(
                'Error loading ${request.url}: ${error.description}',
              );
              pullToRefreshController?.endRefreshing();
              if (mounted) {
                setState(
                  () {
                    isLoading = false;
                    progress = 1.0;
                  },
                );

                // Handle specific authentication errors
                String errorMessage = error.description;
                if (error.description.toLowerCase().contains(
                  'net::err_cert',
                )) {
                  errorMessage = 'SSL Certificate error. Try clearing cache or using a different network.';
                } else if (error.description.toLowerCase().contains(
                  'net::err_internet_disconnected',
                )) {
                  errorMessage = 'No internet connection. Please check your network.';
                } else if (error.description.toLowerCase().contains(
                  'net::err_name_not_resolved',
                )) {
                  errorMessage = 'Cannot reach the server. Please check your internet connection.';
                } else if (error.description.toLowerCase().contains(
                  'timeout',
                )) {
                  errorMessage = 'Connection timeout. Try again.';
                }

                _showErrorSnackBar(
                  errorMessage,
                );
              }
            },
        onProgressChanged:
            (
              controller,
              newProgress,
            ) {
              if (mounted) {
                setState(
                  () {
                    progress =
                        newProgress /
                        100.0;
                  },
                );
              }
            },
        onConsoleMessage:
            (
              controller,
              consoleMessage,
            ) {
              debugPrint(
                'WebView Console: ${consoleMessage.message}',
              );
            },
        shouldOverrideUrlLoading:
            (
              controller,
              navigationAction,
            ) async {
              return iaw.NavigationActionPolicy.ALLOW;
            },
        onReceivedHttpError:
            (
              controller,
              request,
              errorResponse,
            ) {
              debugPrint(
                'HTTP Error: ${errorResponse.statusCode} for ${request.url}',
              );
            },
        onPermissionRequest:
            (
              controller,
              request,
            ) async {
              return iaw.PermissionResponse(
                resources: request.resources,
                action: iaw.PermissionResponseAction.GRANT,
              );
            },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error building mobile WebView: $e',
      );
      return _buildFallbackUI();
    }
  }

  Widget _buildFallbackUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.web_asset_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'WebView not available on this platform',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton.icon(
            onPressed: _launchInBrowser,
            icon: const Icon(
              Icons.open_in_browser,
            ),
            label: const Text(
              'Open in Browser',
            ),
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

  Future<
    void
  >
  _toggleDesktopMode() async {
    try {
      if (inAppWebViewController !=
          null) {
        final currentUserAgent = await inAppWebViewController!.getSettings();
        final newUserAgent =
            currentUserAgent?.userAgent?.contains(
                  'Mobile',
                ) ==
                true
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                newUserAgent.contains(
                      'Mobile',
                    )
                    ? 'Switched to mobile mode'
                    : 'Switched to desktop mode',
              ),
              duration: const Duration(
                seconds: 2,
              ),
            ),
          );
        }
      }
    } catch (
      e
    ) {
      debugPrint(
        'Error toggling desktop mode: $e',
      );
      if (mounted) {
        _showErrorSnackBar(
          'Failed to toggle desktop mode: $e',
        );
      }
    }
  }

  void _setupJavaScriptHandlers(
    iaw.InAppWebViewController controller,
  ) {
    try {
      controller.addJavaScriptHandler(
        handlerName: 'flutterHandler',
        callback:
            (
              args,
            ) {
              try {
                debugPrint(
                  'JavaScript message: $args',
                );
              } catch (
                e
              ) {
                debugPrint(
                  'Error handling JavaScript message: $e',
                );
              }
            },
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error setting up JavaScript handlers: $e',
      );
    }
  }

  void _showErrorSnackBar(
    String message,
  ) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $message',
          ),
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
    } catch (
      e
    ) {
      debugPrint(
        'Error during dispose: $e',
      );
    }
    super.dispose();
  }
}
