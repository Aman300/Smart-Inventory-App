import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/core_providers.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _hostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _hostController.text = storage.getHost();
  }

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  void _saveHost() async {
    final host = _hostController.text.trim();
    if (host.isEmpty) return;

    final storage = ref.read(storageServiceProvider);
    await storage.saveHost(host);
    
    // Update active static host memory
    ApiConstants.host = host;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Server host address saved!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Theme Mode Card selector
            Card(
              child: ListTile(
                leading: Icon(
                  themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between dark and light themes'),
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Server Host IP Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dns, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        const Text(
                          'API Server IP Settings',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'If you are running the backend server on a physical machine and testing the app on a separate physical mobile device, enter your computer\'s local network IP address here.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _hostController,
                      decoration: const InputDecoration(
                        labelText: 'API Host IP/Name',
                        hintText: 'e.g. 192.168.1.5 or 10.0.2.2',
                        prefixIcon: Icon(Icons.link),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: _saveHost,
                      child: const Text('Save Host Address'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
