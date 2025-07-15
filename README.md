# All-in-One AI Assistant

A Flutter app that provides access to multiple AI platforms in a single interface, similar to a web browser or ChatAI Widget.

## Features

- **Multiple AI Platforms**: Access ChatGPT, Google Gemini, Microsoft Copilot, Claude, and Perplexity
- **Cross-Platform Support**: Works on Android, iOS, and Desktop (with fallback to external browser)
- **Persistent Sessions**: Login sessions are maintained across app restarts
- **Desktop User Agent**: Optimized for desktop versions of AI platforms
- **Navigation Controls**: Back, forward, refresh, and menu options
- **Mobile Optimizations**: CSS injections for better mobile experience
- **Error Handling**: Comprehensive error handling with user feedback

## Platforms Supported

### Mobile (Android/iOS)
- Uses `flutter_inappwebview` for full-featured web browsing
- Persistent cookies and sessions
- Desktop user agent for better compatibility
- Pull-to-refresh functionality
- JavaScript support and optimizations

### Desktop (Linux/macOS/Windows)
- Uses `webview_flutter` where available
- Fallback to external browser for unsupported platforms
- Platform-aware UI adaptations

## AI Platforms Included

1. **ChatGPT** (OpenAI) - `https://chat.openai.com/`
2. **Google Gemini** - `https://gemini.google.com/`
3. **Microsoft Copilot** - `https://copilot.microsoft.com/`
4. **Claude** (Anthropic) - `https://claude.ai/`
5. **Perplexity** - `https://www.perplexity.ai/`

## Key Improvements Made

### Bug Fixes
1. **Black Screen Issue**: Fixed WebView initialization and settings
2. **Login Persistence**: Implemented session management with SharedPreferences
3. **Platform Compatibility**: Added conditional compilation for different platforms
4. **Navigation Issues**: Improved back/forward navigation handling

### Code Improvements
1. **Better Error Handling**: Added comprehensive error handling and user feedback
2. **Responsive UI**: Improved card design with better visual hierarchy
3. **Platform Detection**: Smart platform detection for optimal WebView selection
4. **User Agent Management**: Desktop user agent for better AI platform compatibility
5. **Memory Management**: Proper disposal and lifecycle management

### New Features
1. **More AI Platforms**: Added Claude and Perplexity
2. **Desktop Mode Toggle**: Switch between mobile and desktop user agents
3. **External Browser Option**: Open in system browser when needed
4. **Cache Management**: Clear cache and cookies options
5. **Progress Indicators**: Visual feedback for loading states

## Dependencies

```yaml
dependencies:
  flutter_inappwebview: ^6.1.5  # Mobile WebView
  webview_flutter: ^4.4.4       # Desktop WebView
  flutter_riverpod: ^2.6.1      # State management
  shared_preferences: ^2.2.2    # Session persistence
  url_launcher: ^6.2.2          # External browser fallback
```

## Installation

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run` for your target platform

## Usage

1. Launch the app
2. Select your preferred AI platform from the list
3. Login to your account (session will be saved)
4. Use the navigation controls as needed
5. Access menu options for additional features

## Technical Details

### WebView Configuration
- JavaScript enabled with full permissions
- Hardware acceleration enabled
- Mixed content allowed for compatibility
- Third-party cookies enabled
- DOM storage and database enabled

### Security Features
- Secure cookie handling
- Permission management for camera/microphone
- HTTPS enforcement where possible

### Performance Optimizations
- Hybrid composition for Android
- CSS injection for mobile optimizations
- Efficient memory management
- Smart caching strategies

## Troubleshooting

### Common Issues

1. **Black Screen on ChatGPT**
   - Fixed with proper WebView settings and user agent
   - Ensure JavaScript is enabled

2. **Login Not Persisting**
   - Fixed with SharedPreferences implementation
   - Cookies are now properly saved and restored

3. **Desktop Compatibility**
   - App now detects platform and uses appropriate WebView
   - Falls back to external browser when needed

### Platform-Specific Notes

- **Android**: Requires API level 21+ for WebView features
- **iOS**: Requires iOS 11+ for InAppWebView
- **Desktop**: May require additional setup for WebView on some Linux distributions

## Contributing

Feel free to contribute by:
- Adding more AI platforms
- Improving UI/UX
- Fixing bugs
- Adding new features

## License

This project is open source and available under the MIT License.