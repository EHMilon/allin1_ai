import 'package:flutter/material.dart';
import 'package:allin1_ai/screens/settings_screen.dart';
import 'package:allin1_ai/screens/web_view_screen.dart';
import 'package:allin1_ai/utils/provider_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    // Try loading saved list
    final saved = await ProviderStorage.load();
    if (!mounted) return; // Address BuildContext across async gaps warning
    if (saved != null) {
      setState(() => _providers = saved);
      return;
    }
    
    // Fallback to built-in defaults
    final defaultProviders = [
      {
        'name': 'ChatGPT',
        'webUrl': 'https://chat.openai.com/',
        'logoUrl': null,
        'icon': Icons.chat_bubble_outline.codePoint,
        'color': Colors.green.value, // Reverted to .value
        'description': 'OpenAI\'s conversational AI assistant',
        'isCustom': false,
      },
      {
        'name': 'Google Gemini',
        'webUrl': 'https://gemini.google.com/',
        'logoUrl': null,
        'icon': Icons.auto_awesome.codePoint,
        'color': Colors.blue.value, // Reverted to .value
        'description': 'Google\'s advanced AI model',
        'isCustom': false,
      },
      {
        'name': 'Microsoft Copilot',
        'webUrl': 'https://copilot.microsoft.com/',
        'logoUrl': null,
        'icon': Icons.code.codePoint,
        'color': Colors.orange.value, // Reverted to .value
        'description': 'Microsoft\'s AI-powered assistant',
        'isCustom': false,
      },
      {
        'name': 'Claude',
        'webUrl': 'https://claude.ai/',
        'logoUrl': null,
        'icon': Icons.psychology.codePoint,
        'color': Colors.purple.value, // Reverted to .value
        'description': 'Anthropic\'s helpful AI assistant',
        'isCustom': false,
      },
      {
        'name': 'Perplexity',
        'webUrl': 'https://www.perplexity.ai/',
        'logoUrl': null,
        'icon': Icons.search.codePoint,
        'color': Colors.teal.value, // Reverted to .value
        'description': 'AI-powered search and research',
        'isCustom': false,
      },
    ];

    for (var provider in defaultProviders) {
      provider['logoUrl'] = _faviconUrl(provider['webUrl'] as String);
    }

    _providers = defaultProviders;
    await _saveProviders();
    setState(() {});
  }

  Future<void> _saveProviders() async {
    await ProviderStorage.save(_providers);
  }

  String _faviconUrl(String pageUrl) {
    try {
      final uri = Uri.parse(pageUrl);
      final domain = uri.host;
      return 'https://www.google.com/s2/favicons?sz=64&domain=$domain';
    } catch (e) {
      return '';
    }
  }

  Future<void> _showAddDialog() async {
    final nameCtl = TextEditingController();
    final urlCtl = TextEditingController();
    final descCtl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Website'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtl,
                decoration: const InputDecoration(
                  labelText: 'AI Provider Name',
                  hintText: 'e.g., DeepSeek',
                ),
                validator: (s) =>
                    (s == null || s.trim().isEmpty)
                        ? 'Please enter a name'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: urlCtl,
                decoration: const InputDecoration(
                  labelText: 'Web Address',
                  hintText: 'https://example.com',
                ),
                validator: (s) {
                  if (s == null || s.trim().isEmpty) {
                    return 'Please enter a URL';
                  }
                  final u = Uri.tryParse(s.trim());
                  if (u == null || !u.hasScheme) return 'Invalid URL';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descCtl,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return; // Address BuildContext across async gaps warning
              if (!_formKey.currentState!.validate()) return;
              final name = nameCtl.text.trim();
              final url = urlCtl.text.trim();
              final description = descCtl.text.trim();
              final favicon = _faviconUrl(url);

              setState(() {
                _providers.add({
                  'name': name,
                  'webUrl': url,
                  'logoUrl': favicon,
                  'icon': Icons.link.codePoint,
                  'color': Colors.grey.value, // Reverted to .value
                  'description': description,
                  'isCustom': true,
                });
              });
              await _saveProviders();
              if (!mounted) return; // Address BuildContext across async gaps warning
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All-in-One AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 4,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // AI providers list
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _providers.length,
              onReorder: (oldIndex, newIndex) async {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _providers.removeAt(oldIndex);
                  _providers.insert(newIndex, item);
                });
                await _saveProviders();
              },
              itemBuilder: (context, index) {
                final provider = _providers[index];
                final name = provider['name'] as String;
                final url = provider['webUrl'] as String;
                final logoUrl = provider['logoUrl'] as String?;
                final color = Color(provider['color'] as int);
                final iconCode = provider['icon'] as int;
                final iconData = IconData(iconCode, fontFamily: 'MaterialIcons');
                final description = provider['description'] as String? ?? '';
                // final isCustom = provider['isCustom'] as bool? ?? false; // Commented out to fix unused_local_variable warning

                return Card(
                  key: ValueKey(provider),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1), // Reverted to .withOpacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: logoUrl != null && logoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                logoUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  iconData,
                                  color: color,
                                  size: 28,
                                ),
                              ),
                            )
                          : Icon(
                              iconData,
                              color: color,
                              size: 28,
                            ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: description.isNotEmpty
                        ? Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          )
                        : null,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'remove') {
                          setState(() {
                            _providers.removeAt(index);
                          });
                          _saveProviders();
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Remove', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebViewScreen(
                            url: url,
                            title: name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        tooltip: 'Add Website',
        child: const Icon(Icons.add),
      ),
    );
  }
}
