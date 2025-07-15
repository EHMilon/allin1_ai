import 'package:flutter/material.dart';
import 'package:allin1_ai/screens/settings_screen.dart';
import 'package:allin1_ai/auth/auth_alternatives_screen.dart';
import 'package:allin1_ai/auth/simple_auth_screen.dart';
import 'package:allin1_ai/auth/web_view_screen.dart';
import 'package:allin1_ai/auth/demo_google_auth.dart';

class HomeScreen
    extends
        StatelessWidget {
  final List<
    Map<
      String,
      dynamic
    >
  >
  aiProviders = [
    {
      'name': 'ChatGPT',
      'webUrl': 'https://chat.openai.com/',
      'logo': 'assets/chatgpt_logo.png',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.green,
      'description': 'OpenAI\'s conversational AI assistant',
    },
    {
      'name': 'Google Gemini',
      'webUrl': 'https://gemini.google.com/',
      'logo': 'assets/gemini_logo.png',
      'icon': Icons.auto_awesome,
      'color': Colors.blue,
      'description': 'Google\'s advanced AI model',
    },
    {
      'name': 'Microsoft Copilot',
      'webUrl': 'https://copilot.microsoft.com/',
      'logo': 'assets/copilot_logo.png',
      'icon': Icons.code,
      'color': Colors.orange,
      'description': 'Microsoft\'s AI-powered assistant',
    },
    {
      'name': 'Claude',
      'webUrl': 'https://claude.ai/',
      'logo': 'assets/claude_logo.png',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'description': 'Anthropic\'s helpful AI assistant',
    },
    {
      'name': 'Perplexity',
      'webUrl': 'https://www.perplexity.ai/',
      'logo': 'assets/perplexity_logo.png',
      'icon': Icons.search,
      'color': Colors.teal,
      'description': 'AI-powered search and research',
    },
  ];

  HomeScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All-in-One AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
        backgroundColor: Theme.of(
          context,
        ).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bug_report,
            ),
            tooltip: 'Google Sign-In Demo',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const DemoGoogleAuth(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.alt_route,
            ),
            tooltip: 'Authentication Alternatives',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const AuthAlternativesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Authentication alternatives banner
              Container(
                margin: const EdgeInsets.all(
                  8.0,
                ),
                child: Card(
                  color: Colors.blue.shade50,
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const AuthAlternativesScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        16.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Having sign-in issues?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                const Text(
                                  'Tap for auth options • Long press for direct access',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blue.shade700,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // AI providers list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aiProviders.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final provider = aiProviders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 6.0,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            16,
                          ),
                          onTap: () {
                            // Determine platform key for OAuth
                            String platformKey = provider['name']!.toLowerCase();
                            if (platformKey.contains(
                              'gemini',
                            ))
                              platformKey = 'google';
                            if (platformKey.contains(
                              'chatgpt',
                            ))
                              platformKey = 'openai';
                            if (platformKey.contains(
                              'copilot',
                            )) {
                              platformKey = 'microsoft';
                            }
                            if (platformKey.contains(
                              'claude',
                            )) {
                              platformKey = 'anthropic';
                            }
                            if (platformKey.contains(
                              'perplexity',
                            )) {
                              platformKey = 'perplexity';
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => SimpleAuthScreen(
                                      platform: platformKey,
                                      platformUrl: provider['webUrl']!,
                                      platformName: provider['name']!,
                                    ),
                              ),
                            );
                          },
                          onLongPress: () {
                            // Direct WebView access on long press
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (
                                      context,
                                    ) => WebViewScreen(
                                      url: provider['webUrl']!,
                                      title: provider['name']!,
                                    ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              16.0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color:
                                        (provider['color']
                                                as Color)
                                            .withOpacity(
                                              0.1,
                                            ),
                                    borderRadius: BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: Icon(
                                    provider['icon']
                                        as IconData,
                                    color:
                                        provider['color']
                                            as Color,
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
                                        provider['name']
                                            as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        provider['description']
                                            as String,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
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
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
