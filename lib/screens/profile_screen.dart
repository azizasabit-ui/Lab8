import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'outfit_builder_screen.dart';
import 'register_screen.dart';

/// LAB 7 - Tab 3: simple profile / settings screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String _name = 'Guest Shopper';
  bool _notifications = true;
  bool _newsletter = false;
  String _prefSize = 'M';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editName() async {
    _nameController.text = _name;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_nameController.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _name = result);
    }
  }

  Widget _stat(String label, int value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text('$value',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: primary,
                        child: Text(
                          _name.isEmpty ? '?' : _name[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text('THREADLY member',
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit name',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: _editName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ListenableBuilder(
                    listenable: appState,
                    builder: (context, _) => Row(
                      children: [
                        _stat('Favorites', appState.favoritesCount,
                            Icons.favorite_border),
                        _stat('In cart', appState.cartCount,
                            Icons.shopping_bag_outlined),
                        _stat('Saved looks', appState.looks.length,
                            Icons.collections_bookmark_outlined),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Push notifications'),
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.mail_outline),
                      title: const Text('Newsletter'),
                      value: _newsletter,
                      onChanged: (v) => setState(() => _newsletter = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Preferred clothing size',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final s in ['S', 'M', 'L', 'XL'])
                                ChoiceChip(
                                  label: Text(s),
                                  selected: s == _prefSize,
                                  onSelected: (_) =>
                                      setState(() => _prefSize = s),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.auto_awesome),
                      title: const Text('Outfit Builder'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const OutfitBuilderScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.person_add_alt_1_outlined),
                      title: const Text('Create account'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
