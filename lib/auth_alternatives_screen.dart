import 'package:flutter/material.dart';
import 'alternative_auth_solutions.dart';

class AuthAlternativesScreen
    extends
        StatelessWidget {
  const AuthAlternativesScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Authentication Alternatives',
        ),
        backgroundColor: Theme.of(
          context,
        ).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(
            16,
          ),
          children: [
            // Header
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Google Authentication Issues?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Try these alternative solutions to access AI platforms without WebView restrictions.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // Solution 1: Native Browser
            _buildSolutionCard(
              context,
              icon: Icons.open_in_browser,
              title: 'Open in Native Browser',
              subtitle: 'Most reliable solution - 95% success rate',
              description: 'Opens authentication in your device\'s default browser, bypassing all WebView restrictions.',
              color: Colors.green,
              onTap: () => _showNativeBrowserOptions(
                context,
              ),
            ),

            // Solution 2: Alternative Platforms
            _buildSolutionCard(
              context,
              icon: Icons.alt_route,
              title: 'Alternative AI Platforms',
              subtitle: 'Use platforms that don\'t require Google',
              description: 'Access AI services through platforms with email/password authentication or no login required.',
              color: Colors.blue,
              onTap: () => _showAlternativePlatforms(
                context,
              ),
            ),

            // Solution 3: App-to-App Authentication
            _buildSolutionCard(
              context,
              icon: Icons.apps,
              title: 'App-to-App Authentication',
              subtitle: 'Use official Google/Microsoft apps',
              description: 'Authenticate through the official apps if installed on your device.',
              color: Colors.purple,
              onTap: () => _showAppToAppOptions(
                context,
              ),
            ),

            // Solution 4: Session Management
            _buildSolutionCard(
              context,
              icon: Icons.import_export,
              title: 'Session Import/Export',
              subtitle: 'Transfer authentication from browser',
              description: 'Export session data from a browser where you\'re already logged in.',
              color: Colors.teal,
              onTap: () => _showSessionManagement(
                context,
              ),
            ),

            // Solution 5: Local AI
            _buildSolutionCard(
              context,
              icon: Icons.computer,
              title: 'Local AI Models',
              subtitle: 'Run AI on your device - no authentication needed',
              description: 'Use AI models that run locally on your device without any online authentication.',
              color: Colors.indigo,
              onTap: () => _showLocalAIOptions(
                context,
              ),
            ),

            // Solution 6: Manual Methods
            _buildSolutionCard(
              context,
              icon: Icons.build,
              title: 'Advanced Manual Methods',
              subtitle: 'For technical users',
              description: 'QR code authentication, manual token entry, and proxy server methods.',
              color: Colors.orange,
              onTap: () => _showManualMethods(
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
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
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNativeBrowserOptions(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      builder:
          (
            context,
          ) => Container(
            padding: const EdgeInsets.all(
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Native Browser Authentication',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Choose which service you want to access:',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),

                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Google Gemini',
                  ),
                  subtitle: const Text(
                    'Open in browser for authentication',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                    AlternativeAuthSolutions.openWithNativeBrowser(
                      'https://gemini.google.com',
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.chat,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'ChatGPT',
                  ),
                  subtitle: const Text(
                    'Open in browser for authentication',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                    AlternativeAuthSolutions.openWithNativeBrowser(
                      'https://chat.openai.com',
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.code,
                    color: Colors.orange,
                  ),
                  title: const Text(
                    'Microsoft Copilot',
                  ),
                  subtitle: const Text(
                    'Open in browser for authentication',
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                    AlternativeAuthSolutions.openWithNativeBrowser(
                      'https://copilot.microsoft.com',
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showAlternativePlatforms(
    BuildContext context,
  ) {
    final platforms = AlternativeAuthSolutions.getAlternativePlatforms();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            const Text(
              'Alternative AI Platforms',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'These platforms work without Google authentication:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(
              height: 16,
            ),

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: platforms.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  final platform = platforms[index];
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getReliabilityColor(
                          platform['reliability'],
                        ),
                        child: Text(
                          platform['name'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        platform['name'],
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            platform['description'],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            children: [
                              Icon(
                                platform['authMethod'] == 'email'
                                    ? Icons.email
                                    : Icons.login,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              Expanded(
                                child: Text(
                                  platform['authMethod'] == 'email'
                                      ? 'Email/Password'
                                      : 'No login required',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                          AlternativeAuthSolutions.openWithNativeBrowser(
                            platform['url'],
                          );
                        },
                        child: const Text(
                          'Open',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppToAppOptions(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'App-to-App Authentication',
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This method tries to open the official Google or Microsoft apps for authentication.',
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              'Requirements:',
            ),
            Text(
              '• Google app or Chrome browser installed',
            ),
            Text(
              '• Microsoft Authenticator or Edge browser',
            ),
            Text(
              '• Already signed in to these apps',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
            ),
            child: const Text(
              'Cancel',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
              AlternativeAuthSolutions.setupDeepLinkAuth(
                context,
                'google',
              );
            },
            child: const Text(
              'Try Google App',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
              );
              AlternativeAuthSolutions.setupDeepLinkAuth(
                context,
                'microsoft',
              );
            },
            child: const Text(
              'Try Microsoft App',
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionManagement(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Text(
              'Session Management',
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Transfer your authentication session from a browser where you\'re already logged in.',
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Steps:',
                ),
                Text(
                  '1. Sign in to the AI platform in your browser',
                ),
                Text(
                  '2. Export session data',
                ),
                Text(
                  '3. Import it into this app',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'Cancel',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                  AlternativeAuthSolutions.exportSession(
                    context,
                  );
                },
                child: const Text(
                  'Export Session',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                  AlternativeAuthSolutions.importSession(
                    context,
                  );
                },
                child: const Text(
                  'Import Session',
                ),
              ),
            ],
          ),
    );
  }

  void _showLocalAIOptions(
    BuildContext context,
  ) {
    final localOptions = AlternativeAuthSolutions.getLocalAIOptions();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (
            context,
          ) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (
                  context,
                  scrollController,
                ) => Container(
                  padding: const EdgeInsets.all(
                    24,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Local AI Models',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'Run AI models locally - no internet or authentication required:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),

                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: localOptions.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final option = localOptions[index];
                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  child: ExpansionTile(
                                    leading: const Icon(
                                      Icons.computer,
                                      color: Colors.indigo,
                                    ),
                                    title: Text(
                                      option['name'],
                                    ),
                                    subtitle: Text(
                                      option['description'],
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(
                                          16,
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Setup: ${option['setup']}',
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              'Pros: ${option['pros']}',
                                              style: const TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              'Cons: ${option['cons']}',
                                              style: const TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showManualMethods(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Text(
              'Advanced Manual Methods',
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'These methods require technical knowledge but can bypass most restrictions.',
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Available methods:',
                ),
                Text(
                  '• QR Code authentication',
                ),
                Text(
                  '• Manual token entry',
                ),
                Text(
                  '• Proxy server authentication',
                ),
                Text(
                  '• Cookie/session transfer',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'Cancel',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                  AlternativeAuthSolutions.setupDeepLinkAuth(
                    context,
                    'google',
                  );
                },
                child: const Text(
                  'Show Methods',
                ),
              ),
            ],
          ),
    );
  }

  Color _getReliabilityColor(
    String reliability,
  ) {
    switch (reliability) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
