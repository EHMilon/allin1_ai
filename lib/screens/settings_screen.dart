import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:allin1_ai/auth/session_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _useDesktopMode = true;
  bool _enableJavaScript = true;
  bool _clearCacheOnExit = false;
  bool _enableNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useDesktopMode = prefs.getBool('desktop_mode') ?? true;
      _enableJavaScript = prefs.getBool('enable_javascript') ?? true;
      _clearCacheOnExit = prefs.getBool('clear_cache_on_exit') ?? false;
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('desktop_mode', _useDesktopMode);
    await prefs.setBool('enable_javascript', _enableJavaScript);
    await prefs.setBool('clear_cache_on_exit', _clearCacheOnExit);
    await prefs.setBool('enable_notifications', _enableNotifications);
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will clear all saved login sessions, cache, and cookies. You will need to log in again to all AI platforms. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Clear all cookies
        await iaw.CookieManager.instance().deleteAllCookies();
        
        // Clear session manager data
        await SessionManager.clearAllCookies();
        
        // Clear shared preferences (except settings)
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys().where((key) => 
          !key.startsWith('desktop_mode') &&
          !key.startsWith('enable_javascript') &&
          !key.startsWith('clear_cache_on_exit') &&
          !key.startsWith('enable_notifications')
        );
        for (String key in keys) {
          await prefs.remove(key);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'WebView Settings',
            [
              SwitchListTile(
                title: const Text('Use Desktop Mode'),
                subtitle: const Text('Load desktop versions of AI platforms'),
                value: _useDesktopMode,
                onChanged: (value) {
                  setState(() {
                    _useDesktopMode = value;
                  });
                  _saveSettings();
                },
              ),
              SwitchListTile(
                title: const Text('Enable JavaScript'),
                subtitle: const Text('Required for AI platforms to work properly'),
                value: _enableJavaScript,
                onChanged: (value) {
                  setState(() {
                    _enableJavaScript = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Privacy & Data',
            [
              SwitchListTile(
                title: const Text('Clear Cache on Exit'),
                subtitle: const Text('Automatically clear cache when app closes'),
                value: _clearCacheOnExit,
                onChanged: (value) {
                  setState(() {
                    _clearCacheOnExit = value;
                  });
                  _saveSettings();
                },
              ),
              ListTile(
                title: const Text('Clear All Data'),
                subtitle: const Text('Clear all saved sessions and cache'),
                trailing: const Icon(Icons.delete_forever, color: Colors.red),
                onTap: _clearAllData,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'App Settings',
            [
              SwitchListTile(
                title: const Text('Enable Notifications'),
                subtitle: const Text('Receive app notifications'),
                value: _enableNotifications,
                onChanged: (value) {
                  setState(() {
                    _enableNotifications = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            'About',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
                trailing: const Icon(Icons.info_outline),
              ),
              ListTile(
                title: const Text('Developer'),
                subtitle: const Text('AI Assistant Team'),
                trailing: const Icon(Icons.person_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
